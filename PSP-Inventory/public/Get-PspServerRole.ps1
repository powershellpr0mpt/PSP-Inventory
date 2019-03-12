function Get-PspServerRole {
    <#
    .SYNOPSIS
    Get Server Roles for local or remote machines.

    .DESCRIPTION
    Get Server Roles for local or remote machines.
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
    PS C:\> Get-PspServerRole -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

    ComputerName   RoleId Name                  InventoryDate
    ------------   ------ ----                  -------------
    CONTOSO-SRV01   481 File and Storage Services       3/12/2019 10:18:40 AM
    CONTOSO-SRV01   487 SMB 1.0/CIFS File Sharing Support 3/12/2019 10:18:40 AM
    CONTOSO-SRV01   418 .NET Framework 4.6          3/12/2019 10:18:40 AM
    CONTOSO-SRV01   466 .NET Framework 4.6 Features     3/12/2019 10:18:40 AM
    CONTOSO-SRV01   420 WCF Services              3/12/2019 10:18:40 AM
    CONTOSO-SRV01   425 TCP Port Sharing            3/12/2019 10:18:40 AM
    CONTOSO-SRV01   412 Windows PowerShell 5.1        3/12/2019 10:18:40 AM
    CONTOSO-SRV01   417 Windows PowerShell          3/12/2019 10:18:40 AM
    CONTOSO-SRV01   482 Storage Services            3/12/2019 10:18:40 AM
    CONTOSO-SRV01   1003 Windows Defender            3/12/2019 10:18:40 AM
    CONTOSO-SRV01   1020 Windows Defender Features       3/12/2019 10:18:40 AM
    CONTOSO-SRV01   340 WoW64 Support             3/12/2019 10:18:40 AM
    CONTOSO-SRV02   481 File and Storage Services       3/12/2019 10:18:40 AM
    CONTOSO-SRV02   418 .NET Framework 4.7          3/12/2019 10:18:41 AM
    CONTOSO-SRV02   466 .NET Framework 4.7 Features     3/12/2019 10:18:41 AM
    CONTOSO-SRV02   420 WCF Services              3/12/2019 10:18:41 AM
    CONTOSO-SRV02   425 TCP Port Sharing            3/12/2019 10:18:41 AM
    CONTOSO-SRV02   412 Windows PowerShell 5.1        3/12/2019 10:18:41 AM
    CONTOSO-SRV02   417 Windows PowerShell          3/12/2019 10:18:41 AM
    CONTOSO-SRV02   482 Storage Services            3/12/2019 10:18:41 AM
    CONTOSO-SRV02   1043 System Data Archiver          3/12/2019 10:18:41 AM
    CONTOSO-SRV02   1003 Windows Defender Antivirus      3/12/2019 10:18:41 AM
    CONTOSO-SRV02   340 WoW64 Support             3/12/2019 10:18:41 AM

    Gets the installed server roles for CONTOSO-SRV01 and CONTOSO-SRV02.

    .NOTES
    Name: Get-PspServerRole.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 22-12-2018
    DateModified: 12-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.ServerRole')]
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
            _GetRoleInfo -Cimsession $Session
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $CimSession.count -gt 0) {
            Remove-Cimsession $CimSession
        }
    }
}