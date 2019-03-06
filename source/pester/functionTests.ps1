$btTestModuleName = 'btTestModule'
$btTestRepoName = 'btTestRepo'
$btTestFolder = "$($env:temp)\$btTestModuleName"
if(test-path $btTestFolder)
{
    remove-item -Force -Path $btTestFolder -Confirm:$false -Recurse |out-null
}


new-item -ItemType Directory -Path $btTestFolder -Force |out-null
#Use this to ensure we get rid of any special characters, concatinating etc
#Because the environment variable makes the temp folder cmd prompt safe, but PS doesnt need that
$btTestPath = "$($(get-item $btTestFolder).fullname)"
set-location $btTestPath

describe 'Check Test Folder' {
    context 'Temp build folder' {
        it "should be $btTestPath" {
            $(get-location).path | Should -Be $btTestPath
        }
        it 'Should be Empty' {
            $(get-childitem $btTestPath) |Should -be $null
        }
    }
}

$prevWarningPref = $WarningPreference
$WarningPreference = 'SilentlyContinue'

describe 'Warning Preference' {
    it 'Should be Silent' {
        $WarningPreference |Should -be 'SilentlyContinue'
    }

}



#Lets make a temporary repository

$repositoryFolder  = "$btTestPath\testRepository"
new-item -ItemType Directory -Path $repositoryFolder -Force |Out-Null
$btTestRepo = $(get-psrepository -name $btTestRepoName -ErrorAction Ignore)
if($btTestRepo)
{
    #Remove the old repository, make sure that the path is correct
    Unregister-PSRepository -name $btTestRepoName
}

register-psrepository -name $btTestRepoName -SourceLocation $repositoryFolder -PublishLocation $repositoryFolder -InstallationPolicy Trusted



describe 'Check PowerShellGet on this machine, make a test repository' {
    context 'Check test repsitory exists' {
        $btTestRepo = $(get-psrepository -name $btTestRepoName -ErrorAction Ignore)
        it 'repository should not be null' {
            $btTestRepo |should -not -be  $null
        }
        it 'repository should have correct paths' {
            $btTestRepo.PublishLocation |should -be $repositoryFolder
            $btTestRepo.SourceLocation |should -be $repositoryFolder
        }
        it 'Should be trusted'{
            $btTestRepo.Trusted |Should -be $true
        }
        it 'Should have an empty repository' {
            $moduleList = find-module -Repository $btTestRepoName -ErrorAction SilentlyContinue
            $moduleList | should -be $null
            $($moduleList|measure-object).count | Should -be 0
        }

    }

}

#Ensure we have them cleared from our saved repo as well

describe 'Save and retrieve btRepository settings' {
    context 'Save repository' {
        try{
            save-btRepository -repository $btTestRepoName -token 'NotAToken' -errorAction stop
            $savedRepo = $true
        }catch{
            $savedRepo = $false
        }
        
        
        it 'Should have saved a repo' {
            $savedRepo| should -be $true
    
        }
    }

    context 'Retrieve Repository' {
        $savedRepository = get-btRepository $btTestRepoName
        
        it 'Should have returned a hashtable' {
            $savedRepository.getType().Name |should -be 'Hashtable'

        }

        it 'Should have set the correct token' {
            $savedRepository.nugetApiKey |should -be 'NotAToken'
        }
    }

    context 'Retrieve Repository' {
        $savedRepository = get-btRepository $btTestRepoName
        
        it 'Should have returned a hashtable' {
            $savedRepository.getType().Name |should -be 'Hashtable'

        }

        it 'Should have set the correct token' {
            $savedRepository.nugetApiKey |should -be 'NotAToken'
        }
    }
    
    context 'Update Token' {
        try{
            save-btRepository -repository $btTestRepoName -token 'StillNotAToken' -update -errorAction stop 
            $savedRepo = $true
        }catch{
            $savedRepo = $false
        }
        
        
        it 'Should have saved a repo' {
            $savedRepo| should -be $true
    
        }
    }

    context 'Should retrieve appropriate updates' {
        $savedRepository = get-btRepository $btTestRepoName
        
        it 'Should have returned a hashtable' {
            $savedRepository.getType().Name |should -be 'Hashtable'

        }

        it 'Should have set the correct token' {
            $savedRepository.nugetApiKey |should -be 'StillNotAToken'
        }
    }
}

