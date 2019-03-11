---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# get-btGitDetails

## SYNOPSIS
Simple description

## SYNTAX

```
get-btGitDetails [[-modulePath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Detailed Description

## EXAMPLES

### EXAMPLE 1
```
verb-noun param1
```

#### DESCRIPTION
Line by line of what this example will do


#### OUTPUT
Copy of the output of this line

## PARAMETERS

### -modulePath
Where does the module live?

------------

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $(get-location).path
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
Last-Edit-Date: 2019-06-03


Changelog:
    2019-03-06 - AA
        
        - Initial Script
    
    2019-03-07 - AA
        - Fixed the git commands to run as a job
        - Trim the returned data

## RELATED LINKS
