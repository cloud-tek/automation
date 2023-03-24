#!/usr/local/bin/pwsh

<#
[
  {
    "id": "CloudTek.Automation.Shell"
  },
  {
    "id": "CloudTek.Automation.K8S"
  }
]
#>

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $false)][string]$version = "0.0.0",
  [Parameter(Mandatory = $false)][string]$prerelease
)

Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.19";

Register-PSGallery;
Register-LocalRepository;

try {
  & $PSScriptRoot/Version.ps1 -module $module -version $version -prerelease $prerelease;

  Get-PSRepository -Name "local";
  Push-Location -Path "$PSScriptRoot/../tmp/$module"
  [hashtable]$data = Import-PowerShellDataFile "./$module.psd1"

  if ($null -ne $data.RequiredModules) {
    $data.RequiredModules | % {
      & $PSScriptRoot/Publish-Local.ps1 -module $_.ModuleName -version $_.ModuleVersion -prerelease $prerelease;

      [string]$computedVersion = if ([string]::IsNullOrEmpty($prerelease)) { $_.Version; } else { "$($_.Version)-$($prerelease.Replace(".", [string]::Empty))" }

      Install-Module -Repository "local" -Name $_.ModuleName -RequiredVersion $version -Verbose -Force;
    }
  }

  if (-not(Test-Path -Path "$PSScriptRoot/../packages/$module.$version.nupkg")) {
    [hashtable] $publishArgs = @{
      Repository = "local"
      Path       = "$PSScriptRoot/../tmp/$module"
      Force      = $true
    };

    Get-Location | Out-String | Write-Host;
    Publish-Module @publishArgs;
  }
}
catch {
  Write-Error "Failed to publish module locally, $module : `n`t$_";
  Exit 1;
}
finally {
  Pop-Location;
}


Write-Host "Done" -ForegroundColor Green;
