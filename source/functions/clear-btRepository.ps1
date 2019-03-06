function clear-btRepository
{

    <#
        .SYNOPSIS
            Find and remove a saved repository
            
        .DESCRIPTION
            Removes saved repository settings
        
        .PARAMETER repository
            Name of the repository to use the credentials against
                        
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-04
            
            
            Changelog:
                2019-02-01 - AA
                    
                    - Initial Script

                2019-02-01 - AA
                    
                    - Fixed help
                        - Still had get-btRepository documentation by accident

                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$true)]
        [string]$repository,
        [switch]$force
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
            write-warning 'Repository not found'
            return
        }


        write-verbose 'Checking we have settings'
        if($btRepositories."$repository")
        {
            write-verbose "Repository $repository found"
            if(!$force)
            {
                $confirm = read-host "Are you sure you wish to remove the $repository repository`n(Use -force switch to suppress this message)`nEnter 'Y' to confirm:"
                if($confirm -eq 'y')
                {
                    write-warning "$repository will be removed from save state"
                    $btRepositories.remove("$repository")
                    $btRepositories|export-clixml $btRepositoriesPath -force
                }else{
                    write-warning "Leaving $repository Repository in saved state"

                }

            }else{
                write-warning "-force param used, removing repository"
                $btRepositories.remove("$repository")
                $btRepositories|export-clixml $btRepositoriesPath -force
            }
            
        }else{
            write-warning 'Repository settings not found'

            return
        }
    }
}