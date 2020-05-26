<#
Module Mixed by BarTender
	A Framework for making PowerShell Modules
	Version: 6.1.22
	Author: Adrian.Andersson
	Copyright: 2019 Domain Group

Module Details:
	Module: bartender
	Description: A Framework for making PowerShell Modules
	Revision: 6.1.22.8
	Author: Adrian.Andersson
	Company: Domain Group

Check Manifest for more details
#>

function get-btScriptText
{
    <#
        .SYNOPSIS
            Get the text from file
            
        .DESCRIPTION
            Get the text from file
            Can do some clean-up for you based on parameters used
            
        .PARAMETER psfile
            Mandatory
            Accepts array
            Full filepath(s) to the script file to get the text from.
        
        
        .PARAMETER isFunction
           Tell the script to capture the function names as function-resources
           For building manifest
        
        .PARAMETER isDSCClass
           Tell the script to capture the class names as dsc-resources
           For building manifest
        .PARAMETER removeQuotes
           Remove single line quotes like this #quote quote quote
        .PARAMETER trimSpaces
            Get rid of horizontal space, trimming excess spaces around text and removing any spacing
        .PARAMETER RemoveEmptyLines
           Get rid of most empty lines
            
        .EXAMPLE
            $items = get-btScriptItems .\source\functions\
            $text = get-btScriptText $items.fileList.fullname -isFunction $true
            
            #### DESCRIPTION
            Use the filelist provided by get-btScriptItems
            Grab the contents of all the ps1 files
            Ensure that we capture the function names for our Manifest use later
            
            
            #### OUTPUT
               TypeName: System.Management.Automation.PSCustomObject
                Name              MemberType   Definition
                ----              ----------   ----------
                dscResources      NoteProperty Object[] dscResources=System.Object[]
                functionResources NoteProperty Object[] functionResources=System.Object[]
                output            NoteProperty string output=...
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-05-17
            
            
           Changelog:
                
                    
                2018-04-19 - AA
                    
                    - Initial Script
                    - Added primary functionality
                
                2018-04-24 - AA
                    
                    - Made it return object rather than just text-block
                2018-04-26 - AA
                    
                    - Fixed the help
                    - Fixed the way it grabbed file contents
                    - Improved the capture of functions and dsc modules
                2018-05-17 - AA
                    
                    - Updated help
                    
                    
        .COMPONENT
            Bartender
        .INPUTS
           null
        .OUTPUTS
            custom object
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [string[]]$psfile,
        [bool]$isFunction = $false,
        [bool]$isDSCClass = $false,
        [bool]$removeQuotes = $true,
        [bool]$trimSpaces = $false,
        [bool]$RemoveEmptyLines = $true
        
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $$(MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $$($MyInvocation.BoundParameters|Out-String)"
        $outputObj = [pscustomobject]@{
            output = ""
            functionResources = @()
            dscResources = @()
        }
    }
    
    process{
        foreach($file in $psfile)
        {
            $content = get-content $file
            $lineNo = 1
            $content = foreach($line in $content)
            {
                if($isFunction -eq $true)
                {
                    if($line -like 'function *')
                    {
                        Write-Verbose "FOUND FUNCTION: $($file)`n`tLine:$lineNo"
                        $functionName = $($line -split 'function ')[1]
                        if($functionname -like '*{*')
                        {
                            $functionName = $($functionName -split '{')[0]
                        }
                        $functionName = $functionName.trim()
                        $outputObj.functionResources += $functionName
                        Write-Verbose "Adding $functionName to function resources"
                        remove-variable functionName -ErrorAction SilentlyContinue
                    }
                }
                if($isDSCClass -eq $true)
                {
                    if($line -like 'class *')
                    {
                        Write-Verbose "FOUND CLASS: $($file)`n`tLine:$lineNo"
                        $dscClassName = $($line -split 'class ')[1]
                        write-verbose $dscClassName
                        if($dscClassName -like '*{*')
                        {
                            $dscClassName = $($dscClassName -split '{')[0]
                        }
                        $dscClassName = $dscClassName.trim()
                        $outputObj.dscResources += $dscClassName
                        Write-Verbose "Adding $dscClassName to dscResources resources"
                        remove-variable functionName -ErrorAction SilentlyContinue
                    }
                }
                if($removeQuotes -eq $true)
                {
                    
                    if($line -like '*#*' -and (($line -notlike '*<#*') -and ($line -notlike '*#>*')))
                    {
                        Write-Verbose 'Scrubbing quotes'
                        $line = $($line -split '#')[0]
                    }
                }
                if($trimSpaces -eq $true)
                {
                    $line = $line.trim()
                }
                if($RemoveEmptyLines -eq $true)
                {
                    if($line.length -gt 0)
                    {
                        $line
                    }
                }else{
                    $line
                }
                $lineNo++
            }
            if($RemoveEmptyLines -eq $true)
            {
                $content = $content | where-object {$_ -ne "^\s+" -and $_ -ne ''}
            }
            $outputObj.output += "`n$($content|out-string)"
        }
        $outputObj
        
    }
   
    
}

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

function get-btChangeDetails
{
    <#
        .SYNOPSIS
            Try and work out what function files changed, were created etc, from the last release
            
        .DESCRIPTION
            Gets the lastModified date of the previous release module manifest
            Check the source function folders with get-btFolderItems
            See what functions live in there
            See if the lastModified is after the previous release
            Note that the functions were potentially changed
            
        .PARAMETER modulePath
            Path to module
        .PARAMETER functionFolders
            What source folders do functions live in
        .PARAMETER configFile
            btconfig.xml
        .PARAMETER newRelease
            If this is set to true, will calculate the differences between previousrelease and lastrelease
            as configered in the config file
            By default, it will calculate the differences between the lastRelease and the last revision instead
        ------------
        .EXAMPLE
            get-btChangeDetails
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-06
            
            
            Changelog:
                2019-03-06 - AA
                    
                    - Initial Script
                2019-03-11 - AA
                    - Changed to read the lastrelease and previousrelease from the config module
                    - Broke the summary into smaller portions was getting a bit hectic
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    PARAM(
        [string]$modulePath = $(get-location).path,
        [string[]]$functionFolders = @('functions','private'),
        [string]$configFile = 'btConfig.xml',
        [switch]$newRelease
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
        $sourcePath = get-item "$modulePath\source" -ErrorAction Ignore
        
    }
    
    process{
        write-verbose 'Getting config settings'
        $configSettings = import-clixml "$modulePath\$configFile"
        if(!$configSettings)
        {
            throw 'Unable to find config file'
        }
        write-verbose 'Validating Module path'
        if(!$(test-path $modulePath) -or !$(test-path $sourcePath))
        {
            throw 'modulePath invalid'
        }
        if($newRelease)
        {
            write-verbose 'Comparing last Release to previous release'
            if($configSettings.lastrelease.version -and $configSettings.lastRelease.date)
            {
                $currentRelease = $configSettings.lastrelease.version.toString(3)
                $currentReleaseDate = $configSettilgs.lastRelease.date
                $currentReleaseModulePath = $(get-item "$modulePath\$($configSettings.moduleName)\$currentRelease\$($configSettings.moduleName).psm1"-ErrorAction ignore).FullName
                
            }else{
                write-warning 'lastrelease not found, exiting'
                return
            }
            if($configSettings.previousrelease.version -and $configSettings.previousrelease.date)
            {
                write-verbose 'Using previous release as comparison'
                $previousRelease = $configSettings.previousrelease.version.toString(3)
                $previousReleaseDate = $configSettings.previousrelease.date
                $previousReleaseModulePath = $(get-item "$modulePath\$($configSettings.moduleName)\$previousRelease\$($configSettings.moduleName).psm1" -ErrorAction ignore).FullName
            }else{
                write-warning 'Previous Release not found, using empty version and old date'
                $previousRelease = [version]'0.0.0'
                $previousReleaseDate = $null
                $previousReleaseModulePath = $null
            }
             
        }else{
            write-verbose 'comparing last revision to last release'
            $currentRelease = $(get-childitem "$modulePath\rev" |where-object{$_.PsIsContainer -eq $true}|sort-object -Property lastWriteTime -Descending|select-object -first 1).basename
            $currentReleaseDate = $(get-date)
            $currentReleaseModulePath = $(get-item "$modulePath\rev\$currentRelease\$($configSettings.moduleName).psm1"-ErrorAction ignore).FullName
            if($configSettings.lastrelease.version -and $configSettings.lastRelease.date)
            {
                write-verbose 'Using lastRelease as comparison'
                $previousRelease = $configSettings.lastrelease.version.toString(3)
                $previousReleaseDate = $configSettings.lastRelease.date
                $previousReleaseModulePath = $(get-item "$modulePath\$($configSettings.moduleName)\$previousRelease\$($configSettings.moduleName).psm1" -ErrorAction ignore).FullName
            }else{
                write-warning 'Previous Release not found, using empty version and old date'
                $previousRelease = [version]'0.0.0'
                $previousReleaseDate = $null
                $previousReleaseModulePath = $null
            }
        }
        
        
        $functions = foreach($folder in $functionFolders)
        {
            write-verbose "Checking folder: $folder"
            $folderPath = "$sourcePath\$folder"
            write-verbose "FullPath: $folderPath"
            if(!(test-path $folderPath))
            {
                throw "function path for $folder folder invalid"
            }
            $folderScripts = get-btFolderItems -path $folderPath
            if($newRelease)
            {
                write-verbose 'Working out markdown path'
                $markdownPath = $(get-item "$modulePath\documentation\$currentRelease\functions" -ErrorAction Ignore).FullName
            }else{
                $markdownPath -eq $null
            }
            
            #Get the markdowns
            if($currentRelease)
            {
                if($markdownPath)
                {
                    $markdownItems = get-childitem $markdownPath -Filter *.md
                }else{
                    write-warning 'Markdown items not found'
                    $markdownItems = $null
                }
            }
            write-verbose "PreviousReleaseDate: $previousReleaseDate"
            foreach($file in $folderScripts)
            {
                write-verbose "Checking file: $($file.path)"
                $fileFunctions = get-btScriptFunctions -path $($file.path)
                write-verbose "Checking Functions Functions"
                foreach($function in $fileFunctions)
                {
                    $fileItem = get-item $($file.path)
                    $fileIsNew = if(($fileItem.CreationTime -gt $previousReleaseDate) -and ($fileItem.LastWriteTime -gt $previousReleaseDate)){$true}else{$false}
                    $fileIsModified = if(($fileItem.LastWriteTime -gt $previousReleaseDate) -and ($fileIsNew -eq $false)){$true}else{$false}
                    $markdownList = $($markdownItems|where-object{$_.length -gt 400}).basename
                    $hasMarkdown = if($function -in $markdownList)
                    {
                        $true
                    }else{
                        $false
                    }
                    [psCustomObject] @{
                        fileLastModified = $fileItem.LastWriteTime
                        fileCreated = $fileItem.CreationTime
                        filename = $fileItem.Name
                        filePath = ".\source\$folder$($file.relativePath.replace('.\','\'))"
                        relativePath = $file.relativePath
                        fileIsNew = $fileIsNew
                        fileIsModified = $fileIsModified
                        function = $function
                        folder = $folder
                        hasmarkdown = $hasMarkdown
                    }
                }
            }
        }
        $fileSelector = @(
            'name',
            'extension',
            'basename',
            'lastwritetime',
            'creationtime',
            @{
                name = 'relativepath'
                expression = {$($_.fullname).replace("$sourcePath",'.')}
            },
            @{
                name = 'fileIsNew'
                expression = {$_.CreationTime -gt $previousReleaseDate -and $_.lastWritetime -gt $previousReleaseDate}
            },
            @{
                name = 'fileIsModified'
                expression = {$_.lastWriteTime -gt $previousReleaseDate -and $_.creationTime -lt $previousReleaseDate}
            },
            @{
                name = 'sourceDirectory'
                expression = {$($_.directory.fullname).replace("$sourcePath\",'').split('\')[0]}
            },
            'length'
        )
        
        $files = get-childitem -path $sourcePath -file -Recurse -Exclude @('.btorderend','.btorderstart','.btignore','.gitignore')|select-object $fileSelector -unique
        if($currentReleaseModulePath -and $previousReleaseModulePath)
        {
            write-verbose 'Check if the module files are similar'
            $fileCompare = $(get-btStringComparison -string1 $(get-content $currentReleaseModulePath|out-string) -string2 $(get-content $previousReleaseModulePath|out-string)).DiffPercent
        }else{
            $fileCompare = 'na'
        }
        
        write-verbose 'Getting Summary Details'
        $publicFunctions = $($functions|where-object{$_.folder -ne 'private'})
        $publicFunctionsCount = $($publicFunctions |measure-object).count
        $publicFunctionsWithMarkdown = $($publicFunctions|where-object{$_.hasMarkdown -eq $true}|measure-object ).count
        if($publicFunctionsCount -ge 1)
        {
            $commentBasedHelpCoverage = [math]::round($($publicFunctionsWithMarkdown/$publicFunctionsCount)*100,0)
        }else{
            $commentBasedHelpCoverage = 0
        }
     
        $summary = [ordered]@{
            commentBasedHelpCoverage = $commentBasedHelpCoverage
            version = $currentRelease
            comparisonVersion = $previousRelease
            estimatedChangePercent = "$fileCompare %"
        }
        $fileSummary = @{
            totalFiles = $($files|measure-object).Count
            newFiles = $($files|where-object{$_.fileIsNew -eq $true}|measure-object).Count
            modifiedFiles = $($files|where-object{$_.fileIsModified -eq $true}|measure-object).Count
            totalFileSize = "$([math]::Round($($($files|measure-object -Property length -Sum).sum),2) / 1kb) kb"
        }
        $functionSummary = @{
            totalFunctions = $($functions|measure-object).Count
            newFunctions = $($functions|where-object{$_.fileIsNew -eq $true}|measure-object).Count
            modifiedFunctions = $($functions|where-object{$_.fileIsModified -eq $true}|measure-object).Count
            privateFunctions = $($functions|where-object{$_.folder -eq 'private'}|measure-object).Count
            publicFunctions = $publicFunctionsCount
        }
        [pscustomObject]@{
            summary = $summary
            files = $files
            functions = $functions
            functionSummary = $functionSummary
            fileSummary = $fileSummary
        }
    }
}

function get-btDefaultSettings
{
    <#
        .SYNOPSIS
            Retrieve the current users default BT Settings
            
        .DESCRIPTION
            Retrieve the current users default BT Settings
            
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
            $btDefaultsPath = "$btSaveFolder\btDefaults_$($env:computername).xml"
            if(!$(test-path $btSaveFolder))
            {
                write-verbose 'bt path not found, no settings saved'
            }else{
                write-verbose 'bt path exists'
            }
        }else{
            throw 'Local Profile unavailable'
        }
        
        
        write-verbose 'Importing existing default settings'
        if(test-path $btDefaultsPath)
        {
            try{
                
                $btDefaultSettings = import-clixml $btDefaultsPath -errorAction stop
                write-verbose 'Existing saved defaults imported'
                return $btDefaultSettings
            }catch{
                write-error $error[0]
                throw 'Unable to import defaults settings'
            }
        }else{
            write-verbose 'Previous settings not found'
        }
    }
    
}

