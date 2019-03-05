function _GetOSInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$Cimsession
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering OS information"
    $TimeZone = Get-CimInstance -CimSession $CimSession -ClassName Win32_TimeZone -Property Caption -ErrorAction Stop
    $OS = Get-CimInstance -CimSession $CimSession -ClassName Win32_OperatingSystem -Property Caption, Version, ServicePackMajorVersion, ServicePackMinorVersion, LastBootUpTime, OSArchitecture
    $ProductKey = (Get-CimInstance -CimSession $CimSession -Query 'SELECT OA3xOriginalProductKey FROM SoftwareLicensingService').OA3xOriginalProductKey
    $PageFile = Get-CimInstance -CimSession $CimSession -ClassName Win32_PageFile -Property Name, FileSize
    [PSCustomObject]@{
        PSTypename = 'PSP.Inventory.OperatingSystemInfo'
        ComputerName   = $Cimsession.ComputerName
        Caption        = $OS.Caption
        Version        = $OS.Version
        ServicePack    = ("{0}.{1}" -f $OS.ServicePackMajorVersion, $OS.ServicePackMinorVersion)
        ProductKey     = $ProductKey
        LastReboot     = $OS.LastBootUpTime
        OSArchitecture = $OS.OSArchitecture
        TimeZone       = $TimeZone.Caption
        PageFile       = $PageFile.Name
        PageFileSizeGB = ([math]::round(($PageFile.FileSize / 1GB), 0))
        InventoryDate  = (Get-Date)
    }
}