# Bartender

Mixes, muddles, shakes and serves PowerShell modules

## What is this

A module builder framework for PowerShell
It takes the contents of the enums, classes, filters and functions directories and places them into a single module file with a module manifest. It does versioning, and strips out formatting for a smaller payload, and is designed to be used with a PS Nuget Repository

## Why did I make this

I wanted a way to quickly make PowerShell modules in a way that was easier to collaborate on, reversion, and keep the pieces separate.

I also wanted a way to make the module file a bit smaller for easier loading and exporting. This has the added benefit of making the module code harder to read, so you will in most scenarios want to update the master source files and not the module itself.

It is based (loosely) on PSake, but I wanted something a bit lighter-weight and segmented and entirely PowerShell focused, you also don't need to write the build script, it is interpreted from the folder structures.

### Features

- Will combine Enums, Functions, Filters and Classes directories in the Source directory from individual scripts into a single module
- Will only process .ps1 files
- Should exclude files in the .btExclude of each subfolder (untested)
- Allows specification of DSC classes
  - NOTE: When making DSC Classes, you will _require_ one file per class
  - CONT: The filename will need to be the same as the class name
  - CONT: This is required because of how PowerShell Modules expect to export DSC resources
- Strips out single quotes (if configured)
- Removes spaces and empty lines (if configured)
- Requires a configuration file
- Iterates the Module Release version for you automatically
  - If configured, will also publish on build increment or higher
    - May require population of publishtoken.txt
    - publishtoken.txt _should_ by default be excluded from GIT
- Use swithes to increase the other version parts
  - Switches Available:
    - incrementMajorVersion
    - incrementMinorVersion
    - incrementBuildVersion
  - Will rebase all lower segments
    - E.g. increaseing minor version will set buildversion and release to 0

### Functions

#### new-btproject

##### Description

create the folder framework for a new project

##### Parameters

#### start-btbuild

##### Description

Compile the files into a module, increment version

##### Parameters

#### publish-btProject

##### Description

Push the module to a powershell NuGet gallery

Uses the publish-module commandlet

##### Parameters

### ToDo

- Move Revisions to a new folder path, in order to keep the builds version clean in git -done
- Remove the repository token entirely, instead
  - Create a file in users userdata folder
  - Keep all the repositories and credentials there
    - Make a function to update and create credentials
    - Use that along with btconfig params to manage credentials
    - Add useCredentials switches to btconfig
- Update newbtProject
  - Lots of changes, almost a whole rebuild
  - Make the files and folders with a update-btFilestructure call -done
    - single sauce for all the things -done
- new function for updating a btproject
- Change the way the start-btbuild function works -done
    - Increment and publish only after a new revision
    - So revision, test, if tests past, clone to release folder, publish
    - This will save unecesary test cycles

### Misc

Bartender was built using itself, so the version is higher than expected due to testing incrementation