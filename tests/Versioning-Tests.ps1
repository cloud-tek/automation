#!/usr/local/bin/pwsh

Install-Module Pester;
Import-Module Pester;
Import-Module "$PSScriptRoot/../scripts/Utils.psm1" -Force;

Describe -Name "versioning tests" {
  It "Should render version correctly" -ForEach @(
    @{ "Name" = "Test01"; "Version" = "0.7.8"; "PreRelease" = $null; }
    @{ "Name" = "Test02"; "Version" = "0.9.0"; "PreRelease" = "beta5"; }
    @{ "Name" = "Test03"; "Version" = "0.19.0"; "PreRelease" = "beta7"; }
  )  {
    # Arrange
    Copy-TestModule -Module $Name -Source "$PSScriptRoot/data" -Destination "$PSScriptRoot/../src";
    # [string]$source = "$PSScriptRoot/data/Module.psd1";
    # [string]$path = "$PSScriptRoot/../src/$($Name)"

    # New-Item -Path $path -ItemType Directory;
    # Copy-Item -Path $source -Destination "$path/$($Name).psd1";

    # Act
    & $PSScriptRoot/../scripts/Version.ps1 -module $Name -version $Version -prerelease $PreRelease;

    # Assert
    [hashtable]$data = Import-PowerShellDataFile "$PSScriptRoot/../tmp/$Name/$($Name).psd1";

    [string]$expectedVersion = if ($null -eq $PreRelease) { $Version } else { "$Version-$($PreRelease.Replace(".", [string]::Empty))"};

    $data.ModuleVersion | Should -Be $Version -Because "$Name ModuleVersion should be $Version";

    if($null -ne $PreRelease) {
      $data.PrivateData.PSData.PreRelease | Should -Be "-$($PreRelease.Replace(".", [string]::Empty))" -Because "$Name PSData.PreRelease should be -$($PreRelease.Replace(".", [string]::Empty))";
    }

    if ($null -ne $data.RequiredModules) {
      $data.RequiredModules | % {
        $_.ModuleVersion | Should -Be $Version -Because "$Name RequiredModules' ModuleVersion should be $Version";
      }
    }
  }
}


