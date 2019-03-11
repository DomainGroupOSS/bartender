---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# save-btRepository

## SYNOPSIS
Save API token and, if supplied, Repository Credentials

## SYNTAX

```
save-btRepository [-repository] <String> [-token] <String> [[-credential] <PSCredential>] [-update]
 [<CommonParameters>]
```

## DESCRIPTION
Save API token and credentials, in order to provide the ability to publish/find modules without 
having to enter this stuff all the time

## EXAMPLES

### EXAMPLE 1
```
save-btRepository -repository myRepo -token MyAPIToken -credentail get-credential
```

#### DESCRIPTION
Will save the repository myRepo with the token, and prompt once for credentials.


#### OUTPUT
Copy of the output of this line

## PARAMETERS

### -repository
Name of the repository to use the credentials against

Requires repository to already be registered

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

### -token
The Repository API Token to use to publish the module

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -credential
The Repository Credential to use
If no credentials are supplied only the token will be saved.
If your repository requires credentials for saving/listing modules,
Then you will need to supply the credentials here.
They are used to verify whether any dependant modules need to be uploaded when publishing

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

### -update
Use to overwrite any existing saved repo settings

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

## RELATED LINKS
