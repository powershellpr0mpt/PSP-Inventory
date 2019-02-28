Function Get-SecurityUpdate {
    <#
    .SYNOPSIS
    Get all the security update information for local or remote machines

    .DESCRIPTION
    Get all the security update information for local or remote machines.
    Requires the RemoteRegistry to be enabled on the machine.
    Will look for 'Update','Rollup','Security Update','Service Pack' and 'HotFix'


    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine

    .EXAMPLE
    Get-SecurityUpdate -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'

    Description
    -----------
    Gets the security update information for both CONTOSO-SRV01 and CONTOSO-WEB01

    .NOTES
    Name: Get-SecurityUpdate.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 21-02-2019
    DateModified: 27-02-2019
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.SecurityUpdate')]
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
            $Paths = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
            foreach ($Path in $Paths) { 
                try { 
                    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
                }
                catch { 
                    $_ 
                    Continue 
                } 
                try {
                    $regkey = $reg.OpenSubKey($Path)  
                    $subkeys = $regkey.GetSubKeyNames()      
                    foreach ($key in $subkeys) {   
                        $thisKey = $Path + "\\" + $key   
                        $thisSubKey = $reg.OpenSubKey($thisKey)   
                        $DisplayName = $thisSubKey.getValue("DisplayName")
                        if ($DisplayName -AND $DisplayName -match '^Update for|Rollup|^Security Update|^Service Pack|^HotFix') {
                            $Date = $thisSubKey.GetValue('InstallDate')
                            if ($Date) {
                                Write-Verbose $Date 
                                $Date = $Date -replace '(\d{4})(\d{2})(\d{2})', '$1-$2-$3'
                                Write-Verbose $Date 
                                $Date = Get-Date $Date
                            } 
                            if ($DisplayName -match '(?<DisplayName>.*)\((?<KB>KB.*?)\).*') {
                                $DisplayName = $Matches.DisplayName
                                $HotFixID = $Matches.KB
                            }
                            switch -Wildcard ($DisplayName) {
                                "Service Pack*" {$Description = 'Service Pack'}
                                "Hotfix*" {$Description = 'Hotfix'}
                                "Update*" {$Description = 'Update'}
                                "Security Update*" {$Description = 'Security Update'}
                                Default {$Description = 'Unknown'}
                            }
                            $Update = [PSCustomObject] @{
                                ComputerName  = $Computer
                                Type          = $Description
                                HotFixID      = $HotFixID
                                InstalledOn   = $Date
                                Description   = $DisplayName
                                InventoryDate = $Date
                            }
                            $Update.PSTypeNames.Insert(0,'PSP.Inventory.SecurityUpdate')
                            $Update
                        } 
                    }   
                    $reg.Close() 
                }
                catch {}                  
            }  
        } 
    } 
}
