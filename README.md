# PSP-Inventory

## What does it do

The PSP-Inventory module provides new cmdlets for you to inventorise your Windows environment.
The following items are collected for you:

- System Info [CPU/Mem etc]
- Operating System Info
- Disk Info
- Network Info
- Installed Software
- Installed Security Updates
- Installed Server Roles
- Installed Certificates
- Scheduled Tasks
- Local Groups
- Local Users

The module has been created with a mindset to be able to quickly make an inventory of a new environment, providing default information required to get to know new systems.
Seeing that I tend to work on a project basis a lot for different companies, getting inventory data really helps me with quickly evaluating the systems I need to work on.
It might also simply help with keeping track of changes made on a system over time by re-running cmdlets and comparing the data collected.

![alt text](https://powershellpr0mpt.com/wp-content/uploads/2019/03/example1.png "Quickly collect all information required")

![alt text](https://powershellpr0mpt.com/wp-content/uploads/2019/03/example2.png "Objects are formatted for an easy on the eye display, but contain every bit of info you might require")

## Installing PSP-Inventory

```powershell
# Install PSP-Inventory from the Powershell Gallery
Find-Module PSP-Inventory | Install-Module
```

### BREAKING CHANGES

Do note that due to the release of v1.0.0 there might be breaking changes.
This solves some of the issues the module was having, but might impact current users of the module.
Be sure to check the [Change Log](CHANGELOG.md) for exact information on what has been changed.

### Change Log

[Change Log can be viewed here](CHANGELOG.md)

### To Contribute

[Please see the following article](CONTRIBUTING.md)

### License

[License can be seen here](LICENSE.md)

### Known Issues

- View the [Issues](https://github.com/powershellpr0mpt/PSP-Inventory/issues) list to see what's currently known.

### Examples

Here are a few simple examples on how to use the module for basic inventory needs.

All cmdlets currently already provide comment based help available within PowerShell itself, which can be found [here](https://github.com/powershellpr0mpt/PSP-Inventory/tree/master/PSP-Inventory/docs)

#### Getting Network information

```powershell
#Collect the list of computers to query
$Computers = Get-Content 'C:\Temp\Computers.txt'
Get-PspNicInfo -ComputerName $Computers -Drivers | Format-Table

ComputerName Alias    Index PhysicalAdapter IPAddress                                 Status    MacAddress        DHCPEnabled DHCPServer DNSServers
------------ -----    ----- --------------- ---------                                 ------    ----------        ----------- ---------- ----------
DC2012R2     Ethernet 10               True {192.168.14.3, fe80::e456:f730:f610:7eac} Connected 00:17:FB:00:00:00       False            {127.0.0.1}
SRV2012      Ethernet 10               True {192.168.14.5, fe80::2d7c:d6b8:d670:38df} Connected 00:17:FB:00:00:02       False            {192.168.14.3}
SRV2016CORE  Ethernet 1                True {192.168.14.6, fe80::a438:7d49:4f12:b000} Connected 00:17:FB:00:00:03       False            {192.168.14.3}
SRV2019CORE  Ethernet 1                True {192.168.14.7, fe80::31f3:d92a:a4b9:e3a8} Connected 00:17:FB:00:00:04       False            {192.168.14.3}
```

#### Finding installed software and export it to Excel

This depends on the availability of the [ImportExcel](https://github.com/dfinke/ImportExcel) module on your system

```powershell
$Software = Get-PspSoftware -ComputerName NYC-DC01

$Software | Export-Excel -Path "$Home\Inventory\Inventory.xlsx" -WorksheetName 'Software' -Append -AutoSize -AutoFilter -FreezeTopRowFirstColumn
```

This will provide you an Excel sheet work a worksheet named Software containing all the collected data.
It will be automatically sized, filtered and the top row and first column will be frozen.

If there's already data in this Excel sheet, it will automatically append the data to it instead of overwriting it.

### Compatibility

#### Operating Systems

  This module has been tested on the following Windows Systems:

  Operating System | Tested | Expected to work
  ---|---|---
  Windows 10 - 1809 | Yes | Yes
  Windows 10 - 1803 | Yes | Yes
  Windows 8.1 | No | Yes
  Windows 7 | No | Yes
  Windows Server 2019 | Yes | Yes
  Windows Server 2016 | Yes | Yes
  Windows Server 2012R2 | Yes | Yes
  Windows Server 2012 | Yes | Yes
  Windows Server 2008R2 | Yes | Yes
  Windows Server 2008 | Yes | Yes
  Windows Server 2003R2 | Yes | Yes

  It is not expected that this module will function on Unix/MacOS and they are not supported.

#### PowerShell Versions

  This module has been tested with the following PowerShell versions:

  PowerShell Version | Tested
  --- | ---
  PowerShell 6 Core | Yes
Windows PowerShell 5.1 | Yes
Windows PowerShell 5 | Yes
Windows PowerShell 4 | Yes
Windows PowerShell 3 | Yes
Windows PowerShell 2 | Yes