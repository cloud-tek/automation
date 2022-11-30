
function Register-PSGallery() {
  Write-Host "Registering PSRepository (PSGallery) ..." -ForegroundColor Gray;
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Unregister-PSRepository -Name PSGallery
  Register-PSRepository -Default
}

function Register-LocalPSResourceRepository([string] $path, [string]$name) {
  [hashtable[]]$repositories = @(
    @{ Name = $name; Uri = $path; Trusted = $true; Priority = 10 }
  );

  Register-PSResourceRepository -Repository $repositories;
}

function Register-PSResourceRepositories([string]$url) {
  [hashtable[]]$repositories = @(
    @{ PSGallery = $true; Trusted = $true; Priority = 20 }
    @{ Name = "nuget"; Uri = $url; Trusted = $true; Priority = 40 }
    @{ Name = "NuGetGallery"; Uri = "https://api.nuget.org/v3/index.json"; Trusted = $true; Priority = 50 }
  );

  Register-PSResourceRepository -Repository $repositories;
  Register-PSRepository `
  -Name "nuget" `
  -SourceLocation $url `
  -PublishLocation $url;
}

# function Register-NuGet([string]$url) {
#   Write-Host "Registering PSRepository ($name)..." -ForegroundColor Gray;
#   [string]$nuget = "https://api.nuget.org/v3/index.json";

#   Register-PSResourceRepository -Name "NuGetGallery" -Uri $nuget -Trusted
#   Register-PSResourceRepository -Name "nuget" -Uri $url -Trusted;

#   Register-PSRepository `
#     -Name "nuget" `
#     -SourceLocation $url `
#     -PublishLocation $url;
# }

function Import-PowershellGet([string] $version) {
  Import-Module -Name "/home/runner/.local/share/powershell/Modules/PowerShellGet/$version/PowerShellGet.psd1" -Force; # -RequiredVersion $version;
}

function Invoke-Command {
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true)]
      [scriptblock]$ScriptBlock,

      [Parameter(Position=1, Mandatory=$false)]
      [int]$Retries = 5,

      [Parameter(Position=2, Mandatory=$false)]
      [int]$Interval = 100
  )

  Begin {
      $cnt = 0
  }

  Process {
      do {
          $cnt++
          try {
              # If you want messages from the ScriptBlock
              # Invoke-Command -Command $ScriptBlock
              # Otherwise use this command which won't display underlying script messages
              $ScriptBlock.Invoke()
              return
          } catch {
              Write-Error $_.Exception.InnerException.Message -ErrorAction Continue
              Start-Sleep -Milliseconds $Interval
          }
      } while ($cnt -lt $Retries)

      # Throw an error after $Retries unsuccessful invocations. Doesn't need
      # a condition, since the function returns upon successful invocation.
      throw 'Execution failed.'
  }
}


Export-ModuleMember -Function Import-PowershellGet;
Export-ModuleMember -Function Register-PSGallery;
Export-ModuleMember -Function Register-PSResourceRepositories;
Export-ModuleMember -Function Register-LocalPSResourceRepository;
Export-ModuleMember -Function Invoke-Command;
