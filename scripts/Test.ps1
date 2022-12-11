Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

Register-LocalPSResourceRepository -name "local" -path "$PSScriptRoot/../packages";

Get-PsResourceRepository;

Get-PSRepository -Name "local";

Find-PSResource -Repository "local";
