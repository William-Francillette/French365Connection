[CmdletBinding()]
param
(
    [Parameter()]
    [System.String]
    $WorkingDirectory=$env:TEMP,

    [Parameter()]
    [System.String]
    $FileName="report_$((Get-Date).toString("yyyyMMdd")).json"
)

Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All, Application.ReadWrite.All, Directory.ReadWrite.All

$content = Get-Content "$WorkingDirectory\$FileName" | ConvertFrom-Json
$targetPermissions = $content.Permissions

$currentAppRoleAssignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $content.ApplicationClientId
[Array]$resourceIds = $currentAppRoleAssignments | Select-Object -Unique -ExpandProperty ResourceId
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

$appRoleDefinitions = (Get-MgServicePrincipal -filter "id in $resourceFilter").AppRoles


$currentPermissions =@()
foreach ($appRoleAssignment in $currentAppRoleAssignments)
{
    $currentPermissions += @{
        appRoleId = $appRoleAssignment.appRoleId
        value = ($appRoleDefinitions | Where-Object -FilterScript {$_.id -eq $appRoleAssignment.appRoleId}).Value
    }
}

$deltaPermissions = Compare-Object `
    -ReferenceObject $currentPermissions.Value `
    -DifferenceObject $targetPermissions.Value

$deltaPermissionsToRemove = $deltaPermissions | Where-Object -FilterScript {$_.SideIndicator -eq '<='}
$deltaPermissionsToAdd = $deltaPermissions | Where-Object -FilterScript {$_.SideIndicator -eq '=>'}

foreach($permissionValue in $deltaPermissionsToRemove.InputObject)
{

    $permission = $currentPermissions | Where-Object -FilterScript {$_.Value -eq $permissionValue}
    $appRoleId = $permission.appRoleId
    if([String]::IsNullOrWhiteSpace($appRoleId))
    {
        $appRoleId = ((Get-MgServicePrincipal -Filter "displayName -eq '$($permission.ResourceDisplayName)'").AppRoles | Where-Object -FilterScript {$_.Value -eq $permissionValue}).Id
    }
    $appRoleAssignmentId = ($currentAppRoleAssignments | Where-Object -FilterScript { $_.AppRoleId -eq $appRoleId}).Id
    Remove-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $content.ApplicationClientId -AppRoleAssignmentId $appRoleAssignmentId 
}

foreach($permissionValue in $deltaPermissionsToAdd.InputObject)
{
    $permission = $targetPermissions | Where-Object -FilterScript {$_.Value -eq $permissionValue}
    $resourceId = $permission.ResourceId
    if([String]::IsNullOrWhiteSpace($resourceId))
    {
        $resourceId = (Get-MgServicePrincipal -Filter "displayName -eq '$($permission.ResourceDisplayName)'").Id
    }
    $appRoleId = $permission.appRoleId
    if([String]::IsNullOrWhiteSpace($appRoleId))
    {
        $appRoleId = ((Get-MgServicePrincipal -Filter "displayName -eq '$($permission.ResourceDisplayName)'").AppRoles | Where-Object -FilterScript {$_.Value -eq $permissionValue}).Id
    }
    $params = @{
        PrincipalId = $content.ApplicationClientId
        ResourceId = $resourceId
        AppRoleId = $appRoleId
    }
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $content.ApplicationClientId -BodyParameter $params 
}