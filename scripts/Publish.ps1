#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$url,
  [Parameter(Mandatory = $true)][string]$apikey,
  [Parameter(Mandatory = $true)][string]$version
)

#[string]$version = "3.0.17-beta17"
#Install-Module PowershellGet -Force -AllowPrerelease;# -RequiredVersion $version;
# Remove-Module -Name PowershellGet;
Import-Module -Name "/home/runner/.local/share/powershell/Modules/PowerShellGet/3.0.17/PowerShellGet.psd1" -Force; # -RequiredVersion $version;

Get-Command -Module PowershellGet | Select-Object -Property name, version -First 3

# https://stackoverflow.com/questions/63385304/powershell-install-no-match-was-found-for-the-specified-search-criteria-and-mo
Write-Host "Registering PSRepository (PSGallery) ..." -ForegroundColor Gray;
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

  $PSVersionTable;

  Get-Module;
  #Get-InstalledModule;


Write-Host "Publishing: $module ==($version)==> $name ..." -ForegroundColor Gray;

Publish-Module -Path "$PSScriptRoot/../src/$module"`
  -Repository $name `
  -NuGetApiKey $apiKey `
  -ErrorAction Continue
  -Force `
  -Verbose;

  Get-Error;
}
catch {
  Write-Error "Failed to publish module $module : `n`t$_";
  Exit 1;
}
finally {
  Pop-Location;
}

Write-Host "Done" -ForegroundColor Green;
