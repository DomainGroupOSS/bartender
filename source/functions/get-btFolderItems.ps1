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
        write-verbose "===========Executing $$(MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $$($MyInvocation.BoundParameters|Out-String)"
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
                Write-warning 'Unable to verify destination folder - using assigned variable as path '
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