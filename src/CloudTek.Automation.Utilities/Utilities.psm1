function Get-Command {
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string] $Cmd,
    [Parameter(Mandatory = $false)][switch] $Throw
  )

  . {
    [bool]$result = $false;

    try {
      & $Cmd | Out-Null
      Write-Host "Command available: '$Cmd'" -ForegroundColor Green;
      $result = $true;
    }
    catch [System.Management.Automation.CommandNotFoundException] {
      if ($Throw.IsPresent -and ($true -eq $Throw)) {
        throw "Command unavailable: '$Cmd'";
      }
    }
  } | Out-Null;

  return $result;
}

function Get-Folder {
  [CmdLetBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $false)][switch]$Create
  )

  if (-not(Test-Path -Path $Path -PathType Container)) {
    if (($Create.IsPresent) -and ($Create -eq $true)) {
      New-Item -Path $Path -ItemType Directory;
    }
    else {
      throw "Path '$Path' not found";
    }
  }
}

Export-ModuleMember -Function Get-Command;
Export-ModuleMember -Function Get-Folder;
