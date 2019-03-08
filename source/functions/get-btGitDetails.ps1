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
        [string]$modulePath = $(get-location).path
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"

        if($modulePath -like '*\')
        {
            Write-Verbose 'Superfluous \ found in path, removing'
            $modulePath = $modulePath.Substring(0,$($modulePath.Length-1))
            Write-Verbose "New path = $modulePath"
        }
        



        
    }
    
    process{
        
        if(!$(test-path $modulePath))
        {
            throw "Module path not found"
        }else{
            $modulePath = $(get-item $modulePath).fullname
        }

        $gitDetailsHash = @{}
        $branchSB = [scriptblock]::Create("set-location $modulePath;git branch")
        $commitSB = [scriptblock]::Create("set-location $modulePath;git rev-parse HEAD")
        $commitShortSB = [scriptblock]::Create("set-location $modulePath;git rev-parse --short HEAD")
        $originSB = [scriptblock]::create("set-location $modulePath;git config --get remote.origin.url")
        write-verbose $branchSB.ToString()
        try{
            $branch = $($($j = start-job $branchSb;wait-job $j|out-null;Receive-Job $j -ErrorAction Stop)|out-string).trim()
        }catch{
            write-warning 'Not a git folder'
            $branch = $null
        }
        
        if($branch)
        {
            $gitDetailsHash.branch = $branch
            $gitDetailsHash.commit = $($($j = start-job $commitSB;wait-job $j|out-null;Receive-Job $j)|out-string).trim()
            $gitDetailsHash.commitShort = $($($j = start-job $commitShortSB;wait-job $j|out-null;Receive-Job $j)|out-string).trim()
            $gitDetailsHash.origin = $($($j = start-job $originSB;wait-job $j|out-null;Receive-Job $j)|out-string).trim()
            [pscustomobject]$gitDetailsHash
        }
        
    }
    
}