---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-Software.md
Schema: 2.0.0
---

# Get-Software

## SYNOPSIS

Get the installed software for local or remote machines

## SYNTAX

```powershell
Get-Software [[-ComputerName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Get the installed software for local or remote machines.  
Requires the RemoteRegistry to be enabled on the machine.  
Will look for both x86 and x64 installed paths.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SecurityUpdate -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
```

Description
--- ---
Gets the software information for both CONTOSO-SRV01 and CONTOSO-WEB01

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

### CommonParameters

This cmdlet supports the common parameters:  
-Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.  
For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Inventory.Software

## NOTES

Name: Get-Software.ps1  
Author: Robert Prüst  
Module: PSP-Inventory  
DateCreated: 21-02-2019  
DateModified: 05-03-2019  
Blog: http://powershellpr0mpt.com

## RELATED LINKS

[http://powershellpr0mpt.com](http://powershellpr0mpt.com)

