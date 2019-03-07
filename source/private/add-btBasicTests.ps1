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