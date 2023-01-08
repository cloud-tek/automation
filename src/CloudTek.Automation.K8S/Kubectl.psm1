Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

[hashtable]$modules = @{
  "CloudTek.Automation.Shell" = "Shell.psm1"
  "CloudTek.Automation.Utilities" = "Utilities.psm1"
};

$modules.Keys | % {
  if(Test-Path $PSScriptRoot/../$_/$modules[$_]) {
    Import-Module $PSScriptRoot/../$_/$modules[$_] -Force;
  } else {
    Import-Module $_;
  }
}
function Kubectl-Apply()
{
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$kubeConfig,
    [Parameter(Mandatory = $true)][string]$fileName,
    [Parameter(Mandatory = $false)][string]$namespace,
    [Parameter(Mandatory = $false)][switch]$recursive,
    [Parameter(Mandatory = $false)][string[]]$additionalArguments
  )
  Set-StrictMode -Version Latest;
  $ErrorActionPreference = "Stop";

  Get-Command -Cmd "kubectl";

  Write-Host ("Validating file: {0} with kubeval" -f $fileName);

  [System.Collections.Generic.List[string]]$kubeValArguments = New-Object System.Collections.Generic.List[string];
  $kubeValArguments.Add($fileName);

  [ShellExecutor]$shellExecutor = New-Object ShellExecutor -ArgumentList 'kubeval', $kubeValArguments;

  $proc = $shellExecutor.Execute();

  if ($proc.exitCode -ne 0) {
    Write-Error ("Provided manifest is not valid. kubeval exited with code: {0}" -f $exitCode);
    return $exitCode;
  }

  [System.Collections.Generic.List[string]]$arguments = New-Object System.Collections.Generic.List[string];

  $arguments.Add("apply");
  $arguments.Add("--kubeconfig $kubeconfig");
  $arguments.Add("-f $fileName");

  if (-not([string]::IsNullOrEmpty($namespace))) {
    $arguments.Add("-n $namespace");
  }

  if ($recursive.IsPresent -and ($recursive -eq $true)) {
    $arguments.Add("-R");
  }

  $arguments = $arguments + $additionalArguments;

  [System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder;
  $arguments | % {
    $sb.Append("$_ ");
  }

  Write-Host ("Executing: kubectl apply {0}" -f $sb.ToString()) -ForegroundColor Yellow;
  Write-Host;

  [ShellExecutor]$shellExecutor = New-Object ShellExecutor -ArgumentList 'kubectl', $arguments;

  $proc = $shellExecutor.Execute();

  if ($proc.exitCode -ne 0)
  {
    Write-Error ("Error: kubectl apply exited with code: {0}" -f $exitCode);
  }

  return $exitCode;
}

Export-ModuleMember -Function Kubectl-Apply;
