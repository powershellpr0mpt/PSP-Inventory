Function Get-LocalUser {
    [OutputType('PSP.Inventory.LocalUser')]
    [Cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    process {
        foreach ($Computer in $Computername) {
            $UserInfo = ([ADSI]"WinNT://$Computer").Children | ? {$_.SchemaClassName -eq 'User'}
            foreach ($User in $UserInfo){
                $Usr = [pscustomobject]@{
                    ComputerName = $Computer
                    UserName = $User.Name[0]
                    Description = $User.Description[0]
                    LastLogin = if ($User.LastLogin[0] -is [datetime]){$User.LastLogin[0]}else{$null}
                    SID = (ConvertTo-SID -BinarySID $User.ObjectSid[0])
                    UserFlags = (Convert-UserFlag -UserFlag $User.UserFlags[0])
                }
                $Usr.PSTypeNames.Insert(0,'PSP.Inventory.LocalUser')
                $Usr
            }
        }
    }
}