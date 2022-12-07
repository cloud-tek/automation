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
  [Parameter(Mandatory = $true)][string]$modules
)

Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-PSGallery;
Register-LocalRepository;

try {
  $list = ConvertFrom-Json -InputObject $modules;
} catch {
  Write-Error "Failed to deserialize module list : $_  : $modules";
  Exit 1;
}

$list | % {
  try {
    Push-Location -Path "$PSScriptRoot/../src/$($_.id)"

    Get-PSRepository -Name "local";

    [hashtable] $publishArgs = @{
      Repository = "local"
      Path = "$PSScriptRoot/../src/$($_.id)"
    };

    Publish-Module @publishArgs;
  }
  catch {
    Write-Error "Failed to publish module locally, $($_.id) : `n`t$_";
    Exit 1;
  }
  finally {
    Pop-Location;
  }
}

Write-Host "Done" -ForegroundColor Green;
