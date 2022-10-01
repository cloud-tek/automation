class ShellExecutor
{
  [System.Diagnostics.ProcessStartInfo]$pInfo
  [int]$lastExitCode
  [string]$StandardOutput

  ShellExecutor([string]$CommandName, [System.Collections.Generic.List[string]]$Arguments)
  {
    $this.InitializePInfo($CommandName, $Arguments, $false, $false, $false);
  }

  ShellExecutor([string]$CommandName,
                [System.Collections.Generic.List[string]]$Arguments,
                [bool]$RedirectStandardError,
                [bool]$RedirectStandardOutput,
                [bool]$UseShellExecute
  )
  {
    $this.InitializePInfo($CommandName, $Arguments, $RedirectStandardError, $RedirectStandardOutput, $UseShellExecute);
  }

  [void] InitializePInfo([string]$CommandName,
                  [System.Collections.Generic.List[string]]$Arguments,
                  [bool]$RedirectStandardError,
                  [bool]$RedirectStandardOutput,
                  [bool]$UseShellExecute)
  {
    $this.pInfo = New-Object System.Diagnostics.ProcessStartInfo
    $this.pInfo.FileName = $CommandName;
    $this.pInfo.RedirectStandardError = $RedirectStandardError;
    $this.pInfo.RedirectStandardOutput = $RedirectStandardOutput;
    $this.pInfo.UseShellExecute = $UseShellExecute;
    $this.pInfo.Arguments = $Arguments.ToArray();
  }

  [object] Execute()
  {
    [System.Diagnostics.Process]$p = New-Object System.Diagnostics.Process
    $p.StartInfo = $this.pInfo;
    $p.Start();
    # $p.StandardOutput cannot be read after $p.WaitForExit()
    $this.StandardOutput = $p.StandardOutput.ReadToEnd();
    $p.WaitForExit();
    $this.lastExitCode = $p.ExitCode;
    return $p;
  }
}

function Invoke-ShellCommand {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline)]
        [string]$CommandString
    )

    $commandTokens = $CommandString.Split(" ")
    $commandName = $commandTokens | Select-Object -First 1
    $arguments = $commandTokens | Select-Object -SkipIndex 0

    $shellExecutor = [ShellExecutor]::new($commandName, $arguments, $false, $true, $false)
    $proc = $shellExecutor.Execute();

    if($proc.exitCode -ne 0){
        throw "Command $commandName $arguments failed with exit code $exitCode"
    }

    return $shellExecutor.StandardOutput
}

Export-ModuleMember -Function Invoke-ShellCommand
