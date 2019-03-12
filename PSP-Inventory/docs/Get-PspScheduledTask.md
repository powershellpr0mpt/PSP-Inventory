---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspScheduledTask.md
Schema: 2.0.0
---

# Get-PspScheduledTask

## SYNOPSIS

Get Scheduled task information for local or remote machines.

## SYNTAX

```powershell
Get-PspScheduledTask [[-ComputerName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Get Scheduled task information for local or remote machines.
Will get all scheduled tasks in the root folder.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspScheduledTask -ComputerName CONTOSO-SRV01,CONTOSO-WEB01,CONTOSO-APP01

ComputerName    Task                                                                          Enabled State    LastResult
------------    ----                                                                          ------- -----    ----------
CONTOSO-SRV01   Optimize Start Menu Cache Files-S-1-5-21-2130384611-3847849876-2318412143-500 False   Disabled Successfully completed
CONTOSO-WEB01   notepad                                                                       False   Disabled Successfully completed
CONTOSO-APP01   GoogleUpdateTaskMachineCore                                                   True    Ready    Successfully completed
CONTOSO-APP01   GoogleUpdateTaskMachineUA                                                     True    Ready    Successfully completed
```

Gets the Scheduled Tasks for CONTOSO-SRV01, CONTOSO-WEB01 and CONTOSO-APP01, displaying the default properties.

## PARAMETERS

### -ComputerName

Provide the computername(s) to query.
Default value is the local machine.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: CN
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

### PSP.Inventory.ScheduledTask

## NOTES

Name: Get-PspScheduledTask.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 23-02-2019
DateModified: 12-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)