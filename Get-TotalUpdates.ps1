$Updates = Get-SecurityUpdate -Computername $Computername -ErrorAction Stop | 
    Select @{L='Computername';E={$Computername}},Description, HotFixID, InstalledOn, Type,@{L='InventoryDate';E={$Date}} | 
    Group-Object HotFixID | ForEach {$_.Group | Sort-Object -Unique DisplayName}
$Hotfixes = Get-HotFix -ComputerName $Computername | ForEach {
    Switch -Wildcard ($_.Description) {
        "Service Pack*" {$Type = 'Service Pack'}
        "Hotfix*" {$Type = 'Hotfix'}
        "Update*" {$Type = 'Update'}
        "Security Update*" {$Type = 'Security Update'}
        Default {$Type = 'Unknown'}
    }
    [pscustomobject]@{
        Computername = $Computername
        Description = $_.Description
        HotFixID = $_.HotFixID
        InstalledOn = $_.InstalledOn
        Type = $Type
        InventoryDate = $Date
    }
} 
$TotalUpdates = $Hotfixes + $Updates