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
 [-newRelease] [<CommonParameters>]
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
Path to module

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
What source folders do functions live in

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
btconfig.xml

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

### -newRelease
If this is set to true, will calculate the differences between previousrelease and lastrelease
as configered in the config file
By default, it will calculate the differences between the lastRelease and the last revision instead
------------

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
    2019-03-11 - AA
        - Changed to read the lastrelease and previousrelease from the config module
        - Broke the summary into smaller portions was getting a bit hectic

## RELATED LINKS
