[cmdletbinding()]
param()
begin {
    $Adapters = Get-NetAdapter
    $InterfaceInfo = Get-NetIPInterface
    $IPAddressConfig = Get-NetIPConfiguration -Detailed
    $DNSInfo = Get-DnsClientServerAddress
}
process {
    foreach ($Adapter in $Adapters) {
        $ifIndex = $Adapter.ifIndex
        $Interface = $InterfaceInfo | Where-Object {$_.ifIndex -eq $ifIndex}
        $IPConfig = $IPAddressConfig | Where-Object {$_.InterfaceIndex -eq $ifIndex }
        $DNS = $DNSInfo | Where-Object {$_.InterfaceIndex -eq $ifIndex}

        [PSCustomObject]@{
            Alias              = $Adapter.Name
            Index              = $ifIndex
            PhysicalAdapter    = if ($Adapter.HardwareInterface) {$adapter.HardwareInterface}else {$false}
            Status             = $Adapter.Status
            ConnectionState    = $Interface.ConnectionState
            Linkspeed          = $Adapter.LinkSpeed
            MacAddress         = $Adapter.MacAddress
            AddressFamily      = $Interface.AddressFamily
            InternetAccess     = $IPconfig.NetProfile.IPv4Connectivity
            NetworkCategory    = $IPConfig.NetProfile.NetworkCategory
            DHCP               = $Interface.DHCP
            IPv4Address        = $IPConfig.IPv4Address.IPAddress
            IPv4DefaultGateway = $IPConfig.IPv4DefaultGateway.NextHop
            IPv6Address        = $IPConfig.IPv6Address.IPAddress
            IPv6DefaultGateway = $IPConfig.IPv6DefaultGateway.NextHop
            DNSServersIPv4     = ($DNS | Where-Object {$_.AddressFamily -eq '2'}).ServerAddresses
            DNSServersIPv6     = ($DNS | Where-Object {$_.AddressFamily -eq '23'}).ServerAddresses
            DriverFileName     = $Adapter.DriverFileName
            DriverVersion      = $Adapter.DriverVersion
            DriverDate         = $Adapter.DriverDate
            DriverDescription  = $Adapter.DriverDescription
            DriverProvider     = $Adapter.DriverProvider
        }
    }
}