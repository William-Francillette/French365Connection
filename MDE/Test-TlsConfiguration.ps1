<#
 - Check Default Secure Protocols: https://learn.microsoft.com/en-us/mem/configmgr/core/plan-design/security/enable-tls-1-2-client#bkmk_winhttp
                            https://support.microsoft.com/en-gb/topic/update-to-enable-tls-1-1-and-tls-1-2-as-default-secure-protocols-in-winhttp-in-windows-c4bd73d2-31d7-761e-0178-11268bb10392
 - check SChannel
 - check cyphers : https://learn.microsoft.com/en-us/power-platform/admin/server-cipher-tls-requirements
                   https://learn.microsoft.com/en-us/windows/win32/secauthn/tls-cipher-suites-in-windows-10-v20h2
 - Disable SSL 3.0, TLS 1.0, and TLS 1.1

#>

$DesiredConfigurationSchema=@(
    @{
        Name = 'Default Secure Protocols'
        Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp\'
        Key = 'DefaultSecureProtocols'
        Type = 'DWORD'
        Value = @('0xAA0','0x800')
        Required = $true
        Compliant = $false
    }
    @{
        Name = 'Default Secure Protocols'
        Path = 'HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp\'
        Key = 'DefaultSecureProtocols'
        Type = 'DWORD'
        Value = @('0xAA0','0x800')
        Required = $true
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.2 Client'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client\'
        Key = 'Enabled'
        Type = 'DWORD'
        Value = @('1')
        Required = $true
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.2 Client'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client\'
        Key = 'DisabledByDefault'
        Type = 'DWORD'
        Value = @('0')
        Required = $true
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.2 Server'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server\'
        Key = 'Enabled'
        Type = 'DWORD'
        Value = @('1')
        Required = $true
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.2 Server'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server\'
        Key = 'DisabledByDefault'
        Type = 'DWORD'
        Value = @('0')
        Required = $true
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.1 Client (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client\'
        Key = 'Enabled'
        Type = 'DWORD'
        Value = @('0')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.1 Client (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client\'
        Key = 'DisabledByDefault'
        Type = 'DWORD'
        Value = @('1')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.1 Server (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server\'
        Key = 'Enabled'
        Type = 'DWORD'
        Value = @('0')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.1 Server (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server\'
        Key = 'DisabledByDefault'
        Type = 'DWORD'
        Value = @('1')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.0 Client (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client\'
        Key = 'Enabled'
        Type = 'DWORD'
        Value = @('0')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.0 Client (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client\'
        Key = 'DisabledByDefault'
        Type = 'DWORD'
        Value = @('1')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.0 Server (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server\'
        Key = 'Enabled'
        Type = 'DWORD'
        Value = @('0')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.0 Server (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server\'
        Key = 'DisabledByDefault'
        Type = 'DWORD'
        Value = @('1')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.0 Client (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client\'
        Key = 'Enabled'
        Type = 'DWORD'
        Value = @('0')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.0 Client (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client\'
        Key = 'DisabledByDefault'
        Type = 'DWORD'
        Value = @('1')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.0 Server (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server\'
        Key = 'Enabled'
        Type = 'DWORD'
        Value = @('0')
        Required = $false
        Compliant = $false
    }

    @{
        Name = 'SChannel TLS 1.0 Server (Optional)'
        Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server\'
        Key = 'DisabledByDefault'
        Type = 'DWORD'
        Value = @('1')
        Required = $false
        Compliant = $false
    }
)
function Get-SettingToString
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter()]
        [Array]
        $Settings
    )

    $result=[System.Text.StringBuilder]::New()


    $categories = ($Settings.Name | Select-Object -Unique )
    foreach ($category in $categories)
    {
        $categorySettings = [Array]($Settings | Where-Object Name -eq $category)
        $result.Append("[") | Out-Null
        $isCategoryCompliant = ([Array]($categorySettings | Where-Object -FilterScript {-Not $_.Compliant})).count -eq 0
        if($isCategoryCompliant)
        {
            $result.Append("X") | Out-Null
        }
        else
        {
            $result.Append(" ") | Out-Null
        }
        $result.Append("] $category`r`n") | Out-Null


        foreach($setting in $categorySettings)
        {
            $result.Append("    [") | Out-Null
            if($setting.Compliant)
            {
                $result.Append("X") | Out-Null
            }
            else
            {
                $result.Append(" ") | Out-Null
            }
            $result.Append("] $($setting.Key)`r`n") | Out-Null
        } 
    }
    return $result.toString()
}
function Get-RegistryKeySetting
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [hashtable]
        $Setting
    )

    $currentValue = Get-ItemProperty -Path $setting.Path -Name $setting.Key -ErrorAction SilentlyContinue
    write-host ($currentValue.($setting.Key) -in $setting.Value)
    write-host ($setting.Path)
    write-host ($setting.Key)
    $Setting.Compliant = $currentValue.($setting.Key) -in $setting.Value
    return $Setting
}



function Test-CypherSuite
{
    $requiredCyphers = @(
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
    "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256"
    "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384"
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384"
    "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256"
    "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA"
    "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"
    "TLS_RSA_WITH_AES_256_GCM_SHA384"
    "TLS_RSA_WITH_AES_128_GCM_SHA256"
    "TLS_RSA_WITH_AES_256_CBC_SHA256"
    "TLS_RSA_WITH_AES_128_CBC_SHA256"
    "TLS_RSA_WITH_AES_256_CBC_SHA"
    "TLS_RSA_WITH_AES_128_CBC_SHA"
    )



    $currentCypher = (Get-TlsCipherSuite).name

    $results = [ordered]@{}
    foreach ($cypher in $requiredCyphers)
    {
        $foundCypher = ($cypher -in $currentCypher)
        $results.add($cypher, $foundCypher)
    }
}

function Test-SChannelProtocol
{
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\"
    $requiredProtocols = [ordered]@{
        "TLS 1.2\Client\Enabled" = 1
        "TLS 1.2\Client\DisabledByDefault" = 0
        "TLS 1.2\Server\Enabled" = 1
        "TLS 1.2\Server\DisabledByDefault" = 0
    }
    
    foreach($protocolName in $requiredProtocols.Keys)
    {
        $split = $protocolName.split("\")
        $currentValue = (Get-ItemProperty -Path "$regPath\$($split[0])\$($split[1])" -Name $split[2] -ErrorAction SilentlyContinue).($split[2])
        Get-ItemProperty -Path "$regPath\$($split[0])\Client" -Name $split[2] 
        
        
        $value = $requiredProtocols.$protocolName -eq $currentValue
    
        $results.add($protocolName, $value)
    
    }
}

$DesiredConfigurationSchema | Where-Object Name -eq "Default Secure Protocols" | ForEach-Object {$_ = Get-RegistryKeySetting -Setting $_}
$DesiredConfigurationSchema | Where-Object Name -like "SChannel*" | ForEach-Object {$_ = Get-RegistryKeySetting -Setting $_}
Write-Output -InputObject (Get-SettingToString -SettingName "Default Secure Protocols" -Settings $DesiredConfigurationSchema)
$tls = $DesiredConfigurationSchema | Where-Object Name -like "SChannel*" 
Write-Output -InputObject (Get-SettingToString -Settings $DesiredConfigurationSchema)
