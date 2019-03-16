function _GetUpdateInfo {
    [cmdletbinding()]
    Param(
        [Microsoft.Management.Infrastructure.CimSession]$Cimsession
    )
    Write-Verbose "[$($CimSession.ComputerName)] - Gathering Security Update information"
    try {
        $Updates = Get-CimInstance -CimSession $CimSession -ClassName Win32_QuickFixEngineering -ErrorAction Stop
        $Updates | ForEach-Object {
            [PSCustomObject]@{
                PSTypeName    = 'PSP.Inventory.SecurityUpdate'
                ComputerName  = $Cimsession.ComputerName
                KBFile        = $_.HotFixID
                Type          = $_.Description
                KBLink        = $_.Caption
                InstalledBy   = $_.InstalledBy
                InstallDate   = $_.InstalledOn
                InventoryDate = (Get-Date)
            }
        }
    }
    catch [Microsoft.Management.Infrastructure.CimException] {
        Write-Warning "[$($CimSession.ComputerName)] - Unable to access data over WinRM, trying DCOM instead"
        $CimOptions = New-CimSessionOption -Protocol DCOM

        $CimProperties = @{
            ErrorAction  = 'Stop'
            Computername = $Cimsession.ComputerName
            SessionOption = $CimOptions
        }
        try {
            $NewCimSession = New-CimSession @CimProperties
        }
        catch {
            Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
        }
        Finally {
            $CimProperties.Remove('SessionOption') | Out-Null
        }
        try {
            $Updates = Get-CimInstance -CimSession $NewCimSession -ClassName Win32_QuickFixEngineering -ErrorAction Stop
            $Updates | ForEach-Object {
                [PSCustomObject]@{
                    PSTypeName    = 'PSP.Inventory.SecurityUpdate'
                    ComputerName  = $NewCimsession.ComputerName
                    KBFile        = $_.HotFixID
                    Type          = $_.Description
                    KBLink        = $_.Caption
                    InstalledBy   = $_.InstalledBy
                    InstallDate   = $_.InstalledOn
                    InventoryDate = (Get-Date)
                }
            }
        } catch {
            Write-Warning "[$Computer] - cannot be reached. $($_.Exception.Message)"
        }
    }
}
