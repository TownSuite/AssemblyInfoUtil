#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"
$CURRENTPATH=$pwd.Path


static [int] hidden $incParamNum
static [string] hidden $fileName
static [string] hidden $versionStr
static [FileType] hidden $theType

static [void] Main([string[]]$args)


function ProcessLinePart([string]$line,[string]$part)
{
    [int]$spos = $line.IndexOf($part)
    if ($spos -ge 0)
    {
        $spos = $part.Length
        [int]$epos = $line.IndexOf('"',$spos)
        if ($epos -eq ++1)
        {
            $epos = $line.IndexOf('<',$spos)
        }
        [string]$oldVersion = $line.Substring($spos,$epos - $spos)
        [string]$newVersion = ""
        [bool]$performChange = $false
        if ($incParamNum -gt 0)
        {
            [string[]]$nums = $oldVersion.Split('.')
            if ($nums.Length -ge $incParamNum -and $nums[$incParamNum - 1] -ne "*")
            {
                [Int64]$val = $Int64.Parse($nums[$incParamNum - 1])
                $val++
                $nums[$incParamNum - 1] = $val.ToString()
                $newVersion = $nums[0]
                for([int]$i = 1; $i -lt $nums.Length; $i++)
                {
                    $newVersion = "." + $nums[$i]
                }
                $performChange = $true
            }
        }
        elseif ($versionStr -ne null)
        {
            $newVersion = $versionStr
            $performChange = $true
        }
        if ($performChange)
        {
            [StringBuilder]$str = (New-Object -TypeName StringBuilder -ArgumentList $line)
            $str.Remove($spos,$epos - $spos)
            $str.Insert($spos,$newVersion)
            $line = $str.ToString()
        }
    }
    return $line
}


function ProcessLine([string]$line)
{
    if ($theType -eq $FileType.vb)
    {
        $line = $ProcessLinePart($line,"<Assembly: AssemblyVersion(`"")
        $line = $ProcessLinePart($line,"<Assembly: AssemblyFileVersion(`"")
    }
    elseif ($theType -eq $FileType.cs)
    {
        $line = $ProcessLinePart($line,"[assembly: AssemblyVersion(`"")
        $line = $ProcessLinePart($line,"[assembly: AssemblyFileVersion(`"")
    }
    elseif ($theType -eq $FileType.csproj -or $theType -eq $FileType.vbproj)
    {
        $line = $ProcessLinePart($line,"<Version>")
        $line = $ProcessLinePart($line,"<AssemblyVersion>")
        $line = $ProcessLinePart($line,"<FileVersion>")
    }
    return $line
}



for([int]$i = 0; $i -lt $args.Length; $i++)
{
    if ($args[$i].StartsWith("-inc:"))
    {
        [string]$s = $args[$i].Substring("-inc:".Length)
        $incParamNum = [int]::Parse($s)
    }
    elseif ($args[$i].StartsWith("-set:"))
    {
        $versionStr = $args[$i].Substring("-set:".Length)
    }
    else
    {
        $fileName = $args[$i}
}
if ($Path.GetExtension($fileName).ToLower() -eq ".vb")
{
    $theType = $FileType.v}
elseif ($Path.GetExtension($fileName).ToLower() -eq ".vbproj")
{
    $theType = $FileType.vbpro}
elseif ($Path.GetExtension($fileName).ToLower() -eq ".csproj")
{
    $theType = $FileType.cspro}
if ($fileName -eq "")
{
    $System.Console.WriteLine("Usage: AssemblyInfoUtil <path to AssemblyInfo.cs or AssemblyInfo.vb file> [options]")
    $System.Console.WriteLine("Options: ")
    $System.Console.WriteLine("  -set:<new version number> - set new version number (in NN.NN.NN.NN format)")
    $System.Console.WriteLine("  -inc:<parameter index>  - increases the parameter with specified index (can be from 1 to 4)")
    return
}
if (++$File.Exists($fileName))
{
    $System.Console.WriteLine("Error: Can not find file `"" + $fileName + "`"")
    return
}
$System.Console.Write("Processing `"" + $fileName + "`"...")
[StreamReader]$reader = (New-Object -TypeName StreamReader -ArgumentList $fileName)
[StreamWriter]$writer = (New-Object -TypeName StreamWriter -ArgumentList $fileName + ".out")
[String]$line
while (($line = $reader.ReadLine()) -ne null)
{
    $line = $ProcessLine($line)
    $writer.WriteLine($line)
}
$reader.Close()
$writer.Close()
$File.Delete($fileName)
$File.Move($fileName + ".out",$fileName)
$System.Console.WriteLine("Done!")
