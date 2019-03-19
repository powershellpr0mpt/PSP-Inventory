Function Get-PspLocalUser {
    <#
    .SYNOPSIS
    Get all local users for local or remote machines.

    .DESCRIPTION
    Get all local users for local or remote machines.
    Provides extra information about the actual user based on the user's settings.

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
    PS C:\> Get-PspLocalUser -ComputerName CONTOSO-SRV01

    ComputerName   UserName       LastLogin
    ------------   --------       ---------
    CONTOSO-SRV01  Administrator  3/12/2019 8:47:17 AM
    CONTOSO-SRV01  DefaultAccount
    CONTOSO-SRV01  Guest

    Gets the local users for CONTOSO-SRV01, displaying the default properties.

    .NOTES
    Name: Get-PspLocalUser.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-02-2019
    DateModified: 12-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.LocalUser')]
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
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Computer') {
            foreach ($Computer in $ComputerName) {
                $Computer = $Computer.toUpper()
                try {
                    $DomainRole = (Get-WmiObject -ComputerName $Computer -Class Win32_ComputerSystem -Property DomainRole -ErrorAction Stop).DomainRole
                    if (!($DomainRole -match "4|5")){
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
                    } else {
                        Write-Warning "[$Computer] - is a Domain Controller, no local users available"
                    }
                }
                catch {
                    Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                }
            }
        }
        foreach ($Session in $PSSession) {
            _GetLocalUser -PSSession $Session
        }
    }
}