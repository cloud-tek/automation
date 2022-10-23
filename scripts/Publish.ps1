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

Write-Host "Registering PSRepository ($name)..." -ForegroundColor Gray;

Register-PSRepository `
  -Name $name `
  -SourceLocation $url `
  -PublishLocation $url;

Write-Host "Publishing: $module ==($version)==> $name ..." -ForegroundColor Gray;

Publish-Module -Path "./$module" `
  -Repository $name `
  -NuGetApiKey $apiKey `
  -Force `
  -Verbose;

Write-Host "Done" -ForegroundColor Green;
