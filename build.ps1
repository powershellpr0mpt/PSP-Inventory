[cmdletbinding()]
param(
    [ValidateSet('Default', 'Build', 'Analyze', 'Test', 'WinZip')]
    $Task = 'Default'
)

Write-Host "Importing Modules:" -ForegroundColor Yellow
$Modules = @('Psake', 'BuildHelpers', 'Pester', 'PSScriptAnalyzer', 'PSDeploy')


ForEach ($Module in $Modules) {
    Write-Host "...$Module" -ForegroundColor Yellow
    try {
        $InstallModuleParams = @{
            Name  = $Module
            Scope = 'CurrentUser'
            Force = $true
        }
        if ($Module -eq 'Pester') {
            $InstallModuleParams.SkipPublisherCheck = $true
        }
        $null = Find-Module $Module -ErrorAction Stop
        $null = Install-Module @InstallModuleParams
        Write-Host "...Importing" -ForegroundColor Green
        Import-Module $Module
        Write-Host "...Complete" -ForegroundColor Green
    }
    catch {
        Write-Host "...Not Found!" -ForegroundColor Red
        Write-Error -Message $_ -ErrorAction Stop
    }
}
Write-Host "Completed Importing Modules`r`n" -ForegroundColor Green

Push-Location $PSScriptRoot
Write-Verbose "Cleaning current Build variables"
Get-ChildItem -Path env:\bh* | Remove-Item
Write-Verbose "Setting Build Variables"
Set-BuildEnvironment

Write-Host "Executing PSake Build`r`n" -ForegroundColor Green

Invoke-Psake -buildFile .\psake.ps1 -properties $PSBoundParameters -noLogo -taskList $Task
exit ( [int]( -not $psake.build_success ) )
