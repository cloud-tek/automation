Install-Module Pester;
Import-Module Pester;

Import-Module $PSScriptRoot/../CloudTek.Automation.Shell/Shell.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.Utilities/Utilities.psm1 -Force;
Import-Module $PSScriptRoot/Kubectl.psm1 -Force;
Import-Module $PSScriptRoot/Kubeconform.psm1 -Force;

Describe -Name "CloudTek.Automation.K8S Kubectl Tests" {
  It "Command should be available" {
    Get-Command -Cmd "kubectl" | Should -BeTrue;
  }

  It "Should execute kubectl apply in dry-run mode" {
    {
      Invoke-KubectlApply `
        -Path "$PSScriptRoot/tests/data/namespace.yaml" `
        -DryRun;
    } | Should -Not -Throw;
  }

  It "Should execute kubectl apply in recursive dry-run mode" {
    {
      Invoke-KubectlApply `
        -Path "$PSScriptRoot/tests/data" `
        -Recursive `
        -DryRun;
    } | Should -Not -Throw;
  }
}

Describe -Name "CloudTek.Automation.K8S Kubeconform Tests" {
  # It "Command should be available" {
  #   Get-Command -Cmd "kubeconform" | Should -BeTrue;
  # }

  # It "Should validate a valid deployment manifest" {
  #  {
  #     Invoke-Kubeconform `
  #       -Path "$PSScriptRoot/tests/data/deployment.valid.yaml" `
  #       -Summary;
  #  } | Should -Not -Throw;
  # }

  It "Should validate a valid deployment manifest in strict mode" {
    {
       Invoke-Kubeconform `
         -Path "$PSScriptRoot/tests/data/deployment.valid.yaml" `
         -Strict `
         -Summary;
    } | Should -Not -Throw;
   }

  It "Should not validate an invalid deployment manifest" {
    {
      Invoke-Kubeconform `
        -Path "$PSScriptRoot/tests/data/deployment.invalid.yaml" `
        -Summary;
    } | Should -Throw;
  }

  It "Should not validate an invalid deployment manifest in strict mode" {
    {
      Invoke-Kubeconform `
        -Path "$PSScriptRoot/tests/data/deployment.invalid.yaml" `
        -Strict `
        -Summary;
    } | Should -Throw;
  }
}

Describe -Name "CloudTek.Automation.K8S HELM Tests" {
  It "Command should be available" {
    Get-Command -Cmd "helm" | Should -BeTrue;
  }
}
