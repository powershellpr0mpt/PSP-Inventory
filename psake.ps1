# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
    $ProjectRoot = $env:BHProjectPath
    $ModuleName = $env:BHProjectName
    $ModuleVersion = (Get-Module -ListAvailable $env:BHPSModuleManifest).Version
    $TestsFolder = "$ProjectRoot\Tests"
    $TestsOutputFolder = "$ProjectRoot\_testresults\"
    $TestsOutput = "$TestsOutputFolder\Test_Help`_$TimeStamp.xml"
    $BuildFolder = "$ProjectRoot\_bin\$ModuleName"
    $VersionFolder = "$BuildFolder\$ModuleVersion"
    $ZipFolder = "$ProjectRoot\_zip"
}

Task default -Depends Build

Task Build {
    Write-Host "Building Module Structure"  -ForegroundColor Blue
    $FunctionsPublic = Get-ChildItem -Path $ProjectRoot\$ModuleName\Public -Recurse -Exclude *.Tests.* -File `
        | ForEach-Object -Process {Get-Content -Path $_.FullName; "`r`n"}
    $FunctionsPrivate = Get-ChildItem -Path $ProjectRoot\$ModuleName\Private -Recurse -Exclude *.Tests.* -File `
        | ForEach-Object -Process {Get-Content -Path $_.FullName; "`r`n"}

    If (-not (Test-Path $BuildFolder)) {
        Write-Host "Creating Build Folder"  -ForegroundColor Blue
        $Null = New-Item -Path $BuildFolder -Type Directory -Force
    } Else {
        Write-Host "Clearing Existing Build Folder  $BuildFolder"  -ForegroundColor Blue
        Remove-Item -Path $BuildFolder/* -Recurse -Force
    }
    Write-Host "Creating Version Folder"  -ForegroundColor Blue
    $Null = New-Item -Path $VersionFolder -Type Directory -Force

    If (-not (Test-Path $ZipFolder)) {
        Write-Host "Creating Zip Folder"  -ForegroundColor Blue
        $Null = New-Item -Path $ZipFolder -Type Directory -Force
    } Else {
        Write-Host "Clearing Existing Zip Folder  $ZipFolder"  -ForegroundColor Blue
        Remove-Item -Path $ZipFolder/* -Recurse -Force
    }

    Write-Host "Copying Module Manifest"  -ForegroundColor Blue
    $Null = Copy-Item -Path "$ProjectRoot\$ModuleName\" -Recurse -Destination $VersionFolder -Force

    Write-Host "Update the PSD1 FunctionsToExport for autoloading on build folder"  -ForegroundColor Blue
    Set-ModuleFunctions -Name "$VersionFolder\$ModuleName"

    Write-Host "Update the PSD1 FormatsToExport for applying custom formats on cmdlets" -ForegroundColor Blue
    Set-ModuleFormats -Name "$VersionFolder\$ModuleName" -FormatsRelativePath '.\formats'

    Write-Host "Module built, verifying module output" -ForegroundColor Blue
    Get-Module -ListAvailable "$VersionFolder\$ModuleName\$ModuleName.psd1" | ForEach-Object -Process {
        $ExportedFunctions = $_ `
            | Select-Object -Property @{ Name = "ExportedFunctions" ; Expression = { [string[]]$_.ExportedFunctions.Keys } } `
            | Select-Object -ExpandProperty ExportedFunctions
        $ExportedAliases = $_ `
            | Select-Object -Property @{ Name = "ExportedAliases"   ; Expression = { [string[]]$_.ExportedAliases.Keys   } } `
            | Select-Object -ExpandProperty ExportedAliases
        $ExportedVariables = $_ `
            | Select-Object -Property @{ Name = "ExportedVariables" ; Expression = { [string[]]$_.ExportedVariables.Keys } } `
            | Select-Object -ExpandProperty ExportedVariables
        Write-Output "Name              : $($_.Name)"
        Write-Output "Description       : $($_.Description)"
        Write-Output "Guid              : $($_.Guid)"
        Write-Output "Version           : $($_.Version)"
        Write-Output "ModuleType        : $($_.ModuleType)"
        Write-Output "ExportedFunctions : $ExportedFunctions"
        Write-Output "ExportedAliases   : $ExportedAliases"
        Write-Output "ExportedVariables : $ExportedVariables"
    }
}

Task Analyze -Depends Build {
    $saResults = Invoke-ScriptAnalyzer -Path $VersionFolder\$ModuleName\$ModuleName.psm1 -Severity @('Error') -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message 'One or more Script Analyzer errors where found.'
    }
}

Task Test -Depends Analyze {
    If (-not (Test-Path $TestsOutputFolder)) {
        Write-Host "Creating Tests Output Folder"  -ForegroundColor Blue
        $Null = New-Item -Path $TestsOutputFolder -Type Directory -Force
    }

    Write-Host "Removing Test Output > 5 runs ago"
    Get-ChildItem $TestsOutputFolder -Recurse | Where-Object {-not $_.PSIsContainer} | Sort-Object CreationTime -Descending | Select-Object -Skip 5 | Remove-Item -Force

    Write-Host "Testing Module"  -ForegroundColor Blue
    $HelpResults = Invoke-Pester $TestsFolder -OutputFormat NUnitXml -OutputFile $TestsOutput -PassThru
    If ($HelpResults.FailedCount -gt 0) {
        Exit $HelpResults.FailedCount
    }
}

Task WinZip -depends Test {
    $FileName = "$ZipFolder\$ModuleName.$ModuleVersion.zip"
    Compress-Archive -Path "$VersionFolder\$ModuleName\" -DestinationPath $FileName -Force
}