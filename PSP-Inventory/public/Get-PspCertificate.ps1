Function Get-PspCertificate {
    <#
    .SYNOPSIS
    Get certification information for local or remote machines.

    .DESCRIPTION
    Get certification information for local or remote machines.
    Allows you to specify exactly which store you want to query.

    .PARAMETER ComputerName
    Provide the computername(s) to query.
    Using this parameter will create a temporary PSSession to obtain the information if available.
    If PowerShell remoting is not available, it will try and obtain the information through .NET.
    Default value is the local machine.

    .PARAMETER Credential
    Provide the credentials for the PowerShell remoting session to be created if current credentials are not sufficient.

    .PARAMETER PSSession
    Provide the PowerShell remoting session object to query if this is already available.
    Once the information has been gathered, the PowerShell session will remain available for further use.

    .PARAMETER StoreName
    Provide the StoreName to query
    Default value is the 'My' name

    .PARAMETER StoreLocation
    Provide the Certification store to query.
    Default value is the 'LocalMachine' store.

    .EXAMPLE
    PS C:\> Get-PspCertificate -ComputerName 'CONTOSO-SRV01'

    ComputerName    NotAfter            NotBefore           Subject                                                                          Thumbprint
    ------------    --------            ---------           -------                                                                          ----------
    CONTOSO-SRV01 9-9-2038 11:31:44   14-9-2018 11:31:44  CN=127.0.0.1                                                                     BA03E7647E61F2562A...
    CONTOSO-SRV01 23-11-2038 15:49:59 28-11-2018 15:49:59 CN=127.0.0.1                                                                     B9EDE957C09C462C68...
    CONTOSO-SRV01 12-3-2019 22:46:38  11-3-2019 22:41:38  CN=1d55f591-ad2c-43dd-abef-ff7e3e6a6f51, DC=dbddf572-f118-4b32-8139-dc6cd6bae4f8 69CD7B0FB0D244E4FA...
    CONTOSO-SRV01 3-12-2028 14:02:53  3-12-2018 13:32:53  CN=1d55f591-ad3c-43dd-abef-ff7e3e6a6f51                                          28165F4FDE3E0FAA24...
    CONTOSO-SRV01 3-12-2019 14:02:58  3-12-2018 13:52:58  CN=a8b24bcf-6f4c-4b8c-907e-37acb9b15d3b                                          0F674857164B0D4197...

    Gets the certification information for CONTOSO-SRV01 using the 'My' storename and 'LocalMachine' storelocation, displaying the default properties.

    .NOTES
    Name: Get-PspCertificate.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 22-02-2019
    DateModified: 11-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.Certificate')]
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
        [System.Management.Automation.Runspaces.PSSession[]]$PSSession,
        [Parameter(Position = 1)]
        [System.Security.Cryptography.X509Certificates.StoreName]$StoreName = 'My',
        [Parameter(Position = 2)]
        [System.Security.Cryptography.X509Certificates.StoreLocation]$StoreLocation = 'LocalMachine'
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Computer') {
            foreach ($Computer in $ComputerName) {
                $Computer = $Computer.toUpper()
                try {
                    Write-Verbose  ("Connecting to {0}\{1}" -f "\\$($Computer)\$($StoreName)", $StoreLocation)
                    $CertStore = New-Object  System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList "\\$($Computer)\$($StoreName)", $StoreLocation
                    $CertStore.Open('ReadOnly')
                    $Certificates = $CertStore.Certificates
                    foreach ($Certificate in $Certificates) {
                        [PSCustomObject]@{
                            PSTypeName    = 'PSP.Inventory.Certificate'
                            ComputerName  = $Computer
                            StoreName     = $StoreName
                            StoreLocation = $StoreLocation
                            FriendlyName  = $Certificate.FriendlyName
                            Thumbprint    = $Certificate.Thumbprint
                            Issuer        = $Certificate.Issuer
                            NotBefore     = $Certificate.NotBefore
                            NotAfter      = $Certificate.NotAfter
                            Subject       = $Certificate.Subject
                            HasPrivateKey = $Certificate.HasPrivateKey
                            Certificate   = $Certificate
                            InventoryDate = (Get-Date)
                        }
                    }
                }
                catch {
                    Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                }
            }
        }
        foreach ($Session in $PSSession) {
            _GetCertInfo -PSSession $Session -StoreName $StoreName.ToString() -StoreLocation $StoreLocation.ToString()
        }
    }
}