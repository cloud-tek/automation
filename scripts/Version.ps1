#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$version
)



Push-Location -Path "$PSScriptRoot/../src/$module";

try {
  Write-Host "Settings $module version to $version ..." -ForegroundColor Gray;

  [string]$file = (Get-Content "./$module.psd1" -Raw -Encoding utf8);

    $file = $file.Replace("ModuleVersion = ""0.0.0""", "ModuleVersion = ""$($version)""");

    Set-Content "./$module.psd1" `
      -Value $file `
      -NoNewline;

    Write-Host "Done" -ForegroundColor Green;
}
catch {
  Write-Error "Failed to read $module.psd1 ... : $_";
  Exit 1;
}
finally {
  Pop-Location;
}
