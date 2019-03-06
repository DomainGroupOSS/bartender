function new-btProject
{

    <#
        .SYNOPSIS
            Start a new bartender project
            Make sure you are in a decent folder location as it uses root
            
        .DESCRIPTION
            Will build out the folder structure for a new bt project
            and make a btConfig.xml file with all the settings set in the parameters
            
        .PARAMETER moduleName
            Mandatory
            The name of your module

        .PARAMETER moduleDescription
            Mandatory
            Description of your module
        
        .PARAMETER modulePath
            Path of your module
            Will use the current path by default

        .PARAMETER moduleAuthor
            Module Author
            Will use $env:USERNAME by default
            Used in module manifest

        .PARAMETER companyName
            Company name
            Used in module manifest

        .PARAMETER majorVersion
            Major version to start at
            Default is 1
            Only required if you want to start at something other than 1 coz your special

        .PARAMETER minorVersion
            Minor version to start at
            Default is 0
            
        .PARAMETER buildVersion
            Build version to start at
            Default is 0

        .PARAMETER minimumPsVersion
            PS Version for your module
            Used in making the manifest and restricting its use
            Default is 5.0.0.0

        .PARAMETER AutoIncrementRevision
            Default True
            Increment the Revision version when running start-btBuild command

        .PARAMETER RemoveSingleLineQuotes
            Default True
            Remove any single line quotes when compiling scripts
        
        .PARAMETER RemoveEmptyLines
            Default True
            Remove any extra empty lines when compiling scripts

        .PARAMETER trimSpaces
            Default False
            Remove any extra spaces
            Breaks your function spacing, so only use if you want a flat file

        .PARAMETER publishOnBuild
            Default True
            When incrementing build version, will push to the repository specified

        .PARAMETER runPesterTests
            Default True
            Add the basic module pester tests to the pester folder

        .PARAMETER repository
            Default powershelf
            The Powershell repository to automatically publish to

        .PARAMETER RequiredModules
            Array of modules you want to include as mandatory when building the manifest

            If a string is supplied, then the version will be whatever latest version is installed

            If a hashtable is supplied it should be constructed as such:
            @{moduleName='myModule';moduleVersion='1.2.3'}
            

        .PARAMETER Tags
            
            The tags to apply in the manifest, helping when searching repositories

        .PARAMETER configFile
            The file to save the config file as
            Defaults to 'btConfig.xml'

            Don't change this, I havent really written it to deal with poor names
        
        .PARAMETER autoDocument
            Default True

            Specify that when running start-btBuild, you want to automatically run get-btDocumentation as well

        .EXAMPLE
            new-btProject -moduleName myModule -moduleDescription 'A new module'
            
            #### DESCRIPTION
            Make a new powershell module project, include the repository token, use the defaults for everything else
            
            
            #### OUTPUT
            Will make the following folder structure:

            - dist
              - documentation
              - source
                - classes
                - dscClasses
                - enums
                - filters
                - functions
                - pester
                - private
                - resource
                - bin
                - lib

            
            Will include a default .gitignore, .btOrderStart, .btOrderEnd

            Will make a new publishtoken.txt that _should_ not be tracked by GIT
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-05-17
            
            
           Changelog:

                2018-04-19 - AA
                    
                    - Initial Script
                    - Added primary functionality
                    - Based off the combine scripts
                

                2018-04-23 - AA
                    
                    - Added token and repository details

                2018-04-26 - AA
                    
                    - Fixed the help

                2018-05-17 - AA
                    
                    - Updated help
                    - Ensure we error out if we already have a config
                    - Cleaned up no longer needed comments

                2018-12-03 - AA
                    
                    - Remove the folder and file creation
                    - Execute the update-btFileStructure to make them instead

                2019-02-04 - AA
                    - Changed all the boolean params
                        - They can now be null
                        - Defaults are now, as a result, in the begin block
                            - Will read from a saved config if one exists
                            - Will then fall-back to an appropriate default
                    - Made the RequiredModules an array
                        - The array will check for HashTable or String entries
                            - Strings need to be the name of an installed module
                            - Hashtable requires moduleVersion and moduleName strings
                            - Where a hashtable is supplied, the version must be installed on the machine
                        - Makes use of new get-btInstalledModules function
                        - Will lock-down the version to the latest at build time as a result
                            - This should allow updated modules to push the latest required package to the repository as a result
                    - Updated repository to allow multiple arguments
                        - Updated -start-btbuild and publish-btModule cmdlets as a result
                        - Allows you to set multiple default repositories to publish to


                    
        .COMPONENT
            Bartender

        .INPUTS
           null

        .OUTPUTS
           null
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [string]$moduleName,
        [Parameter(Mandatory=$true)]
        [string]$moduleDescription,
        [string[]]$repository,
        [string[]]$moduleAuthor,
        [string]$companyName,
        [version]$minimumPsVersion,
        [Nullable[boolean]]$AutoIncrementRevision,
        [Nullable[boolean]]$RemoveSingleLineQuotes,
        [Nullable[boolean]]$RemoveEmptyLines,
        [Nullable[boolean]]$trimSpaces,
        [Nullable[boolean]]$publishOnBuild,
        [Nullable[boolean]]$runPesterTests,
        [Nullable[boolean]]$autoDocument,
        [array]$RequiredModules,
        [string[]]$Tags,
        [int]$majorVersion = 1,
        [int]$minorVersion = 0,
        [int]$buildVersion = 0,
        [string]$modulePath = $(get-location).path,
        [string]$configFile = 'btConfig.xml'
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $$(MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $$($MyInvocation.BoundParameters|Out-String)"
        if($modulePath -like '*\')
        {
            Write-Verbose 'Superfluous \ found in path, removing'
            $modulePath = $modulePath.Substring(0,$($modulePath.Length-1))
            Write-Verbose "New path = $modulePath"
        }

        write-verbose 'Loading user defaults'
        $userDefaults = get-btDefaultSettings
        write-verbose 'Setting parameter defaults'
        if(!$userDefaults)
        {
            write-warning 'You can save your default module preferences by using the save-btDefaultSettings cmdlet'
        }

        write-verbose 'Populating default Params where missing'
        if(!$moduleAuthor)
        {
            if($userDefaults.author)
            {
                $moduleAuthor = $userDefaults.author
            }else{
                $moduleAuthor = $($env:USERNAME)
            }
        }

        if(!$repository)
        {
            if($userDefaults.repository)
            {
                $repository = $userDefaults.repository
            }else{
                write-warning 'Repository not configured'
            }
        }

        if(!$companyName)
        {
            if($userDefaults.company)
            {
                $companyName = $userDefaults.company
            }else{
                write-warning 'companyName not configured'
                $companyName = ' '
            }
        }

        if(!$Tags)
        {
            if($userDefaults.Tags)
            {
                $Tags = $userDefaults.Tags
            }
        }

        if(!$minimumPsVersion)
        {
            if($userDefaults.minimumPsVersion)
            {
                $minimumPsVersion = $userDefaults.minimumPsVersion
            }else{
                $minimumPsVersion = [version]::new(5,0,0,0)
            }
        }

        if($AutoIncrementRevision -eq $null)
        {
            if($userDefaults.AutoIncrementRevision -ne $null)
            {
                $AutoIncrementRevision = $userDefaults.AutoIncrementRevision
            }else{
                $AutoIncrementRevision  = $true
            }
        }

        if($RemoveSingleLineQuotes -eq $null)
        {
            if($userDefaults.RemoveSingleLineQuotes -ne $null)
            {
                $RemoveSingleLineQuotes = $userDefaults.RemoveSingleLineQuotes
            }else{
                $RemoveSingleLineQuotes  = $true
            }
        }

        if($RemoveEmptyLines -eq $null)
        {
            if($userDefaults.RemoveEmptyLines -ne $null)
            {
                $RemoveEmptyLines = $userDefaults.RemoveEmptyLines
            }else{
                $RemoveEmptyLines  = $true
            }
        }

        if($trimSpaces -eq $null)
        {
            if($userDefaults.trimSpaces -ne $null)
            {
                $trimSpaces = $userDefaults.trimSpaces
            }else{
                $trimSpaces  = $false
            }
        }

        if($publishOnBuild -eq $null)
        {
            if($userDefaults.publishOnBuild -ne $null)
            {
                $publishOnBuild = $userDefaults.publishOnBuild
            }else{
                $publishOnBuild  = $true
            }
        }

        if($runPesterTests -eq $null)
        {
            if($userDefaults.runPesterTests -ne $null)
            {
                $runPesterTests = $userDefaults.runPesterTests
            }else{
                $runPesterTests  = $true
            }
        }

        if($autoDocument -eq $null)
        {
            if($userDefaults.autoDocument -ne $null)
            {
                $autoDocument = $userDefaults.autoDocument
            }else{
                $autoDocument  = $true
            }
        }

        write-verbose 'Configuring config file'
        $configPath = "$modulePath\$configFile"
        $throwExceptions = @{}
        
        $errCat = [System.Management.Automation.ErrorCategory]::InvalidData
        $errMsg = [System.Exception]::new("configfile found.`nUse update-btFileStructure to ensure folder structure is compliant with btVersion.")
        $throwExceptions.existingConfigErr = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$configPath)
        $errCat = [System.Management.Automation.ErrorCategory]::InvalidData
        $errMsg = [System.Exception]::new("Unable to validate path for $modulePath")
        $throwExceptions.invalidPathErr = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$configPath)
    }
    
    process{
        write-debug 'starting process'
        write-verbose 'Validating path'
        if(!$(test-path $modulePath))
        {
            throw $throwExceptions.invalidPathErr
        }

        if(test-path $configPath)
        {
            throw $throwExceptions.existingConfigErr
        }

        #Create the gitIgnore and the tokenFile
        #"publishtoken.txt" | Out-File "$modulePath\.gitignore" -Force -Encoding utf8

        write-verbose 'Checking repository viability'
        if($repository)
        {
            foreach($repo in $repository)
            {
                try{
                    $rep = get-psrepository $repository -ErrorAction Stop
                    $rep|out-null
                }catch{
                    write-error "Repository $($repo) is not currently configured.`nPlease configure your publish repository first or specify a different one"
                    return
                }
            }
        }

        write-verbose 'Testing the required modules'
        if($requiredModules)
        {
            foreach($reqModule in $requiredModules)
            {
                $reqModuleType = $reqModule.getType().name
                
                if($reqModuleType -eq 'String')
                {
                    write-verbose "Checking Required module: $reqModule is available on this machine"
                    try{
                        $reqModFound = get-btInstalledModule -moduleName $reqModule -errorAction 'Stop'
                        write-verbose "Module $reqModule was Found"
                    }catch{
                        $error[0]
                        throw 'Unable to complete new-btProject due to required module error (See Above)'
                    }

                }elseIf($reqModuleType -eq 'Hashtable')
                {
                    if($($reqModule.keys) -contains 'moduleName' -and $($reqModule.keys) -contains 'moduleVersion' -and $($reqModule.keys.count) -eq 2)
                    {
                        write-verbose "Hashtable well formed for $($reqModule.ModuleName) required module"
                        try{
                            $reqModFound = get-btInstalledModule @reqModule -errorAction 'Stop'
                            write-verbose "Module $($reqModule.ModuleName) was Found with version $($reqModule.ModuleVersion)"
                        }catch{
                            $error[0]
                            throw 'Unable to complete new-btProject due to required module error (See Above)'
                        }
                    }else{
                        throw "Hashtable poorly formed. Required Module Hashtables should contain 2 keys only, moduleName and moduleVersion"
                    }

                }else{
                    throw 'Required Modules should be a string or a Hashtable'
                }
            }
        }

        #Create the folder structure for support items
        write-verbose '***CREATE THE FILES AND FOLDERS***'
        add-btFilesAndFolders -path $modulePath -force
        #>
        #Create the config file
        write-verbose 'Creating Config File'
        $config = [pscustomobject] @{
            moduleAuthor = $moduleAuthor
            moduleName = $moduleName
            moduleDescription = $moduleDescription
            companyName = $companyName
            version = [version]::new($majorVersion,$minorVersion,$buildVersion,0)
            guid = $(new-guid).guid
            AutoIncrementRevision = $AutoIncrementRevision
            RemoveSingleLineQuotes = $RemoveSingleLineQuotes
            RemoveEmptyLines = $RemoveEmptyLines
            minimumPsVersion = $minimumPsVersion
            RequiredModules = [array]$RequiredModules
            Tags = $Tags
            Repository = $repository
            trimSpaces = $trimSpaces
            publishOnBuild = $publishOnBuild
            runPesterTests = $runPesterTests
            bartenderVersion = $($(get-module -name Bartender).version.tostring())
            autoDocument = $autoDocument
        }
        Write-Debug "Your Config Object:`n`n$($config|Out-String)"
        if(!$config.version -or !$config.moduleName -or !$config.moduleAuthor -or !$config.companyName)
        {
            Write-Error 'Invalid Config'
            return
        }else{
            Write-Verbose 'Exporting Config'
            Export-Clixml -Path $configPath -InputObject $config
        }     
    }
}