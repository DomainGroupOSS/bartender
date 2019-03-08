---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# get-btInstalledModule

## SYNOPSIS
Get the name and version of an already installed module

## SYNTAX

```
get-btInstalledModule [-moduleName] <String> [-moduleVersion <Version>] [<CommonParameters>]
```

## DESCRIPTION
Get the name and version of an already installed module
If moduleVersion is specified, ensures its installed
Otherwise, return the latest version of the module
Return as a moduleSpecification object

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -moduleName
Name of the module to find

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -moduleVersion
If you want to find a specific version of a module

------------

```yaml
Type: Version
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

## OUTPUTS

## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2019-02-01


Changelog:
    2019-02-01 - AA
        
        - Initial Script
    
    2019-03-04 - AA
        
        - Fixed the documentation
        - Changed the returned object to a modulespecification object
            - Ensured fed correct hashtable

## RELATED LINKS
