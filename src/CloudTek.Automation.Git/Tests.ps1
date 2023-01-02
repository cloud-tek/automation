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
        [string]$checkout = "$env:HOME/tmp";
        [string]$token = $env:CloudTek_GitToken;

        Get-Folder -Path $checkout -Create;

        if (Test-Path -Path "$checkout/$folder" -PathType Container) {
          Remove-Item -Path "$checkout/$folder" -Recurse -Force;
        }

        # Act
        if ($null -eq $env:GITHUB_ACTION) {
          Get-GitRepository `
            -Repository "git@github.com:cloud-tek/automation.git" `
            -Branch "main" `
            -Checkout $checkout `
            -Name $folder;
        } elseif ($null -ne $env:CloudTek_PAT) {
          Get-GitRepository `
          -Repository "https://github.com/cloud-tek/automation.git" `
          -Token "$env:CloudTek_PAT" `
          -Branch "main" `
          -Checkout $checkout `
          -Name $folder;
        } else {
          throw "Unable to authenticate Get-GitRepository";
        }

        # Assert
        Test-Path -Path "$checkout/$folder" | Should -Be $true;
    }
  }
