---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# get-btDocumentation

## SYNOPSIS
If you have platyPs on your system, extract the comment_based_help to markdown

## SYNTAX

```
get-btDocumentation [[-path] <String>] [[-configFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Check if you have platyps
If you have platyps:
 - launch the latest compiled version of the module in a scriptblock
 - Read the exported commands from the module manifest
 - Use platyPs to export the inline comment_based_help to MarkDown

 Markdown will be placed in the documentation folder under the respective version
 i.e.
..\documentation\1.0.0\my-function.ps1

## EXAMPLES

### EXAMPLE 1
```
get-btDocumentation
```

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
    2018-07-17 - AA
        
        - Attempted to only execute if there are functions to document
    2018-05-17 - AA
        
        - Initial Script
        - Tested, working
    2019-01-30 - 2019-02-04 - AA
        - Updated to use new folder path
        - Code clean-up

## RELATED LINKS
