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

Connect-MgGraph -Scopes DelegatedPermissionGrant.ReadWrite.All, Directory.ReadWrite.All

[Array]$consents = Get-Content "$WorkingDirectory\$FileName" | ConvertFrom-Json

foreach($consent in $consents)
{
    $consentType = 'AllPrincipals'
    if($consent.ConsentType -eq 'User')
    {
        $consentType='Principal'
    }
    $filter = "ConsentType eq '$consentType'"
    $filter += " and ClientId eq '$($consent.ApplicationClientId)'"
    if($consent.ConsentType -eq 'User')
    {
        $filter += " and PrincipalId eq '$($consent.UserId)'"
    }
    $grant = Get-MgOauth2PermissionGrant -Filter $filter -ErrorAction SilentlyContinue
    $stringScopes = ''
    $scopes = $consent.scopes
    foreach($scope in $scopes)
    {
        $stringScopes += $scope +' '
    }

    $permissionGrant = @{
	    ConsentType = $consentType
	    Scope = $stringScopes 
    }

    if($null -eq $grant)
    {
        $permissionGrant.Add('ClientId', $consent.ApplicationId)
        $permissionGrant.Add('PrincipalId', $consent.UserId)
        New-MgOauth2PermissionGrant -BodyParameter $permissionGrant 
    }
    else
    {
        Update-MgOauth2PermissionGrant -OAuth2PermissionGrantId $grant.Id -BodyParameter $permissionGrant 
    } 
}