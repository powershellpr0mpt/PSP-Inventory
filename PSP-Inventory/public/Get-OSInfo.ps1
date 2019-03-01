function Get-OSInfo {
    <#
    .SYNOPSIS
    Get Operating System information for local or remote machines

    .DESCRIPTION
    Get Operating System information for local or remote machines.
    Tries to use CIM to obtain information, but will revert to DCOM if CIM is not available

    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine

    .EXAMPLE
    Get-OSInfo -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'

    Description
    -----------
    Gets the Operating System information for CONTOSO-SRV01 and CONTOSO-WEB01

    .NOTES
    Name: Get-OSInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-02-2019
    DateModified: 01-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.OperatingSystemInfo')]
    [Cmdletbinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        $InventoryDate = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    process {
        foreach ($Computer in $ComputerName) {
            $Computer = $Computer.ToUpper()
            try {
                $TimeZone = Get-CimInstance -ClassName Win32_TimeZone -Property Caption -ComputerName $Computer -ErrorAction Stop
                $OS = Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption, Version, ServicePackMajorVersion, ServicePackMinorVersion, LastBootUpTime, OSArchitecture -ComputerName $Computer
                $ProductKey = (Get-CimInstance -Query 'SELECT OA3xOriginalProductKey FROM SoftwareLicensingService' -ComputerName $Computer).OA3xOriginalProductKey
                $PageFile = Get-CimInstance -ClassName Win32_PageFile -Property Name, FileSize -ComputerName $Computer
                $OperatingSystem = [PSCustomObject]@{
                    ComputerName   = $Computer
                    Caption        = $OS.Caption
                    Version        = $OS.Version
                    ServicePack    = ("{0}.{1}" -f $OS.ServicePackMajorVersion, $OS.ServicePackMinorVersion)
                    ProductKey     = $ProductKey
                    LastReboot     = $OS.LastBootUpTime
                    OSArchitecture = $OS.OSArchitecture
                    TimeZone       = $TimeZone.Caption
                    PageFile       = $PageFile.Name
                    PageFileSizeGB = ([math]::round(($PageFile.FileSize / 1GB), 0))
                    InventoryDate  = $InventoryDate
                }
                $OperatingSystem.PSTypeNames.Insert(0, 'PSP.Inventory.OperatingSystemInfo')
                $OperatingSystem
            }
            catch [Microsoft.Management.Infrastructure.CimException] {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions
                try {
                    $TimeZone = Get-CimInstance -CimSession $CimSession -ClassName Win32_TimeZone -Property Caption -ErrorAction Stop
                    $OS = Get-CimInstance -CimSession $CimSession -ClassName Win32_OperatingSystem -Property Caption, Version, ServicePackMajorVersion, ServicePackMinorVersion, LastBootUpTime, OSArchitecture
                    $ProductKey = (Get-CimInstance -CimSession $CimSession -Query 'SELECT OA3xOriginalProductKey FROM SoftwareLicensingService').OA3xOriginalProductKey
                    $PageFile = Get-CimInstance -CimSession $CimSession -ClassName Win32_PageFile -Property Name, FileSize
                    $OperatingSystem = [PSCustomObject]@{
                        ComputerName   = $Computer
                        Caption        = $OS.Caption
                        Version        = $OS.Version
                        ServicePack    = ("{0}.{1}" -f $OS.ServicePackMajorVersion, $OS.ServicePackMinorVersion)
                        ProductKey     = $ProductKey
                        LastReboot     = $OS.LastBootUpTime
                        OSArchitecture = $OS.OSArchitecture
                        TimeZone       = $TimeZone.Caption
                        PageFile       = $PageFile.Name
                        PageFileSizeGB = ([math]::round(($PageFile.FileSize / 1GB), 0))
                        InventoryDate  = $InventoryDate
                    }
                    $OperatingSystem.PSTypeNames.Insert(0, 'PSP.Inventory.OperatingSystemInfo')
                    $OperatingSystem
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

