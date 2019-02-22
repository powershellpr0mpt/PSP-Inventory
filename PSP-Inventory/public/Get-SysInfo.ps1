function Get-SysInfo {
    [OutputType('PSP.Inventory.SystemInfo')]
    [Cmdletbinding()] 
    param( 
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] 
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        $Date = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }   
    process {           
        foreach ($Computer in $ComputerName) { 
            try {
                $CS = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $Computer -ErrorAction Stop
                $Enclosure = Get-CimInstance -ClassName Win32_SystemEnclosure -ComputerName $Computer
                $BIOS = Get-CimInstance -ClassName Win32_Bios -ComputerName $Computer
                $General = [PSCustomObject]@{
                    ComputerName = $Computer
                    Manufacturer = $CS.Manufacturer
                    Model = $CS.Model
                    SystemType = $CS.SystemType
                    State = if ($CS.Manufacturer -match "Hyper|Citrix|VMWare|virtual"){'Virtual'}else{'Physical'}
                    SerialNumber = $Enclosure.SerialNumber
                    ChassisType = (Convert-ChassisType $Enclosure.ChassisTypes)
                    Description = $Enclosure.Description
                    NumberofCores = $CS.NumberOfProcessors
                    NumberOfLogicalProcessors = $CS.NumberOfLogicalProcessors
                    TotalPhysicalMemoryGB = ([math]::round(($CS.TotalPhysicalMemory / 1GB),0))
                    BIOSManufacturer = $BIOS.Manufacturer
                    BIOSName = $BIOS.Name
                    BIOSSerialNumber = $BIOS.SerialNumber
                    BIOSVersion = $BIOS.SMBIOSBIOSVersion
                    InventoryDate = $Date
                }
                $General.PSTypeNames.Insert(0,'PSP.Inventory.SystemInfo')
                $General
            } catch [Microsoft.Management.Infrastructure.CimException] {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions
                try
                {
                    $CS = Get-CimInstance -CimSession $CimSession -ClassName Win32_ComputerSystem -ErrorAction Stop
                    $Enclosure = Get-CimInstance -CimSession $CimSession -ClassName Win32_SystemEnclosure 
                    $BIOS = Get-CimInstance -CimSession $CimSession -ClassName Win32_Bios
                    $General = [PSCustomObject]@{
                        ComputerName = $Computer
                        Manufacturer = $CS.Manufacturer
                        Model = $CS.Model
                        SystemType = $CS.SystemType
                        State = if ($CS.Manufacturer -match "Hyper|Citrix|VMWare|virtual"){'Virtual'}else{'Physical'}
                        SerialNumber = $Enclosure.SerialNumber
                        ChassisType = (Convert-ChassisType $Enclosure.ChassisTypes)
                        Description = $Enclosure.Description
                        NumberofCores = $CS.NumberOfProcessors
                        NumberOfLogicalProcessors = $CS.NumberOfLogicalProcessors
                        TotalPhysicalMemoryGB = ([math]::round(($CS.TotalPhysicalMemory / 1GB),0))
                        BIOSManufacturer = $BIOS.Manufacturer
                        BIOSName = $BIOS.Name
                        BIOSSerialNumber = $BIOS.SerialNumber
                        BIOSVersion = $BIOS.SMBIOSBIOSVersion
                        InventoryDate = $Date
                    }
                    $General.PSTypeNames.Insert(0,'PSP.Inventory.SystemInfo')
                    $General 
                }
                catch
                {
                    Write-Warning "Unable to get WMI properties for computer '$Computer'"
                }
            }
            catch
            {
                Write-Warning "Unable to get WMI properties for computer '$Computer'"
            }
        }
    }
}