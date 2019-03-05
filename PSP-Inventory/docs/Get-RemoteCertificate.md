---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-RemoteCertificate.md
Schema: 2.0.0
---

# Get-RemoteCertificate

## SYNOPSIS

Get certification information for local or remote machines

## SYNTAX

```powershell
Get-RemoteCertificate [[-ComputerName] <String[]>] [[-StoreName] <StoreName>]
 [[-StoreLocation] <StoreLocation>] [<CommonParameters>]
```

## DESCRIPTION

Get certification information for local or remote machines.  
Allows you to specify exactly which store you want to query.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-LocalUser -ComputerName 'CONTOSO-SRV01','CONTOSO-WEB01'
```

Description
--- ---
Gets the certification information for both CONTOSO-SRV01 and CONTOSO-WEB01, both using the 'My' storename and 'LocalMachine' storelocation

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

### -StoreName

Provide the StoreName to query.  
Default value is the 'My' name

```yaml
Type: StoreName
Parameter Sets: (All)
Aliases:
Accepted values: AddressBook, AuthRoot, CertificateAuthority, Disallowed, My, Root, TrustedPeople, TrustedPublisher

Required: False
Position: 2
Default value: My
Accept pipeline input: False
Accept wildcard characters: False
```

### -StoreLocation

Provide the Certification store to query.  
Default value is the 'LocalMachine' store

```yaml
Type: StoreLocation
Parameter Sets: (All)
Aliases:
Accepted values: CurrentUser, LocalMachine

Required: False
Position: 3
Default value: LocalMachine
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters:  
-Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.  
For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Inventory.Certificate

## NOTES

Name: Get-RemoteCertificate.ps1  
Author: Robert Prüst  
Module: PSP-Inventory  
DateCreated: 22-02-2019  
DateModified: 05-03-2019  
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)

