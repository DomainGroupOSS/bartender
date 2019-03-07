function new-btReleaseMarkdown
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
        [string]$configFile = 'btConfig.xml'
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
        $manifestPath = "$modulePath\$($configSettings.moduleName)\$($configSettings.versionAsTag)\$($configSettings.moduleName).psd1"
        $metadata = import-metadata -Path $manifestPath

        $changeDetails = get-btChangeDetails 

        $mdStringSelector = @{
            name = 'mdString'
            expression = {"|$($_.function)|$(if($_.folder -eq 'private'){"Private|"}else{"Public|[link](/$($_.function).md)"})|$($_.relativePath)|"}
        }
        $mdTable = $($changeDetails|select-object $mdStringSelector).mdString|out-string

        $gitDetails = get-btGitDetails

        $requiredModulesSelector = @{
            name = 'rmString'
            expression = {"|$($_.moduleName)|$($_.RequiredVersion)|"}
        }

        
        $markdown = @"

# Release Notes $($configSettings.moduleName) - Release $($configSettings.versionAsTag)

## Overview

BuildDate: **$($metaData.privatedata.builtOn)**`n
Authors: **$($metaData.author)**`n
BuildUser: **$($metaData.privateData.builtBy)**`n
Company: **$($metaData.CompanyName)**`n

---
## Functions in Release

### Unmodified

|function|type|mdLink|filename|
|-|-|-|-|-|-|
$($($changeDetails|where-object{$_.fileIsNew -eq $false -and $_.fileIsModified -eq $false}|select-object $mdStringSelector).mdString|out-string)

### Modified

|function|type|mdLink|filename|
|-|-|-|-|-|-|
$($($changeDetails|where-object{$_.fileIsNew -eq $false -and $_.fileIsModified -eq $true}|select-object $mdStringSelector).mdString|out-string)

### New or Moved

|function|type|mdLink|filename|
|-|-|-|-|-|-|
$($($changeDetails|where-object{$_.fileIsNew -eq $true}|select-object $mdStringSelector).mdString|out-string)

**Notes:**
 - For Public Functions, check the relevant markdown link
 - For Private Functions, check the file sourcecode

---
## Required Modules

|moduleName|requiredVersion|
|-|-|
$($($metadata.requiredModules|select-object $requiredModulesSelector).rmString|out-string)

---
## Pester Details

CodeCoverage: **$($metadata.privatedata.pester.codecoverage)**`n
Passed: **$($metadata.privatedata.pester.passed)**`n
TimeToTest: **$($metadata.privatedata.pester.time)**`n

---
## Git Details

Branch: **$($gitDetails.branch.replace('* ','').trim())**`n
Origin: **$($($gitDetails.origin).trim())**`n
Commit: **$($($gitDetails.commitShort).trim())**`n



"@

        $markdown
        

    }
    
    
}