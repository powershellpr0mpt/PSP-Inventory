Function Get-LocalGroupMember {
    [cmdletbinding()]
    param (
        $Group
    )
    $Group.Invoke('Members') | ForEach-Object {
        $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }
}