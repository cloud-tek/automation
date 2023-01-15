# CloudTek.Automation.Shell

## Description

Module used to execute shell-commands

### Get-Command

```pwsh
<# Invokes a command on the shell #>
Invoke-ShellCommand `
  -Command "<required>" `           # Command to invoke. Example: dir, ls, kubectl
  -StandardOut {                    # Scriptblock to execute when command is successful
    param($stdout)
    $script:variable = $stdout;
  } `
  -StandardErr {                    # Scriptblock to execute when command is unsuccesful
    param($stderr)
    $script:variable = $stderr;
  };
```
