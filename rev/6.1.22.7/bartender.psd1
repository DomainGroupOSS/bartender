#
# Module manifest for module 'bartender'
#
# Generated by: Adrian.Andersson
#
# Generated on: 26/05/2020
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'bartender.psm1'

# Version number of this module.
ModuleVersion = '6.1.22.7'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'f69372eb-22c2-48db-b0e6-1d53f5135b08'

# Author of this module
Author = 'Adrian.Andersson'

# Company or vendor of this module
CompanyName = 'Domain Group'

# Copyright statement for this module
Copyright = '2020 Domain Group'

# Description of the functionality provided by this module
Description = 'A Framework for making PowerShell Modules'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '5.0.0.0'

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
RequiredModules = @(@{ModuleName = 'Pester'; GUID = 'a699dea5-2c73-4616-a270-1f7abb777e71'; RequiredVersion = '4.10.1'; }, 
               @{ModuleName = 'Configuration'; GUID = 'e56e5bec-4d97-4dfd-b138-abbaa14464a6'; RequiredVersion = '1.3.1'; }, 
               @{ModuleName = 'platyPS'; GUID = '0bdcabef-a4b7-4a6d-bf7e-d879817ebbff'; RequiredVersion = '0.14.0'; })

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'get-btScriptText', 'publish-btModule', 'clear-btRepository', 
               'get-btChangeDetails', 'get-btDefaultSettings', 'get-btFolderItems', 
               'get-btGitDetails', 'get-btInstalledModule', 'get-btRepository', 
               'new-btProject', 'save-btDefaultSettings', 'save-btRepository', 
               'start-btbuild', 'start-btTestPhase', 'update-btFileStructure', 
               'update-btProject'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

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
        Tags = 'Domain', 'Devops'

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/DomainGroupOSS/bartender/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/DomainGroupOSS/bartender'

        # A URL to an icon representing this module.
        IconUri = 'https://github.com/DomainGroupOSS/bartender/blob/master/icon.png'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        # RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable


    # bartenderCopyright
    bartenderCopyright = '2019 Domain Group'

    # builtOn
    builtOn = '2020-05-26T11:03:35'

    # moduleRevision
    moduleRevision = '6.1.22.7'

    # builtBy
    builtBy = 'Adrian.Andersson'

    # moduleCompiledBy
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'

    # bartenderVersion
    bartenderVersion = '6.1.22'

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
