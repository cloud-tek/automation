Install-Module Pester;
Import-Module Pester;

Describe -Name "CloudTek.Automation.Shell Tests" {
  It "should run" {
    $true | Should -Be $true;
  }
}
