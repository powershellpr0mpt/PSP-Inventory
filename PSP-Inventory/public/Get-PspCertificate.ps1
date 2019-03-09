Function Get-PspCertificate {
    [OutputType('PSP.Inventory.Certificate')]
    [Cmdletbinding(DefaultParameterSetName = 'Computer')]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Computer')]
        [ValidateNotNullorEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(ParameterSetName = 'Computer')]
        [PSCredential]$Credential,
        [Parameter(Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Session')]
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
                            PSTypeName = 'PSP.Inventory.Certificate'
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
                            InventoryDate = $InventoryDate
                        }
                    }
                } catch {
                        Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
                }
            }
        }
        foreach ($Session in $PSSession) {
            _GetCertInfo -PSSession $Session -StoreName $StoreName.ToString() -StoreLocation $StoreLocation.ToString()
        }
    }
}