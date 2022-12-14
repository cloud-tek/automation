Install-Module Pester;
Import-Module Pester;

Import-Module $PSScriptRoot/../CloudTek.Automation.Utilities/Utilities.psm1 -Force;
Import-Module $PSScriptRoot/Git.psm1 -Force;

Describe -Name "git operations tests" {
  <# The PAT used for this test will expire on Jan 2nd 2024 #>
  It "Should clone the git repository using PAT auth and set the correct branch" {
    # Arrange
    [string]$folder = "repo";
    [string]$checkout = "$env:HOME/tmp";

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
    }
    elseif ($null -ne $env:CloudTek_PAT) {
      Get-GitRepository `
        -Repository "https://github.com/cloud-tek/automation.git" `
        -Token "$env:CloudTek_PAT" `
        -Branch "main" `
        -Checkout $checkout `
        -Name $folder;
    }
    else {
      throw "Unable to authenticate Get-GitRepository";
    }

    # Assert
    Test-Path -Path "$checkout/$folder" | Should -Be $true;
  }

  It "Should clone the git repository using GitHub deploy key auth and set the correct branch" {
    # Arrange
    [string]$folder = "ops-git-test-repo-1";
    [string]$checkout = "$env:HOME/tmp";

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
    }
    else {
      Get-GitRepository `
        -Repository "git@github-test-cloudtek:cloud-tek/ops-git-test-repo.git" `
        -Branch "main" `
        -Checkout $checkout `
        -Name $folder;
    }

    # Assert
    Test-Path -Path "$checkout/$folder" | Should -Be $true;
  }

  It "Should throw when cloning a non-existent repository" {
    # Arrange
    [string]$folder = "ops-git-test-repo-x";
    [string]$checkout = "$env:HOME/tmp";

    Get-Folder -Path $checkout -Create;

    if (Test-Path -Path "$checkout/$folder" -PathType Container) {
      Remove-Item -Path "$checkout/$folder" -Recurse -Force;
    }

    # Act & Assert
    {
      if ($null -eq $env:GITHUB_ACTION) {
        Get-GitRepository `
          -Repository "git@github.com:cloud-tek/non-existent-repo.git" `
          -Branch "main" `
          -Checkout $checkout `
          -Name $folder;
      }
      else {
        Get-GitRepository `
          -Repository "git@github-test-cloudtek:cloud-tek/non-existent-repo.git" `
          -Branch "main" `
          -Checkout $checkout `
          -Name $folder;
      }
    } | Should -Throw;
  }

  It "Should throw when cloning a repository using an invalid key" {
    # Arrange
    [string]$folder = "ops-git-test-repo-1";
    [string]$checkout = "$env:HOME/tmp";

    Get-Folder -Path $checkout -Create;

    if (Test-Path -Path "$checkout/$folder" -PathType Container) {
      Remove-Item -Path "$checkout/$folder" -Recurse -Force;
    }

    # Act
    {
      if ($null -eq $env:GITHUB_ACTION) {
        Get-GitRepository `
          -Repository "git@non-existing-key:cloud-tek/automation.git" `
          -Branch "main" `
          -Checkout $checkout `
          -Name $folder;
      }
      else {
        Get-GitRepository `
          -Repository "git@non-existing-key:cloud-tek/ops-git-test-repo.git" `
          -Branch "main" `
          -Checkout $checkout `
          -Name $folder;
      }
    } | Should -Throw;
  }

  It "Should commit & push to a branch" {
    # Arrange
    [string]$folder = "ops-git-test-repo-2";
    [string]$checkout = "$env:HOME/tmp";
    [string]$branch = "main";

    Get-Folder -Path $checkout -Create;

    if (Test-Path -Path "$checkout/$folder" -PathType Container) {
      Remove-Item -Path "$checkout/$folder" -Recurse -Force;
    }

    if ($null -eq $env:GITHUB_ACTION) {
      Get-GitRepository `
        -Repository "git@github.com:cloud-tek/automation.git" `
        -Branch $branch `
        -Checkout $checkout `
        -Name $folder;
    }
    else {
      Get-GitRepository `
        -Repository "git@github-test-cloudtek:cloud-tek/ops-git-test-repo.git" `
        -Branch $branch `
        -Checkout $checkout `
        -Name $folder;
    }

    # Act & Assert
    {
      [string]$now = $((get-date).ToLocalTime().ToString("yyyy-MM-dd HHmmss"));
      Invoke-GitCommit `
        -Checkout $checkout `
        -Name $folder `
        -Branch $branch `
        -Message "Test run $now" `
        -Push `
        -ScriptBlock {
        "Test run" | Out-File -FilePath "$now.txt";
      }
    } | Should -Not -Throw;
  }
}
