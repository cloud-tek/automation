
function Register-PSGallery() {
  Write-Host "Registering PSRepository (PSGallery) ..." -ForegroundColor Gray;
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Unregister-PSRepository -Name PSGallery
  Register-PSRepository -Default
}

function Register-NuGet([string]$url) {
  Write-Host "Registering PSRepository ($name)..." -ForegroundColor Gray;
  [string]$nuget = "https://api.nuget.org/v3/index.json";

  Register-PSResourceRepository -Name "NuGetGallery" -Uri $nuget -Trusted
  Register-PSResourceRepository -Name "nuget" -Uri $url -Trusted;

  Register-PSRepository `
    -Name "nuget" `
    -SourceLocation $url `
    -PublishLocation $url;
}

function Import-PowershellGet([string] $version) {
  Import-Module -Name "/home/runner/.local/share/powershell/Modules/PowerShellGet/$version/PowerShellGet.psd1" -Force; # -RequiredVersion $version;
}


Export-ModuleMember -Function Import-PowershellGet;
Export-ModuleMember -Function Register-PSGallery;
Export-ModuleMember -Function Register-NuGet;
