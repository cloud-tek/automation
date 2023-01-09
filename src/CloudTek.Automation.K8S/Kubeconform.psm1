Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

function Invoke-Kubeconform {

  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Path,
    [Parameter(Mandatory = $false)][switch]$Strict,
    [Parameter(Mandatory = $false)][switch]$Summary,
    [Parameter(Mandatory = $false)][ValidateSet("json, junit, tap, text")][string]$OutputFormat
  )
  . {
    [string]$cmd = "kubeconform";
    Set-StrictMode -Version Latest;
    $ErrorActionPreference = "Stop";

    Get-Command -Cmd $cmd -Throw;

    [System.Collections.Generic.List[string]]$arguments = New-Object System.Collections.Generic.List[string];

    if($Strict.IsPresent -and ($true -eq $Strict)) {
      $arguments.Add("-strict");
    }

    if($Summary.IsPresent -and ($true -eq $Summary)) {
      $arguments.Add("-summary");
    }

    if(-not([string]::IsNullOrEmpty($OutputFormat))) {
      $arguments.Add("-output $OutputFormat");
    }

    $arguments.Add("-verbose");
    $arguments.Add($Path);

    [int]$exitCode = Invoke-ShellCommand `
      -Command $cmd `
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
      throw ("Error: $cmd exited with code: {0}" -f $exitCode);
    }
  } | Out-Null
}

Export-ModuleMember -Function Invoke-Kubeconform;