$oldSettings = get-btDefaultSettings
describe 'Save/Retrieve btUser Defaults' {
    #This is tricky because we do not really want to overwrite the existing settings
    

    context 'Save settings with publishBuild set to true' {

    
        try{
            save-btDefaultSettings -update -publishOnBuild $true
            $savedSettings = $true
        }catch{
            $savedSettings = $false
        }

        it 'Should have saved settings without error' {
            $savedSettings| should -be $true

        }

    }

    context 'Should have set publishBuilt to true' {
        $savedDefaults = get-btDefaultSettings
        it 'Should have set publishOnBuild to True' {
            $savedDefaults.publishOnBuild |should -be $true
        }
    }

    context 'Should update publishBuilt to false' {
        try{
            save-btDefaultSettings -update -publishOnBuild $false
            $savedSettings = $true
        }catch{
            $savedSettings = $false
        }

        it 'Should have saved settings without error' {
            $savedSettings| should -be $true
        }


        $savedDefaults = get-btDefaultSettings
        it 'Should have set publishOnBuild to False' {
            $savedDefaults.publishOnBuild |should -be $false
        }
    }
}


describe 'New BT Project' {
    context 'Create new Project' {
        new-btProject -moduleName $btTestModuleName -moduleDescription $btTestModuleName -repository $btTestRepoName -publishOnBuild $false -companyName 'BartenderTest'
        it 'Should create a new project - including the btConfig.xml' {
            test-path "$btTestPath\btconfig.xml" | Should -Be $true
        }
        it 'Should have created a source folder' {
            test-path "$btTestPath\source" | Should -Be $true
        }
        it 'Should have created a rev folder' {
            test-path "$btTestPath\rev" | Should -Be $true
        }
        it 'Should have created a functions folder' {
            test-path "$btTestPath\source\functions" | Should -Be $true
        }
        it 'Should not have created a bin folder' {
            test-path "$btTestPath\bin" | Should -not -Be $true
        }
    }
}

describe 'Remove Functions Folder' {
    context 'Remove the functions folder' {
        remove-item -Path "$btTestPath\source\functions" -Force -Recurse -Confirm:$false
        it 'Should have removed the functions folder' {
            test-path "$btTestPath\source\functions" | Should -Be $false
        }
    }
}

describe 'Update BT Project' {
    context 'It should run the update-btFileStructure function' {
        try {
            update-btFileStructure -force -path $btTestPath 
            $errorSeen = $false
        }catch{
            $errorSeen = $true
        }
        
        it 'Should run without errors'{ 
            $ErrorSeen | Should -Be $false
        }
         
    }
}

describe 'Check BTProject updated' {
    context 'Check the update-btFileStructure replaces missing folder' {

        it 'Should have recreated the functions folder and base files' {
            "$btTestPath\source\functions" | Should -Exist
        }
    }
    context 'Getting the folder as a secondary test' {
        $folderItem = get-item "$btTestPath\source\functions"
        it 'Should have a folder here' {
            $folderItem.psiscontainer | Should -Be $true
        }
    }
}

if(! $(test-path "$btTestPath\source\functions"))
{
    new-item -ItemType Directory -Path "$btTestPath\source\functions" -Force |out-null
}

