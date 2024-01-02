[CmdletBinding()]
param(
    
    [Parameter()]
    [System.String]
    $ManagedIdentityObjectId
)

# Connect to Grah SD with required permissions
Connect-MgGraph -Scopes 'Application.Read.All','AppRoleAssignment.ReadWrite.All' 

$serverApplicationName = "Microsoft Graph"
$graphApp = Get-MgServicePrincipal -Filter "DisplayName eq '$serverApplicationName'"

#Retrieving required permission to run our M365DSC resource
$appRoleNames = "ThreatHunting.Read.All","Mail.Send"
$appRoleIds = $appRoleNames | ForEach-Object{$appName = $_ ; ($graphApp.AppRoles | Where-Object {$_.Value -eq $appName}).Id}
$appRoleIds | ForEach-Object {
    $appId = $_;
    New-MgServicePrincipalAppRoleAssignment `
        -ServicePrincipalId $managedIdentityObjectId `
        -PrincipalId $managedIdentityObjectId `
        -ResourceId $graphApp.Id `
        -AppRoleId $appId
}
$ExoApp = Get-MgServicePrincipal -Filter "AppId eq '00000002-0000-0ff1-ce00-000000000000'"
$appRoleId = ($ExoApp.AppRoles | Where-Object {$_.DisplayName -eq "Manage Exchange As Application"}).Id

# Assign the managed identity access to the app role.
New-MgServicePrincipalAppRoleAssignment `
    -ServicePrincipalId $managedIdentityObjectId `
    -PrincipalId $managedIdentityObjectId `
    -ResourceId $ExoApp.Id `
    -AppRoleId $appRoleId
