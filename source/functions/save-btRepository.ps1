function save-btRepository
{

    <#
        .SYNOPSIS
            Save API token and, if supplied, Repository Credentials

        .DESCRIPTION
            Save API token and credentials, in order to provide the ability to publish/find modules without
            having to enter this stuff all the time

        .PARAMETER repository
            Name of the repository to use the credentials against

            Requires repository to already be registered

        .PARAMETER token
            The Repository API Token to use to publish the module

        .PARAMETER credential
            The Repository Credential to use

            If no credentials are supplied only the token will be saved.
            If your repository requires credentials for saving/listing modules,
            Then you will need to supply the credentials here.
            They are used to verify whether any dependant modules need to be uploaded when publishing

        .PARAMETER update
            Use to overwrite any existing saved repo settings

        .EXAMPLE
            save-btRepository -repository myRepo -token MyAPIToken -credentail get-credential

            #### DESCRIPTION
            Will save the repository myRepo with the token, and prompt once for credentials.


            #### OUTPUT
            Copy of the output of this line



        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: yyyy-mm-dd


            Changelog:
                2019-02-01 - AA

                    - Initial Script
                        - Unsure what to do about LINUX and PSCORE
                        - Obviously the save path is less than ideal
                        - Also unsure what will happen with roaming profiles
                        - What if we include _this_ computername in the filename

        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [string]$repository,
        [Parameter(Mandatory=$true)]
        [string]$token,
        [pscredential]$credential,
        [switch]$update
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"

    }

    process{
        #Where should we save the module
        write-verbose 'Getting Save location'
        $localPath = "$($env:userprofile)\AppData\local"
        if(test-path $localPath)
        {
            $btSaveFolder = "$localPath\bartender"
            $btRepositoriesPath = "$btSaveFolder\btRepositories_$($env:computername).xml"
            if(!$(test-path $btSaveFolder))
            {
                write-verbose "Creating bartender folder at $btSaveFolder"
                new-item -itemtype directory -path $btSaveFolder

            }else{
                write-verbose 'bt path exists'
            }
        }else{
            throw 'Local Profile unavailable'
        }

        write-verbose 'Checking for valid repository'
        if($repository -notIn $(get-psrepository).name)
        {
            throw "Repository not found with name $repository!`nPlease register a repository first with the 'Register-PSRepository' cmdlet"
        }

        write-verbose 'Importing existing saved repositories'
        if(test-path $btRepositoriesPath)
        {
            try{
                write-verbose 'Importing existing repository settings'
                $btRepositories = import-clixml $btRepositoriesPath -errorAction stop
            }catch{
                write-error $error[0]
                throw 'unable to import repository settings'
            }
        }else{
            write-verbose 'Previous settings not found, creating'
            $btRepositories = @{}
        }


        write-verbose 'Checking we do not already have settings'
        if(($btRepositories."$repository") -and ($update -ne $true))
        {
            throw 'Repository settings already exist. To overwrite use the -update switch'
        }

        write-verbose "Creating new entry for $repository"
        $btRepositories."$repository" = @{}
        $btRepositories."$repository".token = $(new-object System.Management.Automation.PSCredential('apiToken',$($token|convertTo-SecureString -asPlainText -force)))
        if($credential)
        {
            $btRepositories."$repository".credential = $credential
        }else{
            write-warning "No credentials supplied.`nIf your repository requires credentials for saving, you will need to provide them here as well.`nFailure to do so will cause errors when including required/dependant modules"
        }

        write-debug 'Save the file'
        write-verbose 'Updating saved repositories file'
        $btRepositories|export-clixml $btRepositoriesPath -force
    }

}