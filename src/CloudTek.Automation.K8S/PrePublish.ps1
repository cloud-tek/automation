#!/usr/local/bin/pwsh

# https://github.com/PowerShell/PowerShellGet/blob/master/help/Register-PSResourceRepository.md#example-3

[hashtable]$data = Import-PowerShellDataFile ./CloudTek.Automation.K8S.psd1

$data.RequiredModules | % {
  [string]$repository =  "$($_.ModuleName)-local";
  [string]$path = Resolve-Path -Path "$PSScriptRoot/../$($_.ModuleName)";

  if(!(Test-Path -PathType container "$path/artifacts"))
  {
    New-Item -ItemType Directory -Path "$path/artifacts";
  }

  Register-LocalPSResourceRepository -name $repository -path "$path/artifacts";
  Write-Host "`t Installing $($_.ModuleName) ($($_.ModuleVersion)) ..." -ForegroundColor Gray;

  Write-Host "=== Before save-psresource";
  Save-PSResource `
    -Name $_.ModuleName `
    -Repository $repository `
    -Version $_.ModuleVersion `
    -Path $path `
    -AsNupkg -Verbose;
  Write-Host "=== After save-psresource";
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
