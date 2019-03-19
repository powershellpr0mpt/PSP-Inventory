Function Get-PspLocalGroup {
    <#
    .SYNOPSIS
    Get all local groups for local or remote machines.

    .DESCRIPTION
    Get all local groups for local or remote machines.
    Provides extra information such as members.

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
    PS C:\> Get-PspLocalGroup -ComputerName CONTOSO-HV01

    ComputerName GroupName         GroupType
    ------------ ---------         ---------
    CONTOSO-HV01 Access Control Assistance Operators Local Group
    CONTOSO-HV01 Administrators       Local Group
    CONTOSO-HV01 Backup Operators     Local Group
    CONTOSO-HV01 Certificate Service DCOM Access  Local Group
    CONTOSO-HV01 Cryptographic Operators    Local Group
    CONTOSO-HV01 Distributed COM Users      Local Group
    CONTOSO-HV01 Event Log Readers       Local Group
    CONTOSO-HV01 Guests         Local Group
    CONTOSO-HV01 Hyper-V Administrators     Local Group
    CONTOSO-HV01 IIS_IUSRS         Local Group
    CONTOSO-HV01 Network Configuration Operators  Local Group
    CONTOSO-HV01 Performance Log Users      Local Group
    CONTOSO-HV01 Performance Monitor Users     Local Group
    CONTOSO-HV01 Power Users       Local Group
    CONTOSO-HV01 Print Operators      Local Group
    CONTOSO-HV01 RDS Endpoint Servers    Local Group
    CONTOSO-HV01 RDS Management Servers     Local Group
    CONTOSO-HV01 RDS Remote Access Servers     Local Group
    CONTOSO-HV01 Remote Desktop Users    Local Group
    CONTOSO-HV01 Remote Management Users    Local Group
    CONTOSO-HV01 Replicator        Local Group
    CONTOSO-HV01 Storage Replica Administrators   Local Group
    CONTOSO-HV01 System Managed Accounts Group    Local Group
    CONTOSO-HV01 Users          Local Group

    Gets all local groups for the machine CONTOSO-HV01, displaying the default properties.

    .EXAMPLE
    PS C:\> Get-PspLocalGroup -ComputerName CONTOSO-APP01 | Where-Object {$_.GroupName -eq 'Administrators'} | Select-Object ComputerName,GroupName,Members

    ComputerName  GroupName      Members
    ------------  ---------      -------
    CONTOSO-APP01 Administrators Administrator

    Shows you all the members of the Administrators group on CONTOSO-APP01.

    .NOTES
    Name: Get-PspLocalGroup.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-02-2019
    DateModified: 12-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.LocalGroup')]
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
                        $DomainRole = (Get-WmiObject -ComputerName $Computer -ClassName Win32_ComputerSystem -Property DomainRole -ErrorAction Stop).DomainRole                        if (!($DomainRole -match "4|5")){
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
                        } else {
                            Write-Warning "[$Computer] - is a Domain Controller, no local groups available"
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