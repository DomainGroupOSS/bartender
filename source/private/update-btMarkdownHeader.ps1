function update-btMarkdownHeader
{

    <#
        .SYNOPSIS
            Update the top of a markdown file
            
        .DESCRIPTION
            Update the top of a markdown file
            Executes on build to add appropriate info to the header section
            Will also update the name and description
            
        .PARAMETER path
            Path to the module

        .PARAMETER configFile
            btConfig file

        .PARAMETER markdownFile
            Markdown file name

            
        ------------
        .EXAMPLE
            update-btMarkdownHeader
            
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-10 - AA
                    
                    - Initial Script
                    - Updated start-btBuild to get release data
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [string]$path = (Get-Item -Path ".\").FullName,
        [string]$configFile = 'btconfig.xml',
        [string]$markdownFile = 'readme.md'
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"

        
        $configFilePath = "$path\$($configFile)"
        $markdownFilePath = "$path\$($markdownFile)"

        $headerMatch = '<!--Bartender Dynamic Header -- Code Below Here -->'


        
    }
    
    process{
        write-verbose 'Importing config'
        if(!$(test-path $configFilePath))
        {
            throw "$configFile not found"
        }

        $config = import-clixml $configFilePath

        if(!(test-path $markdownFilePath))
        {
            throw "$markdownfile not found"
        }

        write-verbose 'Importing existing markdown'
        $content = get-content $markdownFilePath

        if($config.lastrelease.version)
        {
            $versionTag = $config.lastrelease.version.tostring(3)
            $releaseDate = get-date $config.lastRelease.date -Format yyyy-MM-dd
            
        }else{
            $versionTag = 'na'
            $releaseDate = 'na'
        }

        if(test-path "$path\documentation\$versionTag\release.md")
        {
            $latestReleaseLink = "Latest Release Notes: [here](./documentation/$versionTag/release.md)"
        }else{
            $latestReleaseLink = $null
        }


        write-verbose 'Creating Shield Badges'
        $badges = @{
            releasebadge = "[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=$versionTag&color=blue"
            datebadge = "[datebadge]: https://img.shields.io/static/v1.svg?label=Date&message=$releaseDate&color=yellow"
            powershellBadge = "[psbadge]: https://img.shields.io/static/v1.svg?label=PowerShell&message=$($config.minimumPsVersion.ToString(3))&color=5391FE&logo=powershell"
            btBadge = "[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=$($config.bartenderVersion.toString())&color=0B2047"
        }

        write-verbose 'Generating new Markdown'
        $headerArr = @(
            "# $($config.modulename.toUpper())",
            "$(if(test-path "$path\icon.png"){'![logo](\icon.png)'})",
            "",
            "> $($config.moduleDescription)",
            "",
            "$($badges.releasebadge)",
            "$($badges.datebadge)",
            "$($badges.powershellBadge)",
            "$($badges.btBadge)",
            '',
            '',
            "| Language | Release Version | Release Date | Bartender Version |",
            "|:-------------------:|:-------------------:|:-------------------:|:-------------------:|",
            "|![psbadge]|![releasebadge]|![datebadge]|![btbadge]|"
            '',
            '',
            "Authors: $($config.moduleAuthor -join ',')",
            '',
            "$(if($config.companyName){"Company: $($config.companyName)"})",
            '',
            "$latestReleaseLink",
            '',
            '***',
            ''

        )

        write-verbose 'Checking for header marker for markdown entry point'
        $i = 0
        $contentLines = $content.count
        $lineMatch = -1
        while($i -lt $contentLines -and $lineMatch -lt 0)
        {
            if($content[$i] -eq $headerMatch)
            {
                $lineMatch = $i
            }
            $i++
        }

        if($lineMatch -gt 0)
        {
            write-verbose "Found line at $lineMatch"
            $remainder = $content[$lineMatch..$contentLines]

            $newContent = $headerArr + $remainder
            $contentMarkdown = $newContent -join "`n"

            if($contentMarkdown)
            {
                write-verbose 'Exporting updated markdown file'
                $contentMarkdown|out-file $markdownFilePath
            }


        }

    }
    
}