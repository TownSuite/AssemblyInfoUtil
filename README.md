# AssemblyInfoUtil
Fork of https://www.codeproject.com/Articles/31236/How-To-Update-Assembly-Version-Number-Automaticall

# Increment version numbers

Can increment numbers the following file types.

* AssemblyInfo.vb
* AssemblyInfo.cs
* .csproj
* .vbproj


# Example


Major.Minor.Build


Increment the minor portion of the version number

```powershell
.\AssemblyInfoUtil.exe -inc:2 "D:\Path\to\the\file.csproj"
```
