---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspLocalUser.md
Schema: 2.0.0
---

# Get-PspLocalUser

## SYNOPSIS

Get all local users for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspLocalUser [[-ComputerName] <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### Session

```powershell
Get-PspLocalUser [[-PSSession] <PSSession[]>] [<CommonParameters>]
```

## DESCRIPTION

Get all local users for local or remote machines.
Provides extra information about the actual user based on the user's settings.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspLocalUser -ComputerName CONTOSO-SRV01

ComputerName   UserName       LastLogin
------------   --------       ---------
CONTOSO-SRV01  Administrator  3/12/2019 8:47:17 AM
CONTOSO-SRV01  DefaultAccount
CONTOSO-SRV01  Guest
```

Gets the local users for CONTOSO-SRV01, displaying the default properties.

## PARAMETERS

### -ComputerName

Provide the computername(s) to query.
Using this parameter will create a temporary PSSession to obtain the information if available.
If PowerShell remoting is not available, it will try and obtain the information through ADSI.
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

Provide the credentials for the PowerShell remoting session to be created if current credentials are not sufficient.

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

### -PSSession

Provide the PowerShell remoting session object to query if this is already available.
Once the information has been gathered, the PowerShell session will remain available for further use.

```yaml
Type: PSSession[]
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

### PSP.Inventory.LocalUser

## NOTES

Name: Get-PspLocalUser.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 20-02-2019
DateModified: 12-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)