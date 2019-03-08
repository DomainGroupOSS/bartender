---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# get-btChangeDetails

## SYNOPSIS
Try and work out what function files changed, were created etc, from the last release

## SYNTAX

```
get-btChangeDetails [[-modulePath] <String>] [[-functionFolders] <String[]>] [[-configFile] <String>]
 [-ignoreLast] [<CommonParameters>]
```

## DESCRIPTION
Gets the lastModified date of the previous release module manifest
Check the source function folders with get-btFolderItems
See what functions live in there
See if the lastModified is after the previous release
Note that the functions were potentially changed

## EXAMPLES

### EXAMPLE 1
```
get-btChangeDetails
```

## PARAMETERS

### -modulePath
{{Fill modulePath Description}}

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

### -functionFolders
{{Fill functionFolders Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @('functions','private')
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
Position: 3
Default value: BtConfig.xml
Accept pipeline input: False
Accept wildcard characters: False
```

### -ignoreLast
{{Fill ignoreLast Description}}

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

## OUTPUTS

## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2019-03-06


Changelog:
    2019-03-06 - AA
        
        - Initial Script

## RELATED LINKS
