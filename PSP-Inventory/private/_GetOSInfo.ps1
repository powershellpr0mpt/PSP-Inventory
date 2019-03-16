function _GetOSInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$Cimsession
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering OS information"
    $TimeZone = Get-CimInstance -CimSession $CimSession -ClassName Win32_TimeZone -Property Caption -ErrorAction Stop
    $OS = Get-CimInstance -CimSession $CimSession -ClassName Win32_OperatingSystem -Property Caption, Version, ServicePackMajorVersion, ServicePackMinorVersion, LastBootUpTime, OSArchitecture, InstallDate
    $ProductKey = (Get-CimInstance -CimSession $CimSession -Query 'SELECT OA3xOriginalProductKey FROM SoftwareLicensingService').OA3xOriginalProductKey
    $PageFile = Get-CimInstance -CimSession $CimSession -ClassName Win32_PageFile -Property Name, FileSize
    [PSCustomObject]@{
        PSTypename     = 'PSP.Inventory.OperatingSystemInfo'
        ComputerName   = $Cimsession.ComputerName
        Caption        = $OS.Caption
        Version        = $OS.Version
        ServicePack    = ("{0}.{1}" -f $OS.ServicePackMajorVersion, $OS.ServicePackMinorVersion)
        ProductKey     = $ProductKey
        LastReboot     = $OS.LastBootUpTime
        InstallDate    = $OS.InstallDate
        OSArchitecture = $OS.OSArchitecture
        TimeZone       = $TimeZone.Caption
        PageFile       = if ($PageFile) {foreach ($File in $PageFile) {$File.Name}}else {$null}
        PageFileSizeGB = if ($PageFile) {foreach ($File in $PageFile) {([math]::round(($File.FileSize / 1GB), 0))}} else {$null}
        InventoryDate  = (Get-Date)
    }
}