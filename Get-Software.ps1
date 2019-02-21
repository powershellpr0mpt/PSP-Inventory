Function Get-Software {
    [OutputType('PSP.Inventory.Software')]
    [Cmdletbinding()] 
    Param( 
        [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)] 
        [String[]]$ComputerName = $env:COMPUTERNAME
    )         
    Begin {
        $Date = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    Process {     
        foreach ($Computer in $Computername) { 
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                $Paths = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
                foreach ($Path in $Paths) { 
                    Write-Verbose "Checking Path: $Path"
                    # Create an instance of the Registry Object and open the HKLM base key 
                    try { 
                        $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $Computer, 'Registry64') 
                    }
                    catch { 
                        Write-Error $_ 
                        Continue 
                    } 
                    # Drill down into the Uninstall key using the OpenSubKey Method 
                    try {
                        $regkey = $reg.OpenSubKey($Path)  
                        # Retrieve an array of string that contain all the subkey names 
                        $subkeys = $regkey.GetSubKeyNames()      
                        # Open each Subkey and use GetValue Method to return the required values for each 
                        foreach ($key in $subkeys) {   
                            Write-Verbose "Key: $Key"
                            $thisKey = $Path + "\\" + $key 
                            try {  
                                $thisSubKey = $reg.OpenSubKey($thisKey)   
                                # Prevent Objects with empty DisplayName 
                                $DisplayName = $thisSubKey.getValue("DisplayName")
                                if ($DisplayName -AND $DisplayName -notmatch '^Update for|rollup|^Security Update|^Service Pack|^HotFix') {
                                    $Date = $thisSubKey.GetValue('InstallDate')
                                    if ($Date) {
                                        try {
                                            $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)
                                        }
                                        catch {
                                            Write-Warning "$($Computer): $_ <$($Date)>"
                                            $Date = $Null
                                        }
                                    } 
                                    # Create New Object with empty Properties 
                                    $Publisher = try {
                                        $thisSubKey.GetValue('Publisher').Trim()
                                    } 
                                    catch {
                                        $thisSubKey.GetValue('Publisher')
                                    }
                                    $Version = try {
                                        #Some weirdness with trailing [char]0 on some strings
                                        $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32, 0)))
                                    } 
                                    catch {
                                        $thisSubKey.GetValue('DisplayVersion')
                                    }
                                    $UninstallString = try {
                                        $thisSubKey.GetValue('UninstallString').Trim()
                                    } 
                                    catch {
                                        $thisSubKey.GetValue('UninstallString')
                                    }
                                    $InstallLocation = try {
                                        $thisSubKey.GetValue('InstallLocation').Trim()
                                    } 
                                    catch {
                                        $thisSubKey.GetValue('InstallLocation')
                                    }
                                    $InstallSource = try {
                                        $thisSubKey.GetValue('InstallSource').Trim()
                                    } 
                                    catch {
                                        $thisSubKey.GetValue('InstallSource')
                                    }
                                    $HelpLink = try {
                                        $thisSubKey.GetValue('HelpLink').Trim()
                                    } 
                                    catch {
                                        $thisSubKey.GetValue('HelpLink')
                                    }
                                    $Software = [pscustomobject]@{
                                        ComputerName    = $Computer
                                        DisplayName     = $DisplayName
                                        Version         = $Version
                                        InstallDate     = $Date
                                        Publisher       = $Publisher
                                        UninstallString = $UninstallString
                                        InstallLocation = $InstallLocation
                                        InstallSource   = $InstallSource
                                        HelpLink        = $thisSubKey.GetValue('HelpLink')
                                        EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize') * 1024) / 1MB, 2))
                                        InventoryDate   = $Date
                                    }
                                    $Software.PSTypeNames.Insert(0, 'PSP.Inventory.Software')
                                    $Software
                                }
                            }
                            catch {
                                Write-Warning "$Key : $_"
                            }   
                        }
                    }
                    catch {}   
                    $reg.Close() 
                }                  
            }
            else {
                Write-Error "$($Computer): unable to reach remote system!"
            }
        } 
    } 
} 
