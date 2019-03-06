function _GetNICInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$CimSession,
        [switch]$Drivers
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering NIC information"
    $AdapterProperties = @{
        CimSession = $Cimsession
        ClassName = 'Win32_NetworkAdapter'
        Filter = "Availability = 3"
        Property = @('Name','NetConnectionID','DeviceId','PhysicalAdapter','NetConnectionStatus','Speed','MacAddress')
        ErrorAction = 'Stop'
    }
    $Adapters = Get-CimInstance @AdapterProperties | Where-Object {$_.AdapterTypeId -match '0|9'}
        if ($Drivers) {
            $SignedDrivers = Get-CimInstance -CimSession $CimSession -ClassName Win32_PnPSignedDriverCIMDataFile
        }
        foreach ($Adapter in $Adapters) {
            if ($Adapter.Speed) {
                $LinkSpeed = $Adapter.Speed / 1000000
            }
            else {
                $LinkSpeedProperties = @{
                    CimSession = $CimSession 
                    Namespace = "root/wmi" 
                    Query = "SELECT * FROM MSNdis_LinkSpeed"
                }
                $LinkSpeed = (Get-CimInstance @LinkSpeedProperties | Where-Object {$_.InstanceName -eq $Adapter.Name}).NdisLinkSpeed / 1000
            }
            if ($Drivers) {
                $DriverProperties = @{
                    CimSession = $Cimsession
                    ClassName = 'Win32_PnPSignedDriver'
                    Filter = "Description='$($Adapter.Name)'"
                    Property = @('InfName','DriverVersion','DriverDate','Description','DriverProviderName','Manufacturer','DeviceId')
                }
                $DriverInfo = Get-CimInstance @DriverProperties
            }
            $ConfigProperties = @{
                CimSession = $CimSession 
                ClassName = 'Win32_NetworkAdapterConfiguration' 
                Filter = "Index = '$($Adapter.DeviceId)'" 
                Property = @('IPAddress','DHCPEnabled','DHCPServer','DNSServerSearchOrder','DefaultIPGateway','IPSubnet')
            }
            $Config = Get-CimInstance @ConfigProperties

            [PSCustomObject]@{
                PSTypeName = 'PSP.Inventory.NIC'
                ComputerName      = $Computer
                Alias             = $Adapter.NetConnectionID
                Index             = $Adapter.DeviceId
                PhysicalAdapter   = $Adapter.PhysicalAdapter
                IPAddress         = $Config.IPAddress
                Status            = (Convert-NetworkStatus -NetworkStatus $Adapter.NetConnectionStatus)
                MacAddress        = $Adapter.MacAddress
                DHCPEnabled       = $Config.DHCPEnabled
                DHCPServer        = $Config.DHCPServer
                DNSServers        = $Config.DNSServerSearchOrder
                Gateway           = $Config.DefaultIPGateway
                Subnet            = $Config.IPSubnet
                LinkspeedMB       = $LinkSpeed
                DriverInf         = if ($Drivers) {$DriverInfo.InfName}else {''}
                DriverFileName    = if ($Drivers) {$SignedDrivers.Where{$_.Antecedent.DeviceId -eq $DriverInfo.DeviceId}[0].Dependent.Name}else {''}
                DriverVersion     = if ($Drivers) {$DriverInfo.DriverVersion}else {''}
                DriverDate        = if ($Drivers) {$DriverInfo.DriverDate}else {''}
                DriverDescription = if ($Drivers) {$DriverInfo.Description}else {''}
                DriverProvider    = if ($Drivers) {$DriverInfo.DriverProviderName}else {''}
                NicManufacturer   = if ($Drivers) {$DriverInfo.Manufacturer}else {''}
                InventoryDate     = $InventoryDate
            }
        }
    }