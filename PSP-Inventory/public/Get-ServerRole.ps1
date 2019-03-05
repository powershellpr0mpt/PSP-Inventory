Function Get-ServerRole {
    <#
    .SYNOPSIS
    Get Server Roles for local or remote machines

    .DESCRIPTION
    Get Server Roles for local or remote machines.
    Tries to use CIM to obtain information, but will revert to DCOM if CIM is not available

    .PARAMETER ComputerName
    Provide the computername(s) to query
    Default value is the local machine

    .EXAMPLE
    Get-ServerRole -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'

    Description
    -----------
    Gets the Server Role information for CONTOSO-SRV01 and CONTOSO-WEB01

    .NOTES
    Name: Get-ServerRole.ps1
    Author: Robert Prüst
    Module: PSP-Inventory
    DateCreated: 22-12-2018
    DateModified: 05-03-2019
    Blog: https://powershellpr0mpt.com

    .LINK
    https://powershellpr0mpt.com
    #>

    [OutputType('PSP.Inventory.ServerRole')]
    [Cmdletbinding()]
    Param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        [datetime]$InventoryDate = Get-Date
    }
    process {
        foreach ($Computer in $Computername) {
            $Computer = $Computer.ToUpper()
            Try {
                Get-CimInstance -ClassName Win32_ServerFeature -Property Id, Name -ComputerName $Computer -ErrorAction Stop | ForEach-Object {
                    $Role = [PSCustomObject]@{
                        ComputerName  = $Computer
                        ID            = $_.Id
                        Name          = $_.Name
                        InventoryDate = $InventoryDate
                    }
                    $Role.PSTypeNames.Insert(0, 'PSP.Inventory.ServerRole')
                    $Role
                }
            }
            catch [Microsoft.Management.Infrastructure.CimException] {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions
                try {
                    Get-CimInstance -CimSession $CimSession -ClassName Win32_ServerFeature -Property Id, Name -ErrorAction Stop | ForEach-Object {
                        $Role = [PSCustomObject]@{
                            ComputerName  = $Computer
                            ID            = $_.Id
                            Name          = $_.Name
                            InventoryDate = $InventoryDate
                        }
                        $Role.PSTypeNames.Insert(0, 'PSP.Inventory.ServerRole')
                        $Role
                    }
                }
                catch {
                    Write-Warning "Unable to get WMI properties for computer '$Computer'"
                }
            }
            catch {
                Write-Warning "Unable to get WMI properties for computer '$Computer'"
            }
        }
    }
}