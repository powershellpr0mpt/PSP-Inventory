function Convert-NetworkStatus
{
    <#
    .SYNOPSIS
    Converts network status values from integers to strings

    .DESCRIPTION
    Converts network status values from integers to strings

    .PARAMETER NetworkStatus
    Provide integer representation of network status values to convert to string value

    .EXAMPLE
    Convert-NetworkStatus -NetworkStatus 0x000A

    Description
    -----------
    Converts the network status value of 5 to the string value of 'Hardware disabled'

    .NOTES
    Name: Convert-NetworkStatus.ps1
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
        [int]$NetworkStatus
    )
    switch ($NetworkStatus)
    {
        0 { "Disconnected" }
        1 { "Connecting" }
        2 { "Connected" }
        3 { "Disconnecting" }
        4 { "Hardware not present" }
        5 { "Hardware disabled" }
        6 { "Hardware malfunction" }
        7 { "Media disconnected" }
        8 { "Authenticating" }
        9 { "Authentication succeeded" }
        10 { "Authentication failed" }
        11 { "Invalid Address" }
        12 { "Credentials Required" }
        Default { "Not connected" }
    }
}