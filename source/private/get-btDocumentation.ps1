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