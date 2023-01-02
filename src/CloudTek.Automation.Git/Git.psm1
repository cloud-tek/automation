function Invoke-CommandAt {
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][scriptblock]$ScriptBlock,
    [Parameter(Mandatory = $true)][string]$Location
  )

  Set-StrictMode -Version Latest;
  $ErrorActionPreference = "Stop";

  try {
    Push-Location -Path $Location;
    $ScriptBlock.Invoke();
  }
  finally {
    Pop-Location;
  }
}

function Initialize-Git() {
  & git --version
  & git config user.name "CloudTek.Autmation.Git"
  & git config user.email "<>"
}

function Get-GitRepository() {
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Repository,
    [Parameter(Mandatory = $true)][string]$Branch,
    [Parameter(Mandatory = $true)][string]$Checkout,
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $false)][string]$Token
  )
  Set-StrictMode -Version Latest;
  $ErrorActionPreference = "Stop";

  Get-Command -Cmd "git";
  Get-Folder -Path $Checkout -Create;

  Invoke-CommandAt -ScriptBlock {
    if([string]::IsNullOrEmpty($Token)) {
      & git clone $repository $Name
    } else {
      if($repository.StartsWith("git")) {
        throw "SSH authentication is not supported when using an OAuth2 token";
      }

      & git clone "https://$token@$($repository.Replace("https://", [string]::Empty))" $Name
    }
    Write-Host "$repository cloned ==> $Checkout/$Name" -ForegroundColor Green;
  } -Location "$Checkout";

  Invoke-CommandAt -ScriptBlock {
    Write-Host "Initializing git in: $Checkout/$Name ..."
    Initialize-Git;
  } -Location "$Checkout/$Name"

  Invoke-CommandAt -ScriptBlock {
    & git checkout $Branch
    Write-Host "branch: $Branch" -ForegroundColor Green;
  } -Location "$Checkout/$Name";
}

function Invoke-GitCommit() {
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Branch,
    [Parameter(Mandatory = $true)][string]$Checkout,
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)][string]$Message,
    [Parameter(Mandatory = $true)][scriptblock]$ScriptBlock,
    [Parameter(Mandatory = $false)][switch]$Push
  )

  Set-StrictMode -Version Latest;
  $ErrorActionPreference = "Stop";

  try {
    Push-Location -Path "$Checkout/$Name";

    & git checkout $Branch
    & git pull origin $Branch

    $ScriptBlock.Invoke();

    & git add .
    & git commit -m $Message

    if($Push.IsPresent -and ($true -eq $Push)) {
      & git push origin $Branch
    }
  }
  finally {
    Pop-Location;
  }
}

Export-ModuleMember -Function Get-GitRepository;
Export-ModuleMember -Function Invoke-GitCommit;
