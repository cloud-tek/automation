Install-Module Pester;
Import-Module Pester;

Import-Module $PSScriptRoot/../CloudTek.Automation.Utilities/Utilities.psm1 -Force;
Import-Module $PSScriptRoot/Git.psm1 -Force;

  Describe -Name "git operations tests" {
    It "Should clone the git repository and set the correct branch" -ForEach @(
      @{ "Name" = "Test01"; "Version" = "0.7.8"; "PreRelease" = $null; }
    ) {
        # Arrange
        [string]$folder = "repo";
        [string]$checkout = "$PSScriptRoot/tmp";

        if (Test-Path -Path "$checkout/$folder" -PathType Container) {
          Remove-Item -Path "$checkout/$folder" -Recurse -Force;
        }

        # Act
        Get-GitRepository `
          -Repository "git@github.com:cloud-tek/automation.git" `
          -Branch "main" `
          -Checkout $checkout `
          -Name $folder

        # Assert
        Test-Path -Path "$PSScriptRoot/tmp/repo" | Should -Be $true;
    }
  }
