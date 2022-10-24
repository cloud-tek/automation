#
# Module manifest for module 'CloudTek.Automation.K8S'
#
# Generated by: CloudTek
#
# Generated on: 09/25/2022
#

@{

  # Script module or binary module file associated with this manifest.
  # RootModule = ''

  # Version number of this module.
  ModuleVersion = "<VERSION>"

  # Supported PSEditions
  CompatiblePSEditions = 'Core'

  # ID used to uniquely identify this module
  GUID = '1d45f074-746a-491e-8b78-e79816a8a2e7'

  # Author of this module
  Author = 'CloudTek'

  # Company or vendor of this module
  CompanyName = 'CloudTek'

  # Copyright statement for this module
  Copyright = ''

  # Description of the functionality provided by this module
  Description = 'This package contains reusable kubernetes powershell automation. Created to simplify the psm1 delivery process.'

  # Minimum version of the PowerShell engine required by this module
  PowerShellVersion = '7.2'

  # Name of the PowerShell host required by this module
  # PowerShellHostName = ''

  # Minimum version of the PowerShell host required by this module
  # PowerShellHostVersion = ''

  # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  # DotNetFrameworkVersion = ''

  # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  # ClrVersion = ''

  # Processor architecture (None, X86, Amd64) required by this module
  # ProcessorArchitecture = ''

  # Modules that must be imported into the global environment prior to importing this module
  # RequiredModules = @()

  # Assemblies that must be loaded prior to importing this module
  # RequiredAssemblies = @()

  # Script files (.ps1) that are run in the caller's environment prior to importing this module.
  # ScriptsToProcess = @()

  # Type files (.ps1xml) to be loaded when importing this module
  # TypesToProcess = @()

  # Format files (.ps1xml) to be loaded when importing this module
  # FormatsToProcess = @()

  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  NestedModules = @("./HELM.psm1", "./Kubectl.psm1")

  # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
  FunctionsToExport = @("Deploy-HelmTemplate", "Kubectl-Apply")

  # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
  CmdletsToExport = @()

  # Variables to export from this module
  VariablesToExport = @()

  # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
  AliasesToExport = @()

  # DSC resources to export from this module
  # DscResourcesToExport = @()

  # List of all modules packaged with this module
  # ModuleList = @()

  # List of all files packaged with this module
  # FileList = @()

  # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
  PrivateData = @{

      PSData = @{

          # Tags applied to this module. These help with module discovery in online galleries.
          # Tags = @()

          # A URL to the license for this module.
          # LicenseUri = ''

          # A URL to the main website for this project.
          ProjectUri = 'https://github.com/cloud-tek/automation'
          RepositoryUrl = 'https://github.com/cloud-tek/automation'

          # A URL to an icon representing this module.
          IconUri = 'https://avatars.githubusercontent.com/u/35167581?s=400&u=ca5fdf8da213a9ab3edd83813b5f3491dea70f6c&v=4'

          # ReleaseNotes of this module
          # ReleaseNotes = ''

          # Prerelease string of this module
          # Prerelease = ''

          # Flag to indicate whether the module requires explicit user acceptance for install/update/save
          # RequireLicenseAcceptance = $false

          # External dependent modules of this module
          # ExternalModuleDependencies = @()

      } # End of PSData hashtable

  } # End of PrivateData hashtable

  # HelpInfo URI of this module
  # HelpInfoURI = ''

  # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
  # DefaultCommandPrefix = ''

  }

