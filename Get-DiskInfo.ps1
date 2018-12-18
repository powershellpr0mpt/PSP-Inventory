Get-DiskInfo {
    [cmdletbinding()]
    param()
    begin {
        $Disks = Get-Disk
        $Volumes = Get-Volume
        $Partitions = Get-Partition
    }
    process {
        foreach ($Volume in $Volumes) {
            $Partition = $Partitions | Where-Object {$_.AccessPaths[1] -eq $Volume.Path}
            $Disk = $Disks | Where-Object {$_.Path -eq $Partition.DiskPath}
            [PSCustomObject]@{
                DriveLetter       = $Volume.DriveLetter
                Label             = $Volume.FileSystemLabel
                FileSystem        = $Volume.FileSystem
                Clustersize       = $Volume.AllocationUnitSize
                HealthStatus      = $Volume.HealthStatus
                DedupMode         = $Volume.DedupMode
                DriveType         = $Volume.DriveType
                VolumeTotalSizeGB = [math]::round(($Volume.Size / 1GB), 2)
                VolumeFreeSizeGB  = [math]::round(($Volume.SizeRemaining / 1GB), 2)
                VolumeUsedSizeGB  = [math]::round((($Volume.Size - $Volume.SizeRemaining) / 1GB), 2)
                DiskFriendlyName  = $Disk.FriendlyName
                DiskSerialNumber  = $Disk.SerialNumber
                DiskTotalSizeGB   = [math]::round(($Disk.Size / 1GB), 2)
                Disknumber        = $Partition.DiskNumber
                PartitionNumber   = $Partition.PartitionNumber
                IsActive          = $Partition.IsActive
                IsBoot            = $Partition.IsBoot
                DiskId            = $Disk.Path
            }
        }
    }
}