---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspSysInfo.md
Schema: 2.0.0
---

# Get-PspSysInfo

## SYNOPSIS

Get System information for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspSysInfo [[-ComputerName] <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### Session

```powershell
Get-PspSysInfo [[-CimSession] <CimSession[]>] [<CommonParameters>]
```

## DESCRIPTION

Get System information for local or remote machines.
Will query default information about the actual system, such as CPU & Memory and if it's virtual or physical
Tries to create a CIM session to obtain information, but will revert to DCOM if CIM is not available.
If there's already a CIM session available, this can also be used to obtain the data.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspSysInfo -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

ComputerName   Model           SerialNumber                     CPUCores CPULogical MemoryGB
------------   -----           ------------                     -------- ---------- --------
CONTOSO-SRV01  Virtual Machine 6656-6324-2091-0011-9109-1646-89 1        2          0
CONTOSO-SRV02  Virtual Machine 8945-5393-3426-8378-9495-3257-53 1        2          1
```

Gets the installed server roles for CONTOSO-SRV01 and CONTOSO-SRV02, displaying the default properties.

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

### PSP.Inventory.SystemInfo

## NOTES

Name: Get-PspSysInfo.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 24-02-2019
DateModified: 12-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)