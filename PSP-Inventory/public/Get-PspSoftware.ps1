Function Get-PspSoftware {
    <#
    .SYNOPSIS
    Get the installed software for local or remote machines.

    .DESCRIPTION
    Get the installed software for local or remote machines.
    Will try and access the required data through a PowerShell remoting session, but in case this fails reverts to RemoteRegistry.
    This does however require RemoteRegistry to be enabled on the machine.
    Will look for both x86 and x64 installed paths.

    .PARAMETER ComputerName
    Provide the computername(s) to query.
    Using this parameter will create a temporary PSSession to obtain the information if available.
    If PowerShell remoting is not available, it will try and obtain the information through ADSI.
    Default value is the local machine.

    .PARAMETER Credential
    Provide the credentials for the PowerShell remoting session to be created if current credentials are not sufficient.

    .PARAMETER PSSession
    Provide the PowerShell remoting session object to query if this is already available.
    Once the information has been gathered, the PowerShell session will remain available for further use.

    .EXAMPLE
    PS C:\> Get-PspSoftware -ComputerName CONTOSO-SRV01,CONTOSO-WEB01,CONTOSO-APP01

    ComputerName    : CONTOSO-SRV01
    DisplayName     : Google Chrome
    Version         : 72.0.3626.121
    InstallDate     : 3/11/2019 12:00:00 AM
    Publisher       : Google LLC
    UninstallString : MsiExec.exe /X{0C8D8E7A-485A-39D9-82C9-DF0955BE2A57}
    InstallLocation :
    InstallSource   : C:\Users\Administrator\AppData\Local\Temp\1\Temp1_GoogleChromeEnterpriseBundle64.zip\Installers\
    HelpLink        :
    EstimatedSizeMB : 54.5
    InventoryDate   : 3/12/2019 10:25:45 AM

    ComputerName    : CONTOSO-SRV01
    DisplayName     : Google Update Helper
    Version         : 1.3.33.23
    InstallDate     : 3/11/2019 12:00:00 AM
    Publisher       : Google Inc.
    UninstallString : MsiExec.exe /I{60EC980A-BDA2-4CB6-A427-B07A5498B4CA}
    InstallLocation :
    InstallSource   : C:\Program Files (x86)\Google\Update\1.3.33.23\
    HelpLink        :
    EstimatedSizeMB : 0.04
    InventoryDate   : 3/12/2019 10:25:45 AM

    ComputerName    : CONTOSO-WEB01
    DisplayName     : VLC media player
    Version         : 3.0.6
    InstallDate     :
    Publisher       : VideoLAN
    UninstallString : "C:\Program Files (x86)\VideoLAN\VLC\uninstall.exe"
    InstallLocation : C:\Program Files (x86)\VideoLAN\VLC
    InstallSource   :
    HelpLink        :
    EstimatedSize   : 0
    InventoryDate   : 3/12/2019 10:25:45 AM

    ComputerName    : CONTOSO-APP01
    DisplayName     : Notepad++ (32-bit x86)
    Version         : 7.6.4
    InstallDate     :
    Publisher       : Notepad++ Team
    UninstallString : C:\Program Files (x86)\Notepad++\uninstall.exe
    InstallLocation :
    InstallSource   :
    HelpLink        :
    EstimatedSize   : 4.35
    InventoryDate   : 3/12/2019 10:25:45 AM

    Gets the installed software for CONTOSO-SRV01, CONTOSO-WEB01 and CONTOSO-APP01.


    .NOTES
    Name: Get-PspSoftware.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 21-02-2019
    DateModified: 12-03-2019
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.Software')]
    [Cmdletbinding(DefaultParameterSetName = 'Computer')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
        [ValidateNotNullorEmpty()]
        [Alias('CN')]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(ParameterSetName = 'Computer')]
        [PSCredential]$Credential,
        [Parameter(Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Session')]
        [Alias('Session')]
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