function _GetNicInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$Cimsession,
        [Switch]$Drivers
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering Netwok Interface information"
    $Adapters = Get-CimInstance -CimSession $CimSession -ClassName Win32_NetworkAdapter -Filter "Availability =3" -Property Name, NetConnectionID, DeviceId, PhysicalAdapter, NetConnectionStatus, Speed, MacAddress, AdapterTypeId -ErrorAction Stop | Where-Object {$_.AdapterTypeId -match '0|9'}
    if ($Drivers) {
        $SignedDrivers = Get-CimInstance -CimSession $CimSession -ClassName Win32_PnPSignedDriverCIMDataFile
    }
    foreach ($Adapter in $Adapters) {
        if ($Adapter.Speed) {
            $LinkSpeed = $Adapter.Speed / 1000000
        }
        else {
            $LinkSpeed = (Get-CimInstance -CimSession $CimSession -Namespace "root/wmi" -Query "SELECT * FROM MSNdis_LinkSpeed" | Where-Object {$_.InstanceName -eq $Adapter.Name}).NdisLinkSpeed / 1000
        }
        if ($Drivers) {
            $DriverInfo = Get-CimInstance -CimSession $CimSession -ClassName Win32_PnPSignedDriver -Filter "Description='$($Adapter.Name)'" -Property InfName, DriverVersion, DriverDate, Description, DriverProviderName, Manufacturer, DeviceId
        }
        $Config = Get-CimInstance -CimSession $CimSession -ClassName Win32_NetworkAdapterConfiguration -Filter "Index = '$($Adapter.DeviceId)'" -Property IPAddress, DHCPEnabled, DHCPServer, DNSServerSearchOrder, DefaultIPGateway, IPSubnet

        [PSCustomObject]@{
            PSTypeName        = 'PSP.Inventory.NIC'
            ComputerName      = $Cimsession.ComputerName
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
            InventoryDate     = (Get-Date)
        }
    }
}
