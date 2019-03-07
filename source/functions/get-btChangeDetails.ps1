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
            
        .PARAMETER module
            What is it, why do you want it
            
        ------------
        .EXAMPLE
            get-btChangeDetails
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-06
            
            
            Changelog:
                2019-03-06 - AA
                    
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [string]$modulePath = $(get-location).path,
        [string[]]$functionFolders = @('functions','private'),
        [string]$configFile = 'btConfig.xml',
        [switch]$ignoreLast
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

        $sourcePath = get-item "$modulePath\source"

        

        
        
    }
    
    process{

        write-verbose 'Getting config settings'
        $configSettings = import-clixml "$modulePath\$configFile"
        if(!$configSettings)
        {
            throw 'Unable to find config file'
        }

        write-verbose 'Getting release details'
        $versionSelect = @{
            name = 'version'
            expression = {[version]$_.name}
        }
        

        $releasePath = "$modulePath\$($configSettings.moduleName)"
        write-verbose "Using ReleasePath: $releasePath"


        if($ignoreLast)
        {
            write-verbose 'Getting last 2 releases'
            $releases = get-childitem $releasePath|select-object $versionSelect,lastWriteTime|sort-object version -Descending|select-object -First 2
            

            write-verbose 'Filtering out last release'
            if($($releases|measure-object).count -ne 2)
            {
                write-warning 'Releases not found or no previous releases'
                return $null
            }

            $release = $releases|sort-object -Property version|select-object -First 1

        }else{
            write-verbose 'getting single release'
            $release = get-childitem $releasePath|select-object $versionSelect,lastWriteTime|sort-object version -Descending|select-object -First 1
            write-verbose 'Checking relesae count'
            if($($release|measure-object ).count -ne 1)
            {
                write-warning 'Releases not found or no previous releases'
                return $null
            }

        }

        


        $previousReleaseDate = $release.lastWriteTime
 
        write-verbose "LastModuleTime: $previousReleaseDate"
        if(!$previousReleaseDate)
        {
            throw 'Unable to read previous release time'
        }

        
        
        write-verbose 'Getting prevous release lastModifiedDate'
        
        write-verbose 'Validating path'
        if(!$(test-path $modulePath) -or !$(test-path $sourcePath))
        {
            throw 'modulePath invalid'
        }

        write-verbose 'Getting prevous release lastModifiedDate'


        foreach($folder in $functionFolders)
        {
            write-verbose "Checking folder: $folder"
            $folderPath = "$sourcePath\$folder"
            write-verbose "FullPath: $folderPath"
            if(!(test-path $folderPath))
            {
                throw "function path for $folder folder invalid"
            }

            $folderScripts = get-btFolderItems -path $folderPath
            foreach($file in $folderScripts)
            {
                write-verbose "Checking file: $($file.path)"
                $fileFunctions = get-btScriptFunctions -path $($file.path)
                write-verbose "Got Functions"
                foreach($function in $fileFunctions)
                {
                    $fileItem = get-item $($file.path)
                    $fileIsNew = if($fileItem.CreationTime -gt $previousReleaseDate){$true}else{$false}
                    $fileIsModified = if($fileItem.LastWriteTime -gt $previousReleaseDate){$true}else{$false}
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
                    }
                }
            }
        }        
    }
    
    
}