Function Get-PspSoftware {
    [OutputType('PSP.Inventory.Software')]
    [Cmdletbinding(DefaultParameterSetName = 'Computer')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
        [ValidateNotNullorEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(ParameterSetName = 'Computer')]
        [PSCredential]$Credential,
        [Parameter(Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Session')]
        [System.Management.Automation.Runspaces.PSSession[]]$PSSession
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Computer') {
            $PSSession = @()
            $SessionProperties = @{
                ErrorAction  = 'Stop'
                Computername = ''
            }
            if ($Credential.Username) {
                $SessionProperties.Add('Credential', $Credential)
            }
            foreach ($Computer in $ComputerName) {
                $Computer = $Computer.toUpper()
`               $SessionProperties.ComputerName = $Computer
                Try {
                    $PSSession += New-PSSession @SessionProperties
                }
                catch [System.Management.Automation.Remoting.PSRemotingTransportException] {
                    Write-Warning "[$Computer] - Unable to open PS Remoting session. Reverting to Remote Registry"
                    try {
                        $Paths = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")
                        foreach ($Path in $Paths) {
                            Write-Verbose "[$Computer] - Checking Registry Path: $Path"
                            $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer, 'Registry64')
                            try {
                                $regkey = $reg.OpenSubKey($Path)
                                $subkeys = $regkey.GetSubKeyNames()
                                foreach ($key in $subkeys) {
                                    Write-Verbose "[$Computer] - Checking Registry Key: $Key"
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
                                            [PSCustomObject]@{
                                                PSTypeName      = 'PSP.Inventory.Software'
                                                ComputerName    = $Computer
                                                DisplayName     = $DisplayName
                                                Version         = $Version
                                                InstallDate     = $Date
                                                Publisher       = $Publisher
                                                UninstallString = $UninstallString
                                                InstallLocation = $InstallLocation
                                                InstallSource   = $InstallSource
                                                HelpLink        = $HelpLink
                                                EstimatedSizeMB = [math]::Round(($thisSubKey.GetValue('EstimatedSize') * 1024) / 1MB, 2)
                                                InventoryDate   = (Get-Date)
                                            }
                                        }
                                    }
                                    catch {
                                        Write-Warning "[$Computer] - Unable to access key: $Key "
                                    }
                                }
                            }
                            catch {}
                            $reg.Close()
                        }
                    }
                    catch {
                        Write-Error "[$Computer] - Unable to open Remote Registry"
                        Continue
                    }

                }
                catch {
                    Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                }
            }
        }
        foreach ($Session in $PSSession) {
            _GetSoftwareInfo -PSSession $Session
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $PSSession.count -gt 0) {
            Remove-PSSession $PSSession
        }
    }
}