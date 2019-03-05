function Get-SysInfo {
    <#
    .SYNOPSIS
    Get System information for local or remote machines

    .DESCRIPTION
    Get System information for local or remote machines.
    Will query default information about the actual system, such as CPU & Memory and if it's virtual or physical
    Tries to use CIM to obtain information, but will revert to DCOM if CIM is not available

    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine

    .EXAMPLE
    Get-SysInfo -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'

    Description
    -----------
    Gets the System information for CONTOSO-SRV01 and CONTOSO-WEB01

    .NOTES
    Name: Get-SysInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 24-02-2019
    DateModified: 05-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.SystemInfo')]
    [Cmdletbinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        [datetime]$InventoryDate = Get-Date
    }
    process {
        foreach ($Computer in $ComputerName) {
            $Computer = $Computer.ToUpper()
            try {
                $CS = Get-CimInstance -ClassName Win32_ComputerSystem -Property Manufacturer, Model, SystemType, NumberOfProcessors, NumberOfLogicalProcessors, TotalPhysicalMemory -ComputerName $Computer -ErrorAction Stop
                $Enclosure = Get-CimInstance -ClassName Win32_SystemEnclosure -Property SerialNumber, ChassisTypes, Description -ComputerName $Computer
                $BIOS = Get-CimInstance -ClassName Win32_Bios -Property Name, Manufacturer, SerialNumber, SMBIOSBIOSVersion -ComputerName $Computer
                $General = [PSCustomObject]@{
                    ComputerName              = $Computer
                    Manufacturer              = $CS.Manufacturer
                    Model                     = $CS.Model
                    SystemType                = $CS.SystemType
                    State                     = if ($CS.Manufacturer -match "Hyper|Citrix|VMWare|virtual") {'Virtual'}else {'Physical'}
                    SerialNumber              = $Enclosure.SerialNumber
                    ChassisType               = (Convert-ChassisType $Enclosure.ChassisTypes)
                    Description               = $Enclosure.Description
                    NumberofCores             = $CS.NumberOfProcessors
                    NumberOfLogicalProcessors = $CS.NumberOfLogicalProcessors
                    TotalPhysicalMemoryGB     = ([math]::round(($CS.TotalPhysicalMemory / 1GB), 0))
                    BIOSManufacturer          = $BIOS.Manufacturer
                    BIOSName                  = $BIOS.Name
                    BIOSSerialNumber          = $BIOS.SerialNumber
                    BIOSVersion               = $BIOS.SMBIOSBIOSVersion
                    InventoryDate             = $InventoryDate
                }
                $General.PSTypeNames.Insert(0, 'PSP.Inventory.SystemInfo')
                $General
            }
            catch [Microsoft.Management.Infrastructure.CimException] {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions
                try {
                    $CS = Get-CimInstance -CimSession $CimSession -ClassName Win32_ComputerSystem -Property Manufacturer, Model, SystemType, NumberOfProcessors, NumberOfLogicalProcessors, TotalPhysicalMemory -ErrorAction Stop
                    $Enclosure = Get-CimInstance -CimSession $CimSession -ClassName Win32_SystemEnclosure -Property SerialNumber, ChassisTypes, Description
                    $BIOS = Get-CimInstance -CimSession $CimSession -ClassName Win32_Bios -Property Name, Manufacturer, SerialNumber, SMBIOSBIOSVersion
                    $General = [PSCustomObject]@{
                        ComputerName              = $Computer
                        Manufacturer              = $CS.Manufacturer
                        Model                     = $CS.Model
                        SystemType                = $CS.SystemType
                        State                     = if ($CS.Manufacturer -match "Hyper|Citrix|VMWare|virtual") {'Virtual'}else {'Physical'}
                        SerialNumber              = $Enclosure.SerialNumber
                        ChassisType               = (Convert-ChassisType $Enclosure.ChassisTypes)
                        Description               = $Enclosure.Description
                        NumberofCores             = $CS.NumberOfProcessors
                        NumberOfLogicalProcessors = $CS.NumberOfLogicalProcessors
                        TotalPhysicalMemoryGB     = ([math]::round(($CS.TotalPhysicalMemory / 1GB), 0))
                        BIOSManufacturer          = $BIOS.Manufacturer
                        BIOSName                  = $BIOS.Name
                        BIOSSerialNumber          = $BIOS.SerialNumber
                        BIOSVersion               = $BIOS.SMBIOSBIOSVersion
                        InventoryDate             = $InventoryDate
                    }
                    $General.PSTypeNames.Insert(0, 'PSP.Inventory.SystemInfo')
                    $General
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