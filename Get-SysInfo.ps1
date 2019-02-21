Try {
    $CS = Get-WmiObject Win32_ComputerSystem -ComputerName $Computername -ErrorAction Stop
    $Enclosure = Get-WmiObject Win32_SystemEnclosure -ComputerName $Computername
    $BIOS = Get-WmiObject Win32_Bios -ComputerName $Computername 
    $General = [pscustomobject]@{
        Computername = $Computername
        Manufacturer = $CS.Manufacturer
        Model = $CS.Model
        SystemType = $CS.SystemType
        SerialNumber = $Enclosure.SerialNumber
        ChassisType = (Convert-ChassisType $Enclosure.ChassisTypes)
        Description = $Enclosure.Description
        BIOSManufacturer = $BIOS.Manufacturer
        BIOSName = $BIOS.Name
        BIOSSerialNumber = $BIOS.SerialNumber
        BIOSVersion = $BIOS.SMBIOSBIOSVersion
        InventoryDate = (Get-Date)
    }
}Catch {
    Write-Verbose "WARNING - [$Computername - $(Get-Date)]" -Verbose
    Write-Warning $_
    BREAK
}

$Memory = @(Get-WmiObject Win32_PhysicalMemory -ComputerName $Computername -ErrorAction Stop| ForEach-Object {
    [pscustomobject]@{
        Computername = $Computername
        DeviceID = $_.tag
        MemoryType = $MemoryType[[int]$_.MemoryType]
        "Capacity(GB)" = "{0}" -f ($_.capacity/1GB)
        TypeDetail = $TypeDetail[[int]$_.TypeDetail]
        Locator = $_.DeviceLocator
        InventoryDate = $Date
    }
})

if ($Memory){
    $Memory
}

$Processor = @(Get-WmiObject Win32_Processor -ComputerName $Computername -ErrorAction Stop | ForEach {
    [pscustomobject]@{
        Computername = $Computername
        DeviceID = $_.DeviceID
        Description = $_.Description
        ProcessorType = $ProcessorType[$_.processortype]
        CoreCount = $_.NumberofCores
        NumLogicalProcessors = $_.NumberOfLogicalProcessors
        MaxSpeed = ("{0:N2} GHz" -f ($_.MaxClockSpeed/1000))
        InventoryDate = $Date
    }
})
if ($Processor){
    $Processor
}
