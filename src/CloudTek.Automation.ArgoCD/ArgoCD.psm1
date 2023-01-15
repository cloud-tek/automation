Set-StrictMode -Version Latest;
$ErrorActionPreference = "Stop";

function Get-ArgoCDProjects {
  [CmdLetBinding()]
  [OutputType([string[]])]
  param(
    [Parameter(Mandatory = $false)][string]$kubeConfig,
    [Parameter(Mandatory = $false)][string]$context,
    [Parameter(Mandatory = $false)][string]$namespace = "argocd"
  )

  . {
    [hashtable]$cluster = Get-Cluster -kubeconfig $kubeconfig -context $context;
    [string]$token = Get-ClusterUserToken -kubeconfig $kubeconfig -context $context;
    [string]$server = Get-ClusterApiServer -cluster $cluster;

    [pscustomobject]$apiResult = Invoke-K8SApiRequest `
      -ApiServer $server `
      -Token $token `
      -Path "apis/argoproj.io/v1alpha1/namespaces/$namespace/appprojects";

    [string[]]$result = $apiResult.items.metadata.name
    $result.GetType();
  } | Out-Null;

  return $result;
}

function Get-ArgoCDApplications {
  [CmdLetBinding()]
  [OutputType([string[]])]
  param(
    [Parameter(Mandatory = $false)][string]$kubeConfig,
    [Parameter(Mandatory = $false)][string]$context,
    [Parameter(Mandatory = $false)][string]$namespace = "argocd"
  )

  . {
    [hashtable]$cluster = Get-Cluster -kubeconfig $kubeconfig -context $context;
    [string]$token = Get-ClusterUserToken -kubeconfig $kubeconfig -context $context;
    [string]$server = Get-ClusterApiServer -cluster $cluster;

    [pscustomobject]$apiResult = Invoke-K8SApiRequest `
      -ApiServer $server `
      -Token $token `
      -Path "apis/argoproj.io/v1alpha1/namespaces/$namespace/applications";

    [string[]]$result = $apiResult.items.metadata.name
    $result.GetType();
  } | Out-Null;

  return $result;
}

function Find-ArgoCDProject {
  [CmdLetBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)][string]$name,
    [Parameter(Mandatory = $false)][string]$kubeConfig,
    [Parameter(Mandatory = $false)][string]$context,
    [Parameter(Mandatory = $false)][string]$namespace = "argocd"
  )

  . {
    [string[]]$projects = Get-ArgoCDProjects `
      -kubeconfig $kubeconfig `
      -context $context `
      -namespace $namespace;

    [bool]$result = $projects.Contains($name);
    $result.GetType();
  } | Out-Null;

  return $result;
}
function Find-ArgoCDApplication {
  [CmdLetBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory = $true)][string]$name,
    [Parameter(Mandatory = $false)][string]$kubeConfig,
    [Parameter(Mandatory = $false)][string]$context,
    [Parameter(Mandatory = $false)][string]$namespace = "argocd"
  )

  . {
    [string[]]$applications = Get-ArgoCDApplications `
      -kubeconfig $kubeconfig `
      -context $context `
      -namespace $namespace;

    [bool]$result = $applications.Contains($name);
    $result.GetType();
  } | Out-Null;

  return $result
}

Export-ModuleMember -Function Get-ArgoCDProjects;
Export-ModuleMember -Function Get-ArgoCDApplications;
Export-ModuleMember -Function Find-ArgoCDProject;
Export-ModuleMember -Function Find-ArgoCDApplication;
