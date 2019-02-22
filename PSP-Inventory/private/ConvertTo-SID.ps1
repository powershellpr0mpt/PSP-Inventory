    Function ConvertTo-SID {
        [cmdletbinding()]
        param(
            [byte[]]$BinarySID
        )
        (New-Object System.Security.Principal.SecurityIdentifier($BinarySID,0)).Value
    }