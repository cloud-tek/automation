Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.19";

Register-LocalPSResourceRepository -name "local" -path "$PSScriptRoot/../packages";

Get-PsResourceRepository;

Get-PSRepository -Name "local" | Out-String | Write-Host;

Get-PSResource -Name "CloudTek.Automation.Shell" -Repository "local" | Out-String | Write-Host;
Get-PSResource -Name "CloudTek.Automation.K8S" -Repository "local" | Out-String | Write-Host;
