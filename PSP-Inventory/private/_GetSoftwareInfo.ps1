function _GetSoftwareInfo {
    [cmdletbinding()]
    Param(
        [System.Management.Automation.Runspaces.PSSession]$PSSession
    )
    Write-Verbose "[$($PSSession.ComputerName)] - Gathering Software information"
    $Programs = Invoke-Command -Session $PSSession -ScriptBlock {
        $Keys = @('HKLM:\SOFTWARE\Microsoft\Windows\Currentversion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\Currentversion\Uninstall\*')
        Get-ItemProperty -Path $Keys -ErrorAction SilentlyContinue
    }
    foreach ($Program in $Programs) {
        if ($Program.DisplayName -AND $Program.DisplayName -notmatch '^Update for|rollup|^Security Update|^Service Pack|^HotFix') {
            [PSCustomObject]@{
                PSTypeName      = 'PSP.Inventory.Software'
                ComputerName    = $PSSession.ComputerName
                DisplayName     = $Program.DisplayName
                Version         = $Program.DisplayVersion
                InstallDate     = if ($Program.InstallDate) {try {[datetime]::ParseExact($($Program.InstallDate), 'yyyyMMdd', [System.Globalization.CultureInfo]::InvariantCulture)}catch{$null}} else {$null}
                Publisher       = $Program.Publisher
                UninstallString = $Program.UninstallString
                InstallLocation = $Program.InstallLocation
                InstallSource   = $Program.InstallSource
                HelpLink        = $Program.HelpLink
                EstimatedSize   = [math]::Round(($Program.EstimatedSize * 1024) / 1MB, 2)
                InventoryDate   = (Get-Date)
            }
        }
    }
}
