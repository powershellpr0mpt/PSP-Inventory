<#
    .DESCRIPTION
        Loader file for functions in PSP-Inventory module.

    .NOTES

        Name: PSP-Inventory
        Author: Robert Prust
        Version: 1.0.2
        Blog: https://powershellpr0mpt.com

    .LINK
        https://powershellpr0mpt.com
#>

#Function Loader
[cmdletbinding()]
param()
Write-Verbose $PSScriptRoot

Write-Verbose 'Import Private Functions'
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

Write-Verbose 'Import Public Functions'
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($Function in @($Public + $Private)) {
    Try {
        . $Function.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($Function.FullName): $_"
    }
}

### Export Public functions
Export-ModuleMember -Function $Public.Basename
