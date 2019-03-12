---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspServerRole.md
Schema: 2.0.0
---

# Get-PspServerRole

## SYNOPSIS

Get Server Roles for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspServerRole [[-ComputerName] <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### Session

```powershell
Get-PspServerRole [[-CimSession] <CimSession[]>] [<CommonParameters>]
```

## DESCRIPTION

Get Server Roles for local or remote machines.
Tries to create a CIM session to obtain information, but will revert to DCOM if CIM is not available.
If there's already a CIM session available, this can also be used to obtain the data.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspServerRole -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

ComputerName   RoleId Name                  InventoryDate
------------   ------ ----                  -------------
CONTOSO-SRV01   481 File and Storage Services       3/12/2019 10:18:40 AM
CONTOSO-SRV01   487 SMB 1.0/CIFS File Sharing Support 3/12/2019 10:18:40 AM
CONTOSO-SRV01   418 .NET Framework 4.6          3/12/2019 10:18:40 AM
CONTOSO-SRV01   466 .NET Framework 4.6 Features     3/12/2019 10:18:40 AM
CONTOSO-SRV01   420 WCF Services              3/12/2019 10:18:40 AM
CONTOSO-SRV01   425 TCP Port Sharing            3/12/2019 10:18:40 AM
CONTOSO-SRV01   412 Windows PowerShell 5.1        3/12/2019 10:18:40 AM
CONTOSO-SRV01   417 Windows PowerShell          3/12/2019 10:18:40 AM
CONTOSO-SRV01   482 Storage Services            3/12/2019 10:18:40 AM
CONTOSO-SRV01   1003 Windows Defender            3/12/2019 10:18:40 AM
CONTOSO-SRV01   1020 Windows Defender Features       3/12/2019 10:18:40 AM
CONTOSO-SRV01   340 WoW64 Support             3/12/2019 10:18:40 AM
CONTOSO-SRV02   481 File and Storage Services       3/12/2019 10:18:40 AM
CONTOSO-SRV02   418 .NET Framework 4.7          3/12/2019 10:18:41 AM
CONTOSO-SRV02   466 .NET Framework 4.7 Features     3/12/2019 10:18:41 AM
CONTOSO-SRV02   420 WCF Services              3/12/2019 10:18:41 AM
CONTOSO-SRV02   425 TCP Port Sharing            3/12/2019 10:18:41 AM
CONTOSO-SRV02   412 Windows PowerShell 5.1        3/12/2019 10:18:41 AM
CONTOSO-SRV02   417 Windows PowerShell          3/12/2019 10:18:41 AM
CONTOSO-SRV02   482 Storage Services            3/12/2019 10:18:41 AM
CONTOSO-SRV02   1043 System Data Archiver          3/12/2019 10:18:41 AM
CONTOSO-SRV02   1003 Windows Defender Antivirus      3/12/2019 10:18:41 AM
CONTOSO-SRV02   340 WoW64 Support             3/12/2019 10:18:41 AM
```

Gets the installed server roles for CONTOSO-SRV01 and CONTOSO-SRV02.

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

### PSP.Inventory.ServerRole

## NOTES

Name: Get-PspServerRole.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 22-12-2018
DateModified: 12-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)