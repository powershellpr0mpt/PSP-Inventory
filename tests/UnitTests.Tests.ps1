Write-Host "Using BuildHelpers Variables" -ForegroundColor Yellow
# build vars
$ProjectRoot = $env:BHProjectPath
$ModuleName = $env:BHProjectName
$ModuleVersion = (Get-Module -ListAvailable $env:BHPSModuleManifest).Version
$BuildFolder = "$ProjectRoot\_bin\$ModuleName"
$VersionFolder = "$BuildFolder\$ModuleVersion\$ModuleName"
## testing vars
$ModuleManifestName = "$ModuleName.psd1"
$ModulePath = "$VersionFolder\$ModuleManifestName"

Import-Module $ModulePath -Force

Describe 'Module Manifest Test' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModulePath | Should Be $true
    }
}

Describe 'Module Imported Test' {
    It 'Confirms Module Is Loaded' {
        (Get-Module $ModuleName) -eq $null | Should Be $false
    }
}