---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspSecurityUpdate.md
Schema: 2.0.0
---

# Get-PspSecurityUpdate

## SYNOPSIS
Get all the security update information for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspSecurityUpdate [[-ComputerName] <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### Session

```powershell
Get-PspSecurityUpdate [[-CimSession] <CimSession[]>] [<CommonParameters>]
```

## DESCRIPTION

Get all the security update information for local or remote machines.
Tries to create a CIM session to obtain information, but will revert to DCOM if CIM is not available.
If there's already a CIM session available, this can also be used to obtain the data.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspSecurityUpdate -ComputerName CONTOSO-SRV01,CONTOSO-SRV02

ComputerName   Type            KBFile    InstallDate
------------   ----            ------    -----------
CONTOSO-SRV01  Update          KB4049065 2/2/2018 12:00:00 AM
CONTOSO-SRV01  Security Update KB4048953 2/2/2018 12:00:00 AM
CONTOSO-SRV02  Update          KB4464455 10/29/2018 12:00:00 AM
```

Gets the installed security updates for CONTOSO-SRV01 and CONTOSO-SRV02, displaying the default properties.

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

### PSP.Inventory.SecurityUpdate

## NOTES

Name: Get-PspSecurityUpdate.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 21-02-2019
DateModified: 12-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)