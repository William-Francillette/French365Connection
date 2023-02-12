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

[Array]$content = Get-Content "$WorkingDirectory\$FileName" | ConvertFrom-Json

foreach($userConsent in $content)
{
    $grant = Get-MgOauth2PermissionGrant -Filter "PrincipalId eq '$($userConsent.UserId)'" -ErrorAction SilentlyContinue | Where-Object -FilterScript {$_.ClientId -eq $userConsent.ApplicationClientId} 
    $stringScopes = ''
    $scopes = $userconsent.UserScopes | Where-Object -FilterScript {$_.GrantedBy -eq 'User'}
    foreach($scope in $scopes)
    {
        $stringScopes += $scope.scope +' '
    }

    $permissionGrant = @{
	    ClientId = $userConsent.ApplicationId
	    ConsentType = "Principal"
	    PrincipalId = $userConsent.UserId
	    Scope = $stringScopes 
    }

    if($null -eq $grant)
    {
        New-MgOauth2PermissionGrant -BodyParameter $permissionGrant 
    }
    else
    {
        $permissionGrant.Remove('ClientId') 
        Update-MgOauth2PermissionGrant -OAuth2PermissionGrantId $grant.Id -BodyParameter $permissionGrant 
    } 
}