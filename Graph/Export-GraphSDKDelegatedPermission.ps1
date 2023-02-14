[CmdletBinding()]
param
(
    [Parameter()]
    [System.String]
    $WorkingDirectory = $env:TEMP,

    [Parameter()]
    [System.String]
    $FileName = "report_$((Get-Date).toString("yyyyMMdd")).json",

    [Parameter()]
    [System.String]
    $ApplicationId = '14d82eec-204b-4c2f-b7e8-296a70dab67e',

    [Parameter()]
    [ValidateSet('User','Admin')]
    [System.String]
    $ConsentScope = 'User'
)

Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All, DelegatedPermissionGrant.ReadWrite.All, User.Read

$graphSDK = Get-MgServicePrincipal -filter "appid eq '$ApplicationId'"

$consents = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $graphSDK.id

$userConsents = $consents | Where-Object -FilterScript {$_.ConsentType -eq 'principal'}
$adminConsents = $consents | Where-Object -FilterScript {$_.ConsentType -eq 'allPrincipals'}

$result = @()

$scopedConsents= $adminConsents
if ($ConsentScope -eq 'User')
{
    $scopedConsents= $userConsents
}

foreach($consent in $scopedConsents)
{
    $mgUser=$null
    if ($ConsentScope -eq 'User')
    {
        $mgUser = Get-MgUser -userId $consent.principalId -ErrorAction SilentlyContinue
    }
    
    $scopes =$consent.scope.trim().split(' ')
    $result += [ordered]@{
        ConsentType = $ConsentScope
        ApplicationId = $graphSDK.AppId
        ApplicationClientId = $graphSDK.Id
        ApplicationDisplayName = $graphSDK.AppDisplayName
        ResourceId = $consent.ResourceId
        UserId = $mgUser.Id
        UserDisplayName = $mgUser.DisplayName
        UserFirstName = $mgUser.GivenName
        UserSurname = $mgUser.Surname
        UserPrincipalName = $mgUser.UserPrincipalName
        Scopes = $scopes
    }
}

if(-not (Test-Path -Path $WorkingDirectory))
{
    New-Item -Path $WorkingDirectory -Force -ItemType Directory
}

$result | convertTo-Json -Depth 20| Out-File -FilePath "$WorkingDirectory\$FileName" -Force