#!/usr/local/bin/pwsh

[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$modules,
  [Parameter(Mandatory = $true)][string]$version
)

try {
  $list = ConvertFrom-Json -InputObject $modules;
}
catch {
  Write-Error "Failed to deserialize module list : $_  : $modules";
  Exit 1;
}

$list | % {
  try {
    Push-Location -Path "$PSScriptRoot/../src/$($_.id)";
    Write-Host "Settings $($_.id) version to $version ..." -ForegroundColor Gray;

    [string]$file = (Get-Content "./$($_.id).psd1" -Raw -Encoding utf8);

    $file = $file.Replace("ModuleVersion = ""0.0.0""", "ModuleVersion = ""$($version)""");

    Set-Content "./$($_.id).psd1" `
      -Value $file `
      -NoNewline;

    Write-Host "Done" -ForegroundColor Green;
  }
  catch {
    Write-Error "Failed to read $($_.id).psd1 ... : $_";
    Exit 1;
  }
  finally {
    Pop-Location;
  }
}
