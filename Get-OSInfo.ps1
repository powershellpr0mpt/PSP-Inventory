$TimeZone = Get-WmiObject Win32_TimeZone -ComputerName $Computername -ErrorAction Stop
$OS = Get-WmiObject Win32_OperatingSystem -ComputerName $Computername 
$ProductKey = (Get-WmiObject -query 'SELECT * FROM SoftwareLicensingService').OA3xOriginalProductKey
$PageFile = Get-WMIObject win32_PageFile -ComputerName $Computername 
$LastReboot = Try {
    $OS.ConvertToDateTime($OS.LastBootUpTime)
} 
Catch {
}
$OperatingSystem = [pscustomobject]@{
    ComputerName = $Computername
    Caption = $OS.caption
    Version = $OS.version
    ServicePack = ("{0}.{1}" -f $OS.ServicePackMajorVersion, $OS.ServicePackMinorVersion)
    ProductKey = $ProductKey
    LastReboot = $LastReboot
    OSArchitecture = $OS.OSArchitecture
    TimeZone = $TimeZone.Caption
    PageFile = $PageFile.Name
    PageFileSizeGB = ("{0:N2}" -f ($PageFile.FileSize /1GB))
    InventoryDate = $Date
}
if ($OperatingSystem){
    $OperatingSystem
}
