#!/usr/local/bin/pwsh

[string[]]$modules = @(
  "CloudTek.Automation.Shell"
);

$modules | % {
  Write-Host "Registering PSRepository ($_) ..." -ForegroundColor Gray;
  Write-Host "`t Installing $_ ..." -ForegroundColor Gray;

  #Register-PSRepository -Name $_ -SourceLocation "$PSScriptRoot/../$_";
  Register-PSResourceRepository -Name "NuGetGallery" -Uri "https://api.nuget.org/v3/index.json" -Trusted

  Get-PSRepository;

  Get-Module -ListAvailable PowerShellGet,PackageManagement;

  #Install-Module $_ -Repository $_ -MinimumVersion "0.0.0" -Verbose -ErrorAction Break;
  Install-PSResource -Name "CloudTek.Automation.Shell" -Version "0.1.119" -Repository NuGetGallery -Verbose
}
