Function Get-PspLocalUser {
    [OutputType('PSP.Inventory.LocalUser')]
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
    begin {
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Computer') {
            #initialize an array to hold sessions
            $PSSession = @()
            #define a hashtable of parametes to splat to New-Cimsession
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
                    Write-Warning "[$Computer] - Unable to open PS Remoting session. Reverting to [ADSI]"
                    try {
                        $UserInfo = ([ADSI]"WinNT://$Computer").Children | Where-Object {$_.SchemaClassName -eq 'User'}
                        foreach ($User in $UserInfo) {
                            [PSCustomObject]@{
                                PSTypeName    = 'PSP.Inventory.LocalUser'
                                ComputerName  = $Computer
                                UserName      = $User.Name[0]
                                Description   = $User.Description[0]
                                LastLogin     = if ($User.LastLogin[0] -is [datetime]) {$User.LastLogin[0]}else {$null}
                                SID           = (ConvertTo-SID -BinarySID $User.ObjectSid[0])
                                UserFlags     = (Convert-UserFlag -UserFlag $User.UserFlags[0])
                                InventoryDate = (Get-Date)
                            }
                        }           
                    }
                    catch {
                        Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                    }
                }
                Catch {
                    Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                }
            }
        }
        foreach ($Session in $PSSession) {
            _GetLocalUser -PSSession $Session
        }
    }
    End {
        #remove cim sessions created for computers
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $PSSession.count -gt 0) {
            Remove-PSSession $PSSession
        }
    }
}