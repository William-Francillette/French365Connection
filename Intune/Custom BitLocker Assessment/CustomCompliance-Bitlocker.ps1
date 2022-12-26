
$btVolumes=Get-BitLockerVolume
$btOSVolumes=$btVolumes|where-object -filter {$_.VolumeType -eq 'OperatingSystem'}
$btDataVolumes=$btVolumes|where-object -filter {$_.VolumeType -eq 'Data'}

$isOSDrivesFullyEncrypted=$true
$nonEncryptedOsVolumesString=""

foreach($volume in $btOSVolumes )
{
    if($volume.VolumeStatus -ne "FullyEncrypted")
    {
        $isOSDrivesFullyEncrypted=$false
        if(-not [String]::isNullOrEmpty($nonEncryptedOsVolumesString))
        {
            $nonEncryptedOsVolumesString+=","
        }
        $nonEncryptedOsVolumesString+=$volume.MountPoint.replace(":","")
    }
}

$isDataDrivesFullyEncrypted=$true
$nonEncryptedDataVolumesString=""
foreach($volume in $btDataVolumes )
{
    if($volume.VolumeStatus -ne "FullyEncrypted")
    {
        $isDataDrivesFullyEncrypted=$false
        if(-not [String]::isNullOrEmpty($nonEncryptedDataVolumesString))
        {
            $nonEncryptedDataVolumesString+=","
        }
        $nonEncryptedDataVolumesString+=$volume.MountPoint.replace(":","")
    }
}

$hash=@{OsVolumeEncryptionStatus=$isOSDrivesFullyEncrypted; NonEncryptedOsVolumes=$nonEncryptedOsVolumesString;DataVolumeEncryptionStatus=$isDataDrivesFullyEncrypted; NonEncryptedDataVolumes=$nonEncryptedDataVolumesString}
$hash |ConvertTo-Json -Compress