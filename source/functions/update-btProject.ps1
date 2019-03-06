function update-btProject
{

    <#
        .SYNOPSIS
            Provide a way to update an existing module
            
        .DESCRIPTION
            Will build out the folder structure for a new bt project
            and make a btConfig.xml file with all the settings set in the parameters
            
        .PARAMETER moduleName
            If you want to update the name of your module
            Will not reset the versioning

        .PARAMETER moduleDescription
            Update the description of your module
        
        .PARAMETER moduleAuthor
            Will append to the authors list

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
            Change the default repository(s) to publish to

        .PARAMETER RequiredModules
            Array of modules you want to include as mandatory when building the manifest

            If a string is supplied, then the version will be whatever latest version is installed

            If a hashtable is supplied it should be constructed as such:
            @{moduleName='myModule';moduleVersion='1.2.3'}
            

        .PARAMETER Tags
            
            The tags to apply in the manifest, helping when searching repositories
        
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

                2019-02-25 - AA
                    - Fixed some issues with checking the config file

                2019-03-04 - AA
                    - Fixed this up so that it correctly used existing settings
                        - Would overwrite existing settings with defaults prior
                    - Fixed issue where moduleName and Description were getting dropped
                        - Therefore causing this script to always error
                    - Fix the GUID getting dropped
                    - Fix version rebasing back to 0 by removing it as an update version
                        - Can still be updated manually if needed

                        
                    


                    
        .COMPONENT
            Bartender

        .INPUTS
           null

        .OUTPUTS
           null
    #>

    [CmdletBinding()]
    PARAM(
        [string]$moduleName,
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

        write-verbose 'Loading Existing Settings'
        $existingSettings = import-clixml "$modulePath\$configFile"
        if(!$existingSettings)
        {
            write-warning 'Existing Settings not found'
        }else{
            write-debug 'Existing Settings Loaded'
            write-debug $($existingSettings|Format-List|out-string)
        }

        write-verbose 'Loading user defaults'
        $userDefaults = get-btDefaultSettings
        if(!$userDefaults)
        {
            write-warning 'User defaults Not Found'
            write-warning 'You can save your default module preferences by using the save-btDefaultSettings cmdlet'
        }else{
            write-debug 'User Defaults Loaded'
            write-debug $($userDefaults|format-list|out-string)
        }

        write-verbose 'Ensuring we have a module name or description'
        if(!$moduleName)
        {
            if($existingSettings.moduleName){
                $moduleName = $existingSettings.moduleName
            }else{
                throw 'Modulename not supplied or found'
            }
        }

        write-verbose 'Add in the GUID'
        $guid = $existingSettings.guid
        if(!$guid)
        {
            throw 'Unable to load in the GUID, check your btconfig.xml file because this may cause issues'
        }

        write-verbose 'Add in the current version'
        $version = $existingSettings.version
        if(!$version)
        {
            throw 'Unable to load in the version, check your btconfig.xml file because this may cause issues'
        }

        if(!$moduleDescription)
        {
            if($existingSettings.moduleDescription){
                $moduleDescription = $existingSettings.moduleDescription
            }else{
                throw 'Modulename not supplied or found'
            }
        }

        write-verbose 'Populating Params where missing'
        if(!$moduleAuthor)
        {
            if($existingSettings.moduleAuthor){
                $moduleAuthor = $existingSettings.moduleAuthor
            }
            elseif($userDefaults.author)
            {
                $moduleAuthor = $userDefaults.author
            }else{
                $moduleAuthor = $($env:USERNAME)
            }
        }

        if(!$repository)
        {
            if($existingSettings.repository){
                $repository = $existingSettings.repository
            }elseif($userDefaults.repository)
            {
                $repository = $userDefaults.repository
            }else{
                write-warning 'Repository not configured'
            }
        }

        if(!$companyName)
        {
            if($existingSettings.companyName){
                $companyName = $existingSettings.companyName

            }elseif($userDefaults.company){
                $companyName = $userDefaults.company
            }else{
                write-warning 'companyName not configured'
                $companyName = ' '
            }
        }

        if(!$Tags)
        {
            if($existingSettings.tags)
            {
                $tags = $existingSettings.tags
            }
            elseif($userDefaults.Tags)
            {
                $Tags = $userDefaults.Tags
            }
        }

        if(!$minimumPsVersion)
        {
            if($existingSettings.minimumPsVersion)
            {
                $minimumPsVersion = $existingSettings.minimumPsVersion
            }
            elseif($userDefaults.minimumPsVersion)
            {
                $minimumPsVersion = $userDefaults.minimumPsVersion
            }else{
                $minimumPsVersion = [version]::new(5,0,0,0)
            }
        }

        if($AutoIncrementRevision -eq $null)
        {
            if($existingSettings.AutoIncrementRevision -ne $null)
            {
                $AutoIncrementRevision = $existingSettings.AutoIncrementRevision
            }
            elseif($userDefaults.AutoIncrementRevision -ne $null)
            {
                $AutoIncrementRevision = $userDefaults.AutoIncrementRevision
            }else{
                $AutoIncrementRevision  = $true
            }
        }

        if($RemoveSingleLineQuotes -eq $null)
        {

            if($existingSettings.removeSingleLineQuotes -ne $null)
            {
                $removeSingleLineQuotes = $existingSettings.removeSingleLineQuotes
            }
            elseif($userDefaults.RemoveSingleLineQuotes -ne $null)
            {
                $RemoveSingleLineQuotes = $userDefaults.RemoveSingleLineQuotes
            }else{
                $RemoveSingleLineQuotes  = $true
            }
        }

        if($RemoveEmptyLines -eq $null)
        {
            if($existingSettings.RemoveEmptyLines -ne $null)
            {
                $RemoveEmptyLines = $existingSettings.RemoveEmptyLines
            }
            elseif($userDefaults.RemoveEmptyLines -ne $null)
            {
                $RemoveEmptyLines = $userDefaults.RemoveEmptyLines
            }else{
                $RemoveEmptyLines  = $true
            }
        }

        if($trimSpaces -eq $null)
        {
            if($existingSettings.trimSpaces -ne $null)
            {
                $trimSpaces = $existingSettings.trimSpaces
            }
            elseif($userDefaults.trimSpaces -ne $null)
            {
                $trimSpaces = $userDefaults.trimSpaces
            }else{
                $trimSpaces  = $false
            }
        }

        if($publishOnBuild -eq $null)
        {
            if($existingSettings.publishOnBuild -ne $null)
            {
                $publishOnBuild = $existingSettings.publishOnBuild
            }
            elseif($userDefaults.publishOnBuild -ne $null)
            {
                $publishOnBuild = $userDefaults.publishOnBuild
            }else{
                $publishOnBuild  = $true
            }
        }

        if($runPesterTests -eq $null)
        {
            if($existingSettings.runPesterTests)
            {
                $runPesterTests = $existingSettings.runPesterTests
            }
            elseif($userDefaults.runPesterTests -ne $null)
            {
                $runPesterTests = $userDefaults.runPesterTests
            }else{
                $runPesterTests  = $true
            }
        }

        if($autoDocument -eq $null)
        {
            if($existingSettings.autoDocument -ne $null)
            {
                $autoDocument = $existingSettings.autoDocument
            }
            elseif($userDefaults.autoDocument -ne $null)
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

        if(!$(test-path $configPath))
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

        write-verbose 'Should have finished updating files'

        #Create the config file
        write-verbose 'Creating Config File'
        $config = [pscustomobject] @{
            moduleAuthor = $moduleAuthor
            moduleName = $moduleName
            moduleDescription = $moduleDescription
            companyName = $companyName
            version = $version
            guid = $guid
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