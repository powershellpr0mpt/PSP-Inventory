---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspOSInfo.md
Schema: 2.0.0
---

# Get-PspOSInfo

## SYNOPSIS

Get Operating System information for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspOSInfo [[-ComputerName] <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### Session

```powershell
Get-PspOSInfo [[-CimSession] <CimSession[]>] [<CommonParameters>]
```

## DESCRIPTION

Get Operating System information for local or remote machines.
Tries to create a CIM session to obtain information, but will revert to DCOM if CIM is not available.
If there's already a CIM session available, this can also be used to obtain the data.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspOSInfo -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

ComputerName   Caption                                Version    OSArchitecture LastReboot
------------   -------                                -------    -------------- ----------
CONTOSO-SRV01  Microsoft Windows Server 2016 Standard 10.0.14393 64-bit         3/4/2019 1:41:07 PM
CONTOSO-SRV02  Microsoft Windows Server 2019 Standard 10.0.17763 64-bit         3/4/2019 1:41:25 PM
```

Gets Operating system information for CONTOSO-SRV01 and CONTOSO-SRV02, displaying the default properties.

### EXAMPLE 2

```powershell
PS C:\> Get-PspOSInfo -ComputerName CONTOSO-WEB01 | Format-List

ComputerName   : CONTOSO-WEB01
Caption        : Microsoft Windows Server 2016 Standard
Version        : 10.0.14393
ServicePack    : 0.0
ProductKey     :
LastReboot     : 3/4/2019 1:41:07 PM
OSArchitecture : 64-bit
TimeZone       : (UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna
PageFile       :
PageFileSizeGB : 0
InventoryDate  : 3/12/2019 9:56:50 AM
```

Gets the Operating system information for CONTOSO-WEB01 and shows all collected properties.

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

### PSP.Inventory.OperatingSystemInfo

## NOTES

Name: Get-PspOSInfo.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 20-02-2019
DateModified: 12-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)