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