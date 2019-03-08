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

        write-verbose 'Setting some defaults'
        $codeblockString = '```'


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
            $gitMarkdown = "---`n## Git Details`n$codeblockString`n$($gitHt|format-table|out-string)`n$codeblockString`n"
            
        }

        write-verbose 'Retrieving Change Details'

        $changeDetails = get-btChangeDetails -modulePath $modulePath -ignoreLast

        if($changeDetails)
        {

            write-verbose 'Creating Summary Block'
            $summaryMarkdown = "---`n## Changes Summary`n$codeblockString`n$($changeDetails.summary |format-table|out-string)`n$codeblockString`n"



            write-verbose 'Creating Files Section' 
            $mdFileStringSelector = @{
                name = 'mdString'
                expression = {"|$($_.basename)|$($_.relativePath)|$($_.extension)|$([math]::round($($_.length * 1kb),3))|"}
            }
            $filesHeader = "|name|path|extension|size(kb)`n|----------------|--------------------------------|-----|-----|"
            $newFiles = $($changeDetails.files|where-object{$_.fileIsNew -eq $true}|select-object $mdFileStringSelector).mdString | out-string
            $unmodFiles = $($changeDetails.files|where-object{$_.fileIsModified -eq $false -and $_.fileIsNew -eq $false}|select-object $mdFileStringSelector).mdString | out-string
            $modFiles = $($changeDetails.files|where-object{$_.fileIsModified -eq $true -and $_.fileIsNew -eq $false}|select-object $mdFileStringSelector).mdString | out-string
            if($newFiles)
            {
                $newFilesMd = "### New Files`n$filesHeader`n$newFiles`n"
            }
            if($modFiles)
            {
                $modFilesMd = "### Modified Files`n$filesHeader`n$modFiles`n"
            }
            if($unmodFiles)
            {
                $unmodFilesMd = "### Unchanged Files`n$filesHeader`n$unmodFiles`n"
            }

            $filesMarkdown = "---`n## Files Summary`n`n$newFilesMd`n$modFilesMd`n$unmodFilesMd`n"


            write-verbose 'Creating Functions Section' 
            
            $blobLink = "[link](../blob/$branch/documentation/$versionString"
            $mdFunctionStringSelector = @{
                name = 'mdString'
                expression = {"|$($_.function)|$(if($_.folder -eq 'private'){"Private"}else{"Public"})|$(if($_.hasmarkdown -and $branch){"$blobLink$($_.function).md"})|$($_.relativePath)|"}
            }

            $functionsHeader = "|function|type|mdLink|filename|`n|-|-|-|-|"
            $newFuncs = $($changeDetails.functions|where-object{$_.fileIsNew -eq $true}|select-object $mdFunctionStringSelector).mdString | out-string
            $unmodFuncs = $($changeDetails.functions|where-object{$_.fileIsModified -eq $false -and $_.fileIsNew -eq $false}|select-object $mdFunctionStringSelector).mdString | out-string
            $modFuncs = $($changeDetails.functions|where-object{$_.fileIsModified -eq $true -and $_.fileIsNew -eq $false}|select-object $mdFunctionStringSelector).mdString | out-string
            if($newFuncs)
            {
                $newFuncsMd = "### New Functions`n$functionsHeader`n$newFuncs"
            }
            if($modFuncs)
            {
                $modFuncsMd = "### Modified Functions`n$functionsHeader`n$modFuncs"
            }
            if($unmodFuncs)
            {
                $unmodFuncsMd = "### Unmodified Functions`n$functionsHeader`n$unmodFuncs"
            }

            $functionsMarkdown = "---`n## Functions Summary`n`n$newFuncsMd`n$unmodFuncsMd`n$modFuncsMd"
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
            $pesterMarkdown = "---`n## Pester Details`n$codeblockString`n$($metadata.privatedata.pester|format-table|out-string)`n$codeblockstring`n"

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

        $btbadge = "[btbadge]: https://img.shields.io/static/v1.svg?label=bartenderVer&message=$($metadata.PrivateData.bartenderVersion)&color=blueviolet"
        $releaseBadge = "[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=$($metadata.moduleVersion)&color=blue"

        write-verbose 'Creating Overview'
        $overviewHt = @{
            BuildDate = $($metaData.privatedata.builtOn)
            'Author(s)' = $($metaData.author)
            BuildUser = $($metaData.privateData.builtBy)
            Company = $($metaData.CompanyName)

        }
        $overviewMarkdown = "## Overview`n$codeblockstring`n$($overviewHt| format-table|out-string)`n$codeblockstring"

        write-verbose 'Generating Final Markdown'

        #Still hate herestring and how it deals with tabs
        
        $markdown = @"
# $($configSettings.moduleName) - Release $versionString

| Version | CodeCoverage | Bartener Version|
|-------------------|-------------------|-------------------|
|[releasebadge]|[pesterbadge]|[btbadge]|

$overviewMarkdown

$(
    if($metadata.privatedata.psdata.releasenotes)
    {
        "### Release Notes:`n$($metadata.privatedata.psdata.releasenotes)"
    }
)


$summaryMarkdown

$filesMarkdown

$functionsMarkdown

$modulesMarkdown

$pesterMarkdown

$gitMarkdown

$pesterbadge
$btbadge
$releaseBadge
"@

        $markdown
        

    }
    
    
}