# CloudTek.Automation.Utilities

## Description

Small utility module with helpers that are not specific to any other automation module

### Get-Command

```pwsh
<# Checks if command is accessible on the PATH #>
Get-Command `
  -Cmd "<required> `  # Command name. Example: kubectl
  -Throw;             # Throws if test is failed
```
