param(
    [Parameter()]
    [String]
    $resourcePath = "C:\DevOps\M365DSC\Export",
    [Parameter()]
    [String]
    $OrganizationName
)

Write-Output "Configuring LCM"

$LCMConfigPath = 'C:\M365DSC\LCM'
if (-not (Test-Path -Path $LCMConfigPath))
{
    New-Item -ItemType Directory -Path $LCMConfigPath -Force
}

$LCMConfig = @'
[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Push'
            ConfigurationMode = 'ApplyAndMonitor'
            ConfigurationModeFrequencyMins = 15
        }
    }
}
LCMConfig
'@
$LCMConfig |Out-File "$LCMConfigPath\LCMConfig.ps1"
Set-Location $LCMConfigPath
.\LCMConfig.ps1
Set-DscLocalConfigurationManager -Path "$LCMConfigPath\LCMConfig" -Force

# 5- Start the Configuration
Write-Output "Starting DSC Configuration and Engine"
if(-not (Test-Path $resourcePath))
{
    new-item -ItemType Directory -Path $resourcePath -Force
}
Set-Location $resourcePath
.\M365TenantConfig.ps1 -OrganizationName $OrganizationName
Start-DscConfiguration -Wait -Force -Verbose -Path .\M365TenantConfig