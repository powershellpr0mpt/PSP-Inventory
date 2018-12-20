. $PSScriptRoot\Get-DiskInfo.ps1
describe bla {
    mock Get-Disk {Import-Clixml -Path C:\temp\disk_test_data.xml}
    mock Get-Volume {Import-Clixml -Path C:\temp\volume_test_data.xml}
    mock Get-Partition {Import-Clixml -Path C:\temp\partition_test_data.xml}
    $DiskInfo = Get-DiskInfo
    # it 'driveletter is correct' {
    #     $DiskInfo.driveletter | Should be 'D'
    # }
    # it 'DiskFriendlyname is correct' {
    #     $DiskInfo.Diskfriendlyname
    # }

    it 'Assertion should be correct' {
        $expected = [PSCustomObject]@{
            DiskSerialNumber  = "S246J90B539415"
            DiskTotalSizeGB   = "931.51"
            VolumeTotalSizeGB = "931.51"
            DiskId            = "\\?\scsi#disk&ven_samsung&prod_hd103sj#4&15ad2e1c&0&040000#{53f56307-b6bf-11d0-94f2-00a0c91efb8b}"
            Clustersize       = "4096"
            VolumeUsedSizeGB  = "383.66"
            FileSystem        = "NTFS"
            Label             = "Storagevault"
            DriveLetter       = "D"
            DiskFriendlyName  = "SAMSUNG HD103SJ"
            VolumeFreeSizeGB  = "547.86"
            HealthStatus      = ''
            DedupMode         = ''
            Disknumber        = "1"
            DriveType         = ''
            PartitionNumber   = "1"
            IsBoot            = "False"
            IsActive          = "False"
        }
        Assert-Equivalent -Actual $DiskInfo -Expected $expected
    }
}