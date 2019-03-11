---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# save-btDefaultSettings

## SYNOPSIS
Save API token and, if supplied, Repository Credentials

## SYNTAX

```
save-btDefaultSettings [[-author] <String>] [[-repository] <String>] [[-company] <String>] [[-Tags] <String[]>]
 [[-minimumPsVersion] <Version>] [[-AutoIncrementRevision] <Boolean>] [[-RemoveSingleLineQuotes] <Boolean>]
 [[-RemoveEmptyLines] <Boolean>] [[-trimSpaces] <Boolean>] [[-publishOnBuild] <Boolean>]
 [[-autoDocument] <Boolean>] [[-runPesterTests] <Boolean>] [[-useGitDetails] <Boolean>] [-update]
 [<CommonParameters>]
```

## DESCRIPTION
Save API token and credentials, in order to provide the ability to publish/find modules without 
having to enter this stuff all the time

## EXAMPLES

### EXAMPLE 1
```
save-btDefaultSettings -author my.name -repositories @('myrepo1','psgallery')
```

#### DESCRIPTION
Will save the repository myRepo with the token, and prompt once for credentials.

## PARAMETERS

### -author
Default Module Author

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -repository
Default repositories to publish to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -company
Default Company to publish as

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tags
Default Tags to use

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -minimumPsVersion
The default minimumPsVersion to use

```yaml
Type: Version
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoIncrementRevision
The default AutoIncrementRevision value

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveSingleLineQuotes
Default RemoveSingleLineQuotes value

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveEmptyLines
Default RemoveEmptylines Value

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -trimSpaces
Default trimSpaces value

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -publishOnBuild
Default publishOnBuild value

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -autoDocument
Default autoDocument Value

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -runPesterTests
{{Fill runPesterTests Description}}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -useGitDetails
Grab the license and project URI from Git details
Use them on manifest creation

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -update
Use to overwrite any existing saved default settings

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
Last-Edit-Date: yyyy-mm-dd


Changelog:
    2019-02-01 - AA
        
        - Initial Script
            - Unsure what to do about LINUX and PSCORE
            - Obviously the save path is less than ideal
            - Also unsure what will happen with roaming profiles
            - What if we include _this_ computername in the filename
    2019-03-07 - AA
        
        - Added way to save useGitDetails

## RELATED LINKS
