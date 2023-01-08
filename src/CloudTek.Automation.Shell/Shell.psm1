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
      [System.Diagnostics.ProcessStartInfo]$pInfo = New-Object System.Diagnostics.ProcessStartInfo;
      $pInfo.FileName = $Command;
      $pInfo.RedirectStandardError = $true;
      $pInfo.RedirectStandardOutput = $true;
      $pInfo.UseShellExecute = $false;
      $pInfo.Arguments = $Arguments;

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
      if ((0 -eq $process.ExitCode) -and ($null -ne $StandardOut)) {
        $StandardOut.Invoke($stdout) | Out-Null;
      }

      if ((0 -ne $process.ExitCode) -and ($null -ne $StandardErr)) {
        $StandardErr.Invoke($stderr) | Out-Null;
      }
    }

    # if (0 -ne $process.ExitCode) {
    #   throw "Process exited with $($process.ExitCode)";
    # }
  } | Out-Null;

  return $process.ExitCode;
}
