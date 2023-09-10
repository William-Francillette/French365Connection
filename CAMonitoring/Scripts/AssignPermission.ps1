$managedIdentityObjectId = "0e36d981-23b5-46ad-b6b8-85b0b583b0d9" # Your Managed Identity Object Id here

# Connect to Grah SD with required permissions
Connect-MgGraph -Scopes 'Application.Read.All','AppRoleAssignment.ReadWrite.All' 

$serverApplicationName = "Microsoft Graph"
$serverServicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$serverApplicationName'"
$serverServicePrincipalObjectId = $serverServicePrincipal.Id

#Retrieving required permission to run our M365DSC resource
$appRoleName = @(
    'Policy.Read.All'
    'Policy.ReadWrite.ConditionalAccess'
    'Application.Read.All'
    'RoleManagement.Read.Directory'
    'Group.Read.All'
    'User.Read.All'
    'Agreement.Read.All'
    'Application.Read.All'
)

$appRoleIds = ($serverServicePrincipal.AppRoles | Where-Object {$_.Value -in $appRoleName }).Id

# Assign the managed identity access to the app role.
foreach ($appRoleId in $appRoleIds)
{
    New-MgServicePrincipalAppRoleAssignment `
        -ServicePrincipalId $managedIdentityObjectId `
        -PrincipalId $managedIdentityObjectId `
        -ResourceId $serverServicePrincipalObjectId `
        -AppRoleId $appRoleId
}
