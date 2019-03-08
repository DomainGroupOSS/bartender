function get-btMarkdownFromHashtable
{

    <#
        .SYNOPSIS
            Simple description
            
        .DESCRIPTION
            Detailed Description
            
        .PARAMETER hashtable
            The Hashtable to convert to a Markdown Table
            
        ------------
        .EXAMPLE
            get-mdFromHashtable @{
                first = 'firstname'
                last = 'lastname'
            }

        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-08
            
            
            Changelog:

                2019-03-08 - AA
                    
                    - Initial Script
                    
        .COMPONENT
            bartender
    #>

    [CmdletBinding()]
    PARAM(
        [hashtable]$hashtable
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $header = "|item|value|`n|:-:|:-:|"
        $body = foreach($key in $hashtable.Keys)
        {
            "|$key|$($hashtable."$key")|"
        }

        "$header`n$($body -join "`n")"
        
    }
    
}