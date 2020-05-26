---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# publish-btModule

## SYNOPSIS
Grab the latest version from the bin folder
Push it to a nuget repository

## SYNTAX

```
publish-btModule [-Repository] <String> [[-token] <String>] [[-credential] <PSCredential>]
 [[-configFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
Grab the latest version from the bin folder
Push it to a nuget repository
Will pull the details from the btconfig.xml if params not supplied

## EXAMPLES

### EXAMPLE 1
```
publish-btModule
```

#### DESCRIPTION
Grab the details from btconfig.xml
Use the nuget api token in publishtoken.txt if there is one
Grab the latest version of the module from the bin folder
Initiate a publish-module command with these details


#### OUTPUT
Hopefully, your module has been pushed to your repository

## PARAMETERS

### -Repository
What repository are we publishing to

```yaml
Type: String
Parameter Sets: (All)
Aliases: repo

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -token
Nuget API token
Will use the publishToken.txt if this is not supplied
Will only warn if not provided in case you dont need one
 i.e.
you are pushing to a fileshare repository

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

### -credential
{{ Fill credential Description }}

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -configFile
The Config File to pull the details from
Will use btconfig.xml by default

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: Btconfig.xml
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018-05-17


Changelog:
    2018-04-19 - AA
        
        - Added token and repository details
        - Initial Script
        - Tested working
        
    2018-04-26 - AA
        
        - Fixed the help
    2018-05-17 - AA
        
        - Updated help
    2019-02-04 - AA
        - Use the saved Repository settings if available
            - Do it in such a way that it can be overwritten
        - Removed the secrets loader
        - Made the repository paramater required
        - No longer grab the repository from the config
            - This will now be passed with a forEach in the start-btBuild

## RELATED LINKS
