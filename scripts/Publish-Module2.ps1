#!/usr/local/bin/pwsh

Register-PSResourceRepository -Name local -URL $PSScriptRoot/../output # Needs to be an absolute path.
Publish-PSResource -Path "$PSScriptRoot\src\CloudTek.Automation.K8S" -Repository "local"
