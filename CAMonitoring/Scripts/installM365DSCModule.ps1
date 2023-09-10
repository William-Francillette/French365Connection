[Net.ServicePointManager]::SecurityProtocol =
    [Net.ServicePointManager]::SecurityProtocol -bor
    [Net.SecurityProtocolType]::Tls12

$module = Get-Module PowerShellGet -ErrorAction SilentlyContinue
if ($null -eq $module)
{
    Install-PackageProvider -Name NuGet -Force
    Write-Output "Installing PowerShellGet"
    Install-Module PowerShellGet -Force -AllowClobber
}
$module = Get-Module Microsoft365DSC -ErrorAction SilentlyContinue
if ($null -eq $module)
{
    Write-Output "Installing Microsoft 365 DSC module"
    Install-Module Microsoft365DSC -Confirm:$false -Force
}
Write-Output "Upgrading Microsoft 365 DSC module"
Update-Module Microsoft365DSC -Force -Confirm:$false

Write-Output "Updating Microsoft 365 DSC dependencies"
Update-M365DSCDependencies