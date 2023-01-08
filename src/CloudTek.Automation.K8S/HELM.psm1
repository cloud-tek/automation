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

function Deploy-HelmTemplate() {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$kubeConfig,
        [Parameter(Mandatory = $false)][string]$context,
        [Parameter(Mandatory = $true)][string]$chart,
        [Parameter(Mandatory = $true)][string]$releaseName,
        [Parameter(Mandatory = $false)][string]$outputDir,
        [Parameter(Mandatory = $false)][string]$namespace,
        [Parameter(Mandatory = $true)][string]$version,
        [Parameter(Mandatory = $false)][string]$timeout = "1200s",
        [Parameter(Mandatory = $true)][string[]]$values,
        [Parameter(Mandatory = $false)][hashtable]$overrides,
        [Parameter(Mandatory = $false)][hashtable]$repositories,
        [Parameter(Mandatory = $false)][switch]$atomic,
        [Parameter(Mandatory = $false)][switch]$force,
        [Parameter(Mandatory = $false)][switch]$dryRun
    )
    Get-Command -Cmd "helm";

    Write-Host "Rendering template...";
    if (($null -eq $values) -or ($values.Length -eq 0)) {
        Write-Error "No values were provided";
        return 1;
    }

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
    if($DebugPreference -ne "SilentlyContinue"){
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
        if($dryRun){
          $arguments.Add("install --dry-run");
        }else{
          $arguments.Add("upgrade --install");
          $arguments.Add("--create-namespace");
          $arguments.Add("--wait");
          $arguments.Add("--timeout $timeout");
        }
        $arguments.Add("--kubeconfig $kubeconfig");

        if (-not([string]::IsNullOrEmpty($context))) {
            $arguments.Add("--kube-context $context");
        }

        if($atomic.IsPresent -and ($atomic -eq $true)) {
            $arguments.Add("--atomic");
        }

        if($force.IsPresent -and ($force -eq $true)) {
            $arguments.Add("--force");
        }
    }

    if(![string]::IsNullOrEmpty($namespace)){
        $arguments.Add("--namespace $namespace");
    }

    $arguments.Add("--version $version");

    $values | % {
        Write-Host "Including values: $_";
        $arguments.Add("--values $_");
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

    Write-Host ("Executing: helm {0}" -f $sb.ToString()) -ForegroundColor Yellow;
    Write-Host;

    [int]$exitCode = Invoke-ShellCommand `
      -Command `
      -Arguments;
    [ShellExecutor] $shellExecutor = New-Object ShellExecutor -ArgumentList 'helm', $arguments;

    $proc = $shellExecutor.Execute();

    if ($proc.exitCode -ne 0) {
        Write-Error ("helm template rendering failed with exit code: {0}" -f $exitCode);
    }

    return $exitCode;
}

Export-ModuleMember -Function Deploy-HelmTemplate;
