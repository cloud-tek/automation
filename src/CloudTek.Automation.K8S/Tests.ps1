Install-Module Pester;
Import-Module Pester;

Describe -Name "CloudTek.Automation.K8S Tests" {
  It "should run" {
    $true | Should -Be $true;
  }
}
