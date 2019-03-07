function Get-PspSysInfo {
    [OutputType('PSP.Inventory.SystemInfo')]
    [Cmdletbinding(DefaultParameterSetName = 'Computer')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
        [ValidateNotNullorEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(ParameterSetName = 'Computer')]
        [PSCredential]$Credential,
        [Parameter(Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Session')]
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )
    begin {
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Computer') {
            #initialize an array to hold sessions
            $CimSession = @()
            #define a hashtable of parametes to splat to New-Cimsession
            $CimProperties = @{
                ErrorAction  = 'Stop'
                Computername = ''
            }

            if ($credential.Username) {
                $CimProperties.Add('Credential', $Credential)
            }
            foreach ($Computer in $ComputerName) {
                $Computer = $Computer.toUpper()
`               $CimProperties.ComputerName = $Computer
                Try {
                    $CimSession += New-CimSession @CimProperties
                }
                catch [Microsoft.Management.Infrastructure.CimException] {
                    Write-Warning "[$Computer] - does not have CIM access, reverting to DCOM instead"
                    $CimOptions = New-CimSessionOption -Protocol DCOM
                    $CimProperties.Add('SessionOption', $CimOptions) | Out-Null
                    try {
                        $CimSession += New-CimSession @CimProperties
                    }
                    catch {
                        Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                    }
                    Finally {
                        #remove CimOptions from PSBoundParameters
                        $CimProperties.Remove('SessionOption') | Out-Null
                    }
                }
                Catch {
                    Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                }
            }
        }
        foreach ($Session in $CimSession) {
            _GetSysInfo -Cimsession $Session
        }
    }
    End {
        #remove cim sessions created for computers
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $CimSession.count -gt 0) {
            Remove-Cimsession $CimSession
        }
    }
}