---
external help file: PSP-Inventory-help.xml
Module Name: PSP-Inventory
online version: http://powershellpr0mpt.com
schema: 2.0.0
---

# Get-PspSoftware

## SYNOPSIS
Get the installed software for local or remote machines.

## SYNTAX

### Computer (Default)
```
Get-PspSoftware [[-ComputerName] <String[]>] [-Credential <PSCredential>] [<CommonParameters>]
```

### Session
```
Get-PspSoftware [[-PSSession] <PSSession[]>] [<CommonParameters>]
```

## DESCRIPTION
Get the installed software for local or remote machines.
Will try and access the required data through a PowerShell remoting session, but in case this fails reverts to RemoteRegistry.
This does however require RemoteRegistry to be enabled on the machine.
Will look for both x86 and x64 installed paths.

## EXAMPLES

### EXAMPLE 1
```
Get-PspSoftware -ComputerName CONTOSO-SRV01,CONTOSO-WEB01,CONTOSO-APP01
```

ComputerName    : CONTOSO-SRV01
DisplayName     : Google Chrome
Version         : 72.0.3626.121
InstallDate     : 3/11/2019 12:00:00 AM
Publisher       : Google LLC
UninstallString : MsiExec.exe /X{0C8D8E7A-485A-39D9-82C9-DF0955BE2A57}
InstallLocation :
InstallSource   : C:\Users\Administrator\AppData\Local\Temp\1\Temp1_GoogleChromeEnterpriseBundle64.zip\Installers\
HelpLink        :
EstimatedSizeMB : 54.5
InventoryDate   : 3/12/2019 10:25:45 AM

ComputerName    : CONTOSO-SRV01
DisplayName     : Google Update Helper
Version         : 1.3.33.23
InstallDate     : 3/11/2019 12:00:00 AM
Publisher       : Google Inc.
UninstallString : MsiExec.exe /I{60EC980A-BDA2-4CB6-A427-B07A5498B4CA}
InstallLocation :
InstallSource   : C:\Program Files (x86)\Google\Update\1.3.33.23\
HelpLink        :
EstimatedSizeMB : 0.04
InventoryDate   : 3/12/2019 10:25:45 AM

ComputerName    : CONTOSO-WEB01
DisplayName     : VLC media player
Version         : 3.0.6
InstallDate     :
Publisher       : VideoLAN
UninstallString : "C:\Program Files (x86)\VideoLAN\VLC\uninstall.exe"
InstallLocation : C:\Program Files (x86)\VideoLAN\VLC
InstallSource   :
HelpLink        :
EstimatedSize   : 0
InventoryDate   : 3/12/2019 10:25:45 AM

ComputerName    : CONTOSO-APP01
DisplayName     : Notepad++ (32-bit x86)
Version         : 7.6.4
InstallDate     :
Publisher       : Notepad++ Team
UninstallString : C:\Program Files (x86)\Notepad++\uninstall.exe
InstallLocation :
InstallSource   :
HelpLink        :
EstimatedSize   : 4.35
InventoryDate   : 3/12/2019 10:25:45 AM

Gets the installed software for CONTOSO-SRV01, CONTOSO-WEB01 and CONTOSO-APP01.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### PSP.Inventory.Software
## NOTES
Name: Get-PspSoftware.ps1
Author: Robert Prüst
Module: PSP-Inventory
DateCreated: 21-02-2019
DateModified: 12-03-2019
Blog: http://powershellpr0mpt.com

## RELATED LINKS

[http://powershellpr0mpt.com](http://powershellpr0mpt.com)

