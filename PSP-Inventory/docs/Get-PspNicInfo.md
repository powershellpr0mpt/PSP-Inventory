---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspNicInfo.md
Schema: 2.0.0
---

# Get-PspNicInfo

## SYNOPSIS

Get Network adapter information for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspNicInfo [[-ComputerName] <String[]>] [-Credential <PSCredential>] [-Drivers] [<CommonParameters>]
```

### Session

```powershell
Get-PspNicInfo [[-CimSession] <CimSession[]>] [-Drivers] [<CommonParameters>]
```

## DESCRIPTION

Get Network adapter information for local or remote machines.
Tries to create a CIM session to obtain information, but will revert to DCOM if CIM is not available.
If there's already a CIM session available, this can also be used to obtain the data.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspNicInfo -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

ComputerName   Alias    Index IPAddress                                 Status
------------   -----    ----- ---------                                 ------
CONTOSO-SRV01  Ethernet 1     {192.168.14.6, fe80::a438:7d49:4f12:b000} Connected
CONTOSO-SRV02  Ethernet 1     {192.168.14.7, fe80::31f3:d92a:a4b9:e3a8} Connected
```

Gets network adapter information for both CONTOSO-SRV01 and CONTOSO-SRV02, displaying the default properties.

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

### -Drivers

Switch parameter.
If activated will try and obtain the driver information for the adapter.
Do note that this will substantially increase time required.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:
Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters:
-Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Inventory.NIC

## NOTES

Name: Get-PspNicInfo.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 20-12-2018
DateModified: 12-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)