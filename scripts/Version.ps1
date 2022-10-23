#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$version
)



Push-Location -Path "$PSScriptRoot/../src/$module";

try {
  Write-Host "Settings $module version to $version ..." -ForegroundColor Gray;
  [string]$file = (Get-Content "./$module.psd1");
  $rgx = [regex]::matches($file, "\s*ModuleVersion\s=\s['""](\d*.\d*.\d*)['""]\s*");

  if($rgx.Count -eq 0) {
    throw "No ModuleVersion = 'major.minor.patch' found";
  } else {
    $file.Replace($rgx[0], "ModuleVersion = ""$($version)""");
    Set-Content "./$module.psd1" -Value $file;
    Write-Host "Done" -ForegroundColor Green;
  }
}
catch {
  Write-Error "Failed to read $module.psd1 ... : $_";
  Exit 1;
}
finally {
  Pop-Location;
}
