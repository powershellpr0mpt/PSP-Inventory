Function Get-AdminShare {
    [cmdletbinding()]
    Param (
        $Computername = $Computername
    )
    $WMIParams = @{
        Computername = $Computername
        Class = 'Win32_Share'
        Property = 'Name', 'Path', 'Description', 'Type'
        ErrorAction = 'Stop'
        Filter = "Type='2147483651' OR Type='2147483646' OR Type='2147483647' OR Type='2147483648'"
    }
    Get-WmiObject @WMIParams | Select-Object Name, Path, Description, 
    @{L='Type';E={$ShareType[[int64]$_.Type]}}
}