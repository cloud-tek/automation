Install-Module Pester;
Install-Module powershell-yaml -Force;

Import-Module Pester;

Import-Module $PSScriptRoot/../CloudTek.Automation.Shell/Shell.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.Utilities/Utilities.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.K8S/Kubectl.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.K8S/HELM.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.K8S/K8SApi.psm1 -Force;
Import-Module $PSScriptRoot/ArgoCD.psm1 -Force;

Describe -Name "CloudTek.Automation.ArgoCD Tests" {
  BeforeAll {
    if ($null -ne $env:GITHUB_ACTION) {
      Invoke-KubectlApply `
        -Path "$PSScriptRoot/tests/argocd/namespace.yaml" `

      [hashtable]$repositories = @{
        "argo" = "https://argoproj.github.io/argo-helm"
      };

      Invoke-HelmUpgrade `
        -Namespace "argocd" `
        -Chart "argo/argo-cd" `
        -Release "argo" `
        -Version "5.13.0" `
        -Repositories $repositories;

      Invoke-KubectlRolloutStatus `
        -Namespace "argocd" `
        -Name "deployment/argo-argocd-server";

      Invoke-KubectlApply `
        -Path "$PSScriptRoot/tests/argocd/application.yaml" `
    }
  }

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
    [string]$name = if($null -ne $env:GITHUB_ACTION) { "guestbook" } else { "consul" }
    [bool]$result = Find-ArgoCDApplication -Name $name;

    $result | Should -Be $true;
  }

  It "It should not find a non-existing application" {
    [bool]$result = Find-ArgoCDApplication -Name "non-existing";

    $result | Should -Be $false;
  }
}
