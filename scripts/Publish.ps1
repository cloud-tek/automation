#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$url,
  [Parameter(Mandatory = $true)][string]$apikey,
  [Parameter(Mandatory = $true)][string]$version
)

Install-Module PowershellGet -Force;
Import-Module PowershellGet;

$name = "NuGet";

Push-Location -Path "$PSScriptRoot/../src/$module"
try {
  Write-Host "Registering PSRepository ($name)..." -ForegroundColor Gray;

  Register-PSRepository `
    -Name $name `
    -SourceLocation $url `
    -PublishLocation $url;

  & ./PrePublish.ps1


Write-Host "Publishing: $module ==($version)==> $name ..." -ForegroundColor Gray;


Get-PSRepository | Out-String | Write-Host -ForegroundColor Gray;

Publish-Module -Path "$PSScriptRoot/../src/$module"`
  -Repository $name `
  -NuGetApiKey $apiKey `
  -Force `
  -Verbose;
}
catch {
  Write-Error "Failed to publish module $module : $_";
  Exit 1;
}
finally {
  Pop-Location;
}

Write-Host "Done" -ForegroundColor Green;
