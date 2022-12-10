Import-Module -Name "$PSScriptRoot/Utils.psm1" -Force;
Import-PowerShellGet -Version "3.0.17";

function Register-LocalRepository() {
  [string]$p = "$PSScriptRoot/../packages";

  [hashtable]$arguments = @{
    Name = "local"
    SourceLocation = $p
    PublishLocation = $p
    InstallationPolicy = "Trusted"
    ErrorAction = "SilentlyContinue"
  };

  Register-PSRepository @arguments;
}

Get-PsResourceRepository;

Get-PSRepository -Name "local";

Find-PSResource -Name "CloudTek*"
