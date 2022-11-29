#!/usr/local/bin/pwsh

[string]$Repository = "nuget";

[hashtable]$data = Import-PowerShellDataFile ./CloudTek.Automation.K8S.psd1

$data.RequiredModules | % {
  Write-Host "`t Installing $($_.ModuleName) ($($_.ModuleVersion)) ..." -ForegroundColor Gray;

  Invoke-Command -ScriptBlock {
    Install-PSResource -Name $_.ModuleName -Version $_.ModuleVersion -Repository $Repository -Verbose;
  } -Retries 5 -Interval 10000;
}
