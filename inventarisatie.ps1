Import-Module ActiveDirectory
$arServers = Get-ADComputer -Filter * -Properties operatingsystem,description | ?{$_.operatingsystem -match "server"}
$arResults = @()
$arCerts = @()
$arSchTasks = @()
$arOffLineServers = @()
$arSoftware = @()
$arRoles = @()


#Functions inladne
#function get-cert
function Get-Cert( $computer=$env:computername ){
    $ro=[System.Security.Cryptography.X509Certificates.OpenFlags]"ReadOnly"
    $lm=[System.Security.Cryptography.X509Certificates.StoreLocation]"LocalMachine"
    $store=new-object System.Security.Cryptography.X509Certificates.X509Store("\\$computer\My",$lm)
    $store.Open($ro)
$store.Certificates
}
#Function get INstalledSoftware
Function Get-InstalledSoftware {
    param ($x, $y)
    $obj = $null
    $script:array = $null
    $script:array = @()
    $UninstallKey=$x
    
    #Create an instance of the Registry Object and open the HKLM base key
    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$y) 
    
    #Drill down into the Uninstall key using the OpenSubKey Method
    $regkey=$reg.OpenSubKey($UninstallKey) 

    #Retrieve an array of string that contain all the subkey names
    $subkeys=$regkey.GetSubKeyNames() 

    #Open each Subkey and use GetValue Method to return the required values for eac
    foreach($key in $subkeys){
        $thisKey=$UninstallKey+"\\"+$key 
        $thisSubKey=$reg.OpenSubKey($thisKey) 
        $obj = New-Object PSObject 
        $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $y
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))
        $obj | Add-Member -MemberType NoteProperty -Name "InstallLocation" -Value $($thisSubKey.GetValue("InstallLocation"))
        $obj | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($thisSubKey.GetValue("Publisher"))
        $script:array += $obj
        $script:arraygesort = $script:array | Sort-Object "Displayname"

    } #foreach($key in $subkeys){ closing tag

} #Function GetInstalledSoftware { closing tag
#function Get Installed Roles
Function Get-InstalledRolesandFeatures {
    param ($x)
    $script:installedrolesandfeatures = Invoke-Command -ComputerName "$x" -ScriptBlock {Import-Module servermanager
        Get-WindowsFeature | ?{$_.installed -eq $true} | Sort-Object Displayname  | select -ExpandProperty displayname

    } #Invoke-Command -ComputerName "hvo-s0077" -ScriptBlock {Import-Module servermanager closing tag

} #Function GetInstalledRolesandFeatures { closing tag 


#Maak Invnetory map aan als die nog niet bestaat locatie aan
if (!(test-path c:\inventory))
    {
    New-item -Path c:\inventory -ItemType directory
    }
    else
    {
    write-host "Directy bestaat al" 
    }
    

