Function _GetLocalGroupMember {
    <#
    .SYNOPSIS
    Gets the members of a local group

    .DESCRIPTION
    Gets the members of a local group

    .PARAMETER Group
    Provide the local group name to query for its members

    .EXAMPLE
    _GetLocalGroupMember -Group Administrators

    Description
    -----------
    Gets all the members of the local group 'Administrators'

    .NOTES
    Name: _GetLocalGroupMember.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-02-2019
    DateModified: 07-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [cmdletbinding()]
    param (
        $Group
    )
    $Group.Invoke('Members') | ForEach-Object {
        $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }
}