#!/usr/local/bin/pwsh

[string[]]$modules = @(
  "CloudTek.Automation.Shell"
);

$modules | % {
  Register-PSRepository -Name $_ -SourceLocation "$PSScriptRoot/../$_";
  Install-Module $_ -Repository $_
}
