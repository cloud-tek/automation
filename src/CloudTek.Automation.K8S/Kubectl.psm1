Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

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

  [int]$exitCode = Invoke-ShellCommand `
    -Command "kubectl" `
    -Arguments $arguments.ToArray();

  if ($exitCode -ne 0) {
    throw ("Error: kubectl apply exited with code: {0}" -f $exitCode);
  }
}

function Invoke-KubectlRolloutStatus {
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$name,
    [Parameter(Mandatory = $false)][string]$namespace,
    [Parameter(Mandatory = $false)][string]$kubeconfig,
    [Parameter(Mandatory = $false)][string]$context
  )

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

  $arguments.Add("rollout");
  $arguments.Add("status");

  $arguments.Add($name);

  [int]$exitCode = Invoke-ShellCommand `
    -Command "kubectl" `
    -Arguments $arguments.ToArray();

  if ($exitCode -ne 0) {
    throw ("Error: kubectl rollout status exited with code: {0}" -f $exitCode);
  }
}

Export-ModuleMember -Function Invoke-KubectlApply;
Export-ModuleMember -Function Invoke-KubectlRolloutStatus;
