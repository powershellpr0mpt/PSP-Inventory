function _GetDiskInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$Cimsession
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering Disk information"
    $Volumes = Get-CimInstance -CimSession $CimSession -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ErrorAction Stop
    foreach ($Volume in $Volumes) {
        $Partition = Get-CimAssociatedInstance -CimSession $CimSession -InputObject $Volume -ResultClass Win32_DiskPartition
        $Disk = Get-CimAssociatedInstance -CimSession $CimSession -InputObject $Partition -ResultClassName Win32_DiskDrive

        [PSCustomObject]@{
            PSTypeName         = 'PSP.Inventory.Disk'
            ComputerName       = $CimSession.ComputerName
            DriveLetter        = $Volume.Caption
            Label              = $Volume.VolumeName
            FileSystem         = $Volume.FileSystem
            ClusterSize        = $Partition.BlockSize
            VolumeTotalSizeGB  = [math]::round(($Volume.Size / 1GB), 2)
            VolumeFreeSizeGB   = [math]::round(($Volume.FreeSpace / 1GB), 2)
            VolumeUsedSizeGB   = [math]::round((($Volume.Size - $Volume.FreeSpace) / 1GB), 2)
            DiskFriendlyName   = $Disk.Caption
            DiskTotalSizeGB    = [math]::round(($Disk.Size / 1GB), 2)
            DiskSerialNumber   = $Disk.SerialNumber
            DiskFirmware       = $Disk.FirmwareRevision
            DiskModel          = $Disk.Model
            DiskInterface      = $Disk.InterfaceType
            DiskNumber         = $Disk.Index
            PartitionNumber    = $Partition.Index
            IsPrimaryPartition = $Partition.PrimaryPartition
            IsBootPartition    = $Partition.BootPartition
            InventoryDate      = (Get-Date)
        }
    }
}
