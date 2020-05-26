---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# update-btProject

## SYNOPSIS
Provide a way to update an existing module

## SYNTAX

```
update-btProject [[-moduleName] <String>] [[-moduleDescription] <String>] [[-repository] <String[]>]
 [[-moduleAuthor] <String[]>] [[-companyName] <String>] [[-minimumPsVersion] <Version>]
 [[-AutoIncrementRevision] <Boolean>] [[-RemoveSingleLineQuotes] <Boolean>] [[-RemoveEmptyLines] <Boolean>]
 [[-trimSpaces] <Boolean>] [[-publishOnBuild] <Boolean>] [[-runPesterTests] <Boolean>]
 [[-autoDocument] <Boolean>] [[-useGitDetails] <Boolean>] [[-RequiredModules] <Array>] [[-Tags] <String[]>]
 [[-modulePath] <String>] [[-configFile] <String>] [[-licenseUri] <String>] [[-projectUri] <String>]
 [[-iconUri] <String>] [<CommonParameters>]
```

## DESCRIPTION
Will build out the folder structure for a new bt project
and make a btConfig.xml file with all the settings set in the parameters

## EXAMPLES

### EXAMPLE 1
```
new-btProject -moduleName myModule -moduleDescription 'A new module'
```

#### DESCRIPTION
Make a new powershell module project, include the repository token, use the defaults for everything else


#### OUTPUT
Will make the following folder structure:
- dist
  - documentation
  - source
    - classes
    - dscClasses
    - enums
    - filters
    - functions
    - pester
    - private
    - resource
    - bin
    - lib

Will include a default .gitignore, .btOrderStart, .btOrderEnd
Will make a new publishtoken.txt that _should_ not be tracked by GIT

## PARAMETERS

### -moduleName
If you want to update the name of your module
Will not reset the versioning

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -moduleDescription
Update the description of your module

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -repository
Change the default repository(s) to publish to

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -moduleAuthor
Will append to the authors list

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -companyName
{{ Fill companyName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -minimumPsVersion
PS Version for your module
Used in making the manifest and restricting its use
Default is 5.0.0.0

```yaml
Type: Version
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoIncrementRevision
Default True
Increment the Revision version when running start-btBuild command

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveSingleLineQuotes
Default True
Remove any single line quotes when compiling scripts

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveEmptyLines
Default True
Remove any extra empty lines when compiling scripts

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -trimSpaces
Default False
Remove any extra spaces
Breaks your function spacing, so only use if you want a flat file

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -publishOnBuild
Default True
When incrementing build version, will push to the repository specified

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -runPesterTests
Default True
Add the basic module pester tests to the pester folder

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -autoDocument
Default True
Specify that when running start-btBuild, you want to automatically run get-btDocumentation as well

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -useGitDetails
Try and get the license, project URIs from GIT

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequiredModules
Array of modules you want to include as mandatory when building the manifest
If a string is supplied, then the version will be whatever latest version is installed
If a hashtable is supplied it should be constructed as such:
@{moduleName='myModule';moduleVersion='1.2.3'}

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
The tags to apply in the manifest, helping when searching repositories

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 16
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -modulePath
{{ Fill modulePath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 17
Default value: $(get-location).path
Accept pipeline input: False
Accept wildcard characters: False
```

### -configFile
{{ Fill configFile Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 18
Default value: BtConfig.xml
Accept pipeline input: False
Accept wildcard characters: False
```

### -licenseUri
Override the licenseUri

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 19
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -projectUri
Override the projectUri

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 20
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -iconUri
Override the iconUri

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 21
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### null
## OUTPUTS

### null
## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018-05-17


Changelog:
    2018-04-19 - AA
        
        - Initial Script
        - Added primary functionality
        - Based off the combine scripts
    
    2018-04-23 - AA
        
        - Added token and repository details
    2018-04-26 - AA
        
        - Fixed the help
    2018-05-17 - AA
        
        - Updated help
        - Ensure we error out if we already have a config
        - Cleaned up no longer needed comments
    2018-12-03 - AA
        
        - Remove the folder and file creation
        - Execute the update-btFileStructure to make them instead
    2019-02-04 - AA
        - Changed all the boolean params
            - They can now be null
            - Defaults are now, as a result, in the begin block
                - Will read from a saved config if one exists
                - Will then fall-back to an appropriate default
        - Made the RequiredModules an array
            - The array will check for HashTable or String entries
                - Strings need to be the name of an installed module
                - Hashtable requires moduleVersion and moduleName strings
                - Where a hashtable is supplied, the version must be installed on the machine
            - Makes use of new get-btInstalledModules function
            - Will lock-down the version to the latest at build time as a result
                - This should allow updated modules to push the latest required package to the repository as a result
        - Updated repository to allow multiple arguments
            - Updated -start-btbuild and publish-btModule cmdlets as a result
            - Allows you to set multiple default repositories to publish to
    2019-02-25 - AA
        - Fixed some issues with checking the config file
    2019-03-04 - AA
        - Fixed this up so that it correctly used existing settings
            - Would overwrite existing settings with defaults prior
        - Fixed issue where moduleName and Description were getting dropped
            - Therefore causing this script to always error
        - Fix the GUID getting dropped
        - Fix version rebasing back to 0 by removing it as an update version
            - Can still be updated manually if needed
    2019-03-08 - AA
    - Added way to update licenseuri, iconuri and projecturi
    2019-03-08 - AA
        - Stopped loosing required modules on update

## RELATED LINKS
