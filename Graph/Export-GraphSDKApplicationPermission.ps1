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
    $ApplicationId = '14d82eec-204b-4c2f-b7e8-296a70dab67e'
)

Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

$graphSDK = Get-MgServicePrincipal -filter "appid eq '$ApplicationId'"
$permissions = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $graphSDK.id
[Array]$resourceIds = $permissions | Select-Object -Unique -ExpandProperty ResourceId
$resourceFilter = ''
if($ids.count -gt 0)
{
    $resourceFilter += '('
    foreach($id in $resourceIds)
    {
        $resourceFilter += $(if($resourceFilter -ne '(' ){', '})+"'$id'"
    }
    $resourceFilter += ')'
}

$roleDefinitions = (Get-MgServicePrincipal -filter "id in $resourceFilter").AppRoles

$arrayPermissions =@()
foreach($permission in $permissions)
{
    $arrayPermissions += [Ordered]@{
        ResourceId = $permission.ResourceId
        ResourceDisplayName = $permission.ResourceDisplayName
        AppRoleId = $permission.appRoleId
        Id = $permission.Id
        Value = ($roleDefinitions | Where-Object -FilterScript {$_.id -eq $permission.appRoleId}).Value
    }
}

$result = [ordered]@{
    ApplicationId = $graphSDK.AppId
    ApplicationClientId = $graphSDK.Id
    ApplicationDisplayName = $graphSDK.AppDisplayName
    Permissions = $arrayPermissions
}
if(-not (Test-Path -Path $WorkingDirectory))
{
    New-Item -Path $WorkingDirectory -Force -ItemType Directory
}

$result | convertTo-Json -Depth 20| Out-File -FilePath "$WorkingDirectory\$FileName" -Force