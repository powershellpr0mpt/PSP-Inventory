function Get-PspSysInfo {
    <#
    .SYNOPSIS
    Get System information for local or remote machines.

    .DESCRIPTION
    Get System information for local or remote machines.
    Will query default information about the actual system, such as CPU & Memory and if it's virtual or physical
    Tries to create a CIM session to obtain information, but will revert to DCOM if CIM is not available.
    If there's already a CIM session available, this can also be used to obtain the data.

    .PARAMETER ComputerName
    Provide the computername(s) to query.
    This will create a new CIM session which will be removed once the information has been gathered.
    Default value is the local machine.

    .PARAMETER Credential
    Provide the credentials for the CIM session to be created if current credentials are not sufficient.

    .PARAMETER CimSession
    Provide the CIM session object to query if this is already available.
    Once the information has been gathered, the CIM session will remain available for further use.

    .EXAMPLE
    PS C:\> Get-PspSysInfo -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

    ComputerName   Model           SerialNumber                     CPUCores CPULogical MemoryGB
    ------------   -----           ------------                     -------- ---------- --------
    CONTOSO-SRV01  Virtual Machine 6656-6324-2091-0011-9109-1646-89 1        2          0
    CONTOSO-SRV02  Virtual Machine 8945-5393-3426-8378-9495-3257-53 1        2          1

    Gets the installed server roles for CONTOSO-SRV01 and CONTOSO-SRV02, displaying the default properties.

    .NOTES
    Name: Get-PspSysInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 24-02-2019
    DateModified: 12-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.SystemInfo')]
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
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Computer') {
            $CimSession = @()
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
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $CimSession.count -gt 0) {
            Remove-Cimsession $CimSession
        }
    }
}