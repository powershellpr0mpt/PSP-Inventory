---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspLocalGroup.md
Schema: 2.0.0
---

# Get-PspLocalGroup

## SYNOPSIS

Get all local groups for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspLocalGroup [[-ComputerName] <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### Session

```powershell
Get-PspLocalGroup [[-PSSession] <PSSession[]>] [<CommonParameters>]
```

## DESCRIPTION

Get all local groups for local or remote machines.
Provides extra information such as members.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspLocalGroup -ComputerName CONTOSO-HV01

ComputerName GroupName         GroupType
------------ ---------         ---------
CONTOSO-HV01 Access Control Assistance Operators Local Group
CONTOSO-HV01 Administrators       Local Group
CONTOSO-HV01 Backup Operators     Local Group
CONTOSO-HV01 Certificate Service DCOM Access  Local Group
CONTOSO-HV01 Cryptographic Operators    Local Group
CONTOSO-HV01 Distributed COM Users      Local Group
CONTOSO-HV01 Event Log Readers       Local Group
CONTOSO-HV01 Guests         Local Group
CONTOSO-HV01 Hyper-V Administrators     Local Group
CONTOSO-HV01 IIS_IUSRS         Local Group
CONTOSO-HV01 Network Configuration Operators  Local Group
CONTOSO-HV01 Performance Log Users      Local Group
CONTOSO-HV01 Performance Monitor Users     Local Group
CONTOSO-HV01 Power Users       Local Group
CONTOSO-HV01 Print Operators      Local Group
CONTOSO-HV01 RDS Endpoint Servers    Local Group
CONTOSO-HV01 RDS Management Servers     Local Group
CONTOSO-HV01 RDS Remote Access Servers     Local Group
CONTOSO-HV01 Remote Desktop Users    Local Group
CONTOSO-HV01 Remote Management Users    Local Group
CONTOSO-HV01 Replicator        Local Group
CONTOSO-HV01 Storage Replica Administrators   Local Group
CONTOSO-HV01 System Managed Accounts Group    Local Group
CONTOSO-HV01 Users          Local Group
```

Gets all local groups for the machine CONTOSO-HV01, displaying the default properties.

### EXAMPLE 2

```powershell
PS C:\> Get-PspLocalGroup -ComputerName CONTOSO-APP01 | Where-Object {$_.GroupName -eq 'Administrators'} | Select-Object ComputerName,GroupName,Members

ComputerName  GroupName      Members
------------  ---------      -------
CONTOSO-APP01 Administrators Administrator
```

Shows you all the members of the Administrators group on CONTOSO-APP01.

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

### PSP.Inventory.LocalGroup

## NOTES

Name: Get-PspLocalGroup.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 20-02-2019
DateModified: 12-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)