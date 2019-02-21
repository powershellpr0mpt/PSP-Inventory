Function Get-ServerRole {
    [OutputType('PSP.Inventory.ServerRole')]
    [Cmdletbinding()] 
    Param( 
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$ComputerName = $env:COMPUTERNAME
    )
    begin {
        $Date = Get-Date -f 'dd-MM-yyyy HH:mm:ss'
    }
    process {
        foreach ($Computer in $Computername) { 
            Try {
                Get-CimInstance -ClassName Win32_ServerFeature -ComputerName $Computer -ErrorAction Stop | ForEach-Object {
                    $Role = [pscustomobject]@{
                        ComputerName = $Computer
                        ID = $_.Id
                        Name = $_.Name
                        InventoryDate = $Date
                    }
                    $Role.PSTypeNames.Insert(0,'PSP.Inventory.ServerRole')
                    $Role
                }
            } 
            catch [Microsoft.Management.Infrastructure.CimException]
            {
                Write-Warning "'$Computer' does not have CIM access, reverting to DCOM instead"
                $CimOptions = New-CimSessionOption -Protocol DCOM
                $CimSession = New-CimSession -ComputerName $Computer -SessionOption $CimOptions
                try
                {
                    Get-CimInstance -CimSession $CimSession -ClassName Win32_ServerFeature -ErrorAction Stop | ForEach-Object {
                        $Role = [pscustomobject]@{
                            ComputerName = $Computer
                            ID = $_.Id
                            Name = $_.Name
                            InventoryDate = $Date
                        }
                        $Role.PSTypeNames.Insert(0,'PSP.Inventory.ServerRole')
                        $Role
                    }
                }
                catch
                {
                    Write-Warning "Unable to get WMI properties for computer '$Computer'"
                }
            }
            catch
            {
                Write-Warning "Unable to get WMI properties for computer '$Computer'"
            }
        }
    }
}