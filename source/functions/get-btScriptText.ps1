function get-btScriptText
{
    <#
        .SYNOPSIS
            Get the text from file
            
        .DESCRIPTION
            Get the text from file
            Can do some clean-up for you based on parameters used
            
        .PARAMETER psfile
            Mandatory
            Accepts array

            Full filepath(s) to the script file to get the text from.
        
        
        .PARAMETER isFunction
           Tell the script to capture the function names as function-resources
           For building manifest
        
        .PARAMETER isDSCClass
           Tell the script to capture the class names as dsc-resources
           For building manifest

        .PARAMETER removeQuotes
           Remove single line quotes like this #quote quote quote

        .PARAMETER trimSpaces
            Get rid of horizontal space, trimming excess spaces around text and removing any spacing

        .PARAMETER RemoveEmptyLines
           Get rid of most empty lines
            
        .EXAMPLE
            $items = get-btScriptItems .\source\functions\
            $text = get-btScriptText $items.fileList.fullname -isFunction $true
            
            #### DESCRIPTION
            Use the filelist provided by get-btScriptItems
            Grab the contents of all the ps1 files
            Ensure that we capture the function names for our Manifest use later
            
            
            #### OUTPUT
               TypeName: System.Management.Automation.PSCustomObject

                Name              MemberType   Definition
                ----              ----------   ----------
                dscResources      NoteProperty Object[] dscResources=System.Object[]
                functionResources NoteProperty Object[] functionResources=System.Object[]
                output            NoteProperty string output=...

            
            
        .NOTES
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
                    
                    
        .COMPONENT
            Bartender

        .INPUTS
           null

        .OUTPUTS
            custom object
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [string[]]$psfile,
        [bool]$isFunction = $false,
        [bool]$isDSCClass = $false,
        [bool]$removeQuotes = $true,
        [bool]$trimSpaces = $false,
        [bool]$RemoveEmptyLines = $true

        
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $$(MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $$($MyInvocation.BoundParameters|Out-String)"
        $outputObj = [pscustomobject]@{
            output = ""
            functionResources = @()
            dscResources = @()
        }

    }
    
    process{
        foreach($file in $psfile)
        {
            $content = get-content $file
            $lineNo = 1
            $content = foreach($line in $content)
            {
                if($isFunction -eq $true)
                {
                    if($line -like 'function *')
                    {
                        Write-Verbose "FOUND FUNCTION: $($file)`n`tLine:$lineNo"
                        $functionName = $($line -split 'function ')[1]
                        if($functionname -like '*{*')
                        {
                            $functionName = $($functionName -split '{')[0]
                        }
                        $functionName = $functionName.trim()
                        $outputObj.functionResources += $functionName
                        Write-Verbose "Adding $functionName to function resources"
                        remove-variable functionName -ErrorAction SilentlyContinue
                    }
                }
                if($isDSCClass -eq $true)
                {
                    if($line -like 'class *')
                    {
                        Write-Verbose "FOUND CLASS: $($file)`n`tLine:$lineNo"
                        $dscClassName = $($line -split 'class ')[1]
                        write-verbose $dscClassName
                        if($dscClassName -like '*{*')
                        {
                            $dscClassName = $($dscClassName -split '{')[0]
                        }
                        $dscClassName = $dscClassName.trim()
                        $outputObj.dscResources += $dscClassName
                        Write-Verbose "Adding $dscClassName to dscResources resources"
                        remove-variable functionName -ErrorAction SilentlyContinue
                    }

                }
                if($removeQuotes -eq $true)
                {
                    
                    if($line -like '*#*' -and (($line -notlike '*<#*') -and ($line -notlike '*#>*')))
                    {
                        Write-Verbose 'Scrubbing quotes'
                        $line = $($line -split '#')[0]
                    }
                }
                if($trimSpaces -eq $true)
                {
                    $line = $line.trim()
                }
                if($RemoveEmptyLines -eq $true)
                {
                    if($line.length -gt 0)
                    {
                        $line
                    }
                }else{
                    $line
                }
                $lineNo++
            }
            if($RemoveEmptyLines -eq $true)
            {
                $content = $content | where-object {$_ -ne "^\s+" -and $_ -ne ''}
            }
            $outputObj.output += "`n$($content|out-string)"
        }

        $outputObj
        
    }
   

    
}