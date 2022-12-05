#!/usr/local/bin/pwsh

# https://github.com/PowerShell/PowerShellGet/blob/master/help/Register-PSResourceRepository.md#example-3

[hashtable]$data = Import-PowerShellDataFile ./CloudTek.Automation.K8S.psd1

$data.RequiredModules | % {
  Register-LocalPSResourceRepository -name "$($_.ModuleName)-local" -path "$PSScriptRoot/../$($_.ModuleName)";
  Write-Host "`t Installing $($_.ModuleName) ($($_.ModuleVersion)) ..." -ForegroundColor Gray;

  #Get-PSResourceRepository -Name "$($_.ModuleName)-local";
  #Find-PSResource -Repository "$($_.ModuleName)-local" -Name $_.ModuleName;

  Write-Host "=== Before installation";
  Get-PSResourceRepository | Out-String | Write-Host;
  # -Repository "$($_.ModuleName)-local"
  Find-PSResource -Name "CloudTek*" | Out-String | Write-Host;


  # Install-PSResource -Name $_.ModuleName -Version $_.ModuleVersion -Repository "$($_.ModuleName)-local" -Verbose;

  Install-PSResource -RequiredResource @{
    "$($_.ModuleName)" = @{
      version = "$($_.ModuleVersion)"
      repository = "$($_.ModuleName)-local"
     }
  } -Verbose -Debug;

  Write-Host "=== Check after installation";
  Get-PSResource;
  # Invoke-Command -ScriptBlock {
  #   Install-PSResource -Name $_.ModuleName -Version $_.ModuleVersion -Repository "$($_.ModuleName)-local" -Verbose;
  # } -Retries 10 -Interval 10000;
}
