function Get-PspDiskInfo {
    <#
    .SYNOPSIS
    Get Disk information for local or remote machines.

    .DESCRIPTION
    Get Disk information for local or remote machines.
    Will query Disks, partitions and volumes to obtain as much information as possible.
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
    PS C:\> Get-PspDiskInfo -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'

    ComputerName DriveLetter FileSystem TotalSizeGB FreeSizeGB UsedSizeGB
    ------------ ----------- ---------- ----------- ---------- ----------
    CONTOSO-SRV01  C:          NTFS       50          38.81      11.19
    CONTOSO-WEB01  C:          NTFS       49.36       41.81      7.55

    Gets the disk information for CONTOSO-SRV01 and CONTOSO-WEB01 by creating a temporary CIM session, displaying the default properties.

    .EXAMPLE
    PS C:\> $CimSession = New-CimSession -ComputerName 'CONTOSO-SRV02'
    PS C:\> Get-PspDiskInfo -CimSession $CimSession

    ComputerName DriveLetter FileSystem TotalSizeGB FreeSizeGB UsedSizeGB
    ------------ ----------- ---------- ----------- ---------- ----------
    CONTOSO-SRV02  C:          NTFS       50          38.81      11.19

    Creates a CIM session for CONTOSO-SRV02 and uses this session to get the Disk information from this machine.
    The session can then be re-used for other cmdlets in order to get more information.
    Re-using the session provides performance benefits.

    .NOTES
    Name: Get-PspDiskInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 22-12-2018
    DateModified: 11-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.Disk')]
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
            _GetDiskInfo -Cimsession $Session
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $CimSession.count -gt 0) {
            Remove-Cimsession $CimSession
        }
    }
}