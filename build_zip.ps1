#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$CURRENTPATH = $pwd.Path


# for each folder within build, create a zip file with the same name as the folder
Get-ChildItem -Path "$CURRENTPATH/build" -Directory | ForEach-Object {
    $folderPath = $_.FullName
    $zipPath = "$CURRENTPATH/build/$($_.Name).zip"
    if (Test-Path -Path $zipPath) {
        Remove-Item -Path $zipPath -Force
    }
    Compress-Archive -Path "$folderPath" -DestinationPath $zipPath
}
