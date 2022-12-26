
function Register-PSGallery() {
  Write-Host "Registering PSRepository (PSGallery) ..." -ForegroundColor Gray;
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Unregister-PSRepository -Name PSGallery
  Register-PSRepository -Default
}

function Register-LocalRepository() {
  [string]$p = "$PSScriptRoot/../packages";

  [hashtable]$arguments = @{
    Name = "local"
    SourceLocation = $p
    PublishLocation = $p
    InstallationPolicy = "Trusted"
    ErrorAction = "SilentlyContinue"
  };

  Register-PSRepository @arguments;
}

function Register-LocalPSResourceRepository([string] $path = "$PSScriptRoot/../packages", [string]$name = "local") {
  [string]$p = Resolve-Path -Path $path;
  Write-Host "Registering PSRepository ($name : $p) ..." -ForegroundColor Gray;
  [hashtable[]]$repositories = @(
    @{ Name = $name; Uri = "$p"; Trusted = $true; Priority = 10 }
  );

  Register-PSResourceRepository -Repository $repositories -Verbose;
  Register-PSRepository -SourceLocation $p -PublishLocation $p -Name $name;
}

function Register-PSResourceRepositories([string]$url) {
  [hashtable[]]$repositories = @(
    @{ PSGallery = $true; Trusted = $true; Priority = 20 }
    @{ Name = "nuget"; Uri = $url; Trusted = $true; Priority = 40 }
    @{ Name = "NuGetGallery"; Uri = "https://api.nuget.org/v3/index.json"; Trusted = $true; Priority = 50 }
  );

  Unregister-PSResourceRepository -Name PSGallery;
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

function Copy-File {
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$false)]
      [string]$File,

      [Parameter(Mandatory=$true)]
      [string]$Source,

      [Parameter(Mandatory=$true)]
      [string]$Destination
  )
  [string]$src = "$Source";
  [string]$dst = "$Destination";

  if([string]::IsNullOrEmpty($File)) {

  } else {
    [string]$fileName = $File.Replace("./", [string]::Empty);
    $src = [string]::Concat($src, "/$fileName");
    $dst = [string]::Concat($dst, "/$fileName");
  }

  if(-not(Test-Path -Path $src -PathType Leaf)) {
    throw "Required file $src does not exist";
  }

  Copy-Item -Path $src -Destination $dst -Force;
  Write-Host "Copied $src ==> $dst" -ForegroundColor Gray;
}

function Copy-Module {
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true)]
      [string]$Module,

      [Parameter(Position=1, Mandatory=$true)]
      [string]$Source,

      [Parameter(Position=2, Mandatory=$true)]
      [string]$Destination
  )

  [string]$src = "$Source/$Module";
  [string]$dst = "$Destination/$Module";

  if(-not(Test-Path -Path $src)) {
    throw "Source path $Source/$Module does not exist";
  }

  if(-not(Test-Path -Path $dst)) {
    New-Item -Path $dst -ItemType Directory;
  }

  [hashtable]$data = Import-PowerShellDataFile "$src/$Module.psd1"

  if ($null -ne $data.ScriptsToProcess) {
    $data.ScriptsToProcess | % {
      Copy-File -File $_ -Source $src -Destination $dst;
    }
  }

  if ($null -ne $data.TypesToProcess) {
    $data.TypesToProcess | % {
      Copy-File -File $_ -Source $src -Destination $dst;
    }
  }

  if ($null -ne $data.FormatsToProcess) {
    $data.FormatsToProcess | % {
      Copy-File -File $_ -Source $src -Destination $dst;
    }
  }

  if ($null -ne $data.NestedModules) {
    $data.NestedModules | % {
      Copy-File -File $_ -Source $src -Destination $dst;
    }
  }

  Copy-File -File "$Module.psd1" -Source $src -Destination $dst;
}

function Copy-TestModule {
  [CmdletBinding()]
  Param(
      [Parameter(Position=0, Mandatory=$true)]
      [string]$Module,

      [Parameter(Position=1, Mandatory=$true)]
      [string]$Source,

      [Parameter(Position=2, Mandatory=$true)]
      [string]$Destination
  )

  [string]$src = "$Source";
  [string]$dst = "$Destination/$Module";

  if(-not(Test-Path -Path $src)) {
    throw "Source path $Source/$Module does not exist";
  }

  if(-not(Test-Path -Path $dst)) {
    New-Item -Path $dst -ItemType Directory;
  } else {
    Remove-Item $dst -Recurse -Force;
    New-Item -Path $dst -ItemType Directory;
  }

  [hashtable]$data = Import-PowerShellDataFile "$src/Module.psd1"

  if ($null -ne $data.NestedModules) {
    $data.NestedModules | % {
      Copy-File -Source "$src/$_" -Destination "$dst/$_";
    }
  }

  Copy-File -Source "$src/Module.psd1" -Destination "$dst/$Module.psd1";
}


Export-ModuleMember -Function Import-PowershellGet;
Export-ModuleMember -Function Register-PSGallery;
Export-ModuleMember -Function Register-LocalRepository;
Export-ModuleMember -Function Register-PSResourceRepositories;
Export-ModuleMember -Function Register-LocalPSResourceRepository;
Export-ModuleMember -Function Invoke-Command;
Export-ModuleMember -Function Copy-Module;
Export-ModuleMember -Function Copy-TestModule;
