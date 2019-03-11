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