#!/usr/local/bin/pwsh

[string[]]$modules = @(
  "CloudTek.Automation.Shell"
);

$modules | % {
  Import-Module -Name "$PSScriptRoot/../$_" -Force;
}
