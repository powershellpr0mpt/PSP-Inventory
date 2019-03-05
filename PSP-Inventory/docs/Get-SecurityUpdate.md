---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-SecurityUpdate.md
Schema: 2.0.0
---

# Get-SecurityUpdate

## SYNOPSIS

Get all the security update information for local or remote machines

## SYNTAX

```powershell
Get-SecurityUpdate [[-ComputerName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Get all the security update information for local or remote machines.  
Requires the RemoteRegistry to be enabled on the machine.  
Will look for 'Update','Rollup','Security Update','Service Pack' and 'HotFix'

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SecurityUpdate -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
```

Description
--- ---
Gets the security update information for both CONTOSO-SRV01 and CONTOSO-WEB01

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

### PSP.Inventory.SecurityUpdate

## NOTES

Name: Get-SecurityUpdate.ps1  
Author: Robert Prüst  
Module: PSP-Inventory  
DateCreated: 21-02-2019  
DateModified: 05-03-2019  
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)

