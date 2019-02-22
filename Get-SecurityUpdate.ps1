Function Get-SecurityUpdate {
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
                #Create an instance of the Registry Object and open the HKLM base key 
                try { 
                    $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $Computer) 
                }
                catch { 
                    $_ 
                    Continue 
                } 
                try {
                    #Drill down into the Uninstall key using the OpenSubKey Method 
                    $regkey = $reg.OpenSubKey($Path)  
                    #Retrieve an array of string that contain all the subkey names 
                    $subkeys = $regkey.GetSubKeyNames()      
                    #Open each Subkey and use GetValue Method to return the required values for each 
                    foreach ($key in $subkeys) {   
                        $thisKey = $Path + "\\" + $key   
                        $thisSubKey = $reg.OpenSubKey($thisKey)   
                        # prevent Objects with empty DisplayName 
                        $DisplayName = $thisSubKey.getValue("DisplayName")
                        if ($DisplayName -AND $DisplayName -match '^Update for|rollup|^Security Update|^Service Pack|^HotFix') {
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
                            # create New Object with empty Properties 
                            $Update = [pscustomobject] @{
                                ComputerName  = $Computer
                                Type          = $Description
                                HotFixID      = $HotFixID
                                InstalledOn   = $Date
                                Description   = $DisplayName
                                InventoryDate = $Date
                            }
                            $Update.PSTypeNames.Insert(0, 'PSP.Inventory.SecurityUpdate')
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
