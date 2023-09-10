param(
    [Parameter()]
    [String]
    $TenantId,
    [Parameter()]
    [String]
    $resourcePath = "C:\DevOps\M365DSC\Export"
)

$ProgressPreference = 'SilentlyContinue'

# 3- Export the Entra ID Conditional Access policies
$params = @{
    #Credential           = $Credential
    #ApplicationId         = $ApplicationId
    TenantId              = $TenantId
    #ApplicationSecret    = $ApplicationSecret
}

Write-Output "Extracting resource"
Export-M365DSCConfiguration `
    -Components @("AADConditionalAccessPolicy") `
    -Path $resourcePath `
    -TenantId  $TenantId `
    -ManagedIdentity
