#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$CURRENTPATH = $pwd.Path

function GetVersions([ref]$theVersion, [ref]$path) {	
	# Read the content of the file and find the line containing <Version>
	$versionLine = Get-Content -Path $path.Value | Select-String -Pattern "<Version>"

	# Extract the version number using a regular expression
	if ($versionLine -match "<Version>([0-9.]+)</Version>") {
		$VERSION = $matches[1]
	} else {
		Write-Error "Version tag not found in the file."
	}

    $theVersion.Value = $VERSION
}

New-Item -Path "$CURRENTPATH/build" -ItemType Directory -Force
dotnet build src/AssemblyInfoUtils.sln -c Release

# net10.0 windows self-contained, single file, aot, build output for distribution
dotnet publish src/TownSuite.AssemblyInfoUtil.csproj -c Release -f net10.0 -o "$CURRENTPATH/build/TownSuite.AssemblyInfoUtils"

$VERSION = ""
GetVersions -theVersion ([ref]$VERSION) -path ([ref]"$CURRENTPATH/src/TownSuite.AssemblyInfoUtil.csproj")
Add-Content "$CURRENTPATH/build/parameterproperties.txt" "VERSION=$VERSION"
Add-Content "$CURRENTPATH/build/parameterproperties.txt" "GITHASH=$(git rev-parse --short HEAD)"
Add-Content "$CURRENTPATH/build/parameterproperties.txt" "GITHASH_FULL=$(git rev-parse HEAD)"
