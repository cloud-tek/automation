Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-LocalRepository;

Get-PsResourceRepository;

Get-PSRepository -Name "local";

Find-PSResource -Name "CloudTek*"
