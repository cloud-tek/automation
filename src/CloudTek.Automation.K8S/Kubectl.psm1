Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

# [hashtable]$modules = @{
#   "CloudTek.Automation.Shell" = "Shell.psm1"
#   "CloudTek.Automation.Utilities" = "Utilities.psm1"
# };

# $modules.Keys | % {
#   if(Test-Path $PSScriptRoot/../$_/$modules[$_]) {
#     Import-Module $PSScriptRoot/../$_/$modules[$_] -Force;
#   } else {
#     Import-Module $_;
#   }
# }

function Invoke-KubectlApply {
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $false)][string]$Namespace,
    [Parameter(Mandatory = $false)][switch]$Recursive,
    [Parameter(Mandatory = $false)][string]$KubeConfig,
    [Parameter(Mandatory = $false)][string]$Context,
    [Parameter(Mandatory = $false)][switch]$DryRun
  )

  Set-StrictMode -Version Latest;
  $ErrorActionPreference = "Stop";

  Get-Command -Cmd "kubectl" -Throw;

  [System.Collections.Generic.List[string]]$arguments = New-Object System.Collections.Generic.List[string];

  if (-not([string]::IsNullOrEmpty($KubeConfig))) {
    $arguments.Add("--kubeconfig $KubeConfig");
  }

  if (-not([string]::IsNullOrEmpty($Context))) {
    $arguments.Add("--context $Context");
  }

  if (-not([string]::IsNullOrEmpty($Namespace))) {
    $arguments.Add("-n $Namespace");
  }

  $arguments.Add("apply");
  $arguments.Add("-f $Path");

  if ($Recursive.IsPresent -and ($Recursive -eq $true)) {
    $arguments.Add("-R");
  }

  if ($DryRun.IsPresent -and ($true -eq $DryRun)) {
    $arguments.Add("--dry-run=client");
  }

  [System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder;
  $arguments | % {
    $sb.Append("$_ ");
  }

  Write-Host ("Executing: kubectl {0}" -f $sb.ToString()) -ForegroundColor Gray;
  Write-Host;

  [int]$exitCode = Invoke-ShellCommand `
    -Command "kubectl" `
    -Arguments $arguments.ToArray();

  if ($exitCode -ne 0) {
    throw ("Error: kubectl apply exited with code: {0}" -f $exitCode);
  }
}

Export-ModuleMember -Function Invoke-KubectlApply;
