function Get-NicInfo
{
    [cmdletbinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [switch]$Drivers
    )
    process
    {
        foreach ($Computer in $ComputerName)
        {
            try
            {
                $Adapters = Get-CimInstance -ClassName Win32_NetworkAdapter -ComputerName $Computer -Filter "PhysicalAdapter=True" -ErrorAction Stop
                if ($Drivers)
                {
                    $SignedDrivers = Get-CimInstance -ClassName Win32_PnPSignedDriverCIMDataFile -ComputerName $Computer
                }
                foreach ($Adapter in $Adapters)
                {
                    if ($Drivers)
                    {
                        $DriverInfo = Get-CimInstance -ClassName Win32_PnPSignedDriver -Filter "Description='$($Adapter.Name)'" -ComputerName $Computer
                    }
                    $Config = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "Index = '$($Adapter.DeviceId)'" -ComputerName $Computer

                    [PSCustomObject]@{
                        Computer          = $Computer
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
                        LinkspeedMB       = ($Adapter.Speed / 1000000)
                        DriverInf         = if ($Drivers) {$DriverInfo.InfName}else {''}
                        DriverFileName    = if ($Drivers) {$SignedDrivers.Where{$_.Antecedent.DeviceId -eq $DriverInfo.DeviceId}[0].Dependent.Name}else {''}
                        DriverVersion     = if ($Drivers) {$DriverInfo.DriverVersion}else {''}
                        DriverDate        = if ($Drivers) {$DriverInfo.DriverDate}else {''}
                        DriverDescription = if ($Drivers) {$DriverInfo.Description}else {''}
                        DriverProvider    = if ($Drivers) {$DriverInfo.DriverProviderName}else {''}
                        NicManufacturer   = if ($Drivers) {$DriverInfo.Manufacturer}else {''}
                    }
                }
            }
            catch [Microsoft.Management.Infrastructure.CimException]
            {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions

                $Adapters = Get-CimInstance -CimSession $CimSession -ClassName Win32_NetworkAdapter -Filter "Availability =3"  -ErrorAction Stop | Where-Object {$_.AdapterTypeId -match '0|9'}
                if ($Drivers)
                {
                    $SignedDrivers = Get-CimInstance -CimSession $CimSession -ClassName Win32_PnPSignedDriverCIMDataFile
                }
                foreach ($Adapter in $Adapters)
                {
                    if ($Adapter.Speed)
                    {
                        $LinkSpeed = $Adapter.Speed / 1000000
                    }
                    else
                    {
                        $LinkSpeed = (Get-CimInstance -CimSession $CimSession -Namespace "root/wmi" -Query "SELECT * FROM MSNdis_LinkSpeed" | Where-Object {$_.InstanceName -eq $Adapter.Name}).NdisLinkSpeed / 1000
                    }
                    if ($Drivers)
                    {
                        $DriverInfo = Get-CimInstance -CimSession $CimSession -ClassName Win32_PnPSignedDriver -Filter "Description='$($Adapter.Name)'"
                    }
                    $Config = Get-CimInstance -CimSession $CimSession -ClassName Win32_NetworkAdapterConfiguration -Filter "Index = '$($Adapter.DeviceId)'"

                    [PSCustomObject]@{
                        Computer          = $Computer
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
                        LinkspeedMB       = ($Adapter.Speed / 1000000)
                        DriverInf         = if ($Drivers) {$DriverInfo.InfName}else {''}
                        DriverFileName    = if ($Drivers) {$SignedDrivers.Where{$_.Antecedent.DeviceId -eq $DriverInfo.DeviceId}[0].Dependent.Name}else {''}
                        DriverVersion     = if ($Drivers) {$DriverInfo.DriverVersion}else {''}
                        DriverDate        = if ($Drivers) {$DriverInfo.DriverDate}else {''}
                        DriverDescription = if ($Drivers) {$DriverInfo.Description}else {''}
                        DriverProvider    = if ($Drivers) {$DriverInfo.DriverProviderName}else {''}
                        NicManufacturer   = if ($Drivers) {$DriverInfo.Manufacturer}else {''}
                    }
                }
            }
            catch
            {
                Write-Warning "Unable to get WMI properties for computer '$Computer'"
            }
        }
    }
}
