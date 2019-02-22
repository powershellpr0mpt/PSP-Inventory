Function Get-LocalGroup {
    [OutputType('PSP.Inventory.LocalGroup')]
    [Cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        $GroupType = @{
            0x2        = 'Global Group'
            0x4        = 'Local Group'
            0x8        = 'Universal Group'
            2147483648 = 'Security Enabled'
        }
        $Date = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    process {
        foreach ($Computer in $ComputerName) {
            $GroupInfo = ([ADSI]"WinNT://$Computer").Children | Where-Object {$_.SchemaClassName -eq 'Group'}
            foreach ($Group in $GroupInfo) {
                $Grp = [PSCustomObject]@{
                    ComputerName  = $Computer
                    GroupName     = $Group.Name[0]
                    Members       = ((Get-LocalGroupMember -Group $Group) -join '; ')
                    GroupType     = $GroupType[[int]$Group.GroupType[0]]
                    SID           = (ConvertTo-SID -BinarySID $Group.ObjectSid[0])
                    InventoryDate = $Date
                }
                $Grp.PSTypeNames.Insert(0, 'PSP.Inventory.LocalGroup')
                $Grp
            }
        }
    }
}