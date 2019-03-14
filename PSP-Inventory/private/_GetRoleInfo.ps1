function _GetRoleInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$Cimsession
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering Server Role information"
    #Check if Workstation - https://docs.microsoft.com/en-us/windows/desktop/CIMWin32Prov/win32-operatingsystem#properties
    $ProductType = (Get-CimInstance -CimSession $CimSession -ClassName Win32_OperatingSystem -Property ProductType).ProductType
    if (!($ProductType -eq 1)){
        Get-CimInstance -CimSession $CimSession -ClassName Win32_ServerFeature -Property Id, Name -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                PSTypeName    = 'PSP.Inventory.ServerRole'
                ComputerName  = $CimSession.ComputerName
                RoleId        = $_.Id
                Name          = $_.Name
                InventoryDate = (Get-Date)
            }
        }
    }else{
        Write-Warning "[$($CimSession.ComputerName)] - is a workstation, no roles available"
    }
}