function _GetLocalUser {
    [cmdletbinding()]
    Param(
        [System.Management.Automation.Runspaces.PSSession]$PSSession
    )
    Write-Verbose "[$Computer] - Gathering Local User information"
    Invoke-Command -Session $PSSession -ScriptBlock {
        Function ConvertTo-SID{
            [cmdletbinding()]
            param(
                [byte[]]$BinarySID
            )
            (New-Object System.Security.Principal.SecurityIdentifier($BinarySID, 0)).Value
        }
        Function Convert-UserFlag {
            [cmdletbinding()]
            param (
                $UserFlag
            )
            $List = New-Object System.Collections.ArrayList
            Switch ($UserFlag)
            {
                ($UserFlag -BOR 0x0001) {[void]$List.Add('SCRIPT')}
                ($UserFlag -BOR 0x0002) {[void]$List.Add('ACCOUNTDISABLED')}
                ($UserFlag -BOR 0x0008) {[void]$List.Add('HOMEDIR_REQUIRED')}
                ($UserFlag -BOR 0x0010) {[void]$List.Add('LOCKOUT')}
                ($UserFlag -BOR 0x0020) {[void]$List.Add('PASSWD_NOTREQD')}
                ($UserFlag -BOR 0x0040) {[void]$List.Add('PASSWD_CANT_CHANGE')}
                ($UserFlag -BOR 0x0080) {[void]$List.Add('ENCRYPTED_TEXT_PWD_ALLOWED')}
                ($UserFlag -BOR 0x0100) {[void]$List.Add('TEMP_DUPLICATE_ACCOUNT')}
                ($UserFlag -BOR 0x0200) {[void]$List.Add('NORMAL_ACCOUNT')}
                ($UserFlag -BOR 0x0800) {[void]$List.Add('INTERDOMAIN_TRUST_ACCOUNT')}
                ($UserFlag -BOR 0x1000) {[void]$List.Add('WORKSTATION_TRUST_ACCOUNT')}
                ($UserFlag -BOR 0x2000) {[void]$List.Add('SERVER_TRUST_ACCOUNT')}
                ($UserFlag -BOR 0x10000) {[void]$List.Add('DONT_EXPIRE_PASSWORD')}
                ($UserFlag -BOR 0x20000) {[void]$List.Add('MNS_LOGON_ACCOUNT')}
                ($UserFlag -BOR 0x40000) {[void]$List.Add('SMARTCARD_REQUIRED')}
                ($UserFlag -BOR 0x80000) {[void]$List.Add('TRUSTED_FOR_DELEGATION')}
                ($UserFlag -BOR 0x100000) {[void]$List.Add('NOT_DELEGATED')}
                ($UserFlag -BOR 0x200000) {[void]$List.Add('USE_DES_KEY_ONLY')}
                ($UserFlag -BOR 0x400000) {[void]$List.Add('DONT_REQ_PREAUTH')}
                ($UserFlag -BOR 0x800000) {[void]$List.Add('PASSWORD_EXPIRED')}
                ($UserFlag -BOR 0x1000000) {[void]$List.Add('TRUSTED_TO_AUTH_FOR_DELEGATION')}
                ($UserFlag -BOR 0x04000000) {[void]$List.Add('PARTIAL_SECRETS_ACCOUNT')}
            }
            $List -join '; '
        }
        $Computer = $env:COMPUTERNAME.ToUpper()
        #Check if Domain Controller - https://docs.microsoft.com/en-us/windows/desktop/CIMWin32Prov/win32-operatingsystem#properties
        $ProductType = (Get-CimInstance -ClassName Win32_OperatingSystem -Property ProductType).ProductType
        if (!($ProductType -eq 2)){
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
        }else {
            Write-Warning "[$Computer] - is a Domain Controller, no local users available"
        }
    }
}