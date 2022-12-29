Install-Module Pester;
Import-Module Pester;

Describe -Name "CloudTek.Automation.ArgoCD Tests" {
  It "should run" {
    $true | Should -Be $true;
  }
}
