---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspDiskInfo.md
Schema: 2.0.0
---

# Get-PspDiskInfo

## SYNOPSIS

Get Disk information for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspDiskInfo [[-ComputerName] <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### Session

```powershell
Get-PspDiskInfo [[-CimSession] <CimSession[]>] [<CommonParameters>]
```

## DESCRIPTION

Get Disk information for local or remote machines.
Will query Disks, partitions and volumes to obtain as much information as possible.
Tries to create a CIM session to obtain information, but will revert to DCOM if CIM is not available.
If there's already a CIM session available, this can also be used to obtain the data.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspDiskInfo -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'

ComputerName DriveLetter FileSystem TotalSizeGB FreeSizeGB UsedSizeGB
------------ ----------- ---------- ----------- ---------- ----------
CONTOSO-SRV01  C:          NTFS       50          38.81      11.19
CONTOSO-WEB01  C:          NTFS       49.36       41.81      7.55
```

Gets the disk information for CONTOSO-SRV01 and CONTOSO-WEB01 by creating a temporary CIM session, displaying the default properties.

### EXAMPLE 2

```powershell
PS C:\> $CimSession = New-CimSession -ComputerName 'CONTOSO-SRV02'
PS C:\> Get-PspDiskInfo -CimSession $CimSession

ComputerName DriveLetter FileSystem TotalSizeGB FreeSizeGB UsedSizeGB
------------ ----------- ---------- ----------- ---------- ----------
CONTOSO-SRV02  C:          NTFS       50          38.81      11.19
```

Creates a CIM session for CONTOSO-SRV02 and uses this session to get the Disk information from this machine.
The session can then be re-used for other cmdlets in order to get more information.
Re-using the session provides performance benefits.

## PARAMETERS

### -ComputerName

Provide the computername(s) to query.
This will create a new CIM session which will be removed once the information has been gathered.
Default value is the local machine.

```yaml
Type: String[]
Parameter Sets: Computer
Aliases: CN
Required: False
Position: 1
Default value: $env:COMPUTERNAME
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Credential

Provide the credentials for the CIM session to be created if current credentials are not sufficient.

```yaml
Type: PSCredential
Parameter Sets: Computer
Aliases:
Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CimSession

Provide the CIM session object to query if this is already available.
Once the information has been gathered, the CIM session will remain available for further use.

```yaml
Type: CimSession[]
Parameter Sets: Session
Aliases: Session
Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters:
-Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Inventory.Disk

## NOTES

Name: Get-PspDiskInfo.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 22-12-2018
DateModified: 11-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)