[CmdletBinding()]
param
(
    [Parameter()]
    [String]
    $AdvancedAuditGroupPolicyName=(Read-Host -Prompt "Enter the display name of the GPO used to configure the advanced audit policies")
)

$LDAPAuditingSchema=@(
    @{
        Name = "Audit LDAP 15 Field Engineering"
        Key = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Diagnostics"
        Subkey = "15 Field Engineering"
        Value = 5
        Set = $false
    }
    @{
        Name = "Audit LDAP Expensive Search Results Threshold"        
        Key = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
        Subkey = "Expensive Search Results Threshold"
        Value = 1
        Set = $false
    }
    @{
        Name = "Audit LDAP Inefficient Search Results Threshold"        
        Key = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
        Subkey = "Inefficient Search Results Threshold"
        Value = 1
        Set = $false
    }
    @{
        Name = "Audit LDAP Search Time Threshold (msecs)"        
        Key = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters"
        Subkey = "Search Time Threshold (msecs)"
        Value = 1
        Set = $false
    }
)

$NTLMAuditingSchema=@(
    @{
        Name = "Audit NTLM Authentication In This Domain"        
        Key = "SYSTEM\CurrentControlSet\Services\Netlogon\Parameters"
        Subkey = "auditntlmindomain"
        Value = 7
        Set = $false
    }
    @{
        Name = "Audit Outgoing NTLM Traffic To Remote Servers"
        Key = "SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
        Subkey = "restrictsendingntlmtraffic"
        Value = 1
        Set = $false
    }
    @{
        Name = "Audit Incoming NTLM Traffic To Remote Servers"
        Key = "SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
        Subkey = "auditreceivingntlmtraffic"
        Value = 2
        Set = $false
    }
)

$advancedAuditingSchema=@(
    @{
        Name = "Audit Credential Validation"
        Guid = Guid.Parse("0cce923f-69ae-11d9-bed3-505054503030")
        Value = 3
        Set = $false
    }
    @{
        Name = "Audit Distribution Group Managment"
        Guid = [Guid]::Parse("0cce9238-69ae-11d9-bed3-505054503030")
        Value = 3
        Set = $false
    }
    @{
        Name = "Audit Computer Account Management"
        Guid = [Guid]::Parse("0cce9236-69ae-11d9-bed3-505054503030")
        Value = 3
        Set = $false
    }
    @{
        Name = "Audit Security Group Management"
        Guid = [Guid]::Parse("0cce9237-69ae-11d9-bed3-505054503030")
        Value = 3
        Set = $false
    }
    @{
        Name = "Audit User Account Management"
        Guid = [Guid]::Parse("0cce9235-69ae-11d9-bed3-505054503030")
        Value = 3
        Set = $false
    }
    @{
        Name = "Audit Directory Service Access"
        Guid = [Guid]::Parse("0cce923b-69ae-11d9-bed3-505054503030")
        Value = 3
        Set = $false
    }
    @{
        Name = "Audit Security System Extension"
        Guid = [Guid]::Parse("0cce9211-69ae-11d9-bed3-505054503030")
        Value = 3
        Set = $false
    }
    @{
        Name = "Audit Directory Service Changes"
        Guid = [Guid]::Parse("0cce923c-69ae-11d9-bed3-505054503030")
        Value = 3
        Set = $false
    }
)

$objectAuditingSchema=@(
    @{
        Name = "Audit Descendant User Objects"
        GetObjectType = "bf967aba-0de6-11d0-a285-00aa003049e2"
        Set = $false
    }
    @{
        Name = "Audit Descendant Group Objects"
        GetObjectType = "bf967a9c-0de6-11d0-a285-00aa003049e2"
        Set = $false
    }
    @{
        Name = "Audit Descendant Computer Objects"
        GetObjectType = "bf967a86-0de6-11d0-a285-00aa003049e2"
        Set = $false
    }
    @{
        Name = "Audit Descendant msDS-GroupManagedServiceAccount Objects"
        GetObjectType = "7b8b558a-93a5-4af7-adca-c017e67f1057"
        Set = $false
    }
    @{
        Name = "Audit Descendant msDS-ManagedServiceAccount Objects"
        GetObjectType = "ce206244-5827-4a86-ba1c-1c0c386c1b64"
        Set = $false
    }
)

function Get-RegistryKeySetting
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Array]
        $Settings
    )

    foreach ($setting in $Settings)
    {
        $value=Get-ItemProperty -Path $setting.Key -Name $setting.Subkey
        if($value -eq $setting.Value)
        {
            $setting.set=$true
        }
    }

    return $Settings

}

function Get-GroupPolicySetting
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Array]
        $Settings,

        [Parameter()]
        [String]
        $GroupPolicyName
    )

    [XML]$gpo=Get-GPOReport -DisplayName $GroupPolicyName
    $auditSettings=$gpo.GPO.Computer.ExtensionData.Extension.AuditSetting
    foreach ($setting in $Settings)
    {
        $value=$auditSettings|Where-Object -FilterScript {[guid]($_.SubcategoryGuid) -eq $setting.Guid}
        if($null -ne $value -and $value.SettingValue -eq $setting.Value)
        {
            $setting.set=$true
        }
    }

    return $Settings
}

