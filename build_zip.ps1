#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$CURRENTPATH = $pwd.Path

$xml = [xml](Get-Content "$CURRENTPATH/src/TownSuite.AssemblyInfoUtil.csproj")
$VERSION = $xml.Project.PropertyGroup.Version

# for each folder within build, create a zip file with the version and folder name
Get-ChildItem -Path "$CURRENTPATH/build" -Directory | ForEach-Object {
    $folderPath = $_.FullName
    $zipPath = "$CURRENTPATH/build/$($_.Name).v$VERSION.zip"
    if (Test-Path -Path $zipPath) {
        Remove-Item -Path $zipPath -Force
    }
    Compress-Archive -Path "$folderPath" -DestinationPath $zipPath
}
