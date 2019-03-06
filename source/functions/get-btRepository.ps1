function get-btRepository
{

    <#
        .SYNOPSIS
            Find repository settings, return as a splatable hashtable
            
        .DESCRIPTION
            Find repository settings, return as a splatable hashtable.
            If no repository is found, return null
            
            Also check the repository still exists
        
        .PARAMETER repository
            Name of the repository to use the credentials against
                        
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: yyyy-mm-dd
            
            
            Changelog:
                2019-02-01 - AA
                    
                    - Initial Script

                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding(DefaultParameterSetName='single')]
    PARAM(
        
        [Parameter(Position=0,Mandatory=$true,ParameterSetName='single')]
        [string]$repository,
        [Parameter(ParameterSetName='listAvailable')]
        [switch]$listAvailable
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
        #Where should we save the module
        $localPath = "$($env:userprofile)\AppData\local"
        $btSaveFolder = "$localPath\bartender"
        $btRepositoriesPath = "$btSaveFolder\btRepositories_$($env:computername).xml"
        
    }
    
    process{

        write-verbose 'Importing existing saved repositories'
        if(test-path $btRepositoriesPath)
        {
            try{
                $btRepositories = import-clixml $btRepositoriesPath -errorAction stop
            }catch{
                write-warning 'File was found but unable to import'
                return
            }
        }else{
            write-warning 'No repositories found'
            return
        }

        if($($PSCmdlet.ParameterSetName) -eq 'listAvailable')
        {
            write-verbose 'Getting all repositories'
            foreach($repo in $btRepositories.keys)
            {
                $hash = @{
                    Repository = $repo
                    NuGetApiKey = $($($btRepositories."$repo").token.getNetworkCredential().password)
                }
                if($($btRepositories."$repo".credential))
                {
                    $hash.credential = $btRepositories."$repo".credential
                }
                [pscustomobject]$hash
                remove-variable hash -erroraction 'silentlyContinue'
            }
        }else{
            write-verbose 'Checking we have settings'
            if($btRepositories."$repository")
            {
                write-verbose 'Converting to psget splat hashtable'
                $hash = @{
                    Repository = $repository
                    NuGetApiKey = $($($btRepositories."$repository").token.getNetworkCredential().password)
                }
                if($($btRepositories."$repository".credential))
                {
                    $hash.credential = $btRepositories."$repository".credential
                }
                return $hash
            }else{
                write-warning 'Repository settings not found'
                return
            }
        }

        

        
    }
    
}