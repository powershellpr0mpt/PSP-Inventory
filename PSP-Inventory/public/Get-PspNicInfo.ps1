function Get-PspNicInfo {
    <#
    .SYNOPSIS
    Get Network adapter information for local or remote machines.

    .DESCRIPTION
    Get Network adapter information for local or remote machines.
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

    .PARAMETER Drivers
    Switch parameter.
    If activated will try and obtain the driver information for the adapter.
    Do note that this will substantially increase time required.

    .EXAMPLE
    PS C:\> Get-PspNicInfo -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

    ComputerName   Alias    Index IPAddress                                 Status
    ------------   -----    ----- ---------                                 ------
    CONTOSO-SRV01  Ethernet 1     {192.168.14.6, fe80::a438:7d49:4f12:b000} Connected
    CONTOSO-SRV02  Ethernet 1     {192.168.14.7, fe80::31f3:d92a:a4b9:e3a8} Connected

    Gets network adapter information for both CONTOSO-SRV01 and CONTOSO-SRV02, displaying the default properties.

    .NOTES
    Name: Get-PspNicInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-12-2018
    DateModified: 12-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.NIC')]
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
        [Microsoft.Management.Infrastructure.CimSession[]]$CimSession,
        [Switch]$Drivers
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
            $NicProperties = @{
                CimSession = $Session
                Drivers    = $false
            }
            if ($Drivers) {
                $NicProperties.Drivers = $true
            }
            _GetNicInfo @NicProperties
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $CimSession.count -gt 0) {
            Remove-Cimsession $CimSession
        }
    }
}