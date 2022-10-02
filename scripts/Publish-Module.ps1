[CmdletBinding()]
Param(
  [Parameter(Mandatory = $true)][string]$module,
  [Parameter(Mandatory = $true)][string]$username,
  [Parameter(Mandatory = $true)][string]$password,
  [Parameter(Mandatory = $false)][string]$organization
)

$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, (ConvertTo-SecureString -AsPlainText $password -Force);
Register-PSRepository -Name $sourceName -SourceLocation $source -PublishLocation $source -Credential $creds;

$source = "https://nuget.pkg.github.com/$organization/index.json"
$module = '<module-name>'
$version = '<module-version>'
$apiKey = 'n/a' # keep this as n/a!

Publish-Module -Name $module -Repository $sourceName -RequiredVersion $version -Credential $creds -Force -NuGetApiKey $apiKey
