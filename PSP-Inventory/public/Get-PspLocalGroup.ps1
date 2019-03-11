Function Get-PspLocalGroup {
    [OutputType('PSP.Inventory.LocalGroup')]
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
        $GroupType = @{
            0x2        = 'Global Group'
            0x4        = 'Local Group'
            0x8        = 'Universal Group'
            2147483648 = 'Security Enabled'
        }
    }
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
                    Write-Warning "[$Computer] - Unable to open PS Remoting session. Reverting to [ADSI]"
                    try {
                        $GroupInfo = ([ADSI]"WinNT://$Computer").Children | Where-Object {$_.SchemaClassName -eq 'Group'}
                        foreach ($Group in $GroupInfo) {
                            [PSCustomObject]@{
                                PSTypeName    = 'PSP.Inventory.LocalGroup'
                                ComputerName  = $Computer
                                GroupName     = $Group.Name[0]
                                Members       = ((_GetLocalGroupMember -Group $Group) -join '; ')
                                GroupType     = $GroupType[[int]$Group.GroupType[0]]
                                SID           = (ConvertTo-SID -BinarySID $Group.ObjectSid[0])
                                InventoryDate = $InventoryDate
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
            _GetLocalGroup -PSSession $Session
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $PSSession.count -gt 0) {
            Remove-PSSession $PSSession
        }
    }
}