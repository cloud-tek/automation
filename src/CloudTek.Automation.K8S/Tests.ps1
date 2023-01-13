Install-Module Pester -Force;
Install-Module powershell-yaml -Force;

Import-Module Pester;


Import-Module $PSScriptRoot/../CloudTek.Automation.Shell/Shell.psm1 -Force;
Import-Module $PSScriptRoot/../CloudTek.Automation.Utilities/Utilities.psm1 -Force;
Import-Module $PSScriptRoot/Kubectl.psm1 -Force;
Import-Module $PSScriptRoot/Kubeconform.psm1 -Force;
Import-Module $PSScriptRoot/HELM.psm1 -Force;
Import-Module $PSScriptRoot/K8SApi.psm1 -Force;
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

Describe -Name "CloudTek.Automation.K8S K8SApi Tests" {
  It "Should obtain cluster from kubeconfig" {
    [hashtable]$cluster = Get-Cluster;
    $cluster | Should -Not -Be $null;
  }

  It "Should obtain user from kubeconfig" {
    [hashtable]$user = Get-ClusterUser;
    $user | Should -Not -Be $null;
  }

  It "Should obtain user's token from kubeconfig" {
    [string]$token = Get-ClusterUserToken;
    $token | Should -Not -BeNullOrEmpty;
  }

  It "Should obtain a base64 certificate from a cluster from kubeconfig" {
    [string]$certificate = Get-ClusterCertificateAuthority;
    $certificate | Should -Not -BeNullOrEmpty;
  }

  It "Should obtain a base64 certificate from a cluster" {
    [hashtable]$cluster = Get-Cluster;
    [string]$certificate = Get-ClusterCertificateAuthority -cluster $cluster;
    $certificate | Should -Not -BeNullOrEmpty;
  }

  It "Should obtain a api server from a cluster from kubeconfig" {
    [string]$server = Get-ClusterApiServer;
    $server | Should -Not -BeNullOrEmpty;
  }

  It "Should obtain a api server from a cluster" {
    [hashtable]$cluster = Get-Cluster;
    [string]$server = Get-ClusterApiServer -cluster $cluster;
    $server | Should -Not -BeNullOrEmpty;
  }

  It "Should invoke a k8s api request and obtain a list of namespaces and verify that it contains the default namespace" {
    [hashtable]$cluster = Get-Cluster;
    [string]$token = Get-ClusterUserToken;
    [string]$server = Get-ClusterApiServer -cluster $cluster;

    [pscustomobject]$result = Invoke-K8SApiRequest `
      -ApiServer $server `
      -Token $token `
      -Path "api/v1/namespaces";

    $result | Should -Not -Be $null;
    $result.items | Where-Object { $_.metadata.name -eq "default" } | Should -Not -Be $null;
  }
}
