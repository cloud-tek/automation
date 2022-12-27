#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$url,
  [Parameter(Mandatory = $true)][string]$apikey,
  [Parameter(Mandatory = $true)][string]$version,
  [Parameter(Mandatory = $false)][string]$prerelease
)

[string]$path = "$PSScriptRoot/../tmp/$module";
[string]$packages = "$PSScriptRoot/../packages";
[string]$local = "local";

Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-PSGallery;
Register-PSResourceRepositories -url $url;
Register-LocalPSResourceRepository -name $local -path $packages;

try {
  Push-Location -Path $path;

  & $PSScriptRoot/Version.ps1 -module $module -version $version -prerelease $prerelase;

  [hashtable]$data = Import-PowerShellDataFile "./$module.psd1"

  if ($null -ne $data.RequiredModules) {
    $data.RequiredModules | % {
      [string]$computedVersion = if([string]::IsNullOrEmpty($prerelease)) { $_.Version; } else { "$($_.Version)-$($prerelease.Replace(".", [string]::Empty))" }

      Install-Module -Repository "local" -Name $_.ModuleName -RequiredVersion $computedVersion -Verbose -Force;
    }
  }

  Publish-PSResource -Path $path `
    -Repository "nuget" `
    -ApiKey $apiKey `
    -Verbose `
    -SkipDependenciesCheck `
    -ErrorAction Stop;
}
catch {
  Write-Error "Failed to publish module $module : `n`t$_";
  Exit 1;
}
finally {
  Pop-Location;
}

Write-Host "Done" -ForegroundColor Green;
