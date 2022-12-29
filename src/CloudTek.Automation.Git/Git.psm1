
Import-Module $PSScriptRoot/ArgoCD-Utils.psm1 -Force;

function Get-GitRepository() {
  [CmdLetBinding()]
  [OutputType([string[]])]
  param(
    [Parameter(Mandatory = $true)][string]$Repository,
    [Parameter(Mandatory = $true)][string]$Branch,
    [Parameter(Mandatory = $true)][string]$Checkout,
    [Parameter(Mandatory = $true)][string]$Name

  )
  Set-StrictMode -Version Latest;
  $ErrorActionPreference = "Stop";

  Get-Command -Cmd "git";
  Get-Folder -Path $Checkout -Create;

  try {
    Push-Location -Path $Checkout;
    & git clone $repository $Name
    & git checkout $Branch
  }
  finally {
    Pop-Location;
  }
}

Export-ModuleMember -Function Get-GitRepository;
