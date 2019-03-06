function publish-btModule
{

    <#
        .SYNOPSIS
            Grab the latest version from the bin folder
            Push it to a nuget repository
            
        .DESCRIPTION
            Grab the latest version from the bin folder
            Push it to a nuget repository

            Will pull the details from the btconfig.xml if params not supplied
            
        .PARAMETER Repository
            What repository are we publishing to

        .PARAMETER token
            Nuget API token
            Will use the publishToken.txt if this is not supplied
            Will only warn if not provided in case you dont need one
             i.e. you are pushing to a fileshare repository

        .PARAMETER configFile
            The Config File to pull the details from
            Will use btconfig.xml by default

        .EXAMPLE
            publish-btModule

            
            #### DESCRIPTION
            Grab the details from btconfig.xml
            Use the nuget api token in publishtoken.txt if there is one
            Grab the latest version of the module from the bin folder
            Initiate a publish-module command with these details
            
            
            #### OUTPUT
            Hopefully, your module has been pushed to your repository
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-05-17
            
            
           Changelog:

                2018-04-19 - AA
                    
                    - Added token and repository details
                    - Initial Script
                    - Tested working
                    
                2018-04-26 - AA
                    
                    - Fixed the help

                2018-05-17 - AA
                    
                    - Updated help

                2019-02-04 - AA
                    - Use the saved Repository settings if available
                        - Do it in such a way that it can be overwritten
                    - Removed the secrets loader
                    - Made the repository paramater required
                    - No longer grab the repository from the config
                        - This will now be passed with a forEach in the start-btBuild
                    
        .COMPONENT
            Bartender
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [Alias("repo")]
        [string]$Repository,
        [string]$token,
        [pscredential]$credential,
        [string]$configFile = 'btconfig.xml'
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $$(MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $$($MyInvocation.BoundParameters|Out-String)"
        $invocationPath = (Get-Item -Path ".\").FullName
        Write-Verbose "Working directory: $invocationPath"

        write-verbose 'Checking if we need to import repository credentials'
        if(($token -eq $null) -or ($credential -eq $null))
        {
            write-verbose 'Token and/Or Credential not supplied, checking saved repository settings'
            $btRepository = get-btRepository -repository $repository
            if($btRepository)
            {
                
                if((!$token) -and ($btRepository.NuGetApiKey -ne $null))
                {
                    write-verbose 'Using saved Nuget API Token'
                    $token = $btRepository.NuGetApiKey
                }else{
                    write-verbose 'Using supplied token'
                    write-verbose "Supplied Token: $token"
                    write-verbose "repo Token: $($btRepository.NuGetApiKey)"
                }

                if(($credential -eq $null) -and ($btRepository.credential -ne $null))
                {
                    write-verbose 'Using saved credential'
                    $credential = $btRepository.credential
                }else{
                    write-verbose 'Using supplied credential'
                    write-verbose "Supplied Username: $($credential.username)"
                    write-verbose "Repo Username: $($btRepository.credential.username)"
                }
            }else{
                write-verbose "Saved repository settings not found for: $repository"
                write-verbose 'You can save credentials and nuget API token with the save-btRepository cmdlet'

            }
        }


        write-verbose 'Checking token'

        
        if(!$token -or $token.length -lt 1)
        {
            Write-Warning 'Token invalid or not provided, may be ok if publishing to a fileshare'
        }

        if(!$credential -or $($credential.GetType().name) -ne 'PSCredential')
        {
            Write-Warning 'Invalid Credential, may be ok if there are no module dependancies, or your repository does not require credentials for read access'
        }

        
        $configFilePath = "$invocationPath\$($configFile)"


        $throwExceptions = @{}
        #NoConfig
        $errCat = [System.Management.Automation.ErrorCategory]::InvalidData
        $errMsg = [System.Exception]::new("Config file was not found.`nUse new-btproject for a new project.")
        $throwExceptions.noConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$configFilePath)
        #BadConfig
        $errMsg = [System.Exception]::new('Config file contents unexpected or malformed.')
        $throwExceptions.badConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$configFilePath)

        #NoRepository
        $errMsg = [System.Exception]::new('No repository specified. Unable to continue')
        $throwExceptions.noRepository = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$configFilePath)

        


        
    }
    
    process{
        write-verbose "InvocationPath: $invocationPath"
        write-verbose "configfile: $configfile"

        write-verbose 'Validating Config File'
        
        if(!$(test-path $configFilePath))
        {
            throw $throwExceptions.noConfigError
        }else{
            $config = Import-Clixml $configFilePath

        }

        
        if(!$repository)
        {
            throw 'No repository and/or ModuleName provided'
        }
        
        Write-Verbose "Repository specified as: $repository"
        #Check the repository is setup
        try{
            $rep = get-psrepository $repository -ErrorAction Stop
            $rep|out-null
        }catch{
            write-error "Repository $($repository) is not currently configured.`nPlease configure your publish repository first or specify a different one"
            return
        }
        
        Write-Verbose 'Finding the latest version'
        $version = $config.versionAsTag
        $moduleFolder = "$invocationPath\$($config.modulename)\$version"
        $manifestFile = "$moduleFolder\$($config.modulename).psd1"
        $moduleFile = "$moduleFolder\$($config.modulename).psm1"
        Write-Verbose 'Checking files/folders exist'
        Write-Verbose "Module should live in folder: $moduleFolder`n`tmanifest: $manifestFile`n`tmodule: $moduleFile"
        if(!$(test-path $moduleFolder) -or !$(test-path $manifestFile) -or !$(test-path $moduleFile))
        {
            Write-Error 'Unable to find relevant build for current version. Unable to continue'
            return
        }
        
        Write-Verbose 'Finalising the command params'
        $splat = @{
            Path = $moduleFolder
            Repository =  $Repository
        }
       
        if($token)
        {
            $splat.NugetApiKey = $token
        }

        if($credential)
        {
            $splat.credential = $credential
        }
        
        Write-Verbose $($splat|Out-String)
        Publish-Module @splat

    }
}