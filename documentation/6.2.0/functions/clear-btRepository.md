---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# clear-btRepository

## SYNOPSIS
Find and remove a saved repository

## SYNTAX

```
clear-btRepository [-repository] <String> [-force] [<CommonParameters>]
```

## DESCRIPTION
Removes saved repository settings

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -repository
Name of the repository to use the credentials against

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -force
{{ Fill force Description }}

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

## OUTPUTS

## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2019-03-04


Changelog:
    2019-02-01 - AA
        
        - Initial Script
    2019-02-01 - AA
        
        - Fixed help
            - Still had get-btRepository documentation by accident

## RELATED LINKS