foreach ($strServer in $arServers) {
    #clear attributes
    $strName = $null
    $strDescription = $null
    $strPoweredOn = $null
    $strIPAdres = $null
    $strType = $null
    $strCertificates = $null
    $strOfflineServer = $null
    #####################

    $oProperty = New-Object PSObject
    $oProperty = New-Object PSObject

    #invullen Default info
    $strName = $strServer.name
    $strDescription = $strServer.description
    $strIPAdres = Test-Connection $strName -Count '1' -ErrorAction SilentlyContinue | Select -ExpandProperty ipv4address


    #Start Script
    Write-host "we gaan nu de informatie ophalen voor server $strName" -ForegroundColor Green

    #Testen of de Server aan staat, zo ja:ophalen of Server Fysiek is of Virtueel
    #todo: RPC check inbouwen
    if (Test-Connection -ComputerName $strName -Quiet -Count '1') 
    {
        $strPoweredOn = "Yes"
        
         Try {
         $strHardware = Get-WmiObject -computername $strName -Class Win32_computersystem -ErrorAction stop | select model,Manufacturer         
         }
         
         Catch {
         $strHardware = $Null
         }      
         
         if ($strHardware -ne $null){
            $strHardwareModel = $strHardware.model
            $strHardwareManufacturer = $strHardware.Manufacturer
            If (($strHardwareModel -ne "Virtual Machine") -and ($strHardwareManufacturer -ne "Xen" -or "HyperV"))
            {  
            $strType = "Fysiek"
            } else 
            {
            $strType = "Virtueel"
            }

         }
         else {
         Write-host "Kan geen WMI uitvoeren op Server $strName"
         }
    }
        

     else {
        $strPoweredOn = "No"
        $strOfflineServer = $strName
               
    }


    #wegschrijven van de informatie in oProperty
    $oProperty | Add-Member -MemberType NoteProperty -Name "Name" -Value $strName
    $oProperty | Add-Member -MemberType NoteProperty -Name "Description" -Value $strDescription
    $oProperty | Add-Member -MemberType NoteProperty -Name "PoweredOn" -Value $strPoweredOn
    $oProperty | Add-Member -MemberType NoteProperty -Name "Type" -Value $strType
    $oProperty | Add-Member -MemberType NoteProperty -Name "IPAdres" -Value $strIPAdres
    
    #ophalen van de Certificaten
    if ($strPoweredOn -eq "yes")
    {
        Try{
    $strCertificates = Get-Cert $strName  | select -property subject,NotAfter,friendlyname
              
            foreach ($strCertificate in $strCertificates)
            {
             
                if ($strCertificate.subject -ne $null)                
                {
                $oCerts = New-Object PSObject
                $strCertSubject = $certificate.Subject
                $strCertFriendlyname = $certificate.FriendlyName
                $strCertNotAfter = $certificate.NotAfter                
                $oCerts | Add-Member -MemberType NoteProperty -Name "Servername" -Value $strName
                $oCerts | Add-Member -MemberType NoteProperty -Name "Certificate Subject" -Value $strCertSubject
                $oCerts | Add-Member -MemberType NoteProperty -Name "Friendly Name" -Value $strCertFriendlyname
                $oCerts | Add-Member -MemberType NoteProperty -Name "Not After Date" -Value $strCertNotAfter

                #Zet Ocert in de Array
                $arCerts += $oCerts
                }
           }
        }
        Catch{
    Write-Host "De Server $strName  was wel bereikbaar maar kon de certificaten niet ophalen." 
        }
    }

    #Scheduled Tasks ophalen
    if ($strPoweredOn -eq "Yes")
    {
        $strTaskname = $null
        $strRunAs = $null
        
        try {$schtasks = schtasks.exe /query /s $strName /V /FO CSV | ConvertFrom-Csv | Where { $_.TaskName -ne "TaskName" -and $_."Run As User" -ne "Run As User" -and $_."Logon Mode" -ne "Interactive only"}  | Select-Object "Taskname", "Run As User", "Last Run Time", "Task To Run"}
        Catch {$schtasks = $null}
        
        
        if($schtasks -ne $null) {
            foreach($schtask in $schtasks) {
                $oSchtask = New-Object -TypeName PSObject
                #$oServices = New-Object -TypeName psobject  
            
                $strTaskname = $schtask.Taskname
                $strRunAs = $schtask."Run As User"
                $strLastRun = $schtasks."Last Run Time"
                $StrTasktoRun = $schtasks."Task To Run"
                 $strLastRunGejoined = (@($strTaskname) -join ',')
                 $StrTasktoRunGejoined = (@($strTaskname) -join ',')

                $oSchtask | Add-Member -MemberType NoteProperty -Name "Server" -Value $strName
                $oSchtask | Add-Member -MemberType NoteProperty -Name "Taskname" -Value $strTaskname
                $oSchtask | Add-Member -MemberType NoteProperty -Name "Run As" -Value $strRunAs
                $oSchtask | Add-Member -MemberType NoteProperty -Name "Last Run Time " -Value $strLastRunGejoined
                $oSchtask | Add-Member -MemberType NoteProperty -Name "Task To Run" -Value $StrTasktoRunGejoined
                $arSchtasks += $oSchtask
            }
        }
    }
           


    #Get Software&rollen
    
    if ($strPoweredOn -eq "yes")
        {
        #ophalen alle 32 Bit Software
        try {Get-InstalledSoftware "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" $strName}
        Catch {write-Host "Kan 32bit software niet ophalen van Server $strName" -ForegroundColor Red}
        
        if ($script:arraygesort -ne $null){
            Foreach ($item32 in $script:arraygesort)
            {
                $oItem32 = New-Object PSObject
            
                $strItem32Displayname = $item32.DisplayName
                $strItem32Versie = $item32.DisplayVersion
                $strItem32InstallDir = $item32.InstallLocation
                $strItem32Publisher = $item32.Publisher
                if ($strItem32Displayname -ne $null)
                {
                    $oItem32 | Add-Member -MemberType NoteProperty -Name "Servername" -Value $strName
                    $oItem32 | Add-Member -MemberType NoteProperty -Name "Bits" -Value "32"
                    $oItem32 | Add-Member -MemberType NoteProperty -Name "Displayname" -Value $strItem32Displayname
                    $oItem32 | Add-Member -MemberType NoteProperty -Name "Versie" -Value $strItem32Versie
                    $oItem32 | Add-Member -MemberType NoteProperty -Name "Installatie map" -Value $strItem32InstallDir
                    $oItem32 | Add-Member -MemberType NoteProperty -Name "Uitgever" -Value $strItem32Publisher
                    $arSoftware += $oItem32
                }
                
            }
         }


        #ophalen van 64 bit Software
        Try {Get-InstalledSoftware "SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall" "$strName"}
        Catch {write-Host "Kan 64bit software niet ophalen van Server $strName" -ForegroundColor Red}
           if ($script:arraygesort -ne $null)
           {
               Foreach ($item64 in $script:arraygesort)
               {
                $oItem64 = New-Object PSObject
            
                $strItem64Displayname = $item64.DisplayName
                $strItem64Versie = $item64.DisplayVersion
                $strItem64InstallDir = $item64.InstallLocation
                $strItem64Publisher = $item64.Publisher
                if ($strItem64Displayname -ne $null)
                    {          
                    $oItem64 | Add-Member -MemberType NoteProperty -Name "Servername" -Value $strName
                    $oItem64 | Add-Member -MemberType NoteProperty -Name "Bits" -Value "64"
                    $oItem64 | Add-Member -MemberType NoteProperty -Name "Displayname" -Value $strItem64Displayname
                    $oItem64 | Add-Member -MemberType NoteProperty -Name "Versie" -Value $strItem64Versie
                    $oItem64 | Add-Member -MemberType NoteProperty -Name "Installatie map" -Value $strItem64InstallDir
                    $oItem64 | Add-Member -MemberType NoteProperty -Name "Uitgever" -Value $strItem64Publisher

                    $arSoftware += $oItem64
                    }
               }
           }
        #Ophalen van alle geinstalleerde rollen.
        Try {Get-InstalledRolesandFeatures "$strName"}
        Catch {write-host "Kan de rollen van $strName niet ophalen"}

        if ($script:installedrolesandfeatures -ne $null){

            Foreach ($Role in $script:installedrolesandfeatures)
               {
                $oRoles = New-Object PSObject
                                                        
                $oRoles | Add-Member -MemberType NoteProperty -Name "Servername" -Value $strName
                $oRoles | Add-Member -MemberType NoteProperty -Name "Displayname" -Value $Role
            
                $arRoles += $oRoles
                }

            }
        }
    
    
    #Property's toevoegen aan arResults
    $arResults += $oProperty
    $arOffLineServers +=$strOfflineServer
}

#Wegschrijven van de verschillende Arrays naar documentjes.
$arResults | Export-Csv "C:\inventory\InventarisatieServers.csv" -NoTypeInformation
Write-host "CSV voor Algemen inventarisatie is aangemaakt"
$arCerts | Export-Csv "C:\inventory\Certificates.csv" -NoTypeInformation
Write-host "CSV voor Certificates is aangemaakt"
$arSchTasks | Export-Csv "C:\inventory\ScheduledTasks.csv" -NoTypeInformation
write-host "CSV voor Scheduled Tasks is aangemaakt"
$arSoftware | Export-Csv "C:\inventory\Software.csv" -NoTypeInformation
write-host "CSV voor Software is aangemaakt"
$arRoles | Export-Csv "C:\inventory\Roles.csv" -NoTypeInformation
write-host "CSV voor Roles is aangemaakt"
$arOffLineServers | Out-File "C:\inventory\OFflineservers.txt" 
write-host "TxtFile met Offline Servers is aangemaakt"