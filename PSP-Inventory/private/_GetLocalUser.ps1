function _GetLocalUser {
    [cmdletbinding()]
    Param(
        [System.Management.Automation.Runspaces.PSSession]$PSSession
    )
    $Computer = $PSSession.ComputerName
    Write-Verbose "[$Computer] - Local User information"
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
}