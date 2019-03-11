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

        .PARAMETER versionOverride
            Used to build based on a different version tag

            Generally used for debug only
            
        ------------
        .EXAMPLE
            get-btChangeDetails
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-06
            
            
            Changelog:

                2019-03-06 - AA
                    
                    - Initial Script

                2019-03-08 - AA
                    
                    - Fixed up some spelling mistakes
                    - Fixed the badges
                    - Added files
                    - Added ability to override version
                    - Added badge for commentBasedHelp
                    - Moved everything into a single hear-string
                    - Added a dumb way to close bracket for md link
                    - Fixed a bug where I was multiplying the length by a kb instead of dividing

                2019-03-08 - AA
                    - Reduced kb decimal places to 2
                    - Removed the dumb way to close bracket for md link
                    - Fixed the markdown link
                    - Changed the codeblocks to markdown tables
                    - Center aligned the top badges
                    - Moved the bartender badge to the right
                    - Fix the order of unmodified functions
                    - Fix the spacing around releaseNotes

                2019-03-11 - AA
                    - Changed to handle updated get-btChangeDetails script
                    
        .COMPONENT
            Bartender
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
            $gitMarkdown = "---`n## Git Details`n$(get-btMarkdownFromHashtable $gitHt)`n"
            
        }

        write-verbose 'Retrieving Change Details'

        $changeDetails = get-btChangeDetails -modulePath $modulePath -newRelease

        if($changeDetails)
        {

            write-verbose 'Creating Summary Block'
            $summaryMarkdown = "---`n## Changes Summary`n$(get-btMarkdownFromHashtable $changeDetails.summary)`n"



            write-verbose 'Creating Files Section' 
            $mdFileStringSelector = @{
                name = 'mdString'
                expression = {"|$($_.basename)|$($_.relativePath)|$($_.extension)|$([math]::round($($_.length / 1kb),2))|"}
            }
            $filesHeader = "|name|path|extension|size(kb)`n|----------------|--------------------------------|-----|-----|"
            $newFiles = $($changeDetails.files|where-object{$_.fileIsNew -eq $true}|select-object $mdFileStringSelector).mdString | out-string
            $unmodFiles = $($changeDetails.files|where-object{$_.fileIsModified -eq $false -and $_.fileIsNew -eq $false}|select-object $mdFileStringSelector).mdString | out-string
            $modFiles = $($changeDetails.files|where-object{$_.fileIsModified -eq $true -and $_.fileIsNew -eq $false}|select-object $mdFileStringSelector).mdString | out-string
            if($newFiles)
            {
                $newFilesMd = "#### New Files`n$filesHeader`n$newFiles`n"
            }
            if($modFiles)
            {
                $modFilesMd = "#### Modified Files`n$filesHeader`n$modFiles`n"
            }
            if($unmodFiles)
            {
                $unmodFilesMd = "#### Unchanged Files`n$filesHeader`n$unmodFiles`n"
            }

            $filesMarkdown = "---`n## File`n`n### Summary`n`n$(get-btMarkdownFromHashtable  $changeDetails.filesummary)`n`n### File List`n`n$newFilesMd`n$modFilesMd`n$unmodFilesMd`n"


            write-verbose 'Creating Functions Section' 

            $mdFunctionStringSelector = @{
                name = 'mdString'
                expression = {"|$($_.function)|$(if($_.folder -eq 'private'){"Private"}else{"Public"})|$(if($_.hasmarkdown){"[link](./functions/$($_.function).md)"})|$($_.relativePath)|"}
            }

            $functionsHeader = "|function|type|markdown link|filename|`n|-|-|-|-|"
            $newFuncs = $($changeDetails.functions|where-object{$_.fileIsNew -eq $true}|select-object $mdFunctionStringSelector).mdString | out-string
            $unmodFuncs = $($changeDetails.functions|where-object{$_.fileIsModified -eq $false -and $_.fileIsNew -eq $false}|select-object $mdFunctionStringSelector).mdString | out-string
            $modFuncs = $($changeDetails.functions|where-object{$_.fileIsModified -eq $true -and $_.fileIsNew -eq $false}|select-object $mdFunctionStringSelector).mdString | out-string
            if($newFuncs)
            {
                $newFuncsMd = "#### New Functions`n$functionsHeader`n$newFuncs"
            }
            if($modFuncs)
            {
                $modFuncsMd = "#### Modified Functions`n$functionsHeader`n$modFuncs"
            }
            if($unmodFuncs)
            {
                $unmodFuncsMd = "#### Unmodified Functions`n$functionsHeader`n$unmodFuncs"
            }

            $functionsMarkdown = "---`n## Functions`n`n### Summary`n`n$(get-btMarkdownFromHashtable $changeDetails.functionSummary)`n`n### Function List`n`n$newFuncsMd`n$modFuncsMd`n$unmodFuncsMd"
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
            $pesterMarkdown = "---`n## Pester Details`n$(get-btMarkdownFromHashtable $metadata.privatedata.pester)`n"

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

        $btbadge = "[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=$($metadata.PrivateData.bartenderVersion)&color=0B2047"
        $releaseBadge = "[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=$($metadata.moduleVersion)&color=blue"
        $commentBasedHelpCoverage = $changeDetails.summary.commentBasedHelpCoverage
        if(!$commentBasedHelpCoverage)
        {
            $commentBasedHelpCoverage = 'na'
        }
        $badgeColor = switch ($commentBasedHelpCoverage) {
            {$_ -le 20} {"red";break;}
            {$_ -le 40} {"orange";break;}
            {$_ -le 60} {"yellow"; break;}
            {$_ -le 75} {"yellowgreen"; break;}
            {$_ -le 90} {"green"; break;}
            {$_ -le 100} {"brightgreen"; break;}
            default {"lightgrey"; break;}
        }
        $helpCoverage = "[helpcoveragebadge]: https://img.shields.io/static/v1.svg?label=get-help&message=$commentBasedHelpCoverage&color=$badgeColor"
        
        
        write-verbose 'Creating Overview'
        $overviewHt = @{
            BuildDate = $($metaData.privatedata.builtOn)
            'Author(s)' = $($metaData.author)
            BuildUser = $($metaData.privateData.builtBy)
            Company = $($metaData.CompanyName)

        }
        $overviewMarkdown = "## Overview`n$(get-btMarkdownFromHashtable $overviewHt)`n"

        write-verbose 'Generating Final Markdown'

        #Still hate herestring and how it deals with tabs
        
        $markdown = @"
# $($configSettings.moduleName) - Release $versionString

| Version | Code Coverage | Code Based Help Coverage |Bartender Version|
|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
|![releasebadge]|![pesterbadge]|![helpcoveragebadge]|![btbadge]|

$overviewMarkdown
`n
$(
    if($metadata.privatedata.psdata.releasenotes)
    {
        "### Release Notes:`n`n$($metadata.privatedata.psdata.releasenotes)`n`n"
    }
)
`n
$summaryMarkdown
`n
$filesMarkdown
`n
$functionsMarkdown
`n
$modulesMarkdown
`n
$pesterMarkdown
`n
$gitMarkdown
`n
$pesterbadge
$btbadge
$releaseBadge
$helpCoverage
"@

        $markdown
        

    }
    
    
}