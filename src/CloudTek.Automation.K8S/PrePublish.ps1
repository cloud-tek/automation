#!/usr/local/bin/pwsh

[string[]]$modules = @(
  "CloudTek.Automation.Shell"
);

Write-Host "Installing required modules..." -ForegroundColor Gray;

$modules | % {
  Write-Host "`t $_" -ForegroundColor Gray;
  Register-PSRepository -Name $_ -SourceLocation "$PSScriptRoot/../$_";
  Install-Module $_ -Repository $_
}
