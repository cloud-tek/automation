#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$url,
  [Parameter(Mandatory = $true)][string]$apikey,
  [Parameter(Mandatory = $false)][string]$organization
)

Install-Module PowershellGet -Force;
Import-Module PowershellGet;

$sourceName = "NuGet";
$source = $url

Register-PSRepository -Name $sourceName -SourceLocation $source -PublishLocation $source; #-Credential $creds;

$apiKey = $apiKey; # 'n/a' # keep this as n/a!

Write-Host "Publishing..."
Publish-Module -Path "./$module" `
  -Repository $sourceName `
  -NuGetApiKey $apiKey `
  -Force `
  -Verbose;

#   -Credential $creds `
