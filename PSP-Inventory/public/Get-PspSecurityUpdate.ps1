function Get-PspSecurityUpdate {
    <#
    .SYNOPSIS
    Get all the security update information for local or remote machines.

    .DESCRIPTION
    Get all the security update information for local or remote machines.
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
    PS C:\> Get-PspSecurityUpdate -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

    ComputerName   Type            KBFile    InstallDate
    ------------   ----            ------    -----------
    CONTOSO-SRV01  Update          KB4049065 2/2/2018 12:00:00 AM
    CONTOSO-SRV01  Security Update KB4048953 2/2/2018 12:00:00 AM
    CONTOSO-SRV02  Update          KB4464455 10/29/2018 12:00:00 AM

    Gets the installed security updates for CONTOSO-SRV01 and CONTOSO-SRV02, displaying the default properties.

    .NOTES
    Name: Get-PspSecurityUpdate.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 21-02-2019
    DateModified: 12-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.SecurityUpdate')]
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
            _GetUpdateInfo -Cimsession $Session
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $CimSession.count -gt 0) {
            Remove-Cimsession $CimSession
        }
    }
}