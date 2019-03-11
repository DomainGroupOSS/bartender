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