[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$username,
  [Parameter(Mandatory = $true)][string]$password,
  [Parameter(Mandatory = $false)][string]$organization
)

$sourceName = "GitHub";
$source = "https://nuget.pkg.github.com/$organization/index.json"
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, (ConvertTo-SecureString -AsPlainText $password -Force);
Register-PSRepository -Name $sourceName -SourceLocation $source -PublishLocation $source -Credential $creds;

$version = '0.0.1'
$apiKey = 'n/a' # keep this as n/a!

Publish-Module -Name $module -Repository $sourceName -RequiredVersion $version -Credential $creds -Force -NuGetApiKey $apiKey
