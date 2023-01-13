function Get-Cluster {
  [CmdLetBinding()]
  [OutputType([hashtable])]
  param(
    [Parameter(Mandatory = $false)][string]$kubeconfig,
    [Parameter(Mandatory = $false)][string]$context
  )
  . {
    Import-Module -Name "powershell-yaml" -Force;

    if ([string]::IsNullOrEmpty($kubeconfig)) {
      $kubeconfig = "$env:HOME/.kube/config";
    }

    if (-not(Test-Path -Path $kubeconfig -PathType Leaf)) {
      throw "Requested kubeconfig $kubeconfig not found";
    }

    [string]$yaml = Get-Content -Raw -Path $kubeconfig;
    [hashtable]$cfg = ConvertFrom-Yaml $yaml;

    if ([string]::IsNullOrEmpty($context)) {
      $context = $cfg["current-context"];
    }

    [hashtable]$ctx = $cfg.contexts | Where-Object { $_.name -eq $context }

    if ($null -eq $ctx) {
      throw "Requested context $context not found in the kubeconfig";
    }

    [hashtable]$cluster = $cfg.clusters | Where-Object { $_.name -eq $ctx.context.cluster }

    if ($null -eq $cluster) {
      throw "Requested cluster $cluster not found";
    }
  } | Out-Null;

  return $cluster;
}

function Get-ClusterUser {
  [CmdLetBinding()]
  [OutputType([hashtable])]
  param(
    [Parameter(Mandatory = $false)][string]$kubeconfig,
    [Parameter(Mandatory = $false)][string]$context
  )
  . {
    Import-Module -Name "powershell-yaml" -Force;

    if ([string]::IsNullOrEmpty($kubeconfig)) {
      $kubeconfig = "$env:HOME/.kube/config";
    }

    if (-not(Test-Path -Path $kubeconfig -PathType Leaf)) {
      throw "Requested kubeconfig $kubeconfig not found";
    }

    [string]$yaml = Get-Content -Raw -Path $kubeconfig;
    [hashtable]$cfg = ConvertFrom-Yaml $yaml;

    if ([string]::IsNullOrEmpty($context)) {
      $context = $cfg["current-context"];
    }

    [hashtable]$ctx = $cfg.contexts | Where-Object { $_.name -eq $context }

    if ($null -eq $ctx) {
      throw "Requested context $context not found in the kubeconfig";
    }

    [hashtable]$user = $cfg.users | Where-Object { $_.name -eq $ctx.context.user }

    if ($null -eq $user) {
      throw "Requested user $user not found";
    }
  } | Out-Null;

  return $user;
}

function Get-ClusterApiServer {
  [CmdLetBinding(DefaultParameterSetName = "kubeconfig")]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $false, ParameterSetName = "kubeconfig")][string]$kubeConfig,
    [Parameter(Mandatory = $false, ParameterSetName = "kubeconfig")][string]$context,
    [Parameter(Mandatory = $false, ParameterSetName = "cluster")][hashtable]$cluster
  )

  . {
    if ($null -eq $cluster) {
      $cluster = Get-Cluster -kubeConfig $kubeConfig -context $context;
    }

    [string]$result = $cluster.cluster.server;
  } | Out-Null;

  return $result;
}

function Get-ClusterCertificateAuthority {
  [CmdLetBinding(DefaultParameterSetName = "kubeconfig")]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $false, ParameterSetName = "kubeconfig")][string]$kubeConfig,
    [Parameter(Mandatory = $false, ParameterSetName = "kubeconfig")][string]$context,
    [Parameter(Mandatory = $false, ParameterSetName = "cluster")][hashtable]$cluster
  )

  . {
    if ($null -eq $cluster) {
      $cluster = Get-Cluster -kubeConfig $kubeConfig -context $context;
    }

    [string]$result = $cluster.cluster["certificate-authority-data"];
  } | Out-Null;

  return $result;
}

function Get-ClusterUserToken {
  [CmdLetBinding(DefaultParameterSetName = "kubeconfig")]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $false, ParameterSetName = "kubeconfig")][string]$kubeConfig,
    [Parameter(Mandatory = $false, ParameterSetName = "kubeconfig")][string]$context
  )

  . {
      [hashtable]$user = Get-ClusterUser -kubeConfig $kubeConfig -context $context;


    [string]$result = $user.user.token;
  } | Out-Null;

  return $result;
}

function Invoke-K8SApiRequest {
  [OutputType([pscustomobject])]
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$ApiServer,
    [Parameter(Mandatory = $true)][string]$Token,
    [Parameter(Mandatory = $true)][string]$Path
  )

  . {

    [hashtable]$headers = @{
      "ContentType" = "application/json"
      "Authorization" = "Bearer $Token"
    }

    [pscustomobject] $result = Invoke-RestMethod `
      -Method Get `
      -Uri "$ApiServer/$Path"`
      -Headers $headers `
      -SkipCertificateCheck;
  } | Out-Null;

  return $result;
}

Export-ModuleMember -Function Get-Cluster;
Export-ModuleMember -Function Get-ClusterUser;
Export-ModuleMember -Function Get-ClusterUserToken;
Export-ModuleMember -Function Get-ClusterApiServer;
Export-ModuleMember -Function Get-ClusterCertificateAuthority;
Export-ModuleMember -Function Invoke-K8SApiRequest;
