---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# add-btBasicTests

## SYNOPSIS
Add a basic pester test to the pester folder

## SYNTAX

```
add-btBasicTests [[-path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Add a pester-test to the ..\source\pester folder
This pester-test will test the basic health of your module on execution
The script file (baseModuleTest.ps1) will be added to both the .btOrderStart and .btOrderEnd files, so will run twice
The tests will ensure you are working on only the newly-compiled module and not a previously installed module

## EXAMPLES

### EXAMPLE 1
```
add-btBasicTests
```

#### DESCRIPTION
Create file ..\source\pester\baseModuleTest.ps1
Insert filename into .btOrderStart (At Top)
Insert filename into .btOrderEnd (At Bottom)


#### OUTPUT
N/A

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### null
## OUTPUTS

### null
## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018-05-17


Changelog:
    2018-05-17 - AA
        
        - Initial Script
        - Tested - working
        - Forced a change on get-btFolderItem
    2018-05-18 - AA
        
        - Fixed a bug where it was absolute referencing the module name in the basetest

## RELATED LINKS
