#!/usr/local/bin/pwsh

[string[]]$modules = @(
  "CloudTek.Automation.Shell"
);

$modules | % {
  Write-Host "Registering PSRepository ($_) ..." -ForegroundColor Gray;
  Write-Host "`t Installing $_ ..." -ForegroundColor Gray;
  Register-PSRepository -Name $_ -SourceLocation "$PSScriptRoot/../$_";
  Install-Module $_ -Repository $_
}
