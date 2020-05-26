---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# get-btFolderItems

## SYNOPSIS
Get a list of files from a folder - whilst processing the .btignore and .btorder files

## SYNTAX

### Default (Default)
```
get-btFolderItems [-Path] <String> [-psScriptsOnly] [-Destination <String>] [<CommonParameters>]
```

### SetDestination
```
get-btFolderItems [-Path] <String> [-psScriptsOnly] -Destination <String> [-SetDestination] [-copy]
 [<CommonParameters>]
```

## DESCRIPTION
Get the files out of a folder.
Adds a bit of smarts to it such as:
 - Ignore anything in the .btignore file
 - Order files in the .btorderStart folder first
 - Order any files in the .btOrderEnd folder
 - Randomly add any files that are not in either in between
 - Filter out anything that isn't a PS1 file by default if required
 - Copy the items to a new location

Notes:
  A filename can be in both .btOrderStart and .btOrderEnd
  This can be useful if you would like to process a file twice, once at the start of a workflow and once at the end
  Will always return a full path name

## EXAMPLES

### EXAMPLE 1
```
get-btFolderItems -path .\source\functions
```

##### DESCRIPTION
Get all files in the path .\source\functions, that are not in the .btIgnorefile, order by .btOrderStart and .btOrderEnd respectively

### EXAMPLE 2
```
get-btFolderItems -path .\source\functions -psScriptsOnly
```

##### DESCRIPTION
Get PS1 files in the path .\source\functions, that are not in the .btIgnorefile order by .btOrderStart and .btOrderEnd respectively

### EXAMPLE 3
```
get-btFolderItems -path .\source\functions -psScriptsOnly -copy -destination 'c:\temp\functions'
```

##### DESCRIPTION
Get PS1 files in the path .\source\functions, that are not in the .btIgnorefile order by .btOrderStart and .btOrderEnd respectively
Copy them (inclusive of directory structure) to 'c:\temp\functions'

## PARAMETERS

### -Path
The path of your bartender module
Defaults to current working directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -psScriptsOnly
Filter out any file that is not a ps1 file

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination
If specified with the copy switch, will copy any found files to this location

```yaml
Type: String
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: SetDestination
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetDestination
{{ Fill SetDestination Description }}

```yaml
Type: SwitchParameter
Parameter Sets: SetDestination
Aliases:

Required: False
Position: 7
Default value: $(if($destination){$true}else{$false})
Accept pipeline input: False
Accept wildcard characters: False
```

### -copy
If specified, will copy any found files to the location specified in Destination

```yaml
Type: SwitchParameter
Parameter Sets: SetDestination
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### null
## OUTPUTS

### Should return an object with a list of files in their ordered version.
### By default will have values of:
###  - Path : Full path to file
###  - relativePath : dot Source notatio for file
### If Copy is used, it will also have values for:
###  - NewPath : The full path to where it was copied
###  - NewFolder : New folder path
### custom object
## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018-05-17


Changelog:
    2018-04-19 - AA
        
        - Initial Script
        - Added primary functionality
     2018-04-24- AA
        
        - Added .btOrder file
        - Added ability to copy files
     2018-05-16 - AA
        
        - Added inline help
        - Included in pester tests
    2018-05-17 - AA
        
        - Improved inline help
        - Added ability to process .btorderEnd and .btOrderStart
        - Removed .btOrder processing
        - Fixed a bug with empty lines in the .btOrder* files
    2019-03-11 - AA
        - Changed a warning to a write-verbose

## RELATED LINKS
