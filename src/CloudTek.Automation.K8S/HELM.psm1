Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

function Invoke-HelmUpgrade() {
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$chart,
    [Parameter(Mandatory = $true)][string]$releaseName,
    [Parameter(Mandatory = $true)][string]$version,
    [Parameter(Mandatory = $false)][string]$kubeConfig,
    [Parameter(Mandatory = $false)][string]$context,
    [Parameter(Mandatory = $false)][string]$outputDir,
    [Parameter(Mandatory = $false)][string]$namespace,
    [Parameter(Mandatory = $false)][string]$timeout = "1200s",
    [Parameter(Mandatory = $false)][string[]]$values,
    [Parameter(Mandatory = $false)][hashtable]$overrides,
    [Parameter(Mandatory = $false)][hashtable]$repositories,
    [Parameter(Mandatory = $false)][switch]$atomic,
    [Parameter(Mandatory = $false)][switch]$force,
    [Parameter(Mandatory = $false)][switch]$dryRun
  )
  Get-Command -Cmd "helm";

  Write-Host "Rendering template...";

  [hashtable]$repos = @{
    "stable" = "https://charts.helm.sh/stable"
  }

  if (!($null -eq $repositories)) {
    foreach ($key in $repositories.Keys) {
      $repos.Add($key, $repositories[$key]);
    }
  }

  foreach ($key in $repos.Keys) {
    Write-Host "Adding $key repo...";
    & helm repo add $key $repos[$key]
  }

  & helm repo update

  [System.Collections.Generic.List[string]] $arguments = New-Object System.Collections.Generic.List[string];
  if ($DebugPreference -ne "SilentlyContinue") {
    $arguments.Add("--debug");
  }

  if (![string]::IsNullOrEmpty($outputDir)) {
    if (!(Test-Path $outputDir)) {
      New-Item -ItemType Directory -Path $outputDir;
    }

    $arguments.Add("template");
    $arguments.Add("--output-dir $outputDir");
  }
  else {
    if ($dryRun) {
      $arguments.Add("upgrade --install --dry-run");
    }
    else {
      $arguments.Add("upgrade --install");
      $arguments.Add("--create-namespace");
      $arguments.Add("--wait");
      $arguments.Add("--timeout $timeout");
    }

    if(-not([string]::IsNullOrEmpty($kubeConfig))) {
      $arguments.Add("--kubeconfig $kubeconfig");
    }

    if (-not([string]::IsNullOrEmpty($context))) {
      $arguments.Add("--kube-context $context");
    }

    if ($atomic.IsPresent -and ($atomic -eq $true)) {
      $arguments.Add("--atomic");
    }

    if ($force.IsPresent -and ($force -eq $true)) {
      $arguments.Add("--force");
    }
  }

  if (![string]::IsNullOrEmpty($namespace)) {
    $arguments.Add("--namespace $namespace");
  }

  $arguments.Add("--version $version");

  if ($null -ne $values) {
    $values | % {
      Write-Host "Including values: $_";
      $arguments.Add("--values $_");
    }
  }

  [System.Text.StringBuilder]$overrideArguments = New-Object System.Text.StringBuilder;
  if (!($null -eq $overrides)) {
    [int]$idx = 0;
    foreach ($key in $overrides.Keys) {
      Write-Host "Including overide: $key";
      if (0 -eq $idx) {
        $overrideArguments.Append("--set-string $key={0}" -f $overrides[$key]);
      }
      else {
        $overrideArguments.Append(",$key={0}" -f $overrides[$key])
      }
      $idx++;
    }

    $arguments.Add($overrideArguments.ToString());
  }

  $arguments.Add($releaseName);
  if ("." -eq $chart) {
    $arguments.Add($MyInvocation.PSScriptRoot);
  }
  else {
    $arguments.Add($chart);
  }

  [System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder;
  $arguments | % {
    $sb.Append("$_ ");
  }

  [int]$exitCode = Invoke-ShellCommand `
    -Command "helm" `
    -Arguments $arguments.ToArray() `
    -StandardOut {
      param($stdout)
      Write-Host $stdout;
    } `
    -StandardErr {
      param($stderr)
      Write-Host $stderr;
    };

  if ($exitCode -ne 0) {
    [string]$msg = "Error: helm exited with code: {0}" -f $exitCode;
    Write-Error $msg;
    throw $msg;
  }
}

Export-ModuleMember -Function Invoke-HelmUpgrade;
