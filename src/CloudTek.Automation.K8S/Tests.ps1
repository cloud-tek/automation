# Install-Module Pester -Force;
# Import-Module Pester;

Import-Module $PSScriptRoot/../CloudTek.Automation.Shell/Shell.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.Utilities/Utilities.psm1 -Force;
Import-Module $PSScriptRoot/Kubectl.psm1 -Force;
Import-Module $PSScriptRoot/Kubeconform.psm1 -Force;
Import-Module $PSScriptRoot/HELM.psm1 -Force;

Describe -Name "CloudTek.Automation.K8S Kubectl Tests" {
  It "Command should be available" {
    Get-Command -Cmd "kubectl" | Should -BeTrue;
  }

  It "Should execute kubectl apply in dry-run mode" {
    {
      Invoke-KubectlApply `
        -Path "$PSScriptRoot/tests/data/valid/namespace.yaml" `
        -DryRun;
    } | Should -Not -Throw;
  }

  It "Should execute kubectl apply in recursive dry-run mode" {
    {
      Invoke-KubectlApply `
        -Path "$PSScriptRoot/tests/data/valid" `
        -Recursive `
        -DryRun;
    } | Should -Not -Throw;
  }
}

Describe -Name "CloudTek.Automation.K8S Kubeconform Tests" {
  It "Command should be available" {
    Get-Command -Cmd "kubeconform" | Should -BeTrue;
  }

  It "Should validate a valid deployment manifest" {
    {
      Invoke-Kubeconform `
        -Path "$PSScriptRoot/tests/data/valid/deployment.yaml" `
        -Summary;
    } | Should -Not -Throw;
  }

  It "Should validate a valid deployment manifest in strict mode" {
    {
      Invoke-Kubeconform `
        -Path "$PSScriptRoot/tests/data/valid/deployment.yaml" `
        -Strict `
        -Summary;
    } | Should -Not -Throw;
  }

  It "Should not validate an invalid deployment manifest" {
    {
      Invoke-Kubeconform `
        -Path "$PSScriptRoot/tests/data/invalid/deployment.yaml" `
        -Summary;
    } | Should -Throw;
  }

  It "Should not validate an invalid deployment manifest in strict mode" {
    {
      Invoke-Kubeconform `
        -Path "$PSScriptRoot/tests/data/invalid/deployment.yaml" `
        -Strict `
        -Summary;
    } | Should -Throw;
  }
}

Describe -Name "CloudTek.Automation.K8S HELM Tests" {
  It "Command should be available" {
    Get-Command -Cmd "helm" | Should -BeTrue;
  }

  It "Should upgrade from a public chart in dry-run mode"  -ForEach @(
    @{ "Repository" = "jaegertracing";  "Address" = "https://jaegertracing.github.io/helm-charts";  "Chart" = "jaeger"; "Version" = "0.39.0"; "Release" = "jg";  }
    @{ "Repository" = "dex";            "Address" = "https://charts.dexidp.io";                     "Chart" = "dex";    "Version" = "0.12.1"; "Release" = "dex"; }
    @{ "Repository" = "kubereboot";     "Address" = "https://kubereboot.github.io/charts";          "Chart" = "kured";  "Version" = "4.2.0";  "Release" = "kured";  }
  ) {
    [hashtable]$repositories = @{
      "$Repository" = "$Address"
    };

    Invoke-HelmUpgrade `
      -Chart "$Repository/$Chart" `
      -Release "$Release" `
      -Version "$Version" `
      -Repositories $repositories `
      -DryRun;
  }
}
