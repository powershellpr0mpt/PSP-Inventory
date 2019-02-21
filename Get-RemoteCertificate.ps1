Function Get-RemoteCertificate {
    [OutputType('PSP.Inventory.Certificate')]
    [cmdletbinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Position = 1)]
        [System.Security.Cryptography.X509Certificates.StoreName]$StoreName = 'My',
        [Parameter(Position = 2)]
        [System.Security.Cryptography.X509Certificates.StoreLocation]$StoreLocation = 'LocalMachine'
    )
    Process {
        ForEach ($Computer in  $Computername) {
            Try {
                Write-Verbose  ("Connecting to {0}\{1}" -f "\\$($Computername)\$($StoreName)", $StoreLocation)
                $CertStore = New-Object  System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList "\\$($Computername)\$($StoreName)", $StoreLocation
                $CertStore.Open('ReadOnly')
                $Certificates = $CertStore.Certificates  
                foreach ($Certificate in $Certificates){
                    $Cert = [pscustomobject]@{
                        ComputerName = $Computer
                        StoreName = $StoreName
                        StoreLocation = $StoreLocation
                        FriendlyName = $Certificate.FriendlyName
                        Thumbprint = $Certificate.Thumbprint
                        Issuer = $Certificate.Issuer
                        NotBefore = $Certificate.NotBefore
                        NotAfter = $Certificate.NotAfter
                        Certificate = $Certificate
                    }
                    $Cert.PSTypeNames.Insert(0,'PSP.Inventory.Certificate')
                    $Cert
                }
            }
            Catch {
                Write-Warning  "Unable to get certification information from $($Computer): $_"
            }
        }
    }
} 