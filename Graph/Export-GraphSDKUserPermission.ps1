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

Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All, DelegatedPermissionGrant.ReadWrite.All, User.Read

$graphSDK = Get-MgServicePrincipal -filter "appid eq '14d82eec-204b-4c2f-b7e8-296a70dab67e'"

$userConsents = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $graphSDK.id | Where-Object -FilterScript {$_.ConsentType -eq 'principal'}
$adminConsents = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $graphSDK.id | Where-Object -FilterScript {$_.ConsentType -eq 'allPrincipals'}
$adminScopes = $adminConsents.Scope.trim().split(' ')

$result = @()
foreach($user in $userConsents)
{
    $mgUser = Get-MgUser -userId $user.principalId
    $userScopes =$user.scope.trim().split(' ')
    $richUserScopes = @()
    foreach($scope in $userScopes)
    {
        $richUserScopes += [ordered]@{
            Scope = $scope
            GrantedBy = $( 
                $grantedBy = 'User'
                if( $scope -in $adminScopes)
                {
                    $grantedBy = 'Admin' 
                }
                $GrantedBy
            )
        }
        
    }
    $result += [ordered]@{
        ApplicationId = $graphSDK.AppId
        ApplicationClientId = $graphSDK.Id
        ApplicationDisplayName = $graphSDK.AppDisplayName
        UserId = $mgUser.Id
        UserDisplayName = $mgUser.DisplayName
        UserFirstName = $mgUser.GivenName
        UserSurname = $mgUser.Surname
        UserPrincipalName = $mgUser.UserPrincipalName
        UserScopes = $richUserScopes
    }
}

if(-not (Test-Path -Path $WorkingDirectory))
{
    New-Item -Path $WorkingDirectory -Force -ItemType Directory
}

$result | convertTo-Json | Out-File -FilePath "$WorkingDirectory\$FileName" -Force
