function Invoke-ShellCommand {
  [CmdletBinding()]
  [OutputType([int])]
  param(
    [Parameter(Mandatory = $true)][string]$Command,
    [Parameter(Mandatory = $false)][string[]]$Arguments = $null,
    [Parameter(Mandatory = $false)][scriptblock]$StandardOut = $null,
    [Parameter(Mandatory = $false)][scriptblock]$StandardErr = $null
  )

  . {
    try {
      if($null -ne $Arguments) {
        [System.Text.StringBuilder]$sb = New-Object System.Text.StringBuilder;
        $Arguments | % {
          $sb.Append("$_ ");
        }

        Write-Host ("Executing: '$Command {0}' in $pwd" -f $sb.ToString().TrimEnd()) -ForegroundColor Blue;
      } else {
        Write-Host ("Executing: '$Command' in $pwd") -ForegroundColor Blue;
      }

      Write-Host;

      [System.Diagnostics.ProcessStartInfo]$pInfo = New-Object System.Diagnostics.ProcessStartInfo;
      $pInfo.FileName = $Command;
      $pInfo.RedirectStandardError = $true;
      $pInfo.RedirectStandardOutput = $true;
      $pInfo.UseShellExecute = $false;
      $pInfo.Arguments = $Arguments;
      $pInfo.WorkingDirectory = $pwd;

      [System.Diagnostics.Process]$process = New-Object System.Diagnostics.Process
      $process.StartInfo = $pInfo;
      $process.Start();

      $stdout = $process.StandardOutput.ReadToEnd();
      $stderr = $process.StandardError.ReadToEnd();

      $process.WaitForExit();
    }
    catch [System.Management.Automation.MethodInvocationException] {
      return 1;
    }
    catch {
      throw "Unhandled exception";
    }
    finally {
      if (($null -ne $StandardOut) -and (-not([string]::IsNullOrEmpty($stdout)))) {
        $StandardOut.Invoke($stdout) | Out-Null;
      }

      if (($null -ne $StandardErr) -and (-not([string]::IsNullOrEmpty($stderr)))) {
        $StandardErr.Invoke($stderr) | Out-Null;
      }
    }
  } | Out-Null;

  return $process.ExitCode;
}
