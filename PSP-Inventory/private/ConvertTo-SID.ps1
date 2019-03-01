Function ConvertTo-SID
{
    <#
    .SYNOPSIS
    Converts a binary SID object to SID

    .DESCRIPTION
    Converts a binary SID object to SID

    .PARAMETER BinarySID
    Provide the binary SID object to be converted to SID

    .EXAMPLE
    $User = ([ADSI]"WinNT://$env:COMPUTERNAME").Children | ? {$_.SchemaClassName -eq 'User'} | Select-Object -First 1
    ConvertTo-SID -BinarySID $User.objectSID[0]

    Description
    -----------
    Converts the binary SID object value to the SID value of 'S-1-5-21-1229050671-3685773596-3126007646-504'

    .NOTES
    Name: ConvertTo-SID.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-02-2019
    DateModified: 27-02-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [cmdletbinding()]
    param(
        [byte[]]$BinarySID
    )
    (New-Object System.Security.Principal.SecurityIdentifier($BinarySID, 0)).Value
}