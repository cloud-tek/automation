Install-Module Pester;
Import-Module Pester;

Describe -Name "CloudTek.Automation.Utilities Tests" {
  It "should run" {
    $true | Should -Be $true;
  }
}
