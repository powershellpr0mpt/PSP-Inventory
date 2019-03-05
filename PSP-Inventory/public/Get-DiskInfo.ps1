function Get-DiskInfo {
    <#
    .SYNOPSIS
    Get Disk information for local or remote machines

    .DESCRIPTION
    Get Disk information for local or remote machines.
    Will query Disks, partitions and volumes to obtain as much information as possible.
    Tries to use CIM to obtain information, but will revert to DCOM if CIM is not available

    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine

    .EXAMPLE
    Get-DiskInfo -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'

    Description
    -----------
    Gets the Disk information for CONTOSO-SRV01 and CONTOSO-WEB01

    .NOTES
    Name: Get-DiskInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 22-12-2018
    DateModified: 05-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.Disk')]
    [cmdletbinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        [datetime]$InventoryDate = Get-Date
    }
    process {
        foreach ($Computer in $ComputerName) {
            $Computer = $Computer.ToUpper()
            try {
                $Volumes = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ComputerName $Computer -ErrorAction Stop
                foreach ($Volume in $Volumes) {
                    $Partition = Get-CimAssociatedInstance -InputObject $Volume -ResultClass Win32_DiskPartition
                    $Disk = Get-CimAssociatedInstance -InputObject $Partition -ResultClassName Win32_DiskDrive

                    $Dsk = [PSCustomObject]@{
                        ComputerName       = $Computer
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
                        InventoryDate      = $InventoryDate
                    }
                    $Dsk.PSTypeNames.Insert(0, 'PSP.Inventory.Disk')
                    $Dsk
                }
            }
            catch [Microsoft.Management.Infrastructure.CimException] {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions

                try {
                    $Volumes = Get-CimInstance -CimSession $CimSession -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ErrorAction Stop
                    foreach ($Volume in $Volumes) {
                        $Partition = Get-CimAssociatedInstance -CimSession $CimSession -InputObject $Volume -ResultClass Win32_DiskPartition
                        $Disk = Get-CimAssociatedInstance -CimSession $CimSession -InputObject $Partition -ResultClassName Win32_DiskDrive

                        $Dsk = [PSCustomObject]@{
                            ComputerName       = $Computer
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
                            InventoryDate      = $InventoryDate
                        }
                        $Dsk.PSTypeNames.Insert(0, 'PSP.Inventory.Disk')
                        $Dsk
                    }
                }
                catch {
                    Write-Warning "Unable to get WMI properties for computer '$Computer'"
                }
            }
            catch {
                Write-Warning "Unable to get WMI properties for computer '$Computer'"
            }
        }
    }
}