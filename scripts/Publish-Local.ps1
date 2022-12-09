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
  [Parameter(Mandatory = $false)][string]$version = "0.0.0"
)

Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-PSGallery;
Register-LocalRepository;

try {
  Push-Location -Path "$PSScriptRoot/../src/$module"

  Get-PSRepository -Name "local";

  & $PSScriptRoot/Version.ps1 -module $module -version $version;

  [hashtable]$data = Import-PowerShellDataFile "./$module.psd1"

  if ($null -ne $data.RequiredModules) {
    $data.RequiredModules | % {
      & $PSScriptRoot/Publish-Local.ps1 -module $_.ModuleName -version $_.ModuleVersion;

      Install-Module -Repository "local" -Name $_.ModuleName -RequiredVersion $_.Version -Verbose -Force;
    }
  }

  [hashtable] $publishArgs = @{
    Repository  = "local"
    Path        = "$PSScriptRoot/../src/$module"
    Force       = $true
  };

  Get-Location | Out-String | Write-Host;
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
