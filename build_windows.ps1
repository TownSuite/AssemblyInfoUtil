#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$CURRENTPATH = $pwd.Path

New-Item -Path "$CURRENTPATH\build" -ItemType Directory -Force
dotnet build src\AssemblyInfoUtils.sln -c Release

# net10.0 windows self-contained, single file, aot, build output for distribution
dotnet publish src\TownSuite.AssemblyInfoUtil.csproj -c Release -r "win-x64" --self-contained true -p:PublishSingleFile=true -p:PublishAot=true -f net10.0 -p:StripSymbols=true -p:DebugType=None -p:CopyOutputSymbolsToPublishDirectory=false -p:DebugType=None -o "$CURRENTPATH\build\TownSuite.AssemblyInfoUtils.Windows"
