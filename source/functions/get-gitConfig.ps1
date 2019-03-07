function get-btGitDetails
{

    <#
        .SYNOPSIS
            Simple description
            
        .DESCRIPTION
            Detailed Description
            
        .PARAMETER path
            path to git config
            
        ------------
        .EXAMPLE
            verb-noun param1
            
            #### DESCRIPTION
            Line by line of what this example will do
            
            
            #### OUTPUT
            Copy of the output of this line
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: yyyy-mm-dd
            
            
            Changelog:
                yyyy-mm-dd - AA
                    
                    - Changed x for y
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(

    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $gitDetailsHash = @{}
        $branchSB = [scriptblock]::Create('git branch')
        $commitSB = [scriptblock]::Create('git rev-parse HEAD')
        $commitShortSB = [scriptblock]::Create('git rev-parse --short HEAD')
        $originSB = [scriptblock]::create('git config --get remote.origin.url')
        $branch = $($branchSB.invoke()|out-string)
        if($branch)
        {
            $gitDetailsHash.branch = $branch
            $gitDetailsHash.commit = $($($commitSB.invoke())|out-string)
            $gitDetailsHash.commitShort = $($($commitShortSB.invoke())|out-string)
            $gitDetailsHash.origin = $($($originSB.invoke())|out-string)
            [pscustomobject]$gitDetailsHash
        }
        
    }
    
}