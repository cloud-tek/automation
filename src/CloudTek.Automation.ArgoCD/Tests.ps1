Install-Module Pester;
Import-Module Pester;

Import-Module $PSScriptRoot/../CloudTek.Automation.Shell/Shell.psm1 -Force;
Import-Module $PSScriptRoot/ArgoCD.psm1 -Force;

Describe -Name "CloudTek.Automation.ArgoCD Tests" {
  It "Command should be available" {
    Get-Command -Cmd "kubectl" | Should -BeTrue;
  }

  It "should get a list of applications" {
    [string[]]$result = Get-ArgoCDApplications -namespace "argocd";
    $result.GetType();
  }
}
