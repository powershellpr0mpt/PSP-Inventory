Function Get-LocalGroup {
    [Cmdletbinding()] 
    Param( 
        [Parameter()] 
        [String[]]$Computername = $Computername
    )
    Function ConvertTo-SID {
        Param([byte[]]$BinarySID)
        (New-Object System.Security.Principal.SecurityIdentifier($BinarySID,0)).Value
    }
    Function Get-LocalGroupMember {
        Param ($Group)
        $group.Invoke('members') | ForEach {
            $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        }
    }
    $adsi = [ADSI]"WinNT://$Computername"
    $adsi.Children | where {$_.SchemaClassName -eq 'group'} | 
    Select @{L='Computername';E={$Computername}},@{L='Name';E={$_.Name[0]}},
    @{L='Members';E={((Get-LocalGroupMember -Group $_)) -join '; '}},
    @{L='SID';E={(ConvertTo-SID -BinarySID $_.ObjectSID[0])}},
    @{L='GroupType';E={$GroupType[[int]$_.GroupType[0]]}}
}