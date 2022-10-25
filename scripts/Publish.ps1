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

# https://stackoverflow.com/questions/63385304/powershell-install-no-match-was-found-for-the-specified-search-criteria-and-mo
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Unregister-PSRepository -Name PSGallery
Register-PSRepository -Default

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
  Write-Error "Failed to publish module $module : `n`t$_";
  Exit 1;
}
finally {
  Pop-Location;
}

Write-Host "Done" -ForegroundColor Green;
