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

function Get-GitRepository() {
  [CmdLetBinding()]
  [OutputType([string[]])]
  param(
    [Parameter(Mandatory = $true)][string]$Repository,
    [Parameter(Mandatory = $true)][string]$Branch,
    [Parameter(Mandatory = $true)][string]$Checkout,
    [Parameter(Mandatory = $true)][string]$Name

  )
  Set-StrictMode -Version Latest;
  $ErrorActionPreference = "Stop";

  Get-Command -Cmd "git";
  Get-Folder -Path $Checkout -Create;

  Invoke-CommandAt -ScriptBlock {
    & git clone $repository $Name
    Write-Host "$repository cloned ==> $Checkout/$Name" -ForegroundColor Green;
  } -Location "$Checkout";

  Invoke-CommandAt -ScriptBlock {
    & git checkout $Branch
    Write-Host "branch: $Branch" -ForegroundColor Green;
  } -Location "$Checkout/$Name";
}

Export-ModuleMember -Function Get-GitRepository;
