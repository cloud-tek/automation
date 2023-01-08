using module "CloudTek.Automation.Shell";

Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

function Get-ArgoCDApplications()
{
  [CmdLetBinding()]
  [OutputType([string[]])]
  param(
    [Parameter(Mandatory = $false)][string]$kubeConfig,
    [Parameter(Mandatory = $false)][string]$context,
    [Parameter(Mandatory = $true)][string]$namespace
  )

  [System.Collections.Generic.List[string]]$arguments = New-Object System.Collections.Generic.List[string];

  $arguments.Add("--namespace $namespace");
  $arguments.Add("get applications");

  if (-not([string]::IsNullOrEmpty($kubeconfig))) {
    $arguments.Add("--kubeconfig $kubeconfig");
  }
  if (-not([string]::IsNullOrEmpty($context))) {
    $arguments.Add("--context $context");
  }

  [ShellExecutor]$shellExecutor = New-Object ShellExecutor -ArgumentList 'kubectl', $arguments;

  $proc = $shellExecutor.Execute();

  if ($proc.exitCode -ne 0)
  {
    Write-Error ("Error: kubectl apply exited with code: {0}" -f $exitCode);
    Exit $proc.exitCode;
  }

}

Export-ModuleMember -Function Get-ArgoCDApplications;
