function get-btScriptFunctions
{

    <#
        .SYNOPSIS
            Try and get all the functions from a script
            
        .DESCRIPTION
            Try and get all the functions from a script
            
        .PARAMETER path
            PS1 file to check
            
        .EXAMPLE
            get-scriptFunctions myscript.ps1
            
        DESCRIPTION
            ------------
            Try and get all the functions from a script
            
            
        OUTPUT
        ------------
            Copy of the output of this line
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2017-11-13
            
            
            Changelog:
                2017-11-13 - AA
                    
                    - Initial Script
                2019-03-06 - AA
                    - Copied into BarTender module
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$false,Position=0)]
        [string]$path
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $item = get-item $path
        if(Test-Path $item)
        {

            $contents = get-content $item
            foreach($line in $contents)
            {

                if($line -like 'function *')
                {
                    $($line -split 'function ')[1]

                }
            }
        }else{
            Write-Error 'Nope, cannot find file'
        }
        
    }
    
}