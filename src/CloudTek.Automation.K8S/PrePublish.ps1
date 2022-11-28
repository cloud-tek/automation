#!/usr/local/bin/pwsh

[hashtable]$data = Import-PowerShellDataFile ./CloudTek.Automation.K8S.psd1

$data.RequiredModules | % {
  Write-Host "`t Installing $($_.Module) ($($_.ModuleVersion)) ..." -ForegroundColor Gray;
  Install-PSResource -Name $_.ModuleName -Version $_.ModuleVersion -Repository NuGetGallery -Verbose
}

# [string[]]$modules = @(
#   "CloudTek.Automation.Shell"
# );

# $modules | % {
#   Write-Host "Registering PSRepository ($_) ..." -ForegroundColor Gray;
#   Write-Host "`t Installing $_ ..." -ForegroundColor Gray;

#   #Register-PSRepository -Name $_ -SourceLocation "$PSScriptRoot/../$_";

#   Get-PSRepository;

#   Get-Module -ListAvailable PowerShellGet,PackageManagement;

#   #Install-Module $_ -Repository $_ -MinimumVersion "0.0.0" -Verbose -ErrorAction Break;
#   Install-PSResource -Name "CloudTek.Automation.Shell" -Version "0.1.119" -Repository NuGetGallery -Verbose
# }
