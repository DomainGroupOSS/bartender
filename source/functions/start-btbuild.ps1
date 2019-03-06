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
        #$btmodule = get-module -ListAvailable -Refresh -Name bartender |sort-object version -Descending|Select-Object -First 1
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

        #$scriptVars.preloadFile = "$($scriptVars.moduleOutputFolder)\preload.ps1"
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

        #PostBuildScripts go here
        $postBuildScripts = get-btFolderItems -psScriptsOnly -Path "$invocationPath\postbuildscripts"
        write-debug 'Execute postbuild scripts'
        foreach($postbuildscript in $postbuildscripts)
        {
            write-verbose "Executing postbuild script $($postbuildscript.relativepath)"
            . $postBuildScripts.Path
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

                    <#
                    #New mm the correct way
                    #Issue with this way is
                    #What if the module was changed with a postbuild script?
                    #So this is not ideal
                    
                    $splatManifest.path = "$($scriptVars.releaseDirectory)\$($scriptVars.config.moduleName).psd1"
                    $splatManifest.ModuleVersion = $scriptVars.newVersionAsTag
                    remove-item "$($scriptVars.releaseDirectory)\$($scriptVars.config.moduleName).psd1" -Force -ErrorAction Ignore
                    New-ModuleManifest @splatManifest
                    #>
                    
                    <#
                    #Find and replace method
                    #Issue with this is it doesnt seem very clean
                    #Also, what happens if there is a superfluous space or something
                    
                    
                    #New mm the gc way

                    $scriptVars.newManifestPath = "$($scriptVars.releaseDirectory)\$($scriptVars.config.moduleName).psd1"
                    $scriptVars.newManifest = get-content $scriptVars.newManifestPath
                    $scriptVars.newManifest = $scriptVars.newManifest.replace("ModuleVersion = '$($scriptvars.versionAsTag)'","ModuleVersion = '$($scriptVars.newVersionAsTag)'")
                    $scriptVars.newManifest|out-file $scriptVars.newManifestPath

                    #>

                    <#
                    #Use Configuration Module method
                    #Only downside I can think of is that it requires the config module to be available
                    #We should just make them a requirement
                    #Along with Pester and PlatyPS
                    
                    
                    #>
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
                        $metadata.privatedata.pester.codecoverage = "$codeCoverage %"
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