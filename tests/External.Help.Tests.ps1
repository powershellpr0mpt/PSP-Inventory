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

Get-Module $ModuleName | Remove-Module

Import-Module $ModulePath -Force

Describe -Name 'Check external help' {
    $cmds = Get-Command -Module $ModuleName
    foreach ($cmdlet in $cmds){
        $help = Get-Help $cmdlet
        It "$cmdlet has external help defined" {
            $help.Description | Should -Not -BeNullOrEmpty
        }
        It "$cmdlet has at least one example defined" {
            $help.Examples | Should -Not -BeNullOrEmpty
        }
    }
}