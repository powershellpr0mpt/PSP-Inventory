function _GetRoleInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$Cimsession
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering Server Role information"
    Get-CimInstance -CimSession $CimSession -ClassName Win32_ServerFeature -Property Id, Name -ErrorAction Stop | ForEach-Object {
        [PSCustomObject]@{
            PSTypeName = 'PSP.Inventory.ServerRole'
            ComputerName  = $Cimsession.ComputerName
            ID            = $_.Id
            Name          = $_.Name
            InventoryDate = $InventoryDate
        }
    }
}