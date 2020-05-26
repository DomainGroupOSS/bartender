---
external help file: bartender-help.xml
Module Name: bartender
online version:
schema: 2.0.0
---

# get-btScriptText

## SYNOPSIS
Get the text from file

## SYNTAX

```
get-btScriptText [-psfile] <String[]> [[-isFunction] <Boolean>] [[-isDSCClass] <Boolean>]
 [[-removeQuotes] <Boolean>] [[-trimSpaces] <Boolean>] [[-RemoveEmptyLines] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
Get the text from file
Can do some clean-up for you based on parameters used

## EXAMPLES

### EXAMPLE 1
```
$items = get-btScriptItems .\source\functions\
$text = get-btScriptText $items.fileList.fullname -isFunction $true
```

#### DESCRIPTION
Use the filelist provided by get-btScriptItems
Grab the contents of all the ps1 files
Ensure that we capture the function names for our Manifest use later


#### OUTPUT
   TypeName: System.Management.Automation.PSCustomObject
    Name              MemberType   Definition
    ----              ----------   ----------
    dscResources      NoteProperty Object\[\] dscResources=System.Object\[\]
    functionResources NoteProperty Object\[\] functionResources=System.Object\[\]
    output            NoteProperty string output=...

## PARAMETERS

### -psfile
Mandatory
Accepts array
Full filepath(s) to the script file to get the text from.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -isFunction
Tell the script to capture the function names as function-resources
For building manifest

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -isDSCClass
Tell the script to capture the class names as dsc-resources
For building manifest

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -removeQuotes
Remove single line quotes like this #quote quote quote

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -trimSpaces
Get rid of horizontal space, trimming excess spaces around text and removing any spacing

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveEmptyLines
Get rid of most empty lines

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### null
## OUTPUTS

### custom object
## NOTES
Author: Adrian Andersson
Last-Edit-Date: 2018-05-17


Changelog:
    
        
    2018-04-19 - AA
        
        - Initial Script
        - Added primary functionality
    
    2018-04-24 - AA
        
        - Made it return object rather than just text-block
    2018-04-26 - AA
        
        - Fixed the help
        - Fixed the way it grabbed file contents
        - Improved the capture of functions and dsc modules
    2018-05-17 - AA
        
        - Updated help

## RELATED LINKS
