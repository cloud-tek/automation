Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

function Get-ArgoCDApplications {
  [CmdLetBinding()]
  [OutputType([string[]])]
  param(
    [Parameter(Mandatory = $false)][string]$kubeConfig,
    [Parameter(Mandatory = $false)][string]$context,
    [Parameter(Mandatory = $true)][string]$namespace
  )

  . {
    [System.Collections.Generic.List[string]]$arguments = New-Object System.Collections.Generic.List[string];

    $arguments.Add("--namespace $namespace");
    $arguments.Add("get applications");

    if (-not([string]::IsNullOrEmpty($kubeconfig))) {
      $arguments.Add("--kubeconfig $kubeconfig");
    }
    if (-not([string]::IsNullOrEmpty($context))) {
      $arguments.Add("--context $context");
    }

    $arguments.Add("-o go-template='{{ range .items}}{{.metadata.name}}{{""\n""}}{{end}}'");

    [System.Collections.Generic.List[string]]$result = New-Object System.Collections.Generic.List[string];
    [int] $exitCode = Invoke-ShellCommand `
      -Command "kubectl" `
      -Arguments $arguments.ToArray() `
      -StandardOut {
        param($stdout)
        Write-Host($stdout);
      } `
      -StandardErr {
        param($stderr)
        Write-Host $stderr;
      };


    if ($exitCode -ne 0) {
      [string]$msg = "Error: kubectl exited with code: {0}" -f $exitCode;
      Write-Error $msg;
      throw $msg;
    }
  } | Out-Null

  return $result.ToArray();
}

Export-ModuleMember -Function Get-ArgoCDApplications;
