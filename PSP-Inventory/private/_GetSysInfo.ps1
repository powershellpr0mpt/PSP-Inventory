function _GetSysInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$Cimsession
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering System information"
    $CS = Get-CimInstance -CimSession $CimSession -ClassName Win32_ComputerSystem -Property Manufacturer, Model, SystemType, NumberOfProcessors, NumberOfLogicalProcessors, TotalPhysicalMemory -ErrorAction Stop
    $Enclosure = Get-CimInstance -CimSession $CimSession -ClassName Win32_SystemEnclosure -Property SerialNumber, ChassisTypes, Description
    $BIOS = Get-CimInstance -CimSession $CimSession -ClassName Win32_Bios -Property Name, Manufacturer, SerialNumber, SMBIOSBIOSVersion
    [PSCustomObject]@{
        PSTypeName                = 'PSP.Inventory.SystemInfo'
        ComputerName              = $Cimsession.ComputerName
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
        InventoryDate             = (Get-Date)
    }
}