$helloWorld = "
function get-helloWorld
{
    <#
        .SYNOPSIS
            Test function
            
        .DESCRIPTION
            Test function
            
        .PARAMETER name
            Name to say hi to

        .EXAMPLE
            get-helloWorld

        .NOTES
            Author: Pester Tester

        .COMPONENT
            PesterTester
    #>

    [CmdletBinding()]
    PARAM(
        [string]`$name = 'world'
    )
    return `"hello `$name`"
}
"

$goodbyeWorld = "
function get-goodbyeWorld
{
    <#
    .SYNOPSIS
        Test function
        
    .DESCRIPTION
        Test function
        
    .PARAMETER name
        Name to say hi to

    .EXAMPLE
        get-goodbyeWorld james

    .NOTES
        Author: Pester Tester

    .COMPONENT
        PesterTester
    #>

    [CmdletBinding()]
    PARAM(
        [string]`$name = 'world'
    )
    return `"goodbye `$name`"
}
"
'not a PS1 file'|out-file -FilePath "$btTestPath\source\functions\notPowerShell.txt" |out-null
$helloWorld | out-file -FilePath "$btTestPath\source\functions\helloworld.ps1" |out-null
$goodbyeWorld | out-file -FilePath "$btTestPath\source\functions\goodbyeWorld.ps1" |out-null

#Make a postbuildscript
$postBuild = @"
write-verbose 'Creating test file'
`$testPath = "`$(`$scriptVars.moduleOutputFolder)\test.txt"
write-verbose "TestPath: `$testpath"
'some text'|out-file `$testpath -Force
"@

$postBuild | out-file -FilePath "$btTestPath\postbuildscripts\test.ps1"


#Finish making function files, back to testing

describe 'Create test Scripts' {
    context 'Our test functions should have been created' {
        it 'Should have created the helloWorld script' {
            test-path "$btTestPath\source\functions\helloworld.ps1" | Should -Be $true
        }
        it 'Should have created the goodbyeWorld script' {
            test-path "$btTestPath\source\functions\goodbyeWorld.ps1" | Should -Be $true
        }
        it 'Should have created the notPowerShell text file' {
            test-path "$btTestPath\source\functions\notPowershell.txt" | Should -Be $true
        }
    }
}

describe 'Create postbuildscript example' {
    context 'Our postbuildscript should have been created' {
        it 'Should have created test.ps1' {
            test-path "$btTestPath\postbuildscripts\test.ps1" | should -be $true
        }
    }
}

describe 'Test get-folderItems and get-btScriptText' {
    #Basic Tests
    context 'Basic get-folderItems test' {
        $testFolderItems = $(get-btFolderItems -Path "$btTestPath\source\functions\") #Deliberately with extra slash
        it 'Should get the hello World script' {
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\helloworld.ps1"
        }
        it 'Should get the goodbye World script' {
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\goodbyeWorld.ps1"
        }
        it 'Should get the notPowershell text file' {
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\notPowershell.txt"
        }
    }

    context 'Test btIgnore' {
        '.\helloWorld.ps1' | out-file "$btTestPath\source\functions\.btIgnore" |out-null
        it 'Should now have helloworld in the btIgnore file' {
            $(get-content "$btTestPath\source\functions\.btIgnore")| Should -be '.\helloWorld.ps1'
        }
        remove-variable testfolderitems -ErrorAction ignore -Force |Out-Null #Ensure we dont have the old var still
        $testFolderItems = $(get-btFolderItems -Path "$btTestPath\source\functions") #Deliberately without extra slash
        it 'Should now exclude Hello World' {
            $testFolderItems.Path | Should -not -Contain "$btTestPath\source\functions\helloworld.ps1"
        }
        it 'Should still include the goodbye World script and the notPowershell text file' {
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\goodbyeWorld.ps1"
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\notPowershell.txt"
        }
        #Check the orderStart file and reset ignore
        $null| out-file "$btTestPath\source\functions\.btIgnore" |out-null
    }

    context 'Undo btIgnore, check scriptsOnly switch and btOrderStart' {
        '.\helloWorld.ps1' | out-file "$btTestPath\source\functions\.btOrderStart" |out-null
        remove-variable testfolderitems -ErrorAction ignore -Force |Out-Null #Ensure we dont have the old var still
        $testFolderItems = $(get-btFolderItems -Path "$btTestPath\source\functions\" -psScriptsOnly)
        it 'Should contain the hello World  and goodbye world scripts once again' {
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\helloworld.ps1"
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\goodbyeWorld.ps1"
        }
        it 'Should have excluded the notPowershell text file as it is not a script' {
            $testFolderItems.Path | Should -not -Contain "$btTestPath\source\functions\notPowershell.txt"
        }
        it 'Should now have helloworld in the btOrderStart file' {
            $(get-content "$btTestPath\source\functions\.btOrderStart")| Should -be '.\helloWorld.ps1'
        }
        it 'Should have helloWorld script as the first item' {
            $testFolderItems.Path[0] | should -be "$btTestPath\source\functions\helloworld.ps1"
        }
        $null| out-file "$btTestPath\source\functions\.btOrderStart" |out-null
    }

    context 'check the btOderEnd' {
        '.\goodbyeWorld.ps1' | out-file "$btTestPath\source\functions\.btOrderEnd" |out-null
        remove-variable testfolderitems -ErrorAction ignore -Force |Out-Null #Ensure we dont have the old var still
        $testFolderItems = $(get-btFolderItems -Path "$btTestPath\source\functions" -psScriptsOnly)
        it 'Should contain the hello World  and goodbye world scripts once again' {
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\helloworld.ps1"
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\goodbyeWorld.ps1"
        }
        it 'Should have excluded the notPowershell text file as it is not a script' {
            $testFolderItems.Path | Should -not -Contain "$btTestPath\source\functions\notPowershell.txt"
        }
        it 'Should now have goodbyeWorld in the btOrderEnd file' {
            $(get-content "$btTestPath\source\functions\.btOrderEnd")| Should -be '.\goodbyeWorld.ps1'
        }
        it 'Should have helloWorld script as the first item still' {
            $testFolderItems.Path[0] | should -be "$btTestPath\source\functions\helloworld.ps1"
        }
        it 'Should have an itemcount of 2' {
            $testFolderItems.Path.count | should -be 2
        }
    }

    context 'Check btOrderStart and btOrderEnd together' {
        '.\goodbyeWorld.ps1' | out-file "$btTestPath\source\functions\.btOrderStart" |out-null
        remove-variable testfolderitems -ErrorAction ignore -Force |Out-Null #Ensure we dont have the old var still
        $testFolderItems = $(get-btFolderItems -Path "$btTestPath\source\functions\" -psScriptsOnly)
        it 'Should contain the hello World  and goodbye world scripts once again' {
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\helloworld.ps1"
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\goodbyeWorld.ps1"
        }
        it 'Should have excluded the notPowershell text file as it is not a script' {
            $testFolderItems.Path | Should -not -Contain "$btTestPath\source\functions\notPowershell.txt"
        }
        it 'Should have an itemcount of 3 as goodByeWorld will be in there twice' {
            $testFolderItems.Path.count | should -be 3
        }
        it 'Should have goodbyeworld script as the first item now' {
            $testFolderItems.Path[0] | should -be "$btTestPath\source\functions\goodbyeworld.ps1"
        }
        it 'Should have goodbyeworld script as the last item as well' {
            $testFolderItems.Path[-1] | should -be "$btTestPath\source\functions\goodbyeworld.ps1"
        }

        $null| out-file "$btTestPath\source\functions\.btOrderStart" |out-null
        $null| out-file "$btTestPath\source\functions\.btOrderEnd" |out-null
        it 'Should have an itemcount of 2 again' {
            $testFolderItems.Path.count | should -be 3
        }
        it 'Should contain the hello World  and goodbye world scripts once again' {
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\helloworld.ps1"
            $testFolderItems.Path | Should -Contain "$btTestPath\source\functions\goodbyeWorld.ps1"
        }
    }

    context 'Get clean folder items, check get-btScriptText' {
        remove-variable testfolderitems -ErrorAction ignore -Force |Out-Null #Ensure we dont have the old var still
        $testFolderItems = $(get-btFolderItems -Path "$btTestPath\source\functions\" -psScriptsOnly)
        $testScriptText = get-btScriptText $testFolderItems.path -isFunction 1
        it 'Should have added the helloworld and goodbyeworld to the testScriptText functionResources array' {
            $testScriptText.functionResources |Should -contain 'get-helloWorld'
            $testScriptText.functionResources |Should -contain 'get-goodbyeworld'
        }
    
        it 'Should have the _function_ keyword on the second line' {
            $testScriptText.output.Substring(1,8) |Should -be 'function'
        }
    }
}

#Test the revision
$contextVer = '1.0.0.1'
$contextFolder = "$btTestPath\rev\$contextVer"
describe 'Test start-btBuild revision version' {
    $build = start-btbuild -ignoreBtVersion -WarningAction SilentlyContinue
    context 'Check Build Return Object'{
        it 'Should return a single custom object' {
            $build.getType().Name |should -be 'PSCustomObject'
            $build.getType().BaseType |Should -be 'System.Object'
        }
        
    }
    context 'Check Pester Results' {
        it 'Should have passed building' {
            $build.success |should -be $true
        }
        it 'Should have no pesterFails' {
            $build.pesterFails | Should -be $null
        }
    }
    context 'Check rev folder' {
        it 'Should have a version folder' {
            test-path "$contextFolder" | Should -be $true
        }
        it 'Should have a module manifest' {
            test-path "$contextFolder\$btTestModuleName.psd1" | Should -be $true
        }
        it 'Should have a module file' {
            test-path "$contextFolder\$btTestModuleName.psm1" | Should -be $true
        }
        
    }
    context 'Ensure was not published' {
        it 'Should have an empty repository' {
            $moduleList = find-module -Repository $btTestRepoName -ErrorAction SilentlyContinue
            $moduleList | should -be $null
            $($moduleList|measure-object).count | Should -be 0
        }
    }

    context 'Should have executed our postbuildScript'{
        it 'Should have made a test.txt file' {
            test-path "$contextFolder\test.txt" | Should -be $true
        }
        it 'test.txt Should have contents of "some text"' {
            get-content "$contextFolder\test.txt" | Should -be 'some text'
        }
    }
}

$contextVer = '1.0.1'
$contextFolder = "$btTestPath\$btTestModuleName\$contextVer"
describe "Test start-btBuild build to $contextFolder" {
    

    $build = start-btbuild -ignoreBtVersion -incrementBuildVersion -WarningAction SilentlyContinue
    $lastPesterResult|export-clixml c:\temp\lastPesterResult.xml
    context 'Check Build Return Object'{
        it 'Should return a single custom object' {
            $build.getType().Name |should -be 'PSCustomObject'
            $build.getType().BaseType |Should -be 'System.Object'
        }
        
    }
    context 'Check Pester Results' {
        it 'Should have passed building' {
            $build.success |should -be $true
        }
        it 'Should have no pesterFails' {
            $build.pesterFails | Should -be $null
        }
    }
    context 'Check release folder' {
        it 'Should have a version folder' {
            test-path "$contextFolder" | Should -be $true
        }
        it 'Should have a module manifest' {
            test-path "$contextFolder\$btTestModuleName.psd1" | Should -be $true
        }
        it 'Should have a module file' {
            test-path "$contextFolder\$btTestModuleName.psm1" | Should -be $true
        }
        
    }
    context 'Ensure was not published' {
        it 'Should have an empty repository' {
            $moduleList = find-module -Repository $btTestRepoName -ErrorAction SilentlyContinue
            $moduleList | should -be $null
            $($moduleList|measure-object).count | Should -be 0
        }
    }
        
}

$contextVer = '1.1.0'
$contextFolder = "$btTestPath\$btTestModuleName\$contextVer"
describe "Updating minor version to folder $contextFolder" {
    
    $build = start-btbuild -ignoreBtVersion -incrementMinorVersion -WarningAction SilentlyContinue
    context 'Check Build Return Object'{
        it 'Should return a single custom object' {
            $build.getType().Name |should -be 'PSCustomObject'
            $build.getType().BaseType |Should -be 'System.Object'
        }
        
    }
    context 'Check Pester Results' {
        it 'Should have passed building' {
            $build.success |should -be $true
        }
        it 'Should have no pesterFails' {
            $build.pesterFails | Should -be $null
        }
    }
    context 'Check dist folder' {
        it 'Should have a version folder' {
            test-path "$contextFolder" | Should -be $true
        }
        it 'Should have a module manifest' {
            test-path "$contextFolder\$btTestModuleName.psd1" | Should -be $true
        }
        it 'Should have a module file' {
            test-path "$contextFolder\$btTestModuleName.psm1" | Should -be $true
        }
        
    }
    context 'Ensure was not published' {
        it 'Should have an empty repository' {
            $moduleList = find-module -Repository $btTestRepoName -ErrorAction SilentlyContinue
            $moduleList | should -be $null
            $($moduleList|measure-object).count | Should -be 0
        }
    }
        
}

$contextVer = '2.0.0'
$contextFolder = "$btTestPath\$btTestModuleName\$contextVer"
describe "Updating minor version to $contextFolder" {
    
    $build = start-btbuild -ignoreBtVersion -incrementMajorVersion -WarningAction SilentlyContinue
    
    context 'Check Build Return Object'{
        it 'Should return a single custom object' {
            $build.getType().Name |should -be 'PSCustomObject'
            $build.getType().BaseType |Should -be 'System.Object'
        }
        
    }
    context 'Check Pester Results' {
        it 'Should have passed building' {
            $build.success |should -be $true
        }
        it 'Should have no pesterFails' {
            $build.pesterFails | Should -be $null
        }
    }
    context 'Check dist folder' {
        it 'Should have a version folder' {
            test-path "$contextFolder" | Should -be $true
        }
        it 'Should have a module manifest' {
            test-path "$contextFolder\$btTestModuleName.psd1" | Should -be $true
        }
        it 'Should have a module file' {
            test-path "$contextFolder\$btTestModuleName.psm1" | Should -be $true
        }
        
    }
    context 'Ensure was not published' {
        it 'Should have an empty repository' {
            $moduleList = find-module -Repository $btTestRepoName -ErrorAction SilentlyContinue
            $moduleList | should -be $null
            $($moduleList|measure-object).count | Should -be 0
        }
    }
        
}

$contextVer = '2.0.1'
$contextFolder = "$btTestPath\$btTestModuleName\$contextVer"
describe "Check publish to folder $contextFolder" {
    
    $build = start-btbuild -ignoreBtVersion -incrementBuildVersion -publish $true -WarningAction SilentlyContinue
    context 'Check Build Return Object'{
        it 'Should return a single custom object' {
            $build.getType().Name |should -be 'PSCustomObject'
            $build.getType().BaseType |Should -be 'System.Object'
        }
        
    }
    context 'Check Pester Results' {
        it 'Should have passed building' {
            $build.success |should -be $true
        }
        it 'Should have no pesterFails' {
            $build.pesterFails | Should -be $null
        }
    }
    context 'Check dist folder' {
        it 'Should have a version folder' {
            test-path "$contextFolder" | Should -be $true
        }
        it 'Should have a module manifest' {
            test-path "$contextFolder\$btTestModuleName.psd1" | Should -be $true
        }
        it 'Should have a module file' {
            test-path "$contextFolder\$btTestModuleName.psm1" | Should -be $true
        }
        
    }
    context 'Ensure was published' {
        $moduleList = find-module -Repository $btTestRepoName -ErrorAction Stop
        it "Should have an item in the repository $btTestRepoName" {
            $moduleList | should -be $true
            $($moduleList|measure-object).count | Should -be 1
        }
    }
        
}

describe 'Check documentation folder after publish' {
    context 'Should have functions documented in markdown' {
        $contextVer = '2.0.1'
        it 'Should have correct document version folder' {
            test-path "$btTestPath\documentation\$contextVer" |should -be $true
        }
        $documentItems  = get-childitem "$btTestPath\documentation\$contextVer\"
        it 'Should have 2 items in the folder' {
            $documentItems.count |should -be 2
        }
        it 'Should have get-helloworld.md file in the childitems' {
            $documentItems.name |should -Contain 'get-helloworld.md'
        }
        it 'Should have get-helloworld.md file in the childitems' {
            $documentItems.name |should -Contain 'get-helloworld.md'
        }
        it 'Should find the item via test-path' {
            test-path "$btTestPath\documentation\$contextVer\get-helloworld.md" |should -be $true
        }
    }
}

$contextVer = '2.0.2'
$contextFolder = "$btTestPath\$btTestModuleName\$contextVer"
describe "Check update publish to folder $contextFolder" {
    
    $build = start-btbuild -ignoreBtVersion -incrementBuildVersion -publish $true -WarningAction SilentlyContinue
    context 'Check Build Return Object'{
        it 'Should return a single custom object' {
            $build.getType().Name |should -be 'PSCustomObject'
            $build.getType().BaseType |Should -be 'System.Object'
        }
        
    }
    context 'Check Pester Results' {
        it 'Should have passed building' {
            $build.success |should -be $true
        }
        it 'Should have no pesterFails' {
            $build.pesterFails | Should -be $null
        }
    }
    context 'Check dist folder' {
        it 'Should have a version folder' {
            test-path "$contextFolder" | Should -be $true
        }
        it 'Should have a module manifest' {
            test-path "$contextFolder\$btTestModuleName.psd1" | Should -be $true
        }
        it 'Should have a module file' {
            test-path "$contextFolder\$btTestModuleName.psm1" | Should -be $true
        }
        
    }

    context 'Ensure was published' {
        #This fails beause AllVersions is not valid on a drive share as far as I can figure out
        #Only works on an actual repository
        #Oddly the requiredversion works ok

        #Changing this to be a bit better
        $moduleFind = find-module -Repository $btTestRepoName -name $btTestModuleName
        it "Should have $contextVer in the repo: $btTestRepoName" {
            $moduleFind.version | Should -be $contextVer
        }
    }
}

#Need to add a module Dependency
describe 'Upload Pester Module to the test repository' {
    Publish-Module -Repository $btTestRepoName -Name 'Pester' -RequiredVersion $(get-module -name pester|sort-object -Property Version -Descending|select-object -First 1).version
    $findPester = find-module -Name pester -Repository $btTestRepoName
    $findPester |should -be $true
}

describe 'Check the updateProject command to add a new requiredModule' {
    update-btProject -RequiredModules 'pester' -modulePath $btTestPath
    $configImport = import-clixml $btTestPath\btConfig.xml
    context 'it Should have updated the config file' {
        it 'Should have pester as a required module' {
            $configImport.requiredModules -contains 'Pester'|should -be $true
        }
        it 'Should have no other requirements' {
            $configImport.requiredModules.Count |should -be 1  
        }
    }
}


$contextVer = '2.0.3'
$contextFolder = "$btTestPath\$btTestModuleName\$contextVer"
describe "Check update publish to folder $contextFolder" {
    
    $build = start-btbuild -ignoreBtVersion -incrementBuildVersion -publish $true -WarningAction SilentlyContinue
    context 'Check Build Return Object'{
        it 'Should return a single custom object' {
            $build.getType().Name |should -be 'PSCustomObject'
            $build.getType().BaseType |Should -be 'System.Object'
        }
        
    }
    context 'Check Pester Results' {
        it 'Should have passed building' {
            $build.success |should -be $true
        }
        it 'Should have no pesterFails' {
            $build.pesterFails | Should -be $null
        }
    }
    context 'Check dist folder' {
        it 'Should have a version folder' {
            test-path "$contextFolder" | Should -be $true
        }
        it 'Should have a module manifest' {
            test-path "$contextFolder\$btTestModuleName.psd1" | Should -be $true
        }
        it 'Should have a module file' {
            test-path "$contextFolder\$btTestModuleName.psm1" | Should -be $true
        }
        
    }

    context 'Ensure was published' {
        #This fails beause AllVersions is not valid on a drive share as far as I can figure out
        #Only works on an actual repository
        #Oddly the requiredversion works ok

        #Changing this to be a bit better
        $moduleFind = find-module -Repository $btTestRepoName -name $btTestModuleName -ErrorAction Stop
        it "Should have $contextVer in the repo: $btTestRepoName" {
            $moduleFind.version | Should -be $contextVer
        }
    }
}

describe 'Start-btRevisionCleanUp should have automatically kept only the last 5 revisions' {
    $childFolders = $(get-childitem "$btTestPath\rev" |where-object {$_.PsIsContainer -eq $true})
    it "Should have 5 folders" {
        $childFolders.count |should -be 5
    }

}

#Lets remove the repository

$btTestRepo = $(get-psrepository -name $btTestRepoName -ErrorAction Ignore)
if($btTestRepo)
{
    #Remove the old repository, make sure that the path is correct
    Unregister-PSRepository -name $btTestRepoName
}
       
describe 'Repository removal' {
    context 'Check test repsitory does not exist' {
        $btTestRepo = $(get-psrepository -name $btTestRepoName -ErrorAction Ignore)
        it 'repository should be null' {
            $btTestRepo |should -be  $null
        }
    }
}

describe 'Remove repository from btSave' {
    context 'Check the clear-btRepository function works as expected' {
        clear-btRepository -repository $btTestRepoName -force

        $getRepo = get-btRepository -repository $btTestRepoName

        it 'Should have removed repository' {
            $getRepo |should -be $null
        }
    }

}

if($oldSettings)
{
    describe 'Restore previous btDefault Settings' {
        try{
            save-btDefaultSettings -update @oldSettings
            $savedSettings = $true
        }catch{
            $savedSettings = $false
        }

        it 'Should have saved settings without error' {
            $savedSettings| should -be $true
        }
    }
}


<#Temp stop removal of module
$WarningPreference = $prevWarningPref
set-location c:\ |out-null
remove-item -Force -Path $btTestPath -Confirm:$false -Recurse |out-null

describe 'Check Test Folder Removal' {
    it 'should no longer exist ' {
        test-path $btTestPath | Should -Be $false
    }
}
#>

#Notes:
## Need to add test for multiple repositories
## Need to add tests for module dependancies