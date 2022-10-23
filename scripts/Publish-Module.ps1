#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$url,
  [Parameter(Mandatory = $true)][string]$apikey,
  [Parameter(Mandatory = $false)][string]$organization
)

Install-Module PowershellGet;
Import-Module PowershellGet;

$sourceName = "NuGet";
$source = $url
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, (ConvertTo-SecureString -AsPlainText $password -Force);
Register-PSRepository -Name $sourceName -SourceLocation $source -PublishLocation $source -Credential $creds;

$version = '0.0.1'
$apiKey = $apiKey; # 'n/a' # keep this as n/a!

Write-Host "Publishing..."
Publish-Module -Path "./$module" -Repository $sourceName -Credential $creds -Force -NuGetApiKey $apiKey -Verbose;
