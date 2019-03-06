---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# add-btFilesAndFolders

## SYNOPSIS
Add the files and folders required by Bartender

## SYNTAX

```
add-btFilesAndFolders [[-path] <String>] [-force] [<CommonParameters>]
```

## DESCRIPTION
Check the folder structer and files are what the installed version are expecting
Add them if they are not present

## EXAMPLES

### EXAMPLE 1
```
update-btFileStructure
```

#### DESCRIPTION
Check for differences in Bartender Versions
Update if required

### EXAMPLE 2
```
add-btFilesAndFolders -force
```

#### DESCRIPTION
Add the folders and files

## PARAMETERS

### -path
The path of your bartender module
Defaults to current working directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-Item -Path ".\").FullName
Accept pipeline input: False
Accept wildcard characters: False
```

### -force
Required so that this is not accidentally called

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

### null
## OUTPUTS

### custom object
## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018-12-03


Changelog:
    2018-12-03 - AA
        
        - Initial Script
        - Migrated from update-btFileStructure
    2019-01-30
        - Create new folder for revision
        - Remove the old publishToken.txt
    2019-03-04
        - Fix a bug where the stripping of auth tokens was accidentally a scriptblock

## RELATED LINKS
