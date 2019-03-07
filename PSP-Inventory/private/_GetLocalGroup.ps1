function _GetLocalGroup {
    [cmdletbinding()]
    Param(
        [System.Management.Automation.Runspaces.PSSession]$PSSession
    )
    $Computer = $PSSession.ComputerName
    Write-Verbose "[$Computer] - Local Group information"
    $GroupInfo = ([ADSI]"WinNT://$Computer").Children | Where-Object {$_.SchemaClassName -eq 'Group'}
    foreach ($Group in $GroupInfo) {
        [PSCustomObject]@{
            PSTypeName    = 'PSP.Inventory.LocalGroup'
            ComputerName  = $Computer
            GroupName     = $Group.Name[0]
            Members       = ((_GetLocalGroupMember -Group $Group) -join '; ')
            GroupType     = $GroupType[[int]$Group.GroupType[0]]
            SID           = (ConvertTo-SID -BinarySID $Group.ObjectSid[0])
            InventoryDate = $InventoryDate
        }
    }   
}