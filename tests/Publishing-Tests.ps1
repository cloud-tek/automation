#!/usr/local/bin/pwsh

Install-Module Pester;
Import-Module Pester;
Import-Module "$PSScriptRoot/../scripts/Utils.psm1" -Force;

Describe -Name "local publishing tests" {
  BeforeAll {
    Remove-Item "$PSScriptRoot/../packages/*.nupkg";
  }
  It "Should publish module correctly" -ForEach @(
    @{ "Name" = "Test01"; "Version" = "0.7.8"; "PreRelease" = $null; }
    @{ "Name" = "Test02"; "Version" = "0.7.9"; "PreRelease" = $null; }
    @{ "Name" = "Test03"; "Version" = "0.8.0"; "PreRelease" = $null; }
    # https://github.com/PowerShell/PowerShellGet/issues/843
    # @{ "Name" = "Test02"; "Version" = "0.9.0"; "PreRelease" = "beta.5"; }
    # @{ "Name" = "Test03"; "Version" = "0.19.0"; "PreRelease" = "beta7"; }
  )  {
    # Arrange
    Copy-TestModule -Module $Name -Source "$PSScriptRoot/data" -Destination "$PSScriptRoot/../src";

    # Act
    & $PSScriptRoot/../scripts/Publish-Local.ps1 -module $Name -version $Version -prerelease $PreRelease;

    # Assert
    [hashtable]$data = Import-PowerShellDataFile "$PSScriptRoot/../tmp/$Name/$($Name).psd1";

    $data.ModuleVersion | Should -Be $Version -Because "$Name ModuleVersion should be $Version";

    if($null -ne $PreRelease) {
      $data.PrivateData.PSData.PreRelease | Should -Be "-$PreRelease" -Because "$Name PSData.PreRelease should be -$PreRelease";
    }

    if ($null -ne $data.RequiredModules) {
      $data.RequiredModules | % {
        $_.ModuleVersion | Should -Be $Version -Because "$Name RequiredModules' ModuleVersion should be $Version";
        Test-Path -Path "$PSScriptRoot/../packages/$($_.ModuleName).$($_.ModuleVersion).nupkg" -PathType Leaf | Should -Be $true -Because "$($_.ModuleName).$($_.ModuleVersion).nupkg (dependency) should have been published locally";
      }
    }

    Test-Path -Path "$PSScriptRoot/../packages/$Name.$Version.nupkg" -PathType Leaf | Should -Be $true -Because "$Name.$Version.nupkg should have been published locally";
  }
}
