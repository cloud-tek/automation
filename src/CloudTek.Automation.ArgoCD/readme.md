# CloudTek.Automation.ArgoCD

## Prerequisites

> **Warning**
>
> Ensure argocd CLI is installed
> 
> ```bash
> ARGOCD_VERSION="v2.4.3"
>
> curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64 \
>   && install -m 555 argocd-linux-amd64 /usr/local/bin/argocd \
>   && rm argocd-linux-amd64
> ```

## Description

Module used for low-level interaction with [ArgoCD](https://argoproj.github.io/cd/).

## Cmdlets

### Get-ArgoCDProjects

```pwsh
[string[]]$result = Get-ArgoCDProjects `
  -kubeconfig $kubeconfig `
  -context $context `
  -namespace "<default:argocd>";
```

### Get-ArgoCDApplications

```pwsh
[string[]]$result = Get-ArgoCDApplications `
  -kubeconfig $kubeconfig `
  -context $context `
  -namespace "<default:argocd>";
```

### Find-ArgoCDProject

```pwsh
[bool]$result = Find-ArgoCDProject `
  -name "<required>"
  -kubeconfig $kubeconfig `
  -context $context `
  -namespace "<default:argocd>";
```

### Find-ArgoCDApplication

```pwsh
[bool]$result = Find-ArgoCDApplication `
  -name "<required>"
  -kubeconfig $kubeconfig `
  -context $context `
  -namespace "<default:argocd>";
```
