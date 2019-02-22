function Get-OSInfo {
    [OutputType('PSP.Inventory.OperatingSystemInfo')]
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
                $TimeZone = Get-CimInstance -ClassName Win32_TimeZone -ComputerName $Computer -ErrorAction Stop
                $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $Computer 
                $ProductKey = (Get-CimInstance -Query 'SELECT * FROM SoftwareLicensingService' -ComputerName $Computer).OA3xOriginalProductKey
                $PageFile = Get-CimInstance -ClassName Win32_PageFile -ComputerName $Computer 
                $OperatingSystem = [PSCustomObject]@{
                    ComputerName = $Computer
                    Caption = $OS.Caption
                    Version = $OS.Version
                    ServicePack = ("{0}.{1}" -f $OS.ServicePackMajorVersion, $OS.ServicePackMinorVersion)
                    ProductKey = $ProductKey
                    LastReboot = $OS.LastBootUpTime
                    OSArchitecture = $OS.OSArchitecture
                    TimeZone = $TimeZone.Caption
                    PageFile = $PageFile.Name
                    PageFileSizeGB = ([math]::round(($PageFile.FileSize /1GB),0))
                    InventoryDate = $Date
                }
                $OperatingSystem.PSTypeNames.Insert(0,'PSP.Inventory.OperatingSystemInfo')
                $OperatingSystem
            } catch [Microsoft.Management.Infrastructure.CimException] {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions
                try
                {
                    $TimeZone = Get-CimInstance -CimSession $CimSession -ClassName Win32_TimeZone -ErrorAction Stop
                    $OS = Get-CimInstance -CimSession $CimSession -ClassName Win32_OperatingSystem  
                    $ProductKey = (Get-CimInstance -CimSession $CimSession -Query 'SELECT * FROM SoftwareLicensingService').OA3xOriginalProductKey
                    $PageFile = Get-CimInstance -CimSession $CimSession -ClassName Win32_PageFile 
                    $OperatingSystem = [PSCustomObject]@{
                        ComputerName = $Computer
                        Caption = $OS.Caption
                        Version = $OS.Version
                        ServicePack = ("{0}.{1}" -f $OS.ServicePackMajorVersion, $OS.ServicePackMinorVersion)
                        ProductKey = $ProductKey
                        LastReboot = $OS.LastBootUpTime
                        OSArchitecture = $OS.OSArchitecture
                        TimeZone = $TimeZone.Caption
                        PageFile = $PageFile.Name
                        PageFileSizeGB = ([math]::round(($PageFile.FileSize /1GB),0))
                        InventoryDate = $Date
                    }
                    $OperatingSystem.PSTypeNames.Insert(0,'PSP.Inventory.OperatingSystemInfo')
                    $OperatingSystem
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
        
