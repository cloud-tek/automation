Install-Module Pester;
Import-Module Pester;

Import-Module $PSScriptRoot/../CloudTek.Automation.Shell/Shell.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.Utilities/Utilities.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.K8S/K8SApi.psm1 -Force;
Import-Module $PSScriptRoot/ArgoCD.psm1 -Force;

Describe -Name "CloudTek.Automation.ArgoCD Tests" {
  It "Command should be available" {
    Get-Command -Cmd "kubectl" | Should -BeTrue;
  }

  It "It should get a list of argocd projects" {
    [string[]]$result = Get-ArgoCDProjects;

    $result | Should -Not -Be $null;
    $result | Where-Object { $_ -eq "default" } | Should -Not -Be $null;
  }

  It "It should get a list of argocd applications" {
    [string[]]$result = Get-ArgoCDApplications;

    $result | Should -Not -Be $null;
    $result | Where-Object { $_ -eq "consul" } | Should -Not -Be $null;
  }

  It "It should find existing project" {
    [bool]$result = Find-ArgoCDProject -Name "default";

    $result | Should -Be $true;
  }

  It "It should not find a non-existing project" {
    [bool]$result = Find-ArgoCDProject -Name "non-existing";

    $result | Should -Be $false;
  }

  It "It should find existing application" {
    [bool]$result = Find-ArgoCDApplication -Name "consul";

    $result | Should -Be $true;
  }

  It "It should not find a non-existing application" {
    [bool]$result = Find-ArgoCDApplication -Name "non-existing";

    $result | Should -Be $false;
  }
}
