function Get-PspOSInfo {
    <#
    .SYNOPSIS
    Get Operating System information for local or remote machines.

    .DESCRIPTION
    Get Operating System information for local or remote machines.
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
    PS C:\> Get-PspOSInfo -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

    ComputerName   Caption                                Version    OSArchitecture LastReboot
    ------------   -------                                -------    -------------- ----------
    CONTOSO-SRV01  Microsoft Windows Server 2016 Standard 10.0.14393 64-bit         3/4/2019 1:41:07 PM
    CONTOSO-SRV02  Microsoft Windows Server 2019 Standard 10.0.17763 64-bit         3/4/2019 1:41:25 PM

    Gets Operating system information for CONTOSO-SRV01 and CONTOSO-SRV02, displaying the default properties.

    .EXAMPLE
    PS C:\> Get-PspOSInfo -ComputerName CONTOSO-WEB01 | Format-List

    ComputerName   : CONTOSO-WEB01
    Caption        : Microsoft Windows Server 2016 Standard
    Version        : 10.0.14393
    ServicePack    : 0.0
    ProductKey     :
    LastReboot     : 3/4/2019 1:41:07 PM
    OSArchitecture : 64-bit
    TimeZone       : (UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
    PageFile       :
    PageFileSizeGB : 0
    InventoryDate  : 3/12/2019 9:56:50 AM

    Gets the Operating system information for CONTOSO-WEB01 and shows all collected properties.

    .NOTES
    Name: Get-PspOSInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-02-2019
    DateModified: 12-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.OperatingSystemInfo')]
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
            _GetOSInfo -Cimsession $Session
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $CimSession.count -gt 0) {
            Remove-Cimsession $CimSession
        }
    }
}