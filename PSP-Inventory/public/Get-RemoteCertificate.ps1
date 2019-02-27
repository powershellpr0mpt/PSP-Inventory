Function Get-RemoteCertificate {
    <#
    .SYNOPSIS
    Get certification information for local or remote machines
    
    .DESCRIPTION
    Get certification information for local or remote machines.
    Allows you to specify exactly which store you want to query.
    
    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine
    
    .PARAMETER StoreName
    Provide the StoreName to query
    Default value is the 'My' name
    
    .PARAMETER StoreLocation
    Provide the Certification store to query
    Default value is the 'LocalMachine' store
    
    .EXAMPLE
    Get-LocalUser -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
    
    Description
    -----------
    Gets the certification information for both CONTOSO-SRV01 and CONTOSO-WEB01, both using the 'My' storename and 'LocalMachine' storelocation
    
    .NOTES
    Name: Get-RemoteCertificate.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 22-02-2019
    DateModified: 27-02-2019
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com
    #>
    
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
    begin {
        $Date = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    process {
        foreach ($Computer in  $ComputerName) {
            try {
                Write-Verbose  ("Connecting to {0}\{1}" -f "\\$($Computer)\$($StoreName)", $StoreLocation)
                $CertStore = New-Object  System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList "\\$($Computer)\$($StoreName)", $StoreLocation
                $CertStore.Open('ReadOnly')
                $Certificates = $CertStore.Certificates  
                foreach ($Certificate in $Certificates) {
                    $Cert = [pscustomobject]@{
                        ComputerName  = $Computer
                        StoreName     = $StoreName
                        StoreLocation = $StoreLocation
                        FriendlyName  = $Certificate.FriendlyName
                        Thumbprint    = $Certificate.Thumbprint
                        Issuer        = $Certificate.Issuer
                        NotBefore     = $Certificate.NotBefore
                        NotAfter      = $Certificate.NotAfter
                        Certificate   = $Certificate
                        InventoryDate = $Date
                    }
                    $Cert.PSTypeNames.Insert(0, 'PSP.Inventory.Certificate')
                    $Cert
                }
            }
            catch {
                Write-Warning  "Unable to get certification information from $($Computer): $_"
            }
        }
    }
} 