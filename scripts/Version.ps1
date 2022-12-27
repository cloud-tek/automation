#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$version,
  [Parameter(Mandatory = $false)][string]$prerelease
)
Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;

Copy-Module -Module $module -Source "$PSScriptRoot/../src" -Destination "$PSScriptRoot/../tmp";

Push-Location -Path "$PSScriptRoot/../tmp/$module";

try {
  [string]$file = (Get-Content "./$module.psd1" -Raw -Encoding utf8);
    if(-not([string]::IsNullOrEmpty($prerelease))) {
      $prerelease = $prerelease.Replace(".", [string]::Empty);
      [string]$computedVersion = if ($version.EndsWith($prerelease)) { $version } else { "$($version)-$($prerelease)" };
      Write-Host "Settings $module version to $computedVersion ..." -ForegroundColor Gray;
      $file = $file.Replace("# Prerelease = ''", "Prerelease = '-$($prerelease)'");

      $file = $file.Replace("      ModuleVersion = ""0.0.0""", "      ModuleVersion = ""$($version)"""); # $computedVersion
    } else {
      Write-Host "Settings $module version to $version ..." -ForegroundColor Gray;
    }

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
