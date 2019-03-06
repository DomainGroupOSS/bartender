---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# start-btRevisionCleanup

## SYNOPSIS
Clean-up bt revisions folder

## SYNTAX

```
start-btRevisionCleanup [[-path] <String>] [[-configFile] <String>] [[-revisions] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Remove any previous revisions to try and keep the size down
By default keep the last 5

## EXAMPLES

### EXAMPLE 1
```
start-btRevisionCleanup
```

#### DESCRIPTION
Remove previous revisions

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
{{Fill configFile Description}}

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

### -revisions
{{Fill revisions Description}}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
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
Last-Edit-Date: 2019-12-03


Changelog:
    2019-01-30
        
        - Initial Script
        - Now we are dealing with revisions, we need a way to not keep creeping the revisions up

## RELATED LINKS
