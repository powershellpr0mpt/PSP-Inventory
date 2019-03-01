Function Get-LocalUser {
    <#
    .SYNOPSIS
    Get all local users for local or remote machines
    
    .DESCRIPTION
    Get all local users for local or remote machines.
    Provides extra information about the actual user based on the user's settings
    
    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine
    
    .EXAMPLE
    Get-LocalUser -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
    
    Description
    -----------
    Gets the local users for both CONTOSO-SRV01 and CONTOSO-WEB01
    
    .NOTES
    Name: Get-LocalUser.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-02-2019
    DateModified: 01-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>
    
    [OutputType('PSP.Inventory.LocalUser')]
    [Cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        $InventoryDate = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    process {
        foreach ($Computer in $Computername) {
            $Computer = $Computer.ToUpper()
            $UserInfo = ([ADSI]"WinNT://$Computer").Children | Where-Object {$_.SchemaClassName -eq 'User'}
            foreach ($User in $UserInfo) {
                $Usr = [PSCustomObject]@{
                    ComputerName  = $Computer
                    UserName      = $User.Name[0]
                    Description   = $User.Description[0]
                    LastLogin     = if ($User.LastLogin[0] -is [datetime]) {$User.LastLogin[0]}else {$null}
                    SID           = (ConvertTo-SID -BinarySID $User.ObjectSid[0])
                    UserFlags     = (Convert-UserFlag -UserFlag $User.UserFlags[0])
                    InventoryDate = $InventoryDate
                }
                $Usr.PSTypeNames.Insert(0, 'PSP.Inventory.LocalUser')
                $Usr
            }
        }
    }
}