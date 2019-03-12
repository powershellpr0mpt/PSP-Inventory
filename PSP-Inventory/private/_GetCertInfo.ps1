function _GetCertInfo {
    [cmdletbinding()]
    Param(
        [System.Management.Automation.Runspaces.PSSession]$PSSession,
        [string]$StoreName,
        [string]$StoreLocation
    )
    Write-Verbose "[$($PSSession.ComputerName)] - Gathering Certificate information"
    $Certificates = Invoke-Command -Session $PSSession -ScriptBlock {
        Get-ChildItem "Cert:\$Using:StoreLocation\$Using:StoreName"
    }
    foreach ($Certificate in $Certificates) {
        [PSCustomObject]@{
            PSTypeName    = 'PSP.Inventory.Certificate'
            ComputerName  = $env:COMPUTERNAME.ToUpper()
            StoreName     = $StoreName
            StoreLocation = $StoreLocation
            FriendlyName  = $Certificate.FriendlyName
            Thumbprint    = $Certificate.Thumbprint
            Issuer        = $Certificate.Issuer
            NotBefore     = $Certificate.NotBefore
            NotAfter      = $Certificate.NotAfter
            Subject       = $Certificate.Subject
            HasPrivateKey = $Certificate.HasPrivateKey
            InventoryDate = (Get-Date)
        }
    }
}