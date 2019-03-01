function Get-NicInfo {
    <#
    .SYNOPSIS
    Get Network adapter information for local or remote machines 
    
    .DESCRIPTION
    Get Network adapter information for local or remote machines.
    Tries to use CIM to obtain information, but will revert to DCOM if CIM is not available
    
    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine
    
    .PARAMETER Drivers
    Switch parameter
    If activated will try and obtain the driver information for the adapter.
    Do note that this will substantially increase time required
    
    .EXAMPLE
    Get-NicInfo -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
    
    Description
    -----------
    Gets the "basic" NIC information for CONTOSO-SRV01 and CONTOSO-WEB01
 
    .NOTES
    Name: Get-NicInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-12-2018
    DateModified: 01-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>
    
    [OutputType('PSP.Inventory.NIC')]
    [cmdletbinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [switch]$Drivers
    )
    begin {
        $InventoryDate = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    process {
        foreach ($Computer in $ComputerName) {
            $Computer = $Computer.ToUpper()
            try {
                $Adapters = Get-CimInstance -ClassName Win32_NetworkAdapter -ComputerName $Computer -Filter "PhysicalAdapter=True" -ErrorAction Stop
                if ($Drivers) {
                    $SignedDrivers = Get-CimInstance -ClassName Win32_PnPSignedDriverCIMDataFile -ComputerName $Computer -ErrorAction Stop
                }
                foreach ($Adapter in $Adapters) {
                    if ($Drivers) {
                        $DriverInfo = Get-CimInstance -ClassName Win32_PnPSignedDriver -Filter "Description='$($Adapter.Name)'" -ComputerName $Computer
                    }
                    $Config = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "Index = '$($Adapter.DeviceId)'" -ComputerName $Computer

                    $NIC = [PSCustomObject]@{
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
                        LinkspeedMB       = ($Adapter.Speed / 1000000)
                        DriverInf         = if ($Drivers) {$DriverInfo.InfName}else {''}
                        DriverFileName    = if ($Drivers) {$SignedDrivers.Where{$_.Antecedent.DeviceId -eq $DriverInfo.DeviceId}[0].Dependent.Name}else {''}
                        DriverVersion     = if ($Drivers) {$DriverInfo.DriverVersion}else {''}
                        DriverDate        = if ($Drivers) {$DriverInfo.DriverDate}else {''}
                        DriverDescription = if ($Drivers) {$DriverInfo.Description}else {''}
                        DriverProvider    = if ($Drivers) {$DriverInfo.DriverProviderName}else {''}
                        NicManufacturer   = if ($Drivers) {$DriverInfo.Manufacturer}else {''}
                        InventoryDate     = $InventoryDate
                    }
                    $NIC.PSTypeNames.Insert(0, 'PSP.Inventory.NIC')
                    $NIC
                }
            }
            catch [Microsoft.Management.Infrastructure.CimException] {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions

                try {
                    $Adapters = Get-CimInstance -CimSession $CimSession -ClassName Win32_NetworkAdapter -Filter "Availability =3"  -ErrorAction Stop | Where-Object {$_.AdapterTypeId -match '0|9'}
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
                            $DriverInfo = Get-CimInstance -CimSession $CimSession -ClassName Win32_PnPSignedDriver -Filter "Description='$($Adapter.Name)'"
                        }
                        $Config = Get-CimInstance -CimSession $CimSession -ClassName Win32_NetworkAdapterConfiguration -Filter "Index = '$($Adapter.DeviceId)'"

                        $NIC = [PSCustomObject]@{
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
                        $NIC.PSTypeNames.Insert(0, 'PSP.Inventory.NIC')
                        $NIC    
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
