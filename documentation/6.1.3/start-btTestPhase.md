---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# start-btTestPhase

## SYNOPSIS
Run a test of the module

## SYNTAX

```
start-btTestPhase [[-path] <String>] [-configFile <String>] [-modulePath <String>] [<CommonParameters>]
```

## DESCRIPTION
- Create a new runspace
- Run the module in as a job
- If pester is installed, include in the job any tests in the source\pester folder
- Return a custom result of what occured
Running as a job ensures we are on a clean powershell process, hopefully with no modules loading
Will respect the .btIgnore, .btOrder* files

## EXAMPLES

### EXAMPLE 1
```
start-btTestPhase
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
Position: Named
Default value: Btconfig.xml
Accept pipeline input: False
Accept wildcard characters: False
```

### -modulePath
{{Fill modulePath Description}}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### null
## OUTPUTS

### custom object
## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018-05-17


Changelog:
    2018-05-16 - AA
        
        - Initial Script
        - Tested ok
        - Improved job execution
    2018-05-17 - AA
        
        - Added help
        - Allowed passing of variables to pester for basic module tests
        - Improved job execution
        - Improved the return object
    2019-01-31 - AA
        
        - Rewrite to accept a path for the module
        - So we don't always use the dist path
    2019-02-25
        - Somehow this file disappeared
            - Pulled from the last commit with this file

## RELATED LINKS
