# Bartender

A Framework for making PowerShell Modules

Mixes, muddles, shakes and serves PowerShell modules

## What is this

A module builder framework for PowerShell
It takes the contents of the source subfolders (enums, classes, filters and functions directories) and combines them into a single module file with a module manifest and related necessary resources. 

It does revisioning and versioning, and is designed to be used with a PowerShell-based Nuget Repository for release management.

## Why did I make this

I wanted a way to make PowerShell modules that promoted good coding practices and was easy to use, share and iterate.

The primary goals were collaboration, generalisation and proper release lifecycle.

The list of secondary goals has kept growing as we found issues with standard PowerShell modules or had requirements for specific tasks. In all implementations we tried to stay true to our 4 primary goals.



## Module Features

 ### 
 - Collaboration
    - Standard folder layout and file locations
    - Allow customisation of file orders and subfolders within the framework
    - Provide an integrated way of updating the framework
    - Simplify module creation and focus on function creation
    - Keep all the build settings in a single config file
    - Centralize your scripts
 - Separation of Concerns
    - Source files can be separated on a functional level
    - Classes, DSCClasses, Enums and Functions handled according to their needs
      - Separation of private and public functions
      - Use preload scripts for enums and classes to ensure they are scoped both privately and publicly
 - Easier Module-Wide Pester Testing
    - Include basic pester tests that:
      - Ensure we run in a clean-tree
      - Ensure the module compiles and loads correctly
    - Make adding new tests as simple as making a new ps1 script in the appropriate folder
 - Release Management
    - Automatic publishing to a repository on test-passing
    - Revision increasing for test cycles
    - Version increases (Major, Minor, Build) for releases
    - Integrate a basic release notes markdown
 - Better Module Customisation
    - Deal with extended module manifest PrivateData
 - Use PlatyPS for version documentation
    - Automatically compile the inline help into markdown
    - Allow for the documentation to evolve with the code naturally
    - Ensure properly documented advanced functions create appropriate markdown

## Quick Start Guide

### Install the module

```powershell
install-module -name bartender
```
<sup>*assumes a repository is already in place</sup>

<sup>*Check [here](https://powershellexplained.com/2018-03-03-Powershell-Using-a-NuGet-server-for-a-PSRepository/?utm_source=blog&utm_medium=blog&utm_content=tags) for an execelent blog post from Kevin Marquette for more details</sup>

### Setup your bartender publish repository


```powershell
save-btRepository -repository myRepo -token myNugetToken -credential $(get-credential)
```
<sup>*Token is used for publishing to nuget repositories and is not needed for fileshare repositories</sup>

<sup>*Credentials are used for checking module dependancies and are only required if the repository is private</sup>

### Setup your bartender defaults


```powershell
$myDefaults = @{
   author = 'myname'
   repository = 'myRepo'
   company = 'myCompany'
   tags = @('mydepartment')
   publishOnBuild = $true
   autoDocument = $true
   includeGitDetails = $true
   trimSpaces = $false
   removeEmptyLines = $true
   removeSingleLineQuotes = $false
   runPesterTests = $true
}
save-btDefaultSettings @myDefaults
```

### Create a new btProject

```powershell
md $newProjectFolder
cd $newProjectFolder

new-btProject -moduleName myBtProject -moduleDescription 'my bartender module'
```

### Start Coding


## Misc

### Why Bartender?

### Thanks and Mentions

Thanks to [Warren F](http://ramblingcookiemonster.github.io) and [Kevin Marquette](https://powershellexplained.com/) for their fantastic blogs, for validating some of the ways we were doing things, and for correcting many others



### Bootstrapping
Bartender was built using a bootstrapped version of itself, so the version is higher than expected due to testing incrementation.

