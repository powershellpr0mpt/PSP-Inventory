# PSP-Inventory

## Installing PSP-Inventory

    # Install PSP-Inventory from the Powershell Gallery
    Find-Module PSP-Inventory | Install-Module -AllowClobber

### Change Log

[Change Log can be viewed here](CHANGELOG.md)

### To Contribute

[Please see the following article](CONTRIBUTION.md)

### License

[License can be seen here](LICENSE.md)

### To-Do

- Add ability to write errors to logfile
- More instructions on how to use this module alongside the [PoshRSJob](https://github.com/proxb/PoshRSJob) and [ImportExcel](https://github.com/dfinke/ImportExcel) modules.
The PoshRSJob module will allow parallel collection of data instead of sequential through the use of RunSpaces.
  The ImportExcel module allows you to Export the collected data to Excel and immediately manipulate this data if required, without actually having Excel installed.
  Keep an eye out on this location for more information on how to do this!
- Add examples on how to use the module [code/GIFs]

### Known Issues

- View the [Issues](https://github.com/powershellpr0mpt/PSP-Inventory/issues) list to see what's up! 

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