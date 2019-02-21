Function Convert-ChassisType {
    Param ([int[]]$ChassisType)
    $List = New-Object System.Collections.ArrayList
    Switch ($ChassisType) {
        0x0001  {[void]$List.Add('Other')}
        0x0002  {[void]$List.Add('Unknown')}
        0x0003  {[void]$List.Add('Desktop')}
        0x0004  {[void]$List.Add('Low Profile Desktop')}
        0x0005  {[void]$List.Add('Pizza Box')}
        0x0006  {[void]$List.Add('Mini Tower')}
        0x0007  {[void]$List.Add('Tower')}
        0x0008  {[void]$List.Add('Portable')}
        0x0009  {[void]$List.Add('Laptop')}
        0x000A  {[void]$List.Add('Notebook')}
        0x000B  {[void]$List.Add('Hand Held')}
        0x000C  {[void]$List.Add('Docking Station')}
        0x000D  {[void]$List.Add('All in One')}
        0x000E  {[void]$List.Add('Sub Notebook')}
        0x000F  {[void]$List.Add('Space-Saving')}
        0x0010  {[void]$List.Add('Lunch Box')}
        0x0011  {[void]$List.Add('Main System Chassis')}
        0x0012  {[void]$List.Add('Expansion Chassis')}
        0x0013  {[void]$List.Add('Subchassis')}
        0x0014  {[void]$List.Add('Bus Expansion Chassis')}
        0x0015  {[void]$List.Add('Peripheral Chassis')}
        0x0016  {[void]$List.Add('Storage Chassis')}
        0x0017  {[void]$List.Add('Rack Mount Chassis')}
        0x0018  {[void]$List.Add('Sealed-Case PC')}
    }
    $List -join ', '
}