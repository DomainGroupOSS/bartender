---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# start-btbuild

## SYNOPSIS
Increment the version.
Grab all the scripts.
Compile into a single module file.
Create a manifest.

## SYNTAX

### revisionVersion (Default)
```
start-btbuild [-configFile <String>] [-ReleaseNotes <String>] [-ignoreBtVersion] [-privateDataFile <String>]
 [-ignoreTest] [<CommonParameters>]
```

### buildVersion
```
start-btbuild [-configFile <String>] [-ReleaseNotes <String>] [-incrementBuildVersion] [-ignoreBtVersion]
 [-publish <Boolean>] [-privateDataFile <String>] [-ignoreTest] [<CommonParameters>]
```

### majorVersion
```
start-btbuild [-configFile <String>] [-ReleaseNotes <String>] [-incrementMajorVersion] [-ignoreBtVersion]
 [-publish <Boolean>] [-privateDataFile <String>] [-ignoreTest] [<CommonParameters>]
```

### minorVersion
```
start-btbuild [-configFile <String>] [-ReleaseNotes <String>] [-incrementMinorVersion] [-ignoreBtVersion]
 [-publish <Boolean>] [-privateDataFile <String>] [-ignoreTest] [<CommonParameters>]
```

## DESCRIPTION
- Increment the version depending on the switch used
- Grab any scripts, dsc resources etc from the source file
- Compile into a single module file
- Create a preload.ps1 file
  - to ensure classes and enums are available
  - Will allow using-module and import-module to function similarly
  - Will allow user-substantiation of classes
- Kick off start-btTestPhase
- If enabled, kick off get-btDocumentation
- If tests pass &
  - If incrementing build,major,minor version and autopublish in config OR
  - If publish is true with switch
    - Push to the repository specified

## EXAMPLES

### EXAMPLE 1
```
start-btbuild
```

#### DESCRIPTION
Increment the revision version, good way to ensure everything works


#### OUTPUT
New module manifest and module file, or overright the existing build version.
Test the module
Create documentation if enabled

### EXAMPLE 2
```
start-btbuild -verbose -incrementbuildversion
```

#### DESCRIPTION
Increment the build version
Depending on the btconfig.xml, push to a repository

#### OUTPUT
New module manifest and module file, or overright the existing build version.
Test the module
Create documentation if enabled
Publish the module if required

## PARAMETERS

### -configFile
Default 'btconfig.xml'
The config file to use

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Btconfig.xml
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseNotes
Any release notes to add to the manifest

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -incrementMajorVersion
Switch, increments the major version
Will trigger a publish based on the config file

```yaml
Type: SwitchParameter
Parameter Sets: majorVersion
Aliases: majorver

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -incrementMinorVersion
Switch, increments the minor version
Will trigger a publish based on the config file

```yaml
Type: SwitchParameter
Parameter Sets: minorVersion
Aliases: minorver

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -incrementBuildVersion
Switch, increments the build version
Will trigger a publish based on the config file

```yaml
Type: SwitchParameter
Parameter Sets: buildVersion
Aliases: buildver

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ignoreBtVersion
Run even if there is a difference in bartender versions

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -publish
Boolean value
Override the config files settings
Run the Publish-btmodule on complete

```yaml
Type: Boolean
Parameter Sets: buildVersion, majorVersion, minorVersion
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -privateDataFile
{{Fill privateDataFile Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PrivateData.xml
Accept pipeline input: False
Accept wildcard characters: False
```

### -ignoreTest
{{Fill ignoreTest Description}}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018/05/17


Changelog:
    2018-04-19 - AA
        
        - Initial Script
        - Added primary functionality
        - Based off the combine scripts
   
    2018-04-23 - AA
        
        - Many, Many things fixed     
    2018-04-26 - AA
        
        - Fixed the help
        - Changed the add-files to use get-btscripttext
            - Improved dscresource gathering
            - Improved function resource gathering
    2018-05-11
        - Added publish switch
        - Made the publish switch work
        - Actually made the publish switch work
    2018-05-16
        - Really Really I promise made the publish switch work
        - Added start-btTestPhase
        - Tested it all out
    2018-05-17
        - Tested it all out
        - Added switch for ignoreBtVersion
        - Added failover if btVersions drifted
        - Fixed the help
        - Added get-btDocumentation
        - Tested it again
    2018-05-18
        - Moved the get-btDocumentation to inside the publish block
        - Should mean we don't inadvertantly update documentation prematurely
        - Tried to make the pester result the only output
    2018-05-22
        - Attempted to fix the way arrays were added to the manifest
          - Then reverted it back since it made it worse
        - Stop adding Preload script to manifest when DSCClasses exist, causes funky stuff to happen
        - Fixed issue where btversion was always being flagged as incorrect
    2018-05-23
        - Moved the btVersion check to the right place, it was checking before importing, which is dumb
        - Moved the preloadFileContents switch to the right if block as well, coz I must have been drunk when I put it in
    2018-08-13
        - Made the folder pass section a switch from an if
        - Segmented the preload into seperate files for ENUMS,CLASSES,VALIDATORS
        - Added the preloads to nested-modules as well
    2018-08-30
        - Added privateDataFile
    2018-10-08
        - Removed nested modules for when using DSC, still not the best when dealing with Dsc
        - Brute force added the enums to the main module when using DSC, its not ideal but I'm out of ideas
    
    2018-10-30
        - Added postbuildscripts
            - Need to check if the path is ok (it is)
            - Seems the folder does not get created on new-btproject, need to check that
    2019-01-30 - 2019-02-04 - AA
        - Changed the version output to no longer be the dist folder
            - Tried to simplify a bit
            - Still need the project name as the root folder, since the parent folder is used when importing and publishing
        - Added rev folder
            - Keep all the non-build versions separate from our build versions
            - For BT Projects, revisions should be considered separate for builds
            - Have discovered that Artifactory/Nuget does some _nasty_ things when you build with a revision version
                - Especially if that revision version is a 0
        - Force use of platyps and configuration
            - Made as required modules
        - Clone Rev to Release
            - No longer need to run tests 2 times for the same module
            - Will then use config to update the version in the module manifest
        - Added Pester details to module manifest
            Under Private Data/Pester
        - Changed the publish-btModule call
            - Now does a forEach so you can have multiple repositories in your config
    2019-03-04
        - Fixed bugs with update-btproject
    2019-03-06
        - Changed code-coverage to be an int
        - Added way to get git details for license, project, icon urls
        - Added override where these are set in the module config
    2019-03-10
        - Add a lastRelease hashtable to btconfig on release build complete
            - Add version and date
        - Also clone lastRelease to previous Release
    
    2019-03-12
        - Fix the icon link when generating from git
    2019-03-14
        - Move the postBuildScript step to after release

## RELATED LINKS
