[CmdletBinding()]
param(
    [Parameter()]
    [System.String]
    $OutOfDateThreshold,

    [Parameter()]
    [System.String]
    $StorageAccountRg,

    [Parameter()]
    [System.String]
    $StorageAccountName,

    [Parameter()]
    [System.String]
    $StorageAccountContainerName,

    [Parameter()]
    [System.String]
    $NotificationSenderEmail,

    [Parameter()]
    [System.String]
    $NotificationRecipientsTo,
    
    [Parameter()]
    [System.String]
    $NotificationRecipientsCc
)


#region retrieve variables
    if ([string]::IsNullOrEmpty($OutOfDateThreshold))
    {
        $OutOfDateThreshold = Get-AutomationVariable -Name 'OutOfDateThreshold' -ErrorAction SilentlyContinue
    }

    if ([string]::IsNullOrEmpty($StorageAccountRg))
    {
        $StorageAccountRg = Get-AutomationVariable -Name 'StorageAccountRg' -ErrorAction SilentlyContinue
    }

    if ([string]::IsNullOrEmpty($StorageAccountName))
    {
        $StorageAccountName = Get-AutomationVariable -Name 'StorageAccountName' -ErrorAction SilentlyContinue
    }

    if ([string]::IsNullOrEmpty($StorageAccountContainerName))
    {
        $StorageAccountContainerName = Get-AutomationVariable -Name 'StorageAccountContainerName' -ErrorAction SilentlyContinue
    }

    if ([string]::IsNullOrEmpty($NotificationsDomain))
    {
        $NotificationSenderEmail = Get-AutomationVariable -Name 'NotificationSenderEmail' -ErrorAction SilentlyContinue
    }

    if ([string]::IsNullOrEmpty($NotificationRecipientsTo))
    {
        $NotificationRecipientsTo = Get-AutomationVariable -Name 'NotificationRecipientsTo' -ErrorAction SilentlyContinue
    }
    
    if ([string]::IsNullOrEmpty($NotificationRecipientsCc))
    {
        $NotificationRecipientsCc = Get-AutomationVariable -Name 'NotificationRecipientsCc' -ErrorAction SilentlyContinue
    }
#endregion

#region AdvancedHunting Query
Connect-MgGraph -Identity
$KQLQuery = @"
let updateSCID = dynamic (["scid-2011","scid-2030","scid-5095","scid-6095"]);
 DeviceTvmSecureConfigurationAssessment
| where ConfigurationId in (updateSCID) and IsApplicable
| join (
    DeviceInfo
    | summarize by DeviceId,SensorHealthState,RegistryDeviceTag
    )
    on DeviceId
| where SensorHealthState == "Active"
| extend avdata=parsejson(Context)
| extend sigversion = tostring(avdata[0][0])
| extend engversion = tostring(avdata[0][1])
| extend platformversion = tostring(avdata[0][3])
| extend lastupdatetime = todatetime(avdata[0][2])
| where lastupdatetime < ago($OutOfDateThreshold)
| summarize by DeviceId,DeviceName,OSPlatform,sigversion,engversion,platformversion,lastupdatetime
"@
$uri = "https://graph.microsoft.com/v1.0/security/runHuntingQuery"
$query = @{query = $KQLQuery}|convertto-json -depth 100
$response = Invoke-MgGraphRequest -Uri $uri -Method POST -Body $query -ErrorAction Stop
$results = @()
do
{
    $results += $response.results 
}
while ($response.'@odata.nextLink')
#endregion

#region report export to storage account
$date = (Get-Date).tostring("yyyyMMdd-HHmmss")
$filename = "MDEOutOfDateMonitoring-$date.csv"
$filepath = "$($env:TEMP)\$filename"
$results | Foreach-Object {[PsCustomObject]$_} | ConvertTo-Csv -NoTypeInformation | Out-File -FilePath $filepath

Connect-AzAccount -Identity
$stgAccount = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $StorageAccountRg
Set-AzStorageBlobContent -Context $stgAccount.Context -Container $StorageAccountContainerName -File $filepath -Blob $filename
#endregion

#region report email notification
Import-Module Microsoft.Graph.Users.Actions

$ToRecipients = @()
if(-Not [String]::IsNullOrEmpty($NotificationRecipientsTo))
{
    $ToRecipients = @($NotificationRecipientsTo.split(";") | ForEach-Object {@{EmailAddress = @{Address = $_}}})
}
$CcRecipients = @()
if(-Not [String]::IsNullOrEmpty($NotificationRecipientsCc))
{
    $CcRecipients = @($NotificationRecipientsCc.split(";") | ForEach-Object {@{EmailAddress = @{Address = $_}}})
}
$base64Report = [Convert]::ToBase64String([IO.File]::ReadAllBytes($filepath))

$reportContent = @"
<p>The below devices are reported as out of date</p>
<p/>
"@
$reportContent += $results | Foreach-Object {[PsCustomObject]$_} | ConvertTo-Html -Property DeviceId,DeviceName,OSPlatform,sigversion,engversion,platformversion,lastupdatetime -Fragment

$params = @{
    Message = @{
        Subject = "MDE out of date monitoring report - $date"
        Body = @{
            ContentType = "html"
            Content = $reportContent
        }
        ToRecipients = $ToRecipients
        CcRecipients = $CcRecipients
        Attachments = @(
			@{
				"@odata.type" = "#microsoft.graph.fileAttachment"
				Name = $filename
				ContentType = "text/csv"
				ContentBytes = $base64Report
			}
		)
    }
    SaveToSentItems = "false"
}
 
Send-MgUserMail -UserId $NotificationSenderEmail -BodyParameter $params
#endregion


