Function Get-LocalGroup {
    <#
    .SYNOPSIS
    Get all local groups for local or remote machines
    
    .DESCRIPTION
    Get all local groups for local or remote machines.
    Provides extra information such as members
    
    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine
    
    .EXAMPLE
    Get-LocalGroup -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
    
    Description
    -----------
    Gets the local groups for both CONTOSO-SRV01 and CONTOSO-WEB01
    
    .NOTES
    Name: Get-LocalGroup.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 20-02-2019
    DateModified: 27-02-2019
    Blog: http://powershellpr0mpt.com

    .LINK
    http://powershellpr0mpt.com
    #>
    
    [OutputType('PSP.Inventory.LocalGroup')]
    [Cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        $GroupType = @{
            0x2        = 'Global Group'
            0x4        = 'Local Group'
            0x8        = 'Universal Group'
            2147483648 = 'Security Enabled'
        }
        $Date = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    process {
        foreach ($Computer in $ComputerName) {
            $Computer = $Computer.ToUpper()
            $GroupInfo = ([ADSI]"WinNT://$Computer").Children | Where-Object {$_.SchemaClassName -eq 'Group'}
            foreach ($Group in $GroupInfo) {
                $Grp = [PSCustomObject]@{
                    ComputerName  = $Computer
                    GroupName     = $Group.Name[0]
                    Members       = ((Get-LocalGroupMember -Group $Group) -join '; ')
                    GroupType     = $GroupType[[int]$Group.GroupType[0]]
                    SID           = (ConvertTo-SID -BinarySID $Group.ObjectSid[0])
                    InventoryDate = $Date
                }
                $Grp.PSTypeNames.Insert(0, 'PSP.Inventory.LocalGroup')
                $Grp
            }
        }
    }
}