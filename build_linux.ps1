#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$CURRENTPATH = $pwd.Path

New-Item -Path "$CURRENTPATH/build" -ItemType Directory -Force
dotnet build src/AssemblyInfoUtils.sln -c Release

# net10.0 linux self-contained, single file, aot build output for distribution
dotnet publish src/TownSuite.AssemblyInfoUtil.csproj -c Release -r "linux-x64" --self-contained true -p:PublishSingleFile=true -f net10.0 -o "$CURRENTPATH/build/TownSuite.AssemblyInfoUtils.Linux"    