function get-btFolderItems
{
    <#
        .SYNOPSIS
            Get a list of files from a folder - whilst processing the .btignore and .btorder files
            
        .DESCRIPTION
            Get the files out of a folder. Adds a bit of smarts to it such as:
             - Ignore anything in the .btignore file
             - Order files in the .btorderStart folder first
             - Order any files in the .btOrderEnd folder
             - Randomly add any files that are not in either in between
             - Filter out anything that isn't a PS1 file by default if required
             - Copy the items to a new location
            
            Notes:
              A filename can be in both .btOrderStart and .btOrderEnd
              This can be useful if you would like to process a file twice, once at the start of a workflow and once at the end
              Will always return a full path name
            
        .PARAMETER path
            The path of your bartender module
            Defaults to current working directory
        
        .PARAMETER psScriptsOnly
            Filter out any file that is not a ps1 file
        .PARAMETER copy
            If specified, will copy any found files to the location specified in Destination
        
        .PARAMETER Destination
            If specified with the copy switch, will copy any found files to this location
        
        
            
        .EXAMPLE
            get-btFolderItems -path .\source\functions
            
            ##### DESCRIPTION
            Get all files in the path .\source\functions, that are not in the .btIgnorefile, order by .btOrderStart and .btOrderEnd respectively
        .EXAMPLE
            get-btFolderItems -path .\source\functions -psScriptsOnly
            
            ##### DESCRIPTION
            Get PS1 files in the path .\source\functions, that are not in the .btIgnorefile order by .btOrderStart and .btOrderEnd respectively
        .EXAMPLE
            get-btFolderItems -path .\source\functions -psScriptsOnly -copy -destination 'c:\temp\functions'
            
            ##### DESCRIPTION
            Get PS1 files in the path .\source\functions, that are not in the .btIgnorefile order by .btOrderStart and .btOrderEnd respectively
            Copy them (inclusive of directory structure) to 'c:\temp\functions'
        
        .OUTPUTS
          Should return an object with a list of files in their ordered version.
          By default will have values of:
           - Path : Full path to file
           - relativePath : dot Source notatio for file
          If Copy is used, it will also have values for:
           - NewPath : The full path to where it was copied
           - NewFolder : New folder path
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-05-17
            
            
            Changelog:
                2018-04-19 - AA
                    
                    - Initial Script
                    - Added primary functionality
                 2018-04-24- AA
                    
                    - Added .btOrder file
                    - Added ability to copy files
                 2018-05-16 - AA
                    
                    - Added inline help
                    - Included in pester tests
                2018-05-17 - AA
                    
                    - Improved inline help
                    - Added ability to process .btorderEnd and .btOrderStart
                    - Removed .btOrder processing
                    - Fixed a bug with empty lines in the .btOrder* files
                2019-03-11 - AA
                    - Changed a warning to a write-verbose
                    
                    
        .COMPONENT
            Bartender
        .INPUTS
           null
        .OUTPUTS
            custom object
        
    #>
    [CmdletBinding(DefaultParameterSetName='Default')]
    PARAM(
        [Parameter(ParameterSetName='Default',Mandatory=$true,Position=1)]
        [Parameter(ParameterSetName='SetDestination',Mandatory=$true,Position=1)]
        [string]$Path,
        [Parameter(ParameterSetName='Default',Position=2)]
        [Parameter(ParameterSetName='SetDestination',Position=2)]
        [switch]$psScriptsOnly,
        [Parameter(Mandatory=$false)]
        [Parameter(ParameterSetName='Default',Position=3)]
        [Parameter(ParameterSetName='SetDestination',Mandatory=$true,Position=3)]
        [string]$Destination,
        [Parameter(ParameterSetName='SetDestination',DontShow=$true,Position=6)]
        [switch]$SetDestination = $(if($destination){$true}else{$false}),
        [Parameter(ParameterSetName='SetDestination',Position=4)]
        [switch]$copy
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        if($path[-1] -eq '\')
        {
            write-verbose 'Removing extra \ from path'
            $path = $path.Substring(0,$($path.length-1))
            write-verbose "New Path $path"
        }
        if($Destination[-1] -eq '\')
        {
            write-verbose 'Removing extra \ from path'
            $Destination = $Destination.Substring(0,$($Destination.length-1))
            write-verbose "New destination: $destination"
        }
    }
    
    process{
        try{
            $folder = get-item $path -erroraction stop
        }catch{
            Write-Error 'Unable to retrieve folder'
            return
        }
        if($Destination)
        {
            try{
                $destinationFolder = get-item $Destination -erroraction stop
                $destinationFolder = $destinationFolder.FullName
            }catch{
                Write-verbose 'Unable to verify destination folder - using assigned variable as path '
                $destinationFolder = $Destination
            }
            
            Write-Verbose "Destination set to $destination"
        }
            
        $folderPath = $folder.FullName
        $exclude = @('.btignore','.btorderStart','.btorderEnd','.gitignore')
        if(test-path "$folderPath\.btignore")
        {
            write-verbose 'Adding the exclude content'
            $exclude += get-content "$folderPath\.btignore"|where-object {$_.length -gt 1}
            
        }else{
            if($psScriptsOnly)
            {
                write-warning 'NO .btignore found. All PS1 scripts will be included'
            }else{
                write-warning 'NO .btignore found. All files will be included'
            }
            
        }
        write-verbose "Exclude:`n`n $($($exclude|format-list|Out-String))"
    
        Write-Verbose 'Getting all files'
        if($psScriptsOnly)
        {
            $filelist = get-childitem -Path $folderPath -Recurse -Filter *.ps1|Where-Object{$_.PSIsContainer -eq $false }
        }else{
            $filelist = get-childitem -Path $folderPath -Recurse|Where-Object{$_.PSIsContainer -eq $false}
        }
        write-verbose "Checking: $($($filelist|measure-object).Count) files"
        #Crack this today. Fix the destination, give it a new folder path
        
        write-verbose "FolderFullname`n$("$($folder.FullName)\")"
        foreach($file in $fileList)
        {
            if($SetDestination)
            {
                $file|Add-Member -Name 'newPath' -MemberType NoteProperty -Value $($file.fullname.ToString()).replace($folder.FullName,$destinationFolder)
                $file|Add-Member -name 'newFolder' -memberType NoteProperty -value $($file.directory.ToString()).replace($folder.FullName,$destinationFolder)
            } 
            $file|Add-Member -Name 'relativePath' -MemberType NoteProperty -Value $($file.fullname.ToString()).replace("$($folder.FullName)\",'.\')
        }
        Write-Verbose 'Checking File Order'
        $orderedList = [ordered]@{}
        $i=0
        if(test-path "$folderPath\.btorderStart")
        {
            $order = get-content "$folderPath\.btorderStart"|where-object {$_.length -gt 1}
            
            foreach($file in $order)
            {
                $listItem = $fileList |Where-Object {($_.name -eq $file -or $_.BaseName -eq $file -or $_.relativePath -eq $file)-and($_.name -notin $exclude -and $_.BaseName -notin $exclude -and $_.relativePath -notin $exclude)}|select-object -first 1
                if($listItem)
                {
                    $orderedList."$i" = $listItem
                    $i++
                }
            }
        }else{
            write-warning 'NO .btorderStart found. Start Order will be random'
        }
        if(test-path "$folderpath\.btOrderEnd")
        {
            $orderEnd = get-content "$folderPath\.btOrderEnd"|where-object {$_.length -gt 1}
        }else{
            write-warning 'NO .btorderEnd found. End Order will be random'
        }
        Write-Verbose 'Excluding any items and adding to list'
        foreach($listItem in $($fileList|where-object {($_.name -notin $order -and $_.BaseName -notin $order -and $_.relativePath -notin $order)-and($_.name -notin $orderEnd -and $_.BaseName -notin $orderEnd -and $_.relativePath -notin $orderEnd)-and($_.name -notin $exclude -and $_.BaseName -notin $exclude -and $_.relativePath -notin $exclude)}|sort-object))
        {
            $orderedList."$i" = $listItem
            $i++
        }
        foreach($file in $orderEnd)
        {
            $listItem = $fileList |Where-Object {($_.name -eq $file -or $_.BaseName -eq $file -or $_.relativePath -eq $file)-and($_.name -notin $exclude -and $_.BaseName -notin $exclude -and $_.relativePath -notin $exclude)}|select-object -first 1
            if($listItem)
            {
                $orderedList."$i" = $listItem
                $i++
            }
        }
        $fileListValues = if($SetDestination)
        {
            $orderedList.Values|Select-Object @{Name = 'Path'; Expression = {$_.FullName} },relativePath,newPath,newFolder
        }else{
            $orderedList.Values|Select-Object @{Name = 'Path'; Expression = {$_.FullName} },relativePath
        }
        if($copy)
        {
            Write-Verbose 'Copying new files'
            foreach($file in $fileListValues)
            {
                write-verbose "Checking file $($file.relativepath)"
                write-verbose "Destination Folder: $($file.newFolder)"
                if(!(test-path $file.newFolder))
                {
                    write-verbose 'Destination folder does not exist'
                    try{
                        new-item -ItemType Directory -Path $file.newFolder -Force |Out-Null
                        write-verbose "Made new directory at: `n`t$($file.newFolder)"
                    }catch{
                        write-error "Unable to make directory at: `n`t$($file.newFolder)"
                        return
                    }
                }
                copy-item -Path $file.Path -Destination $file.newPath -Force|Out-Null
            }
            Write-Verbose 'Copy Complete'
        }
        return $fileListValues
        
        
    }
}

function get-btGitDetails
{
    <#
        .SYNOPSIS
            Simple description
            
        .DESCRIPTION
            Detailed Description
            
        .PARAMETER modulePath
            Where does the module live?
            
        ------------
        .EXAMPLE
            verb-noun param1
            
            #### DESCRIPTION
            Line by line of what this example will do
            
            
            #### OUTPUT
            Copy of the output of this line
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-06-03
            
            
            Changelog:
                2019-03-06 - AA
                    
                    - Initial Script
                
                2019-03-07 - AA
                    - Fixed the git commands to run as a job
                    - Trim the returned data
                    
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

function get-btInstalledModule
{
    <#
        .SYNOPSIS
            Get the name and version of an already installed module
            
        .DESCRIPTION
            Get the name and version of an already installed module
            If moduleVersion is specified, ensures its installed
            Otherwise, return the latest version of the module
            Return as a moduleSpecification object
            
        .PARAMETER moduleName
            Name of the module to find
        .PARAMETER moduleVersion
            If you want to find a specific version of a module
            
        ------------
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-02-01
            
            
            Changelog:
                2019-02-01 - AA
                    
                    - Initial Script
                
                2019-03-04 - AA
                    
                    - Fixed the documentation
                    - Changed the returned object to a modulespecification object
                        - Ensured fed correct hashtable
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$moduleName,
        [version]$moduleVersion
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        #Array of what we want to select
        #Easier to do this when we want custom params
        $modSelect = @(
            'GUID',
            @{
                Name='ModuleName'
                Expression = {$_.Name}
            },
            @{
                Name='ModuleVersion'
                Expression={$_.Version}
            }
        )
        $allVersions = get-module -listAvailable -name $moduleName|select-object $modSelect
        if($($allVersions|measure-object).count -ge 1)
        {
            write-verbose 'Modules found'
            if($ModuleVersion)
            {
                write-verbose 'Checking for specific version'
                $found = $allVersions|Where-Object{$_.ModuleVersion -eq $moduleVersion}|Select-Object -first 1
                if($found)
                {
                    write-verbose 'Found specific Version'
                    $selectedMod =  $found
                }else{
                    Throw "Module $moduleName was found on this machine but the version: $moduleVersion is not present"
                }
            }else{
                write-verbose 'Getting Latest Version'
                $selectedMod = $allVersions|Sort-Object ModuleVersion -Descending|Select-Object -first 1
            }
        }else{
            throw "No Modules found with the name $moduleName. Please install them first"
        }
        if($selectedMod)
        {
            Write-Debug "$($selectedMod|format-list|out-string)"
            $hashtable = @{
                guid = $selectedMod.guid
                modulename = $selectedMod.moduleName
                requiredversion = $selectedMod.moduleVersion
                #moduleVersion = $selectedMod.moduleVersion # Use moduleVersion or RequiredVersion, but not both
            }
            [Microsoft.PowerShell.Commands.ModuleSpecification]::new($hashtable)
        }
        
    }
    
}

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
        .PARAMETER useGitDetails
            Try and get the license, project URIs from GIT
        .PARAMETER licenseUri
            Override the licenseUri
        .PARAMETER iconUri
            Override the iconUri
        .PARAMETER projectUri
            Override the projectUri
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
                2019-03-06 - AA
                    
                    - Updated to allow useGitDetails
                    - Updated to store licenseUri,projectUri,inconUri
                    
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
        [Nullable[boolean]]$useGitDetails,
        [array]$RequiredModules,
        [string[]]$Tags,
        [int]$majorVersion = 1,
        [int]$minorVersion = 0,
        [int]$buildVersion = 0,
        [string]$modulePath = $(get-location).path,
        [string]$configFile = 'btConfig.xml',
        [string]$licenseUri,
        [string]$projectUri,
        [string]$iconUri
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
        if($useGitDetails -eq $null)
        {
            if($userDefaults.useGitDetails -ne $null)
            {
                $useGitDetails = $userDefaults.useGitDetails
            }else{
                $useGitDetails  = $true
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
            useGitDetails = $useGitDetails
            licenseUri = $licenseUri
            projectUri = $projectUri
            iconUri = $iconUri
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

function save-btDefaultSettings
{
    <#
        .SYNOPSIS
            Save API token and, if supplied, Repository Credentials
            
        .DESCRIPTION
            Save API token and credentials, in order to provide the ability to publish/find modules without 
            having to enter this stuff all the time
        
        .PARAMETER author
            Default Module Author
        .PARAMETER repository
            Default repositories to publish to
        .PARAMETER company
            Default Company to publish as
        .PARAMETER Tags
            Default Tags to use
        .PARAMETER minimumPsVersion
            The default minimumPsVersion to use
        .PARAMETER AutoIncrementRevision
            The default AutoIncrementRevision value
        .PARAMETER RemoveSingleLineQuotes
            Default RemoveSingleLineQuotes value
        .PARAMETER RemoveEmptyLines
            Default RemoveEmptylines Value
        
        
        .PARAMETER trimSpaces
            Default trimSpaces value
        
        .PARAMETER publishOnBuild
            Default publishOnBuild value
        .PARAMETER autoDocument
            Default autoDocument Value
        .PARAMETER useGitDetails
            Grab the license and project URI from Git details
            Use them on manifest creation
        .PARAMETER update
            Use to overwrite any existing saved default settings
        .EXAMPLE
            save-btDefaultSettings -author my.name -repositories @('myrepo1','psgallery')
            
            #### DESCRIPTION
            Will save the repository myRepo with the token, and prompt once for credentials.
            
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
                2019-03-07 - AA
                    
                    - Added way to save useGitDetails
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    PARAM(
        [string]$author,
        [string]$repository,
        [string]$company,
        [string[]]$Tags,
        [version]$minimumPsVersion,
        [Nullable[boolean]]$AutoIncrementRevision,
        [Nullable[boolean]]$RemoveSingleLineQuotes,
        [Nullable[boolean]]$RemoveEmptyLines,
        [Nullable[boolean]]$trimSpaces,
        [Nullable[boolean]]$publishOnBuild,
        [Nullable[boolean]]$autoDocument,
        [Nullable[boolean]]$runPesterTests,
        [Nullable[boolean]]$useGitDetails,
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
            $btDefaultsPath = "$btSaveFolder\btDefaults_$($env:computername).xml"
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
        
        
        write-verbose 'Importing existing default settings'
        if(test-path $btDefaultsPath)
        {
            try{
                
                $btDefaultSettings = import-clixml $btDefaultsPath -errorAction stop
                write-verbose 'Existing saved default imported'
            }catch{
                write-error $error[0]
                throw 'Unable to import defaults settings'
            }
        }else{
            write-verbose 'Previous settings not found, creating'
            $btDefaultSettings = @{}
        }
        write-verbose 'Checking we do not already have settings'
        write-verbose "$($btDefaultSettings.keys.count)"
        if(($btDefaultSettings.keys.count -ge 1) -and ($update -ne $true))
        {
            throw 'Default settings already exist. To overwrite use the -update switch'
        }
        if($author)
        {
            write-verbose "Setting default author as $author"
            $btDefaultSettings.author = $author
        }
        if($repository)
        {
            write-verbose 'Setting default repository'
            $btDefaultSettings.repository = $repository
        }
        if($company)
        {
            write-verbose 'Setting default company'
            $btDefaultSettings.company = $company
        }
        if($Tags)
        {
            write-verbose 'Setting default Tags'
            $btDefaultSettings.Tags = $tags
        }
        if($minimumPsVersion)
        {
            write-verbose 'Setting default minimumPsVersion'
            $btDefaultSettings.minimumPsVersion = $minimumPsVersion
        }
        if($AutoIncrementRevision -ne $null)
        {
            write-verbose 'Setting default AutoIncrementRevision'
            $btDefaultSettings.AutoIncrementRevision = $AutoIncrementRevision
        }
        if($RemoveSingleLineQuotes -ne $null)
        {
            write-verbose 'Setting default RemoveSingleLineQuotes'
            $btDefaultSettings.RemoveSingleLineQuotes = $RemoveSingleLineQuotes
        }
        if($RemoveEmptyLines -ne $null)
        {
            write-verbose 'Setting default RemoveEmptyLines'
            $btDefaultSettings.RemoveEmptyLines = $RemoveEmptyLines
        }
        if($trimSpaces -ne $null)
        {
            write-verbose 'Setting default trimSpaces'
            $btDefaultSettings.trimSpaces = $trimSpaces
        }
        if($publishOnBuild -ne $null)
        {
            write-verbose 'Setting default publishOnBuild'
            $btDefaultSettings.publishOnBuild = $publishOnBuild
        }
        if($autoDocument -ne $null)
        {
            write-verbose 'Setting default autoDocument'
            $btDefaultSettings.autoDocument = $autoDocument
        }
        if($useGitDetails -ne $null)
        {
            write-verbose 'Setting default autoDocument'
            $btDefaultSettings.useGitDetails = $useGitDetails
        }
        write-debug 'Save the file'
        write-verbose 'Updating saved repositories file'
        $btDefaultSettings|export-clixml $btDefaultsPath -force
    }
    
}

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

function start-btbuild
{
    <#
        .SYNOPSIS
            Increment the version.
            Grab all the scripts.
            Compile into a single module file.
            Create a manifest.
        .DESCRIPTION
            - Increment the version depending on the switch used
            - Grab any scripts, dsc resources etc from the source file
            - Compile into a single module file
            - Create a preload.ps1 file
              - to ensure classes and enums are available
              - Will allow using-module and import-module to function similarly
              - Will allow user-substantiation of classes
            - Kick off start-btTestPhase
            - If enabled, kick off get-btDocumentation
            - If tests pass &
              - If incrementing build,major,minor version and autopublish in config OR
              - If publish is true with switch
                - Push to the repository specified
        .PARAMETER configFile
            Default 'btconfig.xml'
            The config file to use
        .PARAMETER ReleaseNotes
            Any release notes to add to the manifest
        .PARAMETER incrementMajorVersion
            Switch, increments the major version
            Will trigger a publish based on the config file
        .PARAMETER incrementMinorVersion
            Switch, increments the minor version
            Will trigger a publish based on the config file
        .PARAMETER incrementBuildVersion
            Switch, increments the build version
            Will trigger a publish based on the config file
        .PARAMETER test
            Override the config files settings
            One day, might actually trigger a test
        .PARAMETER publish
            Boolean value
            Override the config files settings
            Run the Publish-btmodule on complete
        .PARAMETER ignoreBtVersion
            Run even if there is a difference in bartender versions
        .EXAMPLE
            start-btbuild
        #### DESCRIPTION
            Increment the revision version, good way to ensure everything works
        #### OUTPUT
            New module manifest and module file, or overright the existing build version.
            Test the module
            Create documentation if enabled
        .EXAMPLE
            start-btbuild -verbose -incrementbuildversion
        #### DESCRIPTION
            Increment the build version
            Depending on the btconfig.xml, push to a repository
        #### OUTPUT
            New module manifest and module file, or overright the existing build version.
            Test the module
            Create documentation if enabled
            Publish the module if required
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018/05/17
           Changelog:
                2018-04-19 - AA
                    - Initial Script
                    - Added primary functionality
                    - Based off the combine scripts
                2018-04-23 - AA
                    - Many, Many things fixed
                2018-04-26 - AA
                    - Fixed the help
                    - Changed the add-files to use get-btscripttext
                        - Improved dscresource gathering
                        - Improved function resource gathering
                2018-05-11
                    - Added publish switch
                    - Made the publish switch work
                    - Actually made the publish switch work
                2018-05-16
                    - Really Really I promise made the publish switch work
                    - Added start-btTestPhase
                    - Tested it all out
                2018-05-17
                    - Tested it all out
                    - Added switch for ignoreBtVersion
                    - Added failover if btVersions drifted
                    - Fixed the help
                    - Added get-btDocumentation
                    - Tested it again
                2018-05-18
                    - Moved the get-btDocumentation to inside the publish block
                    - Should mean we don't inadvertantly update documentation prematurely
                    - Tried to make the pester result the only output
                2018-05-22
                    - Attempted to fix the way arrays were added to the manifest
                      - Then reverted it back since it made it worse
                    - Stop adding Preload script to manifest when DSCClasses exist, causes funky stuff to happen
                    - Fixed issue where btversion was always being flagged as incorrect
                2018-05-23
                    - Moved the btVersion check to the right place, it was checking before importing, which is dumb
                    - Moved the preloadFileContents switch to the right if block as well, coz I must have been drunk when I put it in
                2018-08-13
                    - Made the folder pass section a switch from an if
                    - Segmented the preload into seperate files for ENUMS,CLASSES,VALIDATORS
                    - Added the preloads to nested-modules as well
                2018-08-30
                    - Added privateDataFile
                2018-10-08
                    - Removed nested modules for when using DSC, still not the best when dealing with Dsc
                    - Brute force added the enums to the main module when using DSC, its not ideal but I'm out of ideas
                2018-10-30
                    - Added postbuildscripts
                        - Need to check if the path is ok (it is)
                        - Seems the folder does not get created on new-btproject, need to check that
                2019-01-30 - 2019-02-04 - AA
                    - Changed the version output to no longer be the dist folder
                        - Tried to simplify a bit
                        - Still need the project name as the root folder, since the parent folder is used when importing and publishing
                    - Added rev folder
                        - Keep all the non-build versions separate from our build versions
                        - For BT Projects, revisions should be considered separate for builds
                        - Have discovered that Artifactory/Nuget does some _nasty_ things when you build with a revision version
                            - Especially if that revision version is a 0
                    - Force use of platyps and configuration
                        - Made as required modules
                    - Clone Rev to Release
                        - No longer need to run tests 2 times for the same module
                        - Will then use config to update the version in the module manifest
                    - Added Pester details to module manifest
                        Under Private Data/Pester
                    - Changed the publish-btModule call
                        - Now does a forEach so you can have multiple repositories in your config
                2019-03-04
                    - Fixed bugs with update-btproject
                2019-03-06
                    - Changed code-coverage to be an int
                    - Added way to get git details for license, project, icon urls
                    - Added override where these are set in the module config
                2019-03-10
                    - Add a lastRelease hashtable to btconfig on release build complete
                        - Add version and date
                    - Also clone lastRelease to previous Release
                2019-03-12
                    - Fix the icon link when generating from git
                2019-03-14
                    - Move the postBuildScript step to after release
        .COMPONENT
            Bartender
    #>
    [CmdletBinding(DefaultParameterSetName='revisionVersion')]
    param(
        [Parameter(ParameterSetName='minorVersion')]
        [Parameter(ParameterSetName='majorVersion')]
        [Parameter(ParameterSetName='buildVersion')]
        [Parameter(ParameterSetName='revisionVersion')]
        [string]$configFile = 'btconfig.xml',
        [Parameter(ParameterSetName='minorVersion')]
        [Parameter(ParameterSetName='majorVersion')]
        [Parameter(ParameterSetName='buildVersion')]
        [Parameter(ParameterSetName='revisionVersion')]
        [string]$ReleaseNotes,
        [Parameter(ParameterSetName='majorVersion')]
        [Alias("majorver")]
        [switch]$incrementMajorVersion,
        [Parameter(ParameterSetName='minorVersion')]
        [Alias("minorver")]
        [switch]$incrementMinorVersion,
        [Parameter(ParameterSetName='buildVersion')]
        [Alias("buildver")]
        [switch]$incrementBuildVersion,
        [Parameter(ParameterSetName='minorVersion')]
        [Parameter(ParameterSetName='majorVersion')]
        [Parameter(ParameterSetName='buildVersion')]
        [Parameter(ParameterSetName='revisionVersion')]
        [switch]$ignoreBtVersion,
        [Parameter(ParameterSetName='minorVersion')]
        [Parameter(ParameterSetName='majorVersion')]
        [Parameter(ParameterSetName='buildVersion')]
        [nullable[bool]]$publish,
        [Parameter(ParameterSetName='minorVersion')]
        [Parameter(ParameterSetName='majorVersion')]
        [Parameter(ParameterSetName='buildVersion')]
        [Parameter(ParameterSetName='revisionVersion')]
        [string]$privateDataFile = 'privateData.xml',
        [Parameter(ParameterSetName='minorVersion')]
        [Parameter(ParameterSetName='majorVersion')]
        [Parameter(ParameterSetName='buildVersion')]
        [Parameter(ParameterSetName='revisionVersion')]
        [switch]$ignoreTest
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        #Remove last pester result
        remove-variable -Scope global -Name lastPesterResult -Force -ErrorAction ignore
        $invocationPath = (Get-Item -Path ".\").FullName
        #Subfunction
        function add-header{
            [CmdletBinding()]
            param(
                [string]$header,
                [hashtable]$scriptVars
            )
            Write-Verbose "Adding header: $header"
            $divide = '####################################'
            $content = "`n<#$divide`n$header`n$divide#>"
            $content|Out-File  $scriptVars.moduleFile -Append
        }
        #Need to install the module first though
        $btModule = get-module bartender
        if(!$btModule)
        {
            import-module -name bartender
            $btModule = get-module bartender
        }
        write-verbose 'Got BtModule version'
        $metaData = @{
            version = $btmodule.version
            author = $btmodule.author
            copyright = $btmodule.Copyright
            name = $btmodule.Name
            description = $btmodule.Description
        }
        if(test-path "$invocationPath\$($privateDataFile)")
        {
            write-warning 'Importing privateDataFile, if this is a hashtable it will be added to the module manifest'
            $privateDataHash = import-clixml $privateDataFile
            if($privateDataHash.getType().name -eq 'hashtable')
            {
                $metaData.manifestPrivateData = $privateDataHash
            }else{
                write-warning "$privateDataFile does not contain a single hashtable and therefore will be ignored"
                write-verbose 'Generating a clean privateData hashtable'
                $metaData.manifestPrivateData = @{}
            }
        }else{
            write-verbose 'Generating a clean privateData hashtable'
            $metaData.manifestPrivateData = @{}
        }
        #Add our own privateData stuff as well
        $metaData.manifestPrivateData.moduleCompiledBy = "Bartender | $($btmodule.Description)"
        $metaData.manifestPrivateData.bartenderVersion = $btmodule.version
        $metaData.manifestPrivateData.bartenderCopyright = $btmodule.Copyright
        $metaData.manifestPrivateData.builtBy = $env:USERNAME
        $metaData.manifestPrivateData.builtOn = $(get-date -format s)
        write-verbose "PrivateData debug type: $($metaData.manifestPrivateData.GetType().name)"
        write-verbose "PrivateData debug Data:`n $($metaData.manifestPrivateData|out-string)"
        #Where was this command run from
        $scriptVars = @{}
        $scriptVars.configFilePath = "$invocationPath\$($configFile)"
        [array]$scriptVars.folders = @('enums','functions','filters','validationClasses','dscClasses','classes','private')
        <#
            Need to deal with Classes slightly differently
            Need to present them in the psd1 file as a script to run
            SO, we need an extras step that adds a classes.ps1 file
            Then grabs and compiles all the classes to that file
            THEN executes that script via the ScriptsToProcess item in the psd file
            This _should_ then make all the classes freely available after importing.
            E.g.
            ScriptsToProcess = @('Classes.ps1')
        #>
        $throwExceptions = @{}
        #NoConfig
        $errCat = [System.Management.Automation.ErrorCategory]::InvalidData
        $errMsg = [System.Exception]::new("Config file was not found.`nUse new-btproject for a new project.")
        $throwExceptions.noConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        #BadConfig
        $errMsg = [System.Exception]::new('Config file contents unexpected or malformed.')
        $throwExceptions.badConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        $errMsg = [System.Exception]::new('Bartender version deprecated.')
        $throwExceptions.badBartender = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        #EmptyFunctionsArray
        $scriptVars.functionsToExport = @()
        $scriptVars.DscResourcesToExport = @()
    }
    process{
        write-verbose "InvocationPath: $invocationPath"
        write-verbose "configfile: $configfile"
        write-verbose 'Validating Config File'
        if(!$(test-path $scriptVars.configFilePath))
        {
            throw $throwExceptions.noConfigError
        }
        try{
            $scriptVars.config = Import-Clixml $scriptVars.configFilePath -ErrorAction Stop
            Write-Verbose "$($scriptvars.config|Out-String)"
            write-verbose "$($scriptvars|out-string)"
            if(!$scriptVars.config.version -or !$scriptVars.config.moduleName -or !$scriptVars.config.moduleAuthor -or !$scriptVars.config.companyName)
            {
                throw $throwExceptions.badConfigError
            }else{
                if(!$ignoreBtVersion)
                {
                    write-verbose 'Confirming BarTender Version'
                    $currentBtVersion = $btModule.version
                    write-verbose "String: $($scriptVars.config.bartenderVersion)"
                    $configBtVersion = [version]$($scriptVars.config.bartenderVersion)
                    Write-Verbose "Config: $($configBtVersion.ToString())"
                    Write-Verbose "module: $($currentBtVersion.ToString())"
                    write-verbose "module: $($currentBtVersion.ToString()) vs config $($configBtVersion.ToString())  "
                    if($configBtVersion -lt $currentBtVersion)
                    {
                        write-error 'Bartender version in config file is deprecated'
                        'Please update your Bartender Module with the update-btFileStructure command'
                        throw $throwExceptions.badBartender
                    }elseif($configBtVersion -gt $currentBtVersion){
                        write-error 'Bartender version in config file is newer than the one installed'
                        'Please update your Bartender Version with the update-module command'
                        throw $throwExceptions.badBartender
                    }
                }
                #Increment the revision version
                if($scriptVars.config.AutoIncrementRevision -eq $true)
                {
                    Write-Verbose 'Incrementing Revision Version'
                    $scriptVars.newVersion = [version]::new($($scriptVars.config.version.Major),$($scriptVars.config.version.Minor),$($scriptVars.config.version.Build),$($scriptVars.config.version.revision + 1))
                    write-verbose $scriptVars.newVersion
                }else{
                    write-warning 'Skipping revision incrementation'
                }
                write-verbose 'Checking if we need to build a release version'
                switch ($($PSCmdlet.ParameterSetName)) {
                    'minorVersion' {
                        $scriptvars.build = $true
                        write-verbose 'Push Minor Release'
                        $scriptVars.newReleaseVersion = [version]::new($($scriptVars.config.version.Major),$($scriptVars.config.version.Minor + 1),0,0)
                        $scriptVars.newVersionAsTag = "$($scriptVars.newReleaseVersion.Major).$($scriptVars.newReleaseVersion.Minor).$($scriptVars.newReleaseVersion.Build)"
                    }
                    'majorVersion' {
                        write-verbose 'Push Major Release'
                        $scriptvars.build = $true
                        $scriptVars.newReleaseVersion = [version]::new($($scriptVars.config.version.Major + 1),0,0,0)
                        $scriptVars.newVersionAsTag = "$($scriptVars.newReleaseVersion.Major).$($scriptVars.newReleaseVersion.Minor).$($scriptVars.newReleaseVersion.Build)"
                    }
                    'buildVersion' {
                        write-verbose 'Push Build Release'
                        $scriptvars.build = $true
                        $scriptVars.newReleaseVersion = [version]::new($($scriptVars.config.version.Major),$($scriptVars.config.version.Minor),$($scriptVars.config.version.Build + 1),0)
                        $scriptVars.newVersionAsTag = "$($scriptVars.newReleaseVersion.Major).$($scriptVars.newReleaseVersion.Minor).$($scriptVars.newReleaseVersion.Build)"
                    }
                }
                if($scriptVars.newVersion)
                {
                    write-verbose "Incremented Version: $($scriptVars.newVersion)"
                    $scriptVars.config.version = $scriptVars.newVersion
                    #We should also add this bartender version to the config
                    write-verbose 'New bt version incremented in config'
                    write-verbose "Adding this Bartender Version: $($btModule.version.tostring())"
                    #$scriptVars.config.bartenderVersion = $($(get-module -name Bartender).version.tostring())
                    if($scriptVars.config.bartenderVersion)
                    {
                        $scriptVars.config.bartenderVersion = $($btModule.version.tostring())
                    }else{
                        $scriptVars.config | Add-Member -MemberType NoteProperty -Name bartenderVersion -Value $($btModule.version.tostring())
                    }
                    write-verbose 'Working out version tag'
                    $scriptVars.versionAsTag = $scriptVars.config.version.toString()
                    #Save the versionAsTag to the config
                    write-verbose 'Adding versionAsTag to config'
                    try{
                        $scriptVars.config.versionAsTag = $scriptVars.versionAsTag
                    }catch{
                        $scriptVars.config | Add-Member -MemberType NoteProperty -Name versionAsTag -Value $scriptVars.versionAsTag
                    }
                    write-verbose 'Updating Config file'
                    Export-Clixml -Path $scriptVars.configFilePath -InputObject $scriptVars.config
                    write-verbose 'Config file updated'
                }else{
                    write-verbose "Not Incrementing Version $($scriptVars.config.version)"
                }
            }
        }catch{
            write-error $Error[0].Exception
            throw $throwExceptions.badConfigError
        }
        write-verbose 'Config Settings:'
        Write-Verbose "$($scriptvars.config|Out-String)"
        write-debug "Config Updated"
        #Start compiling the items
        #Check we should be compiling for DSC
        #This is important as we need to save the classes as DSC resources
        #Check the folders, paths, tags, versions
        $scriptVars.functionResources = @()
        write-verbose 'Creating in revision directory'
        $scriptVars.moduleOutputFolder = "$invocationPath\rev\$($scriptVars.versionAsTag)"
        write-verbose "Module will be saved to $($scriptVars.moduleOutputFolder)"
        if(!(test-path $scriptVars.moduleOutputFolder))
        {
            write-verbose 'Making module folder since it does not exist'
            new-item $scriptVars.moduleOutputFolder -ItemType Directory | out-null
        }
        $scriptVars.manifestFile = "$($scriptVars.moduleOutputFolder)\$($scriptVars.config.moduleName).psd1"
        write-verbose "Manifest File: $($scriptVars.manifestFile)"
        if(! $(test-path $scriptVars.manifestFile))
        {
            #Should pretty much always create a new one
            Write-Verbose 'New Manifest will be created'
            $updateManifest = $false
        }else{
            #Legacy, change to warning from verbose as a test
            Write-warning 'Existing manifest will be updated'
            $updateManifest = $true
        }
        $scriptVars.moduleFile = "$($scriptVars.moduleOutputFolder)\$($scriptVars.config.moduleName).psm1"
        write-verbose "Module File: $($scriptVars.moduleFile)"
        if(test-path $scriptVars.moduleFile)
        {
            Write-warning 'Module file will be replaced'
            remove-item $scriptVars.moduleFile -Force
            #should basically never see this
            #Making this a warning as well
        }
        $scriptVars.preloadFileContents = $false
        $scriptVars.preloadFiles = @()
        foreach($preFile in @('enums.ps1','validators.ps1','classes.ps1'))
        {
            write-verbose "Checking $preFile"
            $preFilePath = "$($scriptVars.moduleOutputFolder)\$preFile"
            if(test-path $preFilePath)
            {
                write-warning "Removing previous prefile: $prefile"
                remove-item $preFilePath
                #Should also never see this
            }
        }
        remove-variable preFile -ErrorAction ignore
        write-debug 'Manifest, Preload and Module files checked'
        #Add the module Header
        $metadata.moduleHeader = "<#`nModule Mixed by BarTender`n`t$($metaData.description)`n`tVersion: $($metaData.version)`n`tAuthor: $($metaData.author)`n`tCopyright: $($metaData.copyright)`n`nModule Details:`n`tModule: $($scriptVars.config.moduleName)`n`tDescription: $($scriptVars.config.moduleDescription)`n`tRevision: $($scriptVars.config.version)`n`tAuthor: $($scriptVars.config.moduleAuthor)`n`tCompany: $($scriptVars.config.companyName)`n`nCheck Manifest for more details`n#>"
        $metadata.moduleHeader|Out-File $scriptVars.moduleFile -Force
        #Add the required script folder items to the module
        foreach($folder in $scriptVars.folders)
        {
            Write-Verbose "Processing folder $folder"
            $folderItems = get-btfolderItems -Path "$invocationPath\source\$folder" -psScriptsOnly
            if($($folderItems | measure-object).Count -ge 1)
            {
                write-verbose "$($folderItems.Count) Files found, getting content"
                write-verbose 'Getting script text, functions etc'
                $textSplat = @{
                    psFile = $folderItems.Path
                    removeQuotes = $scriptVars.config.RemoveSingleLineQuotes
                    trimSpaces = $scriptVars.config.trimSpaces
                    RemoveEmptyLines = $scriptVars.config.RemoveEmptyLines
                }
                if($folder -eq 'functions')
                {
                    write-verbose 'Will flag scripts as functions'
                    $textSplat.isFunction = $true
                }
                if($folder -eq 'private')
                {
                    write-verbose 'Private functions detected'
                    #Do not splat with isFunction so we don't add them to be exported
                    $textSplat.isFunction = $false
                }
                if($folder -eq 'dscClasses')
                {
                    write-verbose 'Will flag scripts as dsc Classes'
                    $textSplat.isDSCClass = $true
                }
                $textOutput = get-btScriptText @textSplat
                if($textOutput.output.length -gt 10)
                {
                    switch ($folder) {
                        'enums' {
                            write-debug 'Processing Enums'
                            write-verbose 'Outputting contents to Enums file'
                            $textOutput.output|Out-File  "$($scriptVars.moduleOutputFolder)\enums.ps1" -Append
                            #We only need this if there are classes
                            $scriptVars.preloadFileContents = $false
                            $scriptVars.preloadFiles += 'enums.ps1'
                        }
                        'validationClasses' {
                            write-debug 'Processing validation classes'
                            write-verbose 'Outputting contents to Validators file'
                            $textOutput.output|Out-File  "$($scriptVars.moduleOutputFolder)\validators.ps1" -Append
                            #We only need this if there are classes
                            $scriptVars.preloadFileContents = $true
                            $scriptVars.preloadFiles += 'validators.ps1'
                          }
                        'classes' {
                            write-debug 'Processing std classes'
                            write-verbose 'Outputting contents to Classes file'
                            $textOutput.output|Out-File  "$($scriptVars.moduleOutputFolder)\classes.ps1" -Append
                            $scriptVars.preloadFileContents = $true
                            $scriptVars.preloadFiles += 'classes.ps1'
                        }
                        Default {
                            write-debug "Processing folder: $folder"
                            $textOutput.output|Out-File  $scriptVars.moduleFile -Append
                            if($textOutput.functionResources.count -ge 1)
                            {
                                $scriptVars.functionsToExport += $textOutput.functionResources
                            }
                            if($textOutput.dscResources.count -ge 1)
                            {
                                $scriptVars.DscResourcesToExport += $textOutput.dscResources
                            }
                        }
                    }
                }else{
                    write-verbose 'No script contents to include'
                }
            }else{
                write-verbose 'No PS1 files found, ignoring'
            }
        }
        remove-variable folder -ErrorAction SilentlyContinue
    }end{
        write-verbose 'Copying Static Files'
        $folders = @('lib','bin','resource')
        foreach($folder in $folders)
        {
            $copiedItems = get-btfolderItems -path "$invocationPath\source\$folder" -destination "$($scriptVars.moduleOutputFolder)\$folder" -Copy
            Write-Verbose "Copied $($copiedItems.count) static items"
        }
        write-verbose "Version: $($scriptVars.config.version)"
        #By making the hashtable ordered
        #And declaring the things we want null AS Actually null
        #It should actually make them null
        #New-ModuleManifest seems to CARE what order the params are set,
        #if you export functions it sets * to aliases and cmdlets
        $splatManifest = [ordered]@{
            Path = $scriptVars.manifestFile
            RootModule = $(get-item $scriptVars.moduleFile).name
            Author = $($scriptVars.config.moduleAuthor -join ',')
            Copyright = "$(get-date -f yyyy) $($scriptVars.config.companyName)"
            CompanyName = $scriptVars.config.companyName
            Description = $scriptVars.config.moduleDescription
            ModuleVersion = $scriptVars.versionAsTag
            Guid = $scriptVars.config.guid
            PowershellVersion = $scriptVars.config.minimumPsVersion
            FunctionsToExport = @()
            ScriptsToProcess = @()
            NestedModules = $null
            CmdletsToExport = @()
            AliasesToExport = @()
            VariablesToExport = $null
        }
        Write-debug $($splatManifest | Out-String)
        if($scriptVars.DscResourcesToExport.count -ge 1){
            write-verbose "PreloadFileContents: $($scriptvars.preloadFileContents)"
            Write-Verbose 'Adding DSC Resources'
            $splatManifest.DscResourcesToExport = $scriptVars.DscResourcesToExport
            write-warning 'Since DSC resources are included, will not include preload.ps1. It causes some odd behaviour with DSC'
            $scriptvars.preloadFileContents = $false
            write-verbose "PreloadFileContents: $($scriptvars.preloadFileContents)"
            write-verbose 'Need to add the enums to the top of the file'
            $enumsContent = $(get-content "$($scriptVars.moduleOutputFolder)\enums.ps1")
            $moduleContent = get-content $scriptVars.moduleFile
            $enumsContent | out-file $scriptVars.moduleFile -Force
            $moduleContent | out-file $scriptVars.moduleFile -Append
        }
        if($scriptVars.config.Tags){
            Write-Verbose 'Adding Tags'
            $splatManifest.tags = $scriptVars.config.Tags
        }
        if($($scriptVars.config.RequiredModules|measure-object).count -ge 1){
            write-verbose 'Finding Appropriate Module Versions'
            $scriptVars.Modules = foreach($reqModule in $scriptVars.config.RequiredModules)
            {
                $reqModuleType = $reqModule.getType().name
                if($reqModuleType -eq 'String')
                {
                    write-verbose "Checking Required module: $reqModule is available on this machine"
                    try{
                        get-btInstalledModule -moduleName $reqModule -errorAction 'Stop'
                        write-verbose "Module $reqModule was Found"
                    }catch{
                        $error[0]
                        throw 'Unable to complete build due to required module error (See Above)'
                    }
                }elseIf($reqModuleType -eq 'Hashtable')
                {
                    if($($reqModule.keys) -contains 'moduleName' -and $($reqModule.keys) -contains 'moduleVersion' -and $($reqModule.keys.count) -eq 2)
                    {
                        write-verbose "Hashtable well formed for $($reqModule.ModuleName) required module"
                        try{
                            get-btInstalledModule @reqModule -errorAction 'Stop'
                            write-verbose "Module $($reqModule.ModuleName) was Found with version $($reqModule.ModuleVersion)"
                        }catch{
                            $error[0]
                            throw 'Unable to complete build due to required module error (See Above)'
                        }
                    }else{
                        throw "Hashtable poorly formed. Required Module Hashtables should contain 2 keys only, moduleName and moduleVersion"
                    }
                }
            }
            $splatManifest.RequiredModules = $scriptVars.Modules
        }
        if($ReleaseNotes)
        {
            Write-Verbose 'Adding Release Notes'
            $splatManifest.ReleaseNotes = $ReleaseNotes
        }
        if($scriptVars.config.useGitDetails -eq $true)
        {
            write-verbose 'Adding Git Details'
            $scriptVars.gitSettings = get-btGitDetails -modulePath $invocationPath
            if($scriptVars.gitSettings)
            {
                write-verbose 'Retrieved git details, to splatManifest'
                #Use origin as projectUri
                if($scriptVars.gitSettings.origin -and $scriptVars.gitSettings.origin.length -gt 5)
                {
                    $splatManifest.projectUri = $scriptVars.gitSettings.origin
                }
                #See if we have a license file, if we do add the license URI
                #Could be done with a web-request, but then what do we do with private repos
                if($(test-path "$invocationPath\LICENSE"))
                {
                    $splatManifest.licenseUri = "$($scriptVars.gitSettings.origin)/blob/$($($($scriptVars.gitSettings.branch).replace('*','')).trim())/LICENSE"
                }
                #See if icon.png exists and if it does, add it in as well
                if($(test-path "$invocationPath\icon.png"))
                {
                    $splatManifest.iconUri = "$($scriptVars.gitSettings.origin)/blob/$($($($scriptVars.gitSettings.branch).replace('*','')).trim())/icon.png"
                }
            }else{
                write-warning 'useGitDetails is set to true, but was unable to get the repository settings'
            }
        }
        if($scriptVars.config.licenseUri -and $scriptVars.config.licenseUri.length -gt 5)
        {
            write-verbose 'Adding config LicenseUri'
            $splatManifest.licenseUri = $scriptVars.config.licenseUri
        }
        if($scriptVars.config.projectUri -and $scriptVars.config.projectUri.length -gt 5)
        {
            write-verbose 'Adding config projectUri'
            $splatManifest.projectUri = $scriptVars.config.projectUri
        }
        if($scriptVars.config.iconUri -and $scriptVars.config.iconUri.length -gt 5)
        {
            write-verbose 'Adding config iconUri'
            $splatManifest.iconUri = $scriptVars.config.iconUri
        }
        if($scriptVars.functionsToExport.Count -ge 1)
        {
            Write-Verbose 'Adding Function Resources'
            $splatManifest.FunctionsToExport = $scriptVars.functionsToExport
        }
        if($metaData.manifestPrivateData)
        {
            $metaData.manifestPrivateData.moduleRevision = $scriptVars.config.version
            [hashtable]$splatManifest.privateData = $metaData.manifestPrivateData
            write-verbose "Adding privateData;`n`tDebug - privateDataType: $($splatManifest.privatedata.gettype().name)"
        }
        write-verbose "PreloadFileContents: $($scriptvars.preloadFileContents)"
        if($scriptvars.preloadFileContents -eq $true -and $scriptVars.preloadFiles.count -ge 1)
        {
            write-verbose 'Adding Preload to scriptsToProcess'
            $splatManifest.ScriptsToProcess = $scriptVars.preloadFiles
            write-verbose 'Adding nestedModules'
            $splatManifest.NestedModules = $scriptVars.preloadFiles
        }
        Write-Verbose "$updateManifest"
        if($updateManifest -eq $true)
        {
            write-verbose 'Checking for, and removing, old Manifest file'
            remove-item -Path $($scriptVars.manifestFile) -force -ErrorAction Ignore
            New-ModuleManifest @splatManifest
        }else{
            New-ModuleManifest @splatManifest
        }
        #work out whether we should publish
        write-verbose "Script config publish default: $($scriptVars.config.publishOnBuild)"
        if($scriptVars.config.publishOnBuild -eq $true)
        {
            $scriptVars.defaultPublish = $true
        }else{
            $scriptVars.defaultPublish = $false
        }
        switch ($publish) {
            $true { $scriptVars.shouldPublish = $true}
            $false { $scriptVars.shouldPublish = $false }
            $null {
                if($scriptvars.build)
                {
                    $scriptVars.shouldPublish = $scriptVars.defaultPublish
                }else{
                    $scriptVars.shouldPublish = $false
                }
            }
            Default {
                if($scriptvars.build)
                {
                    $scriptVars.shouldPublish = $scriptVars.defaultPublish
                }else{
                    $scriptVars.shouldPublish = $false
                }
            }
        }
        write-debug 'Continue with Pester Tests?'
        if($ignoreTest)
        {
            write-warning 'Skipping test phase'
        }else{
            write-verbose 'Starting test phase'
            try{
                $scriptvars.testResults = start-btTestPhase -path $invocationPath -configFile $configFile -modulePath "$($scriptVars.moduleOutputFolder)"
            }catch{
                throw 'Unable to initiate Test Phase'
            }
        }
        if(($scriptvars.testResults.success -eq $true) -or ($ignoreTest -eq $true))
        {
            if($scriptvars.testResults.pesterDetails)
            {
                write-verbose 'Build Results Returned:'
                $scriptvars.testResults
                $global:lastPesterResult = $scriptvars.testResults.pesterDetails
                write-warning 'PesterResults Saved to global variable $global:lastPesterResult'
            }else{
                write-warning 'Tests explicitely ignored'
            }
            #$scriptvars.build
            if($scriptvars.build -eq $true)
            {
                write-debug 'Continue with publish?'
                Write-Verbose 'Publish triggered - cloning revision folder and updating version'
                #This is where we clone the revision
                if($scriptVars.newReleaseVersion -and $scriptVars.newVersionAsTag)
                {
                    write-verbose 'Incrementing version and cloning to release'
                    #make new directory
                    write-verbose 'creating release directory'
                    $scriptVars.releaseDirectory = "$invocationPath\$($scriptVars.config.moduleName)\$($scriptVars.newVersionAsTag)"
                    new-item -itemtype Directory -Path $scriptVars.releaseDirectory|out-null
                    write-verbose 'Cloning'
                    copy-item -Path "$($scriptVars.moduleOutputFolder)\*" -Destination "$($scriptVars.releaseDirectory)\" -recurse
                    write-verbose 'Creating new module manifest'
                    write-verbose 'Checking for Manifest file'
                    $scriptVars.newManifestPath = "$($scriptVars.releaseDirectory)\$($scriptVars.config.moduleName).psd1"
                    if(!$(test-path $scriptVars.newManifestPath))
                    {
                        throw 'Unable to find new Manifest file'
                    }
                    #Check for configuration module and import it
                    write-verbose 'Checking configuration module to update manifest'
                    if(!$(get-module configuraton))
                    {
                        try{
                            import-module -name configuration -ErrorAction Stop
                        }catch{
                            throw 'Configuration module not on this machine. Please install it first'
                        }
                    }
                    #Using the metadata
                    write-verbose 'Updating manifest file version'
                    $metadata = import-metadata $scriptVars.newManifestPath
                    #Update the version
                    $metadata.ModuleVersion = $scriptVars.newVersionAsTag
                    #Add pester details
                    if($global:lastPesterResult)
                    {
                        write-verbose 'Adding Pester details to manifest'
                        $codeCoverage = [math]::round($($global:lastPesterResult.codecoverage.numberOfCommandsExecuted/$global:lastPesterResult.codecoverage.numberofCommandsAnalyzed)*100,0)
                        $passed = [math]::round($($($global:lastPesterResult.PassedCount / $global:lastPesterResult.TotalCount)*100),0)
                        $metadata.privatedata.pester = @{}
                        $metadata.privatedata.pester.codecoverage = $codeCoverage
                        $metadata.privatedata.pester.time = $global:lastPesterResult.time.ToString()
                        $metadata.privatedata.pester.passed = "$passed %"
                    }
                    #Save the file
                    write-verbose 'Saving manifest file'
                    try{
                        $metadata|export-metadata -Path $scriptVars.newManifestPath
                    }catch{
                        throw 'Error updating Manifest file'
                    }
                    #Test
                    write-verbose 'Ensuring Manifest still valid'
                    try{
                        $scriptVars.manifestTest = Test-ModuleManifest $scriptVars.newManifestPath -ErrorAction stop
                    }catch{
                        throw 'Error: Updated Manifest is invalid'
                    }
                    write-verbose 'Updating Config file'
                    write-verbose 'Adding versionAsTag to module config'
                    $scriptVars.config.versionAsTag = $scriptVars.newVersionAsTag
                    write-verbose 'Adding new version to module config'
                    $scriptVars.config.version  = $scriptVars.newReleaseVersion
                    if(!$($scriptVars.config.previousRelease)){
                        write-verbose 'lastRelease property missing from config, creating it'
                        $scriptVars.config|add-member -MemberType NoteProperty -name previousRelease -Value @{}
                    }
                    if(!$($scriptVars.config.lastrelease)){
                        write-verbose 'lastRelease property missing from config, creating it'
                        $scriptVars.config|add-member -MemberType NoteProperty -name lastRelease -Value @{}
                    }else{
                        write-verbose 'Setting previous details from last release'
                        $scriptVars.config.previousRelease = $scriptVars.config.lastrelease.clone()
                    }
                    write-verbose 'Adding lastRelease items to config'
                    $scriptVars.config.lastRelease = @{
                        version = $scriptVars.newReleaseVersion
                        date = $(get-date)
                    }
                    Export-Clixml -Path $scriptVars.configFilePath -InputObject $scriptVars.config
                    write-verbose 'Config file updated'
                    if($scriptVars.shouldPublish)
                    {
                        write-verbose 'Ok to publish'
                        foreach($repo in $scriptVars.config.repository)
                        {
                            publish-btmodule -Repository $repo
                        }
                    }
                }
                if($scriptVars.config.autoDocument -eq $true)
                {
                    write-verbose 'Updating Documentation'
                    get-btDocumentation -path $invocationPath -configFile $configFile
                }else{
                    write-verbose 'Skipping documentation update'
                }
                #PostBuildScripts go here
                $postBuildScripts = get-btFolderItems -psScriptsOnly -Path "$invocationPath\postbuildscripts"
                write-debug 'Execute any postbuild scripts'
                foreach($postbuildscript in $postbuildscripts)
                {
                    write-verbose "Executing postbuild script $($postbuildscript.relativepath)"
                    . $postBuildScripts.Path
                }
            }else{
                Write-Verbose 'No publish triggered'
            }
        }else{
            #Write-Verbose 'Failed the testing phase'
            Write-Error 'Failed the testing phase'
            if($scriptvars.testResults.pesterDetails)
            {
                write-warning "Build Results Returned:"
                $scriptvars.testResults
                $global:lastPesterResult = $scriptvars.testResults.pesterDetails
                write-warning 'PesterResults Saved to global variable $global:lastPesterResult'
            }else{
                write-warning 'No pester results returned'
            }
        }
        #Last step, cleanup vars
        write-debug 'Clean up old revisions'
        write-verbose 'Cleaning up old revisions'
        start-btRevisionCleanup -path $invocationPath
        remove-variable splatManifest,scriptvars -ErrorAction SilentlyContinue
        write-verbose 'Finished btbuild run'
        write-information 'Finished btbuild run'
    }
}

function start-btTestPhase
{
    <#
        .SYNOPSIS
            Run a test of the module
        .DESCRIPTION
            - Create a new runspace
            - Run the module in as a job
            - If pester is installed, include in the job any tests in the source\pester folder
            - Return a custom result of what occured
            Running as a job ensures we are on a clean powershell process, hopefully with no modules loading
            Will respect the .btIgnore, .btOrder* files
        .PARAMETER path
            The path of your bartender module
            Defaults to current working directory
        .PARAMETER configFile
            The bartender configfile to use
            Defaults to btconfig.xml
        .EXAMPLE
            start-btTestPhase
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-05-17
            Changelog:
                2018-05-16 - AA
                    - Initial Script
                    - Tested ok
                    - Improved job execution
                2018-05-17 - AA
                    - Added help
                    - Allowed passing of variables to pester for basic module tests
                    - Improved job execution
                    - Improved the return object
                2019-01-31 - AA
                    - Rewrite to accept a path for the module
                    - So we don't always use the dist path
                2019-02-25
                    - Somehow this file disappeared
                        - Pulled from the last commit with this file
                2019-03-12
                    - Somehow this file disappeared
                        - Change from using module to import-module
                2019-09-20
                    - Removing the codeCoverage from pester coz its broken
                        - https://github.com/PowerShell/PowerShell/pull/10269
                    - Fixed the pester import command since it does _NOT_ like having multiple imports
                2020-05-25
                    - Added back codeCoverage, is fixed if you use PS 7
                    - Fixed the pester test location folder
                        - Was not correctly loading the module when testing
                    - Updated to use pester 4.10.1 and PlatyPS 0.14.0
        .COMPONENT
            Bartender
        .INPUTS
           null
        .OUTPUTS
            custom object
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0)]
        [string]$path = (Get-Item -Path ".\").FullName,
        [string]$configFile = 'btconfig.xml',
        [string]$modulePath
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $invocationPath = $path
        $scriptVars = @{}
        $scriptVars.configFilePath = "$invocationPath\$($configFile)"
        $scriptVars.testsPath = "$invocationPath\source\pester"
        $throwExceptions = @{}
        #NoConfig
        $errCat = [System.Management.Automation.ErrorCategory]::InvalidData
        $errMsg = [System.Exception]::new("Config file was not found.`nUse new-btproject for a new project.")
        $throwExceptions.noConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        #BadConfig
        $errMsg = [System.Exception]::new('Config file contents unexpected or malformed.')
        $throwExceptions.badConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        $returnResult = [pscustomobject] @{
            success = $false
            message = $null
            pesterDetails = $null
            pesterFails = $null
            pesterCodeCoverPercent = 0
            pesterCommandsAnalyzed = 0
            pesterResults = '0/0'
        }
    }
    process{
        if(!$(test-path $scriptVars.configFilePath))
        {
            throw $throwExceptions.noConfigError
        }
        $scriptVars.config = Import-Clixml $scriptVars.configFilePath -ErrorAction Stop
        Write-Verbose "$($scriptvars.config|Out-String)"
        if(!$scriptVars.config.version -or !$scriptVars.config.moduleName -or !$scriptVars.config.moduleAuthor -or !$scriptVars.config.companyName)
        {
            throw $throwExceptions.badConfigError
        }else{
            write-verbose 'Configuring Params'
            $scriptVars.versionAsTag = $scriptVars.config.versionAsTag
            if($modulePath)
            {
                write-verbose "Using module path of $modulePath"
                write-debug 'Using specified module path'
                $scriptVars.moduleFolder = $modulePath
            }else{
                write-warning 'Testing last release'
                Write-Debug 'Testing last release'
                #Seems this was pretty wrong - needed a rebuild
                $scriptVars.moduleFolder = "$invocationPath\rev\$($scriptVars.versionAsTag)"
            }
            #$scriptVars.moduleFolder = "$invocationPath\dist\$($scriptVars.config.moduleName)\$($scriptVars.versionAsTag)"
            write-verbose 'Checking for Pester'
            $scriptVars.pesterModule = $(get-module -refresh -ListAvailable -Name Pester |sort-object -Property Version -Descending |select-object -First 1)
            if(!$scriptVars.pesterModule)
            {
                write-warning 'Pester not installed, no tests will be performed'
            }elseif(!$scriptVarspestermodule.Version.Major -lt 4)
            {
                Write-Verbose "Found pester Version: $($scriptVars.pesterModule.Version.ToString())"
                write-warning 'This version of Pester is deprecated. Please update to a version greater than 4'
                write-warning 'No tests will be performed'
                $scriptVars.pesterModule -eq $null
            }else{
                Write-Verbose "Using pester Version: $($scriptVars.pesterModule.Version.ToString())"
                write-verbose 'Getting Pester Tests'
                $scriptVars.testScripts = get-btFolderItems -psScriptsOnly -Path $scriptVars.testsPath
                $scriptVars.testCount = $($scriptVars.testScripts | measure-object).count
            }
            if($scriptVars.testCount -ge 1 -and $($scriptVars.pesterModule))
            {
                write-verbose "Found $($scriptVars.testCount) test files. Will process them with invoke"
                #$scriptVars.pesterResults =  invoke-pester -Script $scriptVars.testScripts.path
                #`$pesterResult = invoke-pester -passthru -script @($($(foreach($script in $scriptVars.testScripts.path){"'$script'"}) -join ',')) -show None -codeCoverage '$($scriptVars.moduleFolder)\*'
                $scriptVars.myTestBlock = "
                    import-module '$($scriptVars.moduleFolder)\$($scriptVars.config.moduleName).psd1'
                    `$scriptsArray = @($($(foreach($script in $scriptVars.testScripts.path){"'$script'"}) -join ','))
                    `$pesterScriptsParameter = foreach(`$script in `$scriptsArray)
                    {
                        @{
                            path=`$script
                            Parameters= @{
                                modulePath = '$($scriptVars.moduleFolder)'
                                moduleVersion = '$($scriptVars.versionAsTag)'
                                moduleName = '$($scriptVars.config.moduleName)'
                            }
                        }
                    }
                    if(!(get-module pester)){import-module pester}
                    #Commenting out the code-coverage part
                    #Need to add it back later
                    #May 2020 - adding it back - cant remember Why I took it out
                    #This thread maybe https://github.com/pester/Pester/issues/1318
                    `$pesterResult = invoke-pester -passthru -script `$pesterScriptsParameter -show None -codeCoverage '$($scriptVars.moduleFolder)\$($scriptVars.config.moduleName).psm1'
                    `$pesterResult
                "
            }else{
                write-verbose 'No tests - just checking module'
                $scriptVars.myTestBlock ="
                    using module $($scriptVars.moduleFolder)
                    [psCustomObject] @{
                        TotalCount = 0
                        PassedCount = 0
                        FailedCount = 0
                        Time = `$([timespan]::new(0)).tostring()
                    }
                "
            }
            try{
                write-verbose 'Creating script block'
                $scriptBlock = [scriptblock]::Create($scriptVars.myTestBlock)
                write-verbose "ScriptBlock Contents:`n`n$($scriptVars.myTestBlock)"
            }catch{
                write-error 'Unable to compile scriptblock. Module path could be missing'
                write-verbose "ScriptBlock Contents:`n`n$($scriptVars.myTestBlock)"
                $returnResult.message = 'Unable to compile scriptblock. Module path could be missing'
            }
            write-verbose 'Executing Scriptblock As Job'
            $job = start-job -ScriptBlock $scriptBlock
            Wait-Job $job | Out-Null
            $pesterResults = receive-job $job
            $returnResult.message = 'Module loaded succesfully'
            if($pesterResults.FailedCount -eq 0)
            {
                $returnResult.success = $true
            }else{
                $returnResult.pesterFails = $pesterResults.TestResult | where-object{$_.passed -eq $false}
            }
            $returnResult.pesterDetails = $pesterResults
            if($pesterResults.codecoverage)
            {
                $returnResult.pesterCommandsAnalyzed = $pesterResults.codecoverage.NumberOfCommandsAnalyzed
                $returnResult.pesterCodeCoverPercent = [math]::round($($($pesterResults.codecoverage.NumberOfCommandsExecuted)/$($pesterResults.codecoverage.NumberOfCommandsAnalyzed))*100,0)
            }
            if($pesterResults.PassedCount -ge 1)
            {
                $returnResult.pesterResults = "$($pesterResults.PassedCount)/$($pesterResults.TotalCount)"
            }
            $returnResult
        }
    }
}

function update-btFileStructure
{
    <#
        .SYNOPSIS
            Update the current projects file and config to the installed version of bartender
            
        .DESCRIPTION
            Check the folder structer and files are what the installed version are expecting
            Add them if they are not present
            Add the bartender version to the module config
            Add the autodocument variable to the module config
            
        .PARAMETER path
            The path of your bartender module
            Defaults to current working directory
        
        .PARAMETER configFile
            The bartender configfile to use
            Defaults to btconfig.xml
        .PARAMETER force
            Ignore any differences in version and run anyway
        
        .EXAMPLE
            update-btFileStructure
            
            #### DESCRIPTION
            Check for differences in Bartender Versions
            Update if required
            
            
        .EXAMPLE
            update-btFileStructure -force
            
            #### DESCRIPTION
            Always update
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-05-17
            
            
            Changelog:
                2018-0
                2018-05-17 - AA
                    
                    - Initial Script
                    - Added Help
                    - Updated Config file
                2018-05-17 - AA
                    
                    - Added add-btBasicTests to the update function
                2018-08-13
                    - Added validationClasses folder
                2018-10-30
                    - Added postBuildScript folder
                    - Fixed errormsg with btversion that could occur where the var was declared but empty
                2018-12-03
                    - Added Revisions folder (rev)
                
                2019-02-03
                    - Add a default setting for autodocument
                    
         .COMPONENT
            Bartender
        .INPUTS
           null
        .OUTPUTS
            custom object
    #>
    [CmdletBinding()]
    PARAM(
        [string]$path = (Get-Item -Path ".\").FullName,
        [string]$configFile = 'btconfig.xml',
        [switch]$force
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $btModule = get-module bartender
        $invocationPath = $path
        $scriptVars = @{}
        $scriptVars.configFilePath = "$invocationPath\$($configFile)"
        $throwExceptions = @{}
        #NoConfig
        $errCat = [System.Management.Automation.ErrorCategory]::InvalidData
        $errMsg = [System.Exception]::new("Config file was not found.`nUse new-btproject for a new project.")
        $throwExceptions.noConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        #BadConfig
        $errMsg = [System.Exception]::new('Config file contents unexpected or malformed.')
        $throwExceptions.badConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
    }
    
    process{
        if(!$(test-path $scriptVars.configFilePath))
        {
            throw $throwExceptions.noConfigError
        }
        $scriptVars.config = Import-Clixml $scriptVars.configFilePath -ErrorAction Stop
        Write-Verbose "$($scriptvars.config|Out-String)"
        if(!$scriptVars.config.version -or !$scriptVars.config.moduleName -or !$scriptVars.config.moduleAuthor -or !$scriptVars.config.companyName)
        {
            throw $throwExceptions.badConfigError
        }else{
            $currentBtVersion = $btModule.version
            $configBtVersion = [version]$scriptVars.config.bartenderVersion
            if($configBtVersion -eq $currentBtVersion -and (!$force))
            {
                write-verbose 'Bartender version is already ok'
                
            }elseif($configBtVersion -gt $currentBtVersion -and (!$force)){
                write-error 'Bartender version in config file is newer than the one installed'
                throw 'Please update your Bartender Version with the update-module command'
            }else{
                write-verbose 'Need to upgrade'
                write-verbose "Adding this Bartender Version: $($btModule.version.tostring())"
                #$scriptVars.config.bartenderVersion = $($(get-module -name Bartender).version.tostring())
                if($configBtVersion)
                {
                    $scriptVars.config.bartenderVersion = $($btModule.version.tostring())
                }else{
                    try{
                        $scriptVars.config | Add-Member -MemberType NoteProperty -Name bartenderVersion -Value $($btModule.version.tostring()) -ErrorAction Stop
                    }catch{
                        $scriptVars.config.bartenderVersion = $($btModule.version.tostring())
                    }
                    
                }
                if($scriptVars.config.autoDocument -eq $null)
                {
                    write-warning 'Adding the autoDocument and setting it to true, if this is undesired edit the config.xml'
                    $scriptVars.config | Add-Member -MemberType NoteProperty -Name autoDocument -Value $true
                    add-btBasicTests
                }
                write-verbose 'Updating Config file updated'
                Export-Clixml -Path $scriptVars.configFilePath -InputObject $scriptVars.config
                write-verbose 'Config file updated'
                
                write-verbose '***CREATE THE FILES AND FOLDERS***'
                add-btFilesAndFolders -path $path -force
            }
        }       
        
    }
    
}

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
        .PARAMETER useGitDetails
            Try and get the license, project URIs from GIT
        .PARAMETER licenseUri
            Override the licenseUri
        .PARAMETER iconUri
            Override the iconUri
        .PARAMETER projectUri
            Override the projectUri
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
                2019-03-08 - AA
                - Added way to update licenseuri, iconuri and projecturi
                2019-03-08 - AA
                    - Stopped loosing required modules on update
                    
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
        [Nullable[boolean]]$useGitDetails,
        [array]$RequiredModules,
        [string[]]$Tags,
        [string]$modulePath = $(get-location).path,
        [string]$configFile = 'btConfig.xml',
        [string]$licenseUri,
        [string]$projectUri,
        [string]$iconUri
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
        write-verbose 'Capturing release details'
        if($existingSettings.lastRelease){
            $lastRelease = $existingSettings.lastRelease
        }else{
            $lastRelease = @{}
        }
        if($existingSettings.previousRelease){
            $previousRelease = $existingSettings.previousRelease
        }else{
            $previousRelease = @{}
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
        if($useGitDetails -eq $null)
        {
            if($existingSettings.useGitDetails -ne $null)
            {
                $useGitDetails = $existingSettings.useGitDetails
            }
            elseif($userDefaults.useGitDetails -ne $null)
            {
                $useGitDetails = $userDefaults.useGitDetails
            }else{
                $useGitDetails  = $true
            }
        }
        if($licenseUri -eq $null)
        {
            if($existingSettings.licenseUri -ne $null)
            {
                $licenseUri = $existingSettings.licenseUri
            }
            elseif($userDefaults.licenseUri -ne $null)
            {
                $licenseUri = $userDefaults.licenseUri
            }else{
                $licenseUri  = $true
            }
        }
        if($licenseUri -eq $null)
        {
            if($existingSettings.licenseUri -ne $null)
            {
                $licenseUri = $existingSettings.licenseUri
            }
            elseif($userDefaults.licenseUri -ne $null)
            {
                $licenseUri = $userDefaults.licenseUri
            }else{
                $licenseUri  = $true
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
        }else{
            if($existingSettings.requiredModules)
            {
                $requiredModules = $existingSettings.requiredModules
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
            useGitDetails = $useGitDetails
            licenseUri = $licenseUri
            projectUri = $projectUri
            iconUri = $iconUri
            lastRelease = $lastRelease
            previousRelease = $previousRelease
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


function add-btBasicTests
{
    <#
        .SYNOPSIS
            Add a basic pester test to the pester folder
            
        .DESCRIPTION
            Add a pester-test to the ..\source\pester folder
            This pester-test will test the basic health of your module on execution
            The script file (baseModuleTest.ps1) will be added to both the .btOrderStart and .btOrderEnd files, so will run twice
            The tests will ensure you are working on only the newly-compiled module and not a previously installed module
            
        .PARAMETER path
            The path of your bartender module
            Defaults to current working directory
        
        .EXAMPLE
            add-btBasicTests
            
            #### DESCRIPTION
            Create file ..\source\pester\baseModuleTest.ps1
            Insert filename into .btOrderStart (At Top)
            Insert filename into .btOrderEnd (At Bottom)
            
            
            #### OUTPUT
            N/A
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-05-17
            
            
            Changelog:
                2018-05-17 - AA
                    
                    - Initial Script
                    - Tested - working
                    - Forced a change on get-btFolderItem
                2018-05-18 - AA
                    
                    - Fixed a bug where it was absolute referencing the module name in the basetest
                    
        .COMPONENT
            Bartender
            
        .INPUTS
           null
        .OUTPUTS
            null
    #>
    [CmdletBinding()]
    PARAM(
        [string]$path = (Get-Item -Path ".\").FullName
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $fileContents = @'
Param(
    $moduleVersion,
    $modulePath,
    $moduleName
)
describe 'The module was imported succesfully' {
    $module = get-module -name $moduleName
    it 'Should have imported a single module' {
        ($module | measure-object).count | should -be 1
    }
    it 'Name of the module is correct' {
        $module.Name |Should -be $moduleName
    }
    it 'Should be sourced from the dist folder' {
        $module.modulebase |Should -Be $modulePath
    }
    it 'Imported module Version should match' {
        $module.version |Should -be $moduleVersion
    }
}
describe 'Check for module Dependancies' {
    $loadedModules = get-module
    $moduleDependencies
}
'@
    $pesterFolder = "$path\source\pester"
    $testFilename = 'baseModuleTest.ps1'
    
    }
    
    process{
        if(test-path $pesterFolder)
        {
            write-verbose 'Pester folder found'
            $fullname = "$($(get-item $pesterFolder).fullname)\$testfilename"
            write-verbose "Creating test file at $fullname"
            $fileContents | out-file $fullname -Force
            $orderFiles = @('.btOrderStart','.btOrderEnd')
            foreach($file in $orderFiles)
            {
                write-verbose "Checking if $testFilename in $file, adding if necessary"
                if(test-path $("$pesterFolder\$file"))
                {
                    $content = get-content $("$pesterFolder\$file")
                    if($content -notcontains ".\$testfilename")
                    {
                        write-verbose "adding to $file"
                        if($file -like '*end')
                        {
                            ".\$testfilename" | out-file $("$pesterFolder\$file") -Append
                        }else{
                            ".\$testfilename" | out-file $("$pesterFolder\$file") -force
                            $content |out-file $("$pesterFolder\$file") -Append
                        }
                        
                    }else{
                        write-verbose "Already present in $file"
                    }
                    
                    remove-variable content -ErrorAction Ignore
                }else{
                    write-warning "$file file not found"
                }
            }
        }else{
            write-error 'Unable to find pester folder'
        }
    }
    
}

function add-btFilesAndFolders
{
    <#
        .SYNOPSIS
            Add the files and folders required by Bartender
            
        .DESCRIPTION
            Check the folder structer and files are what the installed version are expecting
            Add them if they are not present
            
            
        .PARAMETER path
            The path of your bartender module
            Defaults to current working directory
        
        .PARAMETER force
            Required so that this is not accidentally called
        
        .EXAMPLE
            update-btFileStructure
            
            #### DESCRIPTION
            Check for differences in Bartender Versions
            Update if required
            
            
        .EXAMPLE
            add-btFilesAndFolders -force
            
            #### DESCRIPTION
            Add the folders and files
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-12-03
            
            
            Changelog:
                2018-12-03 - AA
                    
                    - Initial Script
                    - Migrated from update-btFileStructure
                2019-01-30
                    - Create new folder for revision
                    - Remove the old publishToken.txt
                2019-03-04
                    - Fix a bug where the stripping of auth tokens was accidentally a scriptblock
                2019-03-11
                    - Copy the readme.md if there is not one or the existing one is small
                    
         .COMPONENT
            Bartender
        .INPUTS
           null
        .OUTPUTS
            custom object
    #>
    [CmdletBinding()]
    PARAM(
        [string]$path = (Get-Item -Path ".\").FullName,
        [switch]$force
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        write-verbose "Using path: $path"
        write-debug "Using path: $path"
        
        if(!$force)
        {
            throw 'This function should be called from other functions, use -force if you wish to proceed anyway'
        }
    }
    
    process{
        
        if($force)
        {
            write-verbose 'Verifying the base folder structure'
            $directories = @('documentation','source','rev')
            
            foreach($directory in $directories)
            {
                $fullPath = "$path\$directory"
                if(test-path $fullPath)
                {
                    write-verbose "$directory ok"
                }else{
                    write-verbose "Need to create Source Folder for path $directory"
                    new-item -ItemType Directory -path $fullPath |Out-Null
                    new-item -ItemType File -Path "$fullPath\.gitignore" |Out-Null
                }
                
            }
            Write-Verbose 'Creating source structure'
            $directories = @('functions','enums','classes','pester','filters','dscClasses','validationClasses','private','resource','lib','bin')
            $files = @('.gitignore','.btignore','.btorder','.btorderStart','.btorderEnd')
            foreach($directory in $directories)
            {
                $fullPath = "$path\source\$directory"
                if(test-path $fullPath)
                {
                    write-verbose "$directory ok"
                }else{
                    Write-Verbose "Need to create Source Folder for path $directory"
                    new-item -ItemType Directory -path $fullPath |Out-Null
                    
                }
                foreach($file in $files)
                {
                    $fileFullPath = "$fullPath\$file"
                    if(test-path $fileFullPath)
                    {
                        write-verbose "$fileFullpath exists"
                        if($file -eq '.btorder')
                        {
                            write-verbose 'Renaming .btorder to .btorderstart'
                            rename-item -Path $fileFullPath -NewName '.btorderStart' -Force
                        }
                    }elseif($file -ne '.btorder'){
                        {
                        }
                        write-verbose "Creating $fileFullpath"
                        new-item -ItemType File -Path $fileFullPath
                    }
                }   
            }
            write-verbose 'Creating PostbuildScript folder'
            $directory = 'postBuildScripts'
            $fullPath = "$path\$directory"
            if(test-path $fullPath)
            {
                write-verbose 'postBuildScripts ok'
            }else{
                Write-Verbose 'Need to create postBuildScripts folder'
                new-item -ItemType Directory -path $fullPath |Out-Null
                
            }
            #This should still exist as a var, redeclaring in case it needs chaning in the future
            $files = @('.gitignore','.btignore','.btorder','.btorderStart','.btorderEnd')
            foreach($file in $files)
            {
                $fileFullPath = "$fullPath\$file"
                if(test-path $fileFullPath)
                {
                    write-verbose "$fileFullpath exists"
                    if($file -eq '.btorder')
                    {
                        write-verbose 'Renaming .btorder to .btorderstart'
                        rename-item -Path $fileFullPath -NewName '.btorderStart' -Force
                    }
                }elseif($file -ne '.btorder'){
                    {
                    }
                    write-verbose "Creating $fileFullpath"
                    new-item -ItemType File -Path $fileFullPath
                }
            }
            write-verbose 'Removing legacy publish token'
            
            $secrets = get-childitem -path $path -filter 'publishtoken.txt'
            if($secrets)
            {
                remove-item $secrets -force
                write-warning 'Removed legacy publishtoken.txt'
                write-warning 'Use the save-btRepository cmdlet to save repository settings'
            }
            
            
            #Add the pester files
            add-btBasicTests -path $path
            write-verbose 'Checking for readme.md'
            $readmePath = "$path\readme.md"
            $moduleBase = $(get-module bartender |sort-object -Property Version -Descending |Select-Object -First 1).moduleBase
            $readmeCopy = "$modulebase\resource\readme.md"
            if(test-path $readmeCopy)
            {
                if(!$(test-path $readmePath))
                {
                    #Always Copy
                    write-warning 'readme.md not found, copying from btmodule'
                    copy-item -Path $readmeCopy -Destination $readmePath -Force
                }elseIf($(get-content -path $readmePath).Length -le 30){
                    write-warning 'readme.md found, but length indicates not in use, copying from btModule'
                }else{
                    write-verbose 'readme.md found, length indicative file in use, will not copy from btModule'
                }
            }else{
                write-verbose 'Resource readme not found'
            }
            
        }else{
            throw 'This function should be called from other functions, use -force if you wish to proceed anyway'
        }     
        
        
    }
    
}

function get-btDocumentation
{
    <#
        .SYNOPSIS
            If you have platyPs on your system, extract the comment_based_help to markdown
            
        .DESCRIPTION
            Check if you have platyps
            If you have platyps:
             - launch the latest compiled version of the module in a scriptblock
             - Read the exported commands from the module manifest
             - Use platyPs to export the inline comment_based_help to MarkDown
            
             Markdown will be placed in the documentation folder under the respective version
             i.e. ..\documentation\1.0.0\my-function.ps1
            
        .PARAMETER path
            The path of your bartender module
            Defaults to current working directory
        
        .PARAMETER configFile
            The bartender configfile to use
            Defaults to btconfig.xml
            
        .EXAMPLE
            get-btDocumentation
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2018-05-17
            
            
            Changelog:
                2018-07-17 - AA
                    
                    - Attempted to only execute if there are functions to document
                2018-05-17 - AA
                    
                    - Initial Script
                    - Tested, working
                2019-01-30 - 2019-02-04 - AA
                    - Updated to use new folder path
                    - Code clean-up
                2019-03-07 - 2019-02-04 - AA
                    - Made a call to create md file for release notes
                    - Moved function help to a functions folder
                
                    
        .COMPONENT
            Bartender
        .INPUTS
           null
        .OUTPUTS
            null
        
    #>
    [CmdletBinding()]
    PARAM(
        [string]$path = (Get-Item -Path ".\").FullName,
        [string]$configFile = 'btconfig.xml'
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $$(MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $$($MyInvocation.BoundParameters|Out-String)"
        $invocationPath = $path
        $scriptVars = @{}
        $scriptVars.configFilePath = "$invocationPath\$($configFile)"
        $scriptVars.testsPath = "$invocationPath\source\pester"
        $throwExceptions = @{}
        #NoConfig
        $errCat = [System.Management.Automation.ErrorCategory]::InvalidData
        $errMsg = [System.Exception]::new("Config file was not found.`nUse new-btproject for a new project.")
        $throwExceptions.noConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        #BadConfig
        $errMsg = [System.Exception]::new('Config file contents unexpected or malformed.')
        $throwExceptions.badConfigError = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        $errMsg = [System.Exception]::new('PlatyPS module not installed on this system. Please install it for this feature')
        $throwExceptions.noPlatyPs = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
        $errMsg = [System.Exception]::new('Unable to compile Scriptblock')
        $throwExceptions.badScriptblock = [System.Management.Automation.ErrorRecord]::new($errMsg,1,$errCat,$scriptVars.configFile)
    }
    
    process{
        if(!$(test-path $scriptVars.configFilePath))
        {
            throw $throwExceptions.noConfigError
        }
        
        $scriptVars.config = Import-Clixml $scriptVars.configFilePath -ErrorAction Stop
        Write-Verbose "$($scriptvars.config|Out-String)"
        if(!$scriptVars.config.version -or !$scriptVars.config.moduleName -or !$scriptVars.config.moduleAuthor -or !$scriptVars.config.companyName)
        {
            throw $throwExceptions.badConfigError
        }else{
            write-verbose 'Configuring Params'
            $scriptVars.versionAsTag = $scriptVars.config.versionAsTag
            $scriptVars.moduleFolder = "$invocationPath\$($scriptVars.config.moduleName)\$($scriptVars.versionAsTag)"
            write-verbose 'Checking for PlatyPS'
            $scriptVars.platyPsModule = $(get-module -refresh -ListAvailable -Name platyPs |sort-object -Property Version -Descending |select-object -First 1)
            if(!$scriptVars.platyPsModule)
            {
                throw $throwExceptions.noPlatyPs
            }
            #import-module $scriptVars.platyPsModule
            #What do we need for this to work
            #The commands to get help for
            #The output folder
            #The imput folder
            write-verbose 'Constructing script-block text'
            $scriptVars.myTestBlock = "
                using module '$($scriptVars.moduleFolder)\'
                import-module PlatyPS
                `$moduleData = Import-PowerShellDataFile '$($scriptVars.moduleFolder)\$($scriptVars.config.moduleName).psd1'
                `$outputFolder = '$($invocationPath)\documentation\$($scriptVars.versionAsTag)\functions'
                if(!`$(test-path `$outputFolder))
                {
                    new-item -itemtype directory -path `$outputFolder
                }
                if(`$moduleData.FunctionsToExport.count -ge 1)
                {
                    foreach(`$function in `$moduleData.FunctionsToExport)
                    {
                        try{
                            new-markdownHelp -command `$function -outputfolder `$outputFolder -force
                        }catch{
                            write-warning unable to create help for `$function
                        }
                    }
                }else{
                    write-verbose 'No Functions to document'
                }
            "
            try{
                write-verbose 'Converting script block'
                $scriptBlock = [scriptblock]::Create($scriptVars.myTestBlock)
                write-verbose "ScriptBlock Contents:`n`n$($scriptVars.myTestBlock)"
            }catch{
                write-verbose "ScriptBlock Contents:`n`n$($scriptVars.myTestBlock)"
                throw $throwExceptions.badScriptblock
            }
            write-verbose 'Executing Scriptblock As Job'
            $job = start-job -ScriptBlock $scriptBlock 
            Wait-Job $job | Out-Null
            write-verbose 'Help should be created'
            write-verbose 'Creating release notes'
            $releaseNotesPath = "$($invocationPath)\documentation\$($scriptVars.versionAsTag)\release.md"
            try{
                get-btReleaseMarkdown|out-file $releaseNotesPath
                write-verbose 'release.md created'
            }catch{
                write-warning 'Error creating release notes'
            }
            try{
                update-btMarkdownHeader -path "$($invocationPath)"
                write-verbose 'Updated readme.md header if possible'
            }catch{
                write-warning 'Error updating readme.md'
            }
        }
    }
}

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

function get-btReleaseMarkdown
{
    <#
        .SYNOPSIS
            Create a markdown file of release notes from the last release
            
        .DESCRIPTION
            Uses the get-btChangeDetails to get the function files that have changed
            Tries to create a new release markdown file
            
        .PARAMETER modulePath
            Path to the module
        .PARAMETER configFile
            btConfig xml file
        .PARAMETER versionOverride
            Used to build based on a different version tag
            Generally used for debug only
            
        ------------
        .EXAMPLE
            get-btChangeDetails
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-06
            
            
            Changelog:
                2019-03-06 - AA
                    
                    - Initial Script
                2019-03-08 - AA
                    
                    - Fixed up some spelling mistakes
                    - Fixed the badges
                    - Added files
                    - Added ability to override version
                    - Added badge for commentBasedHelp
                    - Moved everything into a single hear-string
                    - Added a dumb way to close bracket for md link
                    - Fixed a bug where I was multiplying the length by a kb instead of dividing
                2019-03-08 - AA
                    - Reduced kb decimal places to 2
                    - Removed the dumb way to close bracket for md link
                    - Fixed the markdown link
                    - Changed the codeblocks to markdown tables
                    - Center aligned the top badges
                    - Moved the bartender badge to the right
                    - Fix the order of unmodified functions
                    - Fix the spacing around releaseNotes
                2019-03-11 - AA
                    - Changed to handle updated get-btChangeDetails script
                    
        .COMPONENT
            Bartender
    #>
    [CmdletBinding()]
    PARAM(
        [string]$modulePath = $(get-location).path,
        [string]$configFile = 'btConfig.xml',
        [version]$versionOverride
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
        write-verbose 'Getting config settings'
        $configSettings = import-clixml "$modulePath\$configFile"
        if(!$configSettings)
        {
            throw 'Unable to find config file'
        }
        write-verbose 'Loading manifest and getting version'
        $versionString = if($versionOverride){
            $versionOverride.ToString()
        }else{
            $configSettings.versionAsTag
        }
        $manifestPath = "$modulePath\$($configSettings.moduleName)\$versionString\$($configSettings.moduleName).psd1"
        $metadata = import-metadata -Path $manifestPath
        write-verbose 'Setting Git Details'
        $gitDetails = get-btGitDetails -modulePath $modulePath
        if($gitDetails)
        {
            write-verbose 'Adding Git Details'
            $branch = $($gitDetails.branch.replace('* ','').trim())
            $gitHt = @{
                branch = $branch
                origin = $gitDetails.origin
                commit = $gitDetails.commitShort
            }
            $gitMarkdown = "---`n## Git Details`n$(get-btMarkdownFromHashtable $gitHt)`n"
            
        }
        write-verbose 'Retrieving Change Details'
        $changeDetails = get-btChangeDetails -modulePath $modulePath -newRelease
        if($changeDetails)
        {
            write-verbose 'Creating Summary Block'
            $summaryMarkdown = "---`n## Changes Summary`n$(get-btMarkdownFromHashtable $changeDetails.summary)`n"
            write-verbose 'Creating Files Section' 
            $mdFileStringSelector = @{
                name = 'mdString'
                expression = {"|$($_.basename)|$($_.relativePath)|$($_.extension)|$([math]::round($($_.length / 1kb),2))|"}
            }
            $filesHeader = "|name|path|extension|size(kb)`n|----------------|--------------------------------|-----|-----|"
            $newFiles = $($changeDetails.files|where-object{$_.fileIsNew -eq $true}|select-object $mdFileStringSelector).mdString | out-string
            $unmodFiles = $($changeDetails.files|where-object{$_.fileIsModified -eq $false -and $_.fileIsNew -eq $false}|select-object $mdFileStringSelector).mdString | out-string
            $modFiles = $($changeDetails.files|where-object{$_.fileIsModified -eq $true -and $_.fileIsNew -eq $false}|select-object $mdFileStringSelector).mdString | out-string
            if($newFiles)
            {
                $newFilesMd = "#### New Files`n$filesHeader`n$newFiles`n"
            }
            if($modFiles)
            {
                $modFilesMd = "#### Modified Files`n$filesHeader`n$modFiles`n"
            }
            if($unmodFiles)
            {
                $unmodFilesMd = "#### Unchanged Files`n$filesHeader`n$unmodFiles`n"
            }
            $filesMarkdown = "---`n## File`n`n### Summary`n`n$(get-btMarkdownFromHashtable  $changeDetails.filesummary)`n`n### File List`n`n$newFilesMd`n$modFilesMd`n$unmodFilesMd`n"
            write-verbose 'Creating Functions Section' 
            $mdFunctionStringSelector = @{
                name = 'mdString'
                expression = {"|$($_.function)|$(if($_.folder -eq 'private'){"Private"}else{"Public"})|$(if($_.hasmarkdown){"[link](./functions/$($_.function).md)"})|$($_.relativePath)|"}
            }
            $functionsHeader = "|function|type|markdown link|filename|`n|-|-|-|-|"
            $newFuncs = $($changeDetails.functions|where-object{$_.fileIsNew -eq $true}|select-object $mdFunctionStringSelector).mdString | out-string
            $unmodFuncs = $($changeDetails.functions|where-object{$_.fileIsModified -eq $false -and $_.fileIsNew -eq $false}|select-object $mdFunctionStringSelector).mdString | out-string
            $modFuncs = $($changeDetails.functions|where-object{$_.fileIsModified -eq $true -and $_.fileIsNew -eq $false}|select-object $mdFunctionStringSelector).mdString | out-string
            if($newFuncs)
            {
                $newFuncsMd = "#### New Functions`n$functionsHeader`n$newFuncs"
            }
            if($modFuncs)
            {
                $modFuncsMd = "#### Modified Functions`n$functionsHeader`n$modFuncs"
            }
            if($unmodFuncs)
            {
                $unmodFuncsMd = "#### Unmodified Functions`n$functionsHeader`n$unmodFuncs"
            }
            $functionsMarkdown = "---`n## Functions`n`n### Summary`n`n$(get-btMarkdownFromHashtable $changeDetails.functionSummary)`n`n### Function List`n`n$newFuncsMd`n$modFuncsMd`n$unmodFuncsMd"
        }
        write-verbose 'Getting any Required Modules'
        $requiredModulesSelector = @{
            name = 'rmString'
            expression = {"|$($_.moduleName)|$($_.RequiredVersion)|"}
        }
        $modulesmd = $($($metadata.requiredModules|select-object $requiredModulesSelector).rmString|out-string)
        if($modulesmd)
        {
            $modulesMarkdown = "---`n## Required Modules`n|moduleName|requiredVersion|`n|-|-|`n$modulesmd`n"
        }
        
        write-verbose 'Getting Pester Details'
        if($metadata.privatedata.pester)
        {
            write-verbose 'Adding Pester Details'
            $pesterMarkdown = "---`n## Pester Details`n$(get-btMarkdownFromHashtable $metadata.privatedata.pester)`n"
            $badgeColor = switch ($($metadata.privatedata.pester.codecoverage)) {
                {$_ -le 20} {"red";break;}
                {$_ -le 40} {"orange";break;}
                {$_ -le 60} {"yellow"; break;}
                {$_ -le 75} {"yellowgreen"; break;}
                {$_ -le 90} {"green"; break;}
                {$_ -le 100} {"brightgreen"; break;}
                default {"lightgrey"; break;}
            }
            $pesterBadge = "[pesterbadge]: https://img.shields.io/static/v1.svg?label=pester&message=$($metadata.privatedata.pester.codecoverage)&color=$badgeColor"
        }else{
            $pesterMarkdown = $null
            $pesterBadge = '[pesterbadge]: https://img.shields.io/static/v1.svg?label=pester&message=na&color=lightgrey'
        }
        write-verbose 'Generating GIT Badges'
        $btbadge = "[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=$($metadata.PrivateData.bartenderVersion)&color=0B2047"
        $releaseBadge = "[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=$($metadata.moduleVersion)&color=blue"
        $commentBasedHelpCoverage = $changeDetails.summary.commentBasedHelpCoverage
        if(!$commentBasedHelpCoverage)
        {
            $commentBasedHelpCoverage = 'na'
        }
        $badgeColor = switch ($commentBasedHelpCoverage) {
            {$_ -le 20} {"red";break;}
            {$_ -le 40} {"orange";break;}
            {$_ -le 60} {"yellow"; break;}
            {$_ -le 75} {"yellowgreen"; break;}
            {$_ -le 90} {"green"; break;}
            {$_ -le 100} {"brightgreen"; break;}
            default {"lightgrey"; break;}
        }
        $helpCoverage = "[helpcoveragebadge]: https://img.shields.io/static/v1.svg?label=get-help&message=$commentBasedHelpCoverage&color=$badgeColor"
        
        
        write-verbose 'Creating Overview'
        $overviewHt = @{
            BuildDate = $($metaData.privatedata.builtOn)
            'Author(s)' = $($metaData.author)
            BuildUser = $($metaData.privateData.builtBy)
            Company = $($metaData.CompanyName)
        }
        $overviewMarkdown = "## Overview`n$(get-btMarkdownFromHashtable $overviewHt)`n"
        write-verbose 'Generating Final Markdown'
        #Still hate herestring and how it deals with tabs
        
        $markdown = @"
# $($configSettings.moduleName) - Release $versionString
| Version | Code Coverage | Code Based Help Coverage |Bartender Version|
|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
|![releasebadge]|![pesterbadge]|![helpcoveragebadge]|![btbadge]|
$overviewMarkdown
`n
$(
    if($metadata.privatedata.psdata.releasenotes)
    {
        "### Release Notes:`n`n$($metadata.privatedata.psdata.releasenotes)`n`n"
    }
)
`n
$summaryMarkdown
`n
$filesMarkdown
`n
$functionsMarkdown
`n
$modulesMarkdown
`n
$pesterMarkdown
`n
$gitMarkdown
`n
$pesterbadge
$btbadge
$releaseBadge
$helpCoverage
"@
        $markdown
        
    }
    
    
}

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

function get-btStringComparison
{
    <#
        .SYNOPSIS
            Make a comparison between two strings
            See how many characters are the same by counting them up
        .DESCRIPTION
            Compare String1 to String2
            Group each string by the number of characters
            Compare the comparison
            Work out how similar the character composition is of both strings
            
            Works with the group-object function
            As such, provides a very efficient way of comparing string similarity
            It can compare two files of ~ 200,000 chars each, in about 6 seconds
            
        .PARAMETER string1
            the first string to compare
        .PARAMETER string2
            the second string to compare
        .EXAMPLE
            get-btStringComparison -string1 $(get-content $file1) -string2 $(get-content $file2)
            
        #### DESCRIPTION
            Find out how similar two files are
            
            
        #### OUTPUT
            Copy of the output of this line
            
            
        .OUTPUTS
            TotalChars1 TotalChars2 Difference DiffPercent
            ----------- ----------- ---------- -----------
                210269      210269          0           0
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-11
            
            
            Changelog:
                2019-03-11 - AA
                    - Changed Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$string1,
        [ValidateNotNullOrEmpty()]
        [string]$string2
    )
    $length1 = $string1.Length
    $length2 = $string2.Length
    $charArr1 = $string1.ToCharArray()
    $charArr2 = $string2.ToCharArray()
    $charArrU = $charArr1 + $charArr2 |Select-object -Unique
    $summary1 = $charArr1|group-object|select-object name,count
    $summary2 = $charArr2|group-object|select-object name,count
    $summaryAll = foreach($char in $charArrU)
    {
        $c1 = $($summary1|where-object {$_.name -eq $char}).Count
        $c2 = $($summary2|where-object {$_.name -eq $char}).Count
        $diff = $c2 - $c1
        if($diff -lt 0)
        {
            #FlipToPos
            $diff = $diff * -1
        }
        [psCustomObject]@{
            char = $char
            count1 = $c1
            count2 = $c2
            diff = $diff
        }
    }
    $totals = [pscustomobject]@{
        TotalChars1 = $length1
        TotalChars2 = $length2
        Difference = $($summaryAll.diff|measure-object -sum).Sum
        DiffPercent = [math]::round($($($summaryAll.diff|measure-object -sum).Sum / $(@($length1,$lenght2)|measure-object -maximum).Maximum)*100,2)
    }
    $totals
    
}

function start-btRevisionCleanup
{
    <#
        .SYNOPSIS
            Clean-up bt revisions folder
            
        .DESCRIPTION
            Remove any previous revisions to try and keep the size down
            By default keep the last 5
            
            
        .PARAMETER path
            The path of your bartender module
            Defaults to current working directory
        
        .EXAMPLE
            start-btRevisionCleanup
            
            #### DESCRIPTION
            Remove previous revisions
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-12-03
            
            
            Changelog:
                2019-01-30
                    
                    - Initial Script
                    - Now we are dealing with revisions, we need a way to not keep creeping the revisions up
                    
         .COMPONENT
            Bartender
        .INPUTS
           null
        .OUTPUTS
            custom object
    #>
    [CmdletBinding()]
    PARAM(
        [string]$path = (Get-Item -Path ".\").FullName,
        [string]$configFile = 'btconfig.xml',
        [int]$revisions
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        $defaultRevisions = 5
        $invocationPath = $path
        $scriptVars = @{}
        $scriptVars.configFilePath = "$invocationPath\$($configFile)"
        $scriptVars.revisionPath = "$invocationPath\rev" 
        
    }
    
    process{
        $scriptVars.config = Import-Clixml $scriptVars.configFilePath -ErrorAction Stop
        Write-Verbose "$($scriptvars.config|Out-String)"
        if(!$scriptVars.config.version -or !$scriptVars.config.moduleName -or !$scriptVars.config.moduleAuthor -or !$scriptVars.config.companyName)
        {
            throw "Config file was not found.`nUse new-btproject for a new project."
        }
        
        if($revisions -ge 1)
        {
            write-verbose 'Using revision param count'
        }else{
            write-verbose 'Reading revision count from config'
            $revisions = $scriptVars.config.revisionCount
            if(!$revisions)
            {
                write-verbose "Revision count not found, using default of $defaultRevisions"
                $revisions = $defaultRevisions
                try{
                    $scriptVars.config.revisionCount = $defaultRevisions
                }catch{
                    $scriptVars.config|add-member -MemberType NoteProperty -Name revisionCount -Value $defaultRevisions
                }
                
                write-verbose 'Saving default to config file'
                Export-Clixml -Path $scriptVars.configFilePath -InputObject $scriptVars.config
                write-verbose 'Config file updated'
            }
        }
        if(!$revisions)
        {
            throw 'Something wrong with Revision counter'
        }
        write-verbose "Revisions set to: $revisions"
        #If we parse a version from the name, then we can sort properly
        #That way if the dates are all strange from a git view, it wont matter
        #And name itself might be odd, consider version 1.1,10.1,2.1,20.1 and the order that would be in
        $versionSelect = @{
            name ='version'
            expression = {[version]::Parse($($_.name))}
        }
        write-verbose 'Getting revisions'
        #Use * so we can still pipe it to remove-item
        $childItems = get-childItem $scriptVars.revisionPath|select-object *,$versionSelect|where-object{$null -ne $_.version}
        $currentCount = $($childItems|measure-object).count
        $removeCount = $currentCount - $revisions
        if($removeCount -ge 1)
        {
            write-verbose "Need to remove $removeCount versions"
            $childItems|sort-object -property version|select-object -first $removeCount|remove-item -Force -Recurse
        }else{
            write-verbose 'No revisions to remove'
        } 
    }
    
}

function update-btMarkdownHeader
{
    <#
        .SYNOPSIS
            Update the top of a markdown file
            
        .DESCRIPTION
            Update the top of a markdown file
            Executes on build to add appropriate info to the header section
            Will also update the name and description
            
        .PARAMETER path
            Path to the module
        .PARAMETER configFile
            btConfig file
        .PARAMETER markdownFile
            Markdown file name
            
        ------------
        .EXAMPLE
            update-btMarkdownHeader
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-10 - AA
                    
                    - Initial Script
                    - Updated start-btBuild to get release data
                2019-03-11 - AA
                    - Fixed the icon missing
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    PARAM(
        [string]$path = (Get-Item -Path ".\").FullName,
        [string]$configFile = 'btconfig.xml',
        [string]$markdownFile = 'readme.md'
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
        $configFilePath = "$path\$($configFile)"
        $markdownFilePath = "$path\$($markdownFile)"
        $headerMatch = '<!--Bartender Dynamic Header -- Code Below Here -->'
        
    }
    
    process{
        write-verbose 'Importing config'
        if(!$(test-path $configFilePath))
        {
            throw "$configFile not found"
        }
        $config = import-clixml $configFilePath
        if(!(test-path $markdownFilePath))
        {
            throw "$markdownfile not found"
        }
        write-verbose 'Importing existing markdown'
        $content = get-content $markdownFilePath
        if($config.lastrelease.version)
        {
            $versionTag = $config.lastrelease.version.tostring(3)
            $releaseDate = get-date $config.lastRelease.date -Format yyyy-MM-dd
            
        }else{
            $versionTag = 'na'
            $releaseDate = 'na'
        }
        if(test-path "$path\documentation\$versionTag\release.md")
        {
            $latestReleaseLink = "Latest Release Notes: [here](./documentation/$versionTag/release.md)"
        }else{
            $latestReleaseLink = $null
        }
        write-verbose 'Creating Shield Badges'
        $badges = @{
            releasebadge = "[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=$versionTag&color=blue"
            datebadge = "[datebadge]: https://img.shields.io/static/v1.svg?label=Date&message=$releaseDate&color=yellow"
            powershellBadge = "[psbadge]: https://img.shields.io/static/v1.svg?label=PowerShell&message=$($config.minimumPsVersion.ToString(3))&color=5391FE&logo=powershell"
            btBadge = "[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=$($config.bartenderVersion.toString())&color=0B2047"
        }
        write-verbose 'Generating new Markdown'
        $headerArr = @(
            "# $($config.modulename.toUpper())",
            "$(if(test-path "$path\icon.png"){'![logo](./icon.png)'})",
            "",
            "> $($config.moduleDescription)",
            "",
            "$($badges.releasebadge)",
            "$($badges.datebadge)",
            "$($badges.powershellBadge)",
            "$($badges.btBadge)",
            '',
            '',
            "| Language | Release Version | Release Date | Bartender Version |",
            "|:-------------------:|:-------------------:|:-------------------:|:-------------------:|",
            "|![psbadge]|![releasebadge]|![datebadge]|![btbadge]|"
            '',
            '',
            "Authors: $($config.moduleAuthor -join ',')",
            '',
            "$(if($config.companyName){"Company: $($config.companyName)"})",
            '',
            "$latestReleaseLink",
            '',
            '***',
            ''
        )
        write-verbose 'Checking for header marker for markdown entry point'
        $i = 0
        $contentLines = $content.count
        $lineMatch = -1
        while($i -lt $contentLines -and $lineMatch -lt 0)
        {
            if($content[$i] -eq $headerMatch)
            {
                $lineMatch = $i
            }
            $i++
        }
        if($lineMatch -gt 0)
        {
            write-verbose "Found line at $lineMatch"
            $remainder = $content[$lineMatch..$contentLines]
            $newContent = $headerArr + $remainder
            $contentMarkdown = $newContent -join "`n"
            if($contentMarkdown)
            {
                write-verbose 'Exporting updated markdown file'
                $contentMarkdown|out-file $markdownFilePath
            }
        }
    }
    
}

