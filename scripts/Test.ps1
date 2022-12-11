Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-LocalPSResourceRepository -name "local" -path "$PSScriptRoot/../packages";

Get-PsResourceRepository;

Get-PSRepository -Name "local" | Out-String | Write-Host;

#Get-PSResource -Name "local";

Find-PSResource -Name "CloudTek.Automation.Shell" -Repository "local" | Out-String | Write-Host;
Find-PSResource -Name "CloudTek.Automation.K8S" -Repository "local" | Out-String | Write-Host;
