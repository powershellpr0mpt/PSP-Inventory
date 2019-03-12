---
External Help File: PSP-Inventory-help.xml
Module Name: PSP-Inventory
Online Version: https://github.com/powershellpr0mpt/PSP-Inventory/blob/master/docs/Get-PspCertificate.md
Schema: 2.0.0
---

# Get-PspCertificate

## SYNOPSIS

Get certification information for local or remote machines.

## SYNTAX

### Computer (Default)

```powershell
Get-PspCertificate [[-ComputerName] <String[]>] [-Credential <PSCredential>] [[-StoreName] <StoreName>]
 [[-StoreLocation] <StoreLocation>] [<CommonParameters>]
```

### Session

```powershell
Get-PspCertificate [[-PSSession] <PSSession[]>] [[-StoreName] <StoreName>] [[-StoreLocation] <StoreLocation>]
 [<CommonParameters>]
```

## DESCRIPTION

Get certification information for local or remote machines.
Allows you to specify exactly which store you want to query.

## EXAMPLES

### EXAMPLE 1

```powershell
PS C:\> Get-PspCertificate -ComputerName 'CONTOSO-SRV01'

ComputerName    NotAfter            NotBefore           Subject                                                                          Thumbprint
------------    --------            ---------           -------                                                                          ----------
CONTOSO-SRV01 9-9-2038 11:31:44   14-9-2018 11:31:44  CN=127.0.0.1                                                                     BA03E7647E61F2562A...
CONTOSO-SRV01 23-11-2038 15:49:59 28-11-2018 15:49:59 CN=127.0.0.1                                                                     B9EDE957C09C462C68...
CONTOSO-SRV01 12-3-2019 22:46:38  11-3-2019 22:41:38  CN=1d55f591-ad2c-43dd-abef-ff7e3e6a6f51, DC=dbddf572-f118-4b32-8139-dc6cd6bae4f8 69CD7B0FB0D244E4FA...
CONTOSO-SRV01 3-12-2028 14:02:53  3-12-2018 13:32:53  CN=1d55f591-ad3c-43dd-abef-ff7e3e6a6f51                                          28165F4FDE3E0FAA24...
CONTOSO-SRV01 3-12-2019 14:02:58  3-12-2018 13:52:58  CN=a8b24bcf-6f4c-4b8c-907e-37acb9b15d3b                                          0F674857164B0D4197...
```

Gets the certification information for CONTOSO-SRV01 using the 'My' storename and 'LocalMachine' storelocation, displaying the default properties.

## PARAMETERS

### -ComputerName

Provide the computername(s) to query.
Using this parameter will create a temporary PSSession to obtain the information if available.
If PowerShell remoting is not available, it will try and obtain the information through .NET.
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

### -StoreName

Provide the StoreName to query.
Default value is the 'My' name.

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
Default value is the 'LocalMachine' store.

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

Name: Get-PspCertificate.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 22-02-2019
DateModified: 11-03-2019
Blog: https://powershellpr0mpt.com

## RELATED LINKS

[https://powershellpr0mpt.com](https://powershellpr0mpt.com)