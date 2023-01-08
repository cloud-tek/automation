Install-Module Pester;
Import-Module Pester;

Import-Module $PSScriptRoot/Shell.psm1;

[bool]$stdoutHit = $false;

Describe -Name "Invoke-ShellCommand Tests" {
  It "Should execute basic OS command and process STDOUT output" {
     if($IsLinux -or $IsMacOS) {
      Invoke-ShellCommand -Command "ls" `
        -StandardOut {
          param($stdout)
          Write-Host $stdout;
          $script:stdoutHit = $true;
        } `
        -StandardErr {
          param($stderr)
          $false | Should -Be $true -Because "Should never reach this scriptblock";
        } | Should -Be 0;
    } elseif ($IsWindows) {
      Invoke-ShellCommand -Command "dir" `
        -StandardOut {
          param($stdout)
          Write-Host $stdout;
          $script:stdoutHit = $true;
        } `
        -StandardErr {
          param($stderr)
          $false | Should -Be $true -Because "Should never reach this scriptblock";
        } | Should -Be 0;
    } else {
      throw "Unsupported OS"
    }

    $stdoutHit | Should -BeTrue;
  }
}
