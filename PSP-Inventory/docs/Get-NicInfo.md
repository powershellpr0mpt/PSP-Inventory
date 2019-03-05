---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-NicInfo.md
Schema: 2.0.0
---

# Get-NicInfo

## SYNOPSIS

Get Network adapter information for local or remote machines

## SYNTAX

```powershell
Get-NicInfo [[-ComputerName] <String[]>] [-Drivers] [<CommonParameters>]
```

## DESCRIPTION

Get Network adapter information for local or remote machines.  
Tries to use CIM to obtain information, but will revert to DCOM if CIM is not available

## EXAMPLES

### EXAMPLE 1

```powershell
Get-NicInfo -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
```

Description
--- ---
Gets the "basic" NIC information for CONTOSO-SRV01 and CONTOSO-WEB01

## PARAMETERS

### -ComputerName

Provide the computername(s) to query.  
Default value is the local machine

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $env:COMPUTERNAME
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Drivers

Switch parameter.  
If activated will try and obtain the driver information for the adapter.  
Do note that this will substantially increase time required

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

Name: Get-NicInfo.ps1  
Author: Robert Prüst  
Module: PSP-Inventory  
DateCreated: 20-12-2018  
DateModified: 05-03-2019  
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)

