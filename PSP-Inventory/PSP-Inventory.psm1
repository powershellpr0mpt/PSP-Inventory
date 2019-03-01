<#
    .DESCRIPTION
        Loader file for functions in PSP-Inventory module.

    .NOTES

        Name: PSP-Inventory
        Author: Robert Prust
        Version: 0.9.1
        Blog: https://powershellpr0mpt.com

    .LINK
        https://powershellpr0mpt.com
#>

#Function Loader
[cmdletbinding()]
param()
Write-Verbose $PSScriptRoot

Write-Verbose 'Import Private Functions'

if (Test-Path "$PSScriptRoot\Private") {
    $FunctionList = Get-ChildItem -Path "$PSScriptRoot\Private";

    foreach ($File in $FunctionList) {
        . $File.FullName;
        Write-Verbose -Message ('Importing private function file: {0}' -f $File.FullName);
    }
}

Write-Verbose 'Import Public Functions'

if (Test-Path "$PSScriptRoot\Public") {
    $FunctionList = Get-ChildItem -Path "$PSScriptRoot\Public";

    foreach ($File in $FunctionList) {
        . $File.FullName;
        Write-Verbose -Message ('Importing public function file: {0}' -f $File.FullName);
    }
}

### Export all functions
Export-ModuleMember -Function *;
