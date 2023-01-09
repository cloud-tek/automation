Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

[hashtable]$modules = @{
  "CloudTek.Automation.Shell"     = "Shell.psm1"
  "CloudTek.Automation.Utilities" = "Utilities.psm1"
};

$modules.Keys | % {
  if (Test-Path $PSScriptRoot/../$_/$modules[$_]) {
    Import-Module $PSScriptRoot/../$_/$modules[$_] -Force;
  }
  else {
    Import-Module $_;
  }
}
function Invoke-KubectlApply() {
  [CmdLetBinding()]
  param(

    [Parameter(Mandatory = $true)][string]$fileName,
    [Parameter(Mandatory = $false)][string]$namespace,
    [Parameter(Mandatory = $false)][switch]$recursive,
    [Parameter(Mandatory = $false)][string[]]$additionalArguments,
    [Parameter(Mandatory = $false)][string]$kubeConfig = "$env:HOME/.kube/config",
    [Parameter(Mandatory = $false)][string]$context,
    [Parameter(Mandatory = $false)][switch]$dryRun
  )
  . {
    [string]$cmd = "kubeval";
    Set-StrictMode -Version Latest;
    $ErrorActionPreference = "Stop";

    Get-Command -Cmd $cmd -Throw;

    Write-Host ("Validating file: {0} with $cmd ..." -f $fileName);

    [System.Collections.Generic.List[string]]$arguments = New-Object System.Collections.Generic.List[string];
    $arguments.Add($fileName);

    [int]$exitCode = Invoke-ShellCommand `
      -Command $cmd `
      -Arguments $arguments.ToArray() `
      -StandardErr {
      param($stderr)
      Write-Host $stderr;
    };

    if ($exitCode -ne 0) {
      throw ("Error: $cmd exited with code: {0}" -f $exitCode);
    }
  } | Out-Null
}
