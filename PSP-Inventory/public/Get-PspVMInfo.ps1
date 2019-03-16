Function Get-PspVMInfo {
    <#
    .SYNOPSIS
    Gets virtualization information for local or remote machines.

    .DESCRIPTION
    Gets virtualization information for local or remote machines.
    Will try and access the required data through a PowerShell remoting session, but in case this fails reverts to RemoteRegistry.
    This does however require RemoteRegistry to be enabled on the machine.

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
    PS C:\> Get-PspVMInfo -ComputerName CONTOSO-SRV01,CONTOSO-WEB01,CONTOSO-APP01 | Format-List

    ComputerName                 : CONTOSO-SRV01
    HVIntegrationServicesRunning : True
    HVHostName                   : hv01.contoso.com
    HVVMName                     : HV-VM01
    VMWareToolsRunning           : False
    InventoryDate                : 3/16/2019 1:44:10 AM

    ComputerName                 : CONTOSO-WEB01
    HVIntegrationServicesRunning : True
    HVHostName                   : hv01.contoso.com
    HVVMName                     : HV-VM02
    VMWareToolsRunning           : False
    InventoryDate                : 3/16/2019 1:44:10 AM

    ComputerName                 : CONTOSO-APP01
    HVIntegrationServicesRunning : True
    HVHostName                   : hv02.contoso.com
    HVVMName                     : HV-VM12
    VMWareToolsRunning           : False
    InventoryDate                : 3/16/2019 1:44:10 AM

    Gets the virtualization information for CONTOSO-SRV01, CONTOSO-WEB01 and CONTOSO-APP01.

    .NOTES
    Name: Get-PspVMInfo.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 16-03-2019
    DateModified: 16-03-2019
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.VMInfo')]
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
                    Write-Warning "[$Computer] - Unable to open PS Remoting session. Reverting to Remote Registry"
                    try {
                        $HVService = Get-Service -ComputerName $Computer -DisplayName '*Hyper-V*' -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq 'Running'}
                        $VMService = Get-Service -ComputerName $Computer -Name VMTools -ErrorAction SilentlyContinue
                        $HVHostName = $null
                        $HVVMName = $null
                        $Path = @("SOFTWARE\\Microsoft\\Virtual Machine\\Guest\\Parameters")
                        Write-Verbose "[$Computer] - Checking Registry Path: $Path"
                        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer, 'Registry64')
                        try {
                            Write-Verbose "[$Computer] - Checking Registry Key: $Path"
                            $regkey = $reg.OpenSubKey($Path)
                            try {
                                $HVHostName = $regkey.getValue("PhysicalHostNameFullyQualified")
                                $HVVMName = $regkey.getValue("VirtualMachineName")
                            }
                            catch {
                                Write-Warning "[$Computer] - Unable to access key: $Path "
                            }
                        }
                        catch {}
                        $reg.Close()
                        
                        [PSCustomObject]@{
                            PSTypeName                   = 'PSP.Inventory.VMInfo'
                            ComputerName                 = $Computer
                            HVIntegrationServicesRunning = if ($HVService) {$true}else {$false}
                            HVHostName                   = $HVHostName
                            HVVMName                     = $HVVMName
                            VMWareToolsRunning           = if ($VMService) {$true}else {$false}
                            InventoryDate                = (Get-Date)
                        }
                
                    }
                    catch {
                        Write-Error "[$Computer] - Unable to open Remote Registry"
                        Continue
                    }

                }
                catch {
                    Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                }
            }
        }
        foreach ($Session in $PSSession) {
            _GetVMInfo -PSSession $Session
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'Computer' -AND $PSSession.count -gt 0) {
            Remove-PSSession $PSSession
        }
    }
}