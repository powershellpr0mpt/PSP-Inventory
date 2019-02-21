$ServerRoles = Try {
    Get-WmiObject Win32_ServerFeature -ComputerName $Computername -ErrorAction Stop | ForEach {
        [pscustomobject]@{
            Computername = $Computername
            ID = $_.Id
            Name = $_.Name
            InventoryDate = $Date
        }
    }
} 
Catch {}