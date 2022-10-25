#!/usr/local/bin/pwsh

[string[]]$modules = @(
  "CloudTek.Automation.Shell"
);

$modules | % {
  Write-Host "Registering PSRepository ($_) ..." -ForegroundColor Gray;
  Write-Host "`t Installing $_ ..." -ForegroundColor Gray;
  Register-PSRepository -Name $_ -SourceLocation "$PSScriptRoot/../$_";
  Write-Host "repo registered";
  Get-PSRepository;

  Find-Module -Name "CloudTek.Automation.K8S"

  Install-Module $_ -Repository $_;
  Write-Host "module installed"
}
