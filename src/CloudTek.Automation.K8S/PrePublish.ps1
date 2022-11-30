#!/usr/local/bin/pwsh

# https://github.com/PowerShell/PowerShellGet/blob/master/help/Register-PSResourceRepository.md#example-3

[hashtable]$data = Import-PowerShellDataFile ./CloudTek.Automation.K8S.psd1

$data.RequiredModules | % {
  Register-LocalPSResourceRepository -name "$($_.ModuleName)-local" -path "$PSScriptRoot/../$($_.ModuleName)";
  Write-Host "`t Installing $($_.ModuleName) ($($_.ModuleVersion)) ..." -ForegroundColor Gray;

  Get-PSResourceRepository;
  Find-PSResource -Repository "$($_.ModuleName)-local";

  Install-PSResource -Name $_.ModuleName -Version $_.ModuleVersion -Repository "$($_.ModuleName)-local" -Verbose;
  # Invoke-Command -ScriptBlock {
  #   Install-PSResource -Name $_.ModuleName -Version $_.ModuleVersion -Repository "$($_.ModuleName)-local" -Verbose;
  # } -Retries 10 -Interval 10000;
}
