#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module #,
  # [Parameter(Mandatory = $true)][string]$url,
  # [Parameter(Mandatory = $true)][string]$apikey,
  # [Parameter(Mandatory = $true)][string]$version
)

Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-PSGallery;
Register-LocalRepository;

try {
  Push-Location -Path "$PSScriptRoot/../src/$module"

  Get-PSRepository -Name "local";

  [hashtable] $publishArgs = @{
    Repository = "local"
    Path = "$PSScriptRoot/../src/$module"
  };

  Publish-Module @publishArgs;
}
catch {
  Write-Error "Failed to publish module locally, $module : `n`t$_";
  Exit 1;
}
finally {
  Pop-Location;
}

Write-Host "Done" -ForegroundColor Green;