function Get-ObjectAuditingSetting
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [Array]
        $Settings
    )

    $domainDN=(Get-ADDomain).DistinguishedName
    $auditRights=(Get-ACL -Path "AD:\$domainDN" -Audit).Audit
    foreach ($setting in $Settings)
    {
        $value=$auditRights|Where-Object -FilterScript { `
            $_.ActiveDirectoryRights.toString().Contains("CreateChild") -and `
            $_.ActiveDirectoryRights.toString().Contains("DeleteChild") -and `
            $_.ActiveDirectoryRights.toString().Contains("Self") -and `
            $_.ActiveDirectoryRights.toString().Contains("WriteProperty") -and `
            $_.ActiveDirectoryRights.toString().Contains("DeleteTree") -and `
            $_.ActiveDirectoryRights.toString().Contains("ExtendedRight") -and `
            $_.ActiveDirectoryRights.toString().Contains("Delete") -and `
            $_.ActiveDirectoryRights.toString().Contains("WriteDacl") -and `
            $_.ActiveDirectoryRights.toString().Contains("WriteOwner") `
        }
        if($null -ne $value -and $value.InheritedObjectType.toString() -eq $setting.GetObjectType)
        {
            $setting.set=$true
        }
    }

    return $Settings
}

function Get-ADFSAuditingSetting
{
    [CmdletBinding()]
    param
    (

    )
    $setting=@{
        Name = "Audit ADFS Objects"
        Set = $false
    }

    $domainDN=(Get-ADDomain).DistinguishedName
    $auditRights=(Get-ACL -Path "AD:\CN=ADFS,CN=Microsoft,CN=Program Data,$domainDN" -Audit).Audit

    $value=$auditRights|Where-Object -FilterScript { `
        $_.IdentityReference.toString() -eq "Everyone" -and `
        $_.ActiveDirectoryRights.toString().Contains("ReadProperty") -and `
        $_.ActiveDirectoryRights.toString().Contains("WriteProperty") -and `
        $_.InheritanceType.toString() -eq "All" -and `
        $_.InheritedObjectType.toString() -eq "00000000-0000-0000-0000-000000000000" `
    }
    if($null -ne $value)
    {
        $setting.Set=$true
    }
    
    return $setting
}

function Get-ADFSAuditingSetting
{
    [CmdletBinding()]
    param
    (

    )
    $setting=@{
        Name = "Audit Exchange Configuration Objects"
        Set = $false
    }

    $domainDN=(Get-ADDomain).DistinguishedName
    $auditRights=(Get-ACL -Path "AD:\CN=Configuration,$domainDN" -Audit).Audit

    $value=$auditRights|Where-Object -FilterScript { `
        $_.IdentityReference.toString() -eq "Everyone" -and `
        $_.ActiveDirectoryRights.toString().Contains("WriteProperty") -and `
        $_.InheritanceType.toString() -eq "All" -and `
        $_.InheritedObjectType.toString() -eq "00000000-0000-0000-0000-000000000000" `
    }
    if($null -ne $value)
    {
        $setting.Set=$true
    }
    
    return $setting
}

function Get-SettingToString
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter()]
        [String]
        $SettingName,

        [Parameter()]
        [Array]
        $Settings
    )

    $result=[StringBuilder]::New()

    $result.Append("$SettingName`: [") | Out-Null
    if($Settings.Set.Contains($false))
    {
        $result.Append(" ]`r`n") | Out-Null
    }
    else
    {
        $result.Append("X]`r`n") | Out-Null
    }

    foreach($setting in $settings)
    {
        $result.Append("    $setting.Name`: [") | Out-Null
        if($setting.Set)
        {
            $result.Append("X]`r`n") | Out-Null
        }
        else
        {
            $result.Append(" ]`r`n") | Out-Null
        }
    }

    return $result.toString()
}

$LDAPAuditingSchema = Get-RegistryKeySetting -Settings $LDAPAuditingSchema
$NTLMAuditingSchema = Get-RegistryKeySetting -Settings $NTLMAuditingSchema 
$advancedAuditingSchema = Get-GroupPolicySetting -Settings $advancedAuditingSchema
$objectAuditingSchema = Get-ObjectAuditingSetting -Settings $objectAuditingSchema
$ADFSAuditingSchema = Get-ADFSAuditingSetting
$exchangeAuditingSchema = Get-ExchangeAuditingSetting

Write-Output -InputObject (Get-SettingToString -SettingName "Audit LDAP Queries - Event ID 1644" -Settings $LDAPAuditingSchema)
Write-Output -InputObject (Get-SettingToString -SettingName "Audit NTLM - Event ID 8004" -Settings $NTLMAuditingSchema)
Write-Output -InputObject (Get-SettingToString -SettingName "Advanced Audit Policies Events" -Settings $advancedAuditingSchema)
Write-Output -InputObject (Get-SettingToString -SettingName "Audit Objects - Event ID 4662" -Settings $objectAuditingSchema)
Write-Output -InputObject (Get-SettingToString -SettingName "Audit ADFS Events" -Settings $ADFSAuditingSchema)
Write-Output -InputObject (Get-SettingToString -SettingName "Audit Exchange Configuration Events" -Settings $exchangeAuditingSchema)