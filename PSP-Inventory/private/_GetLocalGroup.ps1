function _GetLocalGroup {
    [cmdletbinding()]
    Param(
        [System.Management.Automation.Runspaces.PSSession]$PSSession
    )
    Invoke-Command -Session $PSSession -ScriptBlock {
        $Computer = $env:COMPUTERNAME.ToUpper()
        Write-Verbose "[$Computer] - Gathering Local Group information"
        Function ConvertTo-SID{
            [cmdletbinding()]
            param(
                [byte[]]$BinarySID
            )
            (New-Object System.Security.Principal.SecurityIdentifier($BinarySID, 0)).Value
        }
        Function _GetLocalGroupMember {
            [cmdletbinding()]
            param (
                $Group
            )
            $Group.Invoke('Members') | ForEach-Object {
                $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
            }
        }
        $DomainRole = (Get-CimInstance -CimSession $CimSession -ClassName Win32_ComputerSystem -Property DomainRole).DomainRole
        if (!($DomainRole -match "4|5")){
            $GroupInfo = ([ADSI]"WinNT://$Computer").Children | Where-Object {$_.SchemaClassName -eq 'Group'}
            foreach ($Group in $GroupInfo) {
                [PSCustomObject]@{
                    PSTypeName    = 'PSP.Inventory.LocalGroup'
                    ComputerName  = $Computer
                    GroupName     = $Group.Name[0]
                    Members       = ((_GetLocalGroupMember -Group $Group) -join '; ')
                    GroupType     = $GroupType[[int]$Group.GroupType[0]]
                    SID           = (ConvertTo-SID -BinarySID $Group.ObjectSid[0])
                    InventoryDate = (Get-Date)
                }
            }
        }else {
            Write-Warning "[$Computer] - is a Domain Controller, no local groups available"
        }
    }
}