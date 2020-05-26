---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# update-btFileStructure

## SYNOPSIS
Update the current projects file and config to the installed version of bartender

## SYNTAX

```
update-btFileStructure [[-path] <String>] [[-configFile] <String>] [-force] [<CommonParameters>]
```

## DESCRIPTION
Check the folder structer and files are what the installed version are expecting
Add them if they are not present
Add the bartender version to the module config
Add the autodocument variable to the module config

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
update-btFileStructure -force
```

#### DESCRIPTION
Always update

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

### -configFile
The bartender configfile to use
Defaults to btconfig.xml

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Btconfig.xml
Accept pipeline input: False
Accept wildcard characters: False
```

### -force
Ignore any differences in version and run anyway

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### null
## OUTPUTS

### custom object
## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018-05-17


Changelog:
    2018-0
    2018-05-17 - AA
        
        - Initial Script
        - Added Help
        - Updated Config file
    2018-05-17 - AA
        
        - Added add-btBasicTests to the update function
    2018-08-13
        - Added validationClasses folder
    2018-10-30
        - Added postBuildScript folder
        - Fixed errormsg with btversion that could occur where the var was declared but empty
    2018-12-03
        - Added Revisions folder (rev)
    
    2019-02-03
        - Add a default setting for autodocument

## RELATED LINKS
