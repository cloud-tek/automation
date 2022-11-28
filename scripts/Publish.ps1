#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$url,
  [Parameter(Mandatory = $true)][string]$apikey,
  [Parameter(Mandatory = $true)][string]$version
)

Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-PSGallery;
Register-NuGet -url $url;

Push-Location -Path "$PSScriptRoot/../src/$module"
try {
  & ./PrePublish.ps1

  Write-Host "Publishing: $module ==($version)==> nuget ..." -ForegroundColor Gray;

  Publish-PSResource -Path "$PSScriptRoot/../src/$module"`
    -Repository "nuget" `
    -ApiKey $apiKey `
    -Verbose `
    -ErrorAction SilentlyContinue;
}
catch {
  Write-Error "Failed to publish module $module : `n`t$_";
  Exit 1;
}
finally {
  Pop-Location;
}

Write-Host "Done" -ForegroundColor Green;
