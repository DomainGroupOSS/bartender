---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# get-btRepository

## SYNOPSIS
Find repository settings, return as a splatable hashtable

## SYNTAX

### single (Default)
```
get-btRepository [-repository] <String> [<CommonParameters>]
```

### listAvailable
```
get-btRepository [-listAvailable] [<CommonParameters>]
```

## DESCRIPTION
Find repository settings, return as a splatable hashtable.
If no repository is found, return null

Also check the repository still exists

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
Parameter Sets: single
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -listAvailable
{{Fill listAvailable Description}}

```yaml
Type: SwitchParameter
Parameter Sets: listAvailable
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

## OUTPUTS

## NOTES
Author: Adrian Andersson
Last-Edit-Date: yyyy-mm-dd


Changelog:
    2019-02-01 - AA
        
        - Initial Script

## RELATED LINKS
