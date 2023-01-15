# CloudTek.Automation.K8S

## Description

This module is used to interact with kubernetes using both `kubectl` CLI and k8s REST API

## Submodules

### Kubectl.psm1

#### Description

Submodule used to communicate with kubernetes using `kubectl` CLI

#### Invoke-KubectlApply

**kubectl apply -f {path-to-file}**
```bash
Invoke-KubectlApply `
  -Namespace $namespace `   # k8s namespace
  -Kubeconfig $kubeconfig ` # path to k8s kubeconfig
  -Context $context `       # name of the context to use
  -Path "<required>" `  # path to a folder containing k8s manifests
  -DryRun;              # flag indicating that operations should be executed in dry-run mode
```

**kubectl apply -f {path-to-folder} -R**
```bash
Invoke-KubectlApply `
  -Namespace $namespace `   # k8s namespace
  -Kubeconfig $kubeconfig ` # path to k8s kubeconfig
  -Context $context `       # name of the context to use
  -Path "<required>" `  # path to a folder containing k8s manifests
  -Recursive `          # flag indicating the manifests should be aggregated recursively
  -DryRun;              # flag indicating that operations should be executed in dry-run mode
```

#### Invoke-KubectlRolloutStatus

```bash
Invoke-KubectlRolloutStatus `
  -Name <required> `        # name of the resource. example: deployment/abc
  -Namespace $namespace `   # k8s namespace
  -Kubeconfig $kubeconfig ` # path to k8s kubeconfig
  -Context $context `       # name of the context to use
```

### Kubeconform.psm1

#### Description

Submodule used to validate kubernetes manifests using kubeconform

#### Invoke-Kubeconform

```pwsh
<# Validates manifests' syntactical correctness using kubeconform #>
Invoke-Kubeconform `
  -Path "<requred>" ` # path to manifest(s) to validate
  -Strict `           # strict mode
  -OutputFormat `     # json | junit | tap | text (default)
  -Summary;           # generate summary
```

### HELM.psm1

#### Description

Submodule used to deploy HELM charts

#### Invoke-HELMUpgrade

```pwsh

[string]$repository = "kubereboot";
[hashtable]$repositories = @{
  "$Repository" = "https://kubereboot.github.io/charts"
};

Invoke-HelmUpgrade `
  -Chart "$Repository/kured" `    # name of the HELM chart in repository/chart-name format
  -Release "<required>" `         # name of the HELM release
  -Version "<required>" `         # version of the HELM chart
  -Repositories $repositories `   # HELM repositories for 'helm add' `
  -Namespace $namespace `         # Kubernetes namespace
  -Timeout $timeout `             # Timeout for the operation to complete (example: 1200s)
  -Values $values `               # Array of value files to include
  -Overrides $overrides `         # hashtable of HELM values' overrides
  -Atomic `                       # Flag indicating that the operation should atomically succeed or fail
  -Force `
  -DryRun `                       # Manifest rendering only using helm 'template'
  -OutputDir;                     # Path for HELM to store rendered manifests
```

### K8SAPI.psm1

#### Description

Submodule used to execute HTTP requests against Kubernetes REST API

#### Get-Cluster

```pwsh
<# Gets the cluster object from a kubeconfig's context. Defaults to ~/.kube/config's active context #>
[hashtable]$cluster = Get-Cluster `
  -kubeconfig $kubeconfig ` # (optional) path to kubeconfig
  -context $context;        # (optional) name of the context to use
```

#### Get-ClusterUser

```pwsh
<# Gets the cluster user object from a kubeconfig's context. Defaults to ~/.kube/config's active context #>
[hashtable]$user = Get-ClusterUser `
  -kubeconfig $kubeconfig ` # (optional) path to kubeconfig
  -context $context;        # (optional) name of the context to use
```

#### Get-ClusterUserToken

```pwsh
<# Gets the cluster user's token from a kubeconfig's context. Defaults to ~/.kube/config's active context #>
[string]$token = Get-ClusterUserToken `
 -kubeconfig $kubeconfig ` # (optional) path to kubeconfig
  -context $context;        # (optional) name of the context to use
```

#### Get-ClusterCertificateAuthority

```pwsh 
<# Gets the cluster's certificate authority (CA) from a kubeconfig's context. Defaults to ~/.kube/config's active context #>
[string]$certificate = Get-ClusterCertificateAuthority `
 -kubeconfig $kubeconfig ` # (optional) path to kubeconfig
  -context $context;        # (optional) name of the context to use
```

#### Get-ClusterApiServer

```pwsh
<# Gets the cluster's API server address from a kubeconfig's context. Defaults to ~/.kube/config's active context #>
[string]$server = Get-ClusterApiServer `
  -kubeconfig $kubeconfig ` # (optional) path to kubeconfig
  -context $context;        # (optional) name of the context to use
```

#### Invoke-K8SApiRequest

```pwsh
<# Invokes a REST request against the cluster's API server address. Authenticates with an OAuth token #>
[pscustomobject]$result = Invoke-K8SApiRequest `
  -ApiServer "<required>" `       # Kubernetes API server address (see: Get-ClusterApiServer)
  -Token "<required>" `           # OAuth token (see: Get-ClusterUserToken)
  -Path "<required>";             # Request path. Example: api/v1/namespaces
```
