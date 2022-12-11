#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$url,
  [Parameter(Mandatory = $true)][string]$apikey,
  [Parameter(Mandatory = $true)][string]$version
)

[string]$packages = "$PSScriptRoot/../packages";
[string]$local = "local";

Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-PSGallery;
Register-PSResourceRepositories -url $url;
Register-LocalPSResourceRepository -name $local -path $packages;

Push-Location -Path "$PSScriptRoot/../packages"
try {
  # & ./PrePublish.ps1

  # Write-Host "=== Check after prepublish";
  # Get-PSResource;

  # Write-Host "Publishing: $module ==($version)==> nuget ..." -ForegroundColor Gray;

  Publish-PSResource -Path "$packages/$module/.nupkg" `
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
