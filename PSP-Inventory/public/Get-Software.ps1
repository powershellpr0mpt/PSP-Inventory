Function Get-Software {
    <#
    .SYNOPSIS
    Get the installed software for local or remote machines

    .DESCRIPTION
    Get the installed software for local or remote machines.
    Requires the RemoteRegistry to be enabled on the machine.
    Will look for both x86 and x64 installed paths.

    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine

    .EXAMPLE
    Get-SecurityUpdate -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'

    Description
    -----------
    Gets the software information for both CONTOSO-SRV01 and CONTOSO-WEB01

    .NOTES
    Name: Get-Software.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 21-02-2019
    DateModified: 27-02-2019
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.Software')]
    [Cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] 
        [String[]]$ComputerName = $env:COMPUTERNAME
    )         
    Begin {
        $Date = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    Process {     
        foreach ($Computer in $Computername) {
            $Computer = $Computer.ToUpper()
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                $Paths = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
                foreach ($Path in $Paths) { 
                    Write-Verbose "Checking Path: $Path"
                    try { 
                        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer, 'Registry64')
                    }
                    catch { 
                        Write-Error $_ 
                        Continue 
                    } 
                    try {
                        $regkey = $reg.OpenSubKey($Path)  
                        $subkeys = $regkey.GetSubKeyNames()      
                        foreach ($key in $subkeys) {   
                            Write-Verbose "Key: $Key"
                            $thisKey = $Path + "\\" + $key 
                            try {  
                                $thisSubKey = $reg.OpenSubKey($thisKey)   
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
                                    $Software = [PSCustomObject]@{
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
