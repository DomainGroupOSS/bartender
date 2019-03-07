function save-btDefaultSettings
{

    <#
        .SYNOPSIS
            Save API token and, if supplied, Repository Credentials
            
        .DESCRIPTION
            Save API token and credentials, in order to provide the ability to publish/find modules without 
            having to enter this stuff all the time
        
        .PARAMETER author
            Default Module Author

        .PARAMETER repository
            Default repositories to publish to

        .PARAMETER company
            Default Company to publish as

        .PARAMETER Tags
            Default Tags to use

        .PARAMETER minimumPsVersion
            The default minimumPsVersion to use

        .PARAMETER AutoIncrementRevision
            The default AutoIncrementRevision value

        .PARAMETER RemoveSingleLineQuotes
            Default RemoveSingleLineQuotes value

        .PARAMETER RemoveEmptyLines
            Default RemoveEmptylines Value
        
        
        .PARAMETER trimSpaces
            Default trimSpaces value

        
        .PARAMETER publishOnBuild
            Default publishOnBuild value

        .PARAMETER autoDocument
            Default autoDocument Value

        .PARAMETER update
            Use to overwrite any existing saved default settings

        .EXAMPLE
            save-btDefaultSettings -author my.name -repositories @('myrepo1','psgallery')
            
            #### DESCRIPTION
            Will save the repository myRepo with the token, and prompt once for credentials.
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: yyyy-mm-dd
            
            
            Changelog:
                2019-02-01 - AA
                    
                    - Initial Script
                        - Unsure what to do about LINUX and PSCORE
                        - Obviously the save path is less than ideal
                        - Also unsure what will happen with roaming profiles
                        - What if we include _this_ computername in the filename
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [string]$author,
        [string]$repository,
        [string]$company,
        [string[]]$Tags,
        [version]$minimumPsVersion,
        [Nullable[boolean]]$AutoIncrementRevision,
        [Nullable[boolean]]$RemoveSingleLineQuotes,
        [Nullable[boolean]]$RemoveEmptyLines,
        [Nullable[boolean]]$trimSpaces,
        [Nullable[boolean]]$publishOnBuild,
        [Nullable[boolean]]$autoDocument,
        [Nullable[boolean]]$runPesterTests,
        [Nullable[boolean]]$includeGitDetails,
        [switch]$update,
        [string]$projectUri,
        [string]$licenseUri
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
      
    }
    
    process{
        #Where should we save the module
        write-verbose 'Getting Save location'
        $localPath = "$($env:userprofile)\AppData\local"
        if(test-path $localPath)
        {
            $btSaveFolder = "$localPath\bartender"
            $btDefaultsPath = "$btSaveFolder\btDefaults_$($env:computername).xml"
            if(!$(test-path $btSaveFolder))
            {
                write-verbose "Creating bartender folder at $btSaveFolder"
                new-item -itemtype directory -path $btSaveFolder

            }else{
                write-verbose 'bt path exists'
            }
        }else{
            throw 'Local Profile unavailable'
        }
        
        
        write-verbose 'Importing existing default settings'
        if(test-path $btDefaultsPath)
        {
            try{
                
                $btDefaultSettings = import-clixml $btDefaultsPath -errorAction stop
                write-verbose 'Existing saved default imported'
            }catch{
                write-error $error[0]
                throw 'Unable to import defaults settings'
            }
        }else{
            write-verbose 'Previous settings not found, creating'
            $btDefaultSettings = @{}
        }


        write-verbose 'Checking we do not already have settings'
        write-verbose "$($btDefaultSettings.keys.count)"
        if(($btDefaultSettings.keys.count -ge 1) -and ($update -ne $true))
        {
            throw 'Default settings already exist. To overwrite use the -update switch'
        }

        if($author)
        {
            write-verbose "Setting default author as $author"
            $btDefaultSettings.author = $author
        }

        if($repository)
        {
            write-verbose 'Setting default repository'
            $btDefaultSettings.repository = $repository
        }

        if($company)
        {
            write-verbose 'Setting default company'
            $btDefaultSettings.company = $company
        }

        if($Tags)
        {
            write-verbose 'Setting default Tags'
            $btDefaultSettings.Tags = $tags
        }

        if($minimumPsVersion)
        {
            write-verbose 'Setting default minimumPsVersion'
            $btDefaultSettings.minimumPsVersion = $minimumPsVersion
        }

        if($AutoIncrementRevision -ne $null)
        {
            write-verbose 'Setting default AutoIncrementRevision'
            $btDefaultSettings.AutoIncrementRevision = $AutoIncrementRevision
        }

        if($RemoveSingleLineQuotes -ne $null)
        {
            write-verbose 'Setting default RemoveSingleLineQuotes'
            $btDefaultSettings.RemoveSingleLineQuotes = $RemoveSingleLineQuotes
        }

        if($RemoveEmptyLines -ne $null)
        {
            write-verbose 'Setting default RemoveEmptyLines'
            $btDefaultSettings.RemoveEmptyLines = $RemoveEmptyLines
        }

        if($trimSpaces -ne $null)
        {
            write-verbose 'Setting default trimSpaces'
            $btDefaultSettings.trimSpaces = $trimSpaces
        }

        if($publishOnBuild -ne $null)
        {
            write-verbose 'Setting default publishOnBuild'
            $btDefaultSettings.publishOnBuild = $publishOnBuild
        }

        if($autoDocument -ne $null)
        {
            write-verbose 'Setting default autoDocument'
            $btDefaultSettings.autoDocument = $autoDocument
        }

        write-debug 'Save the file'
        write-verbose 'Updating saved repositories file'
        $btDefaultSettings|export-clixml $btDefaultsPath -force

    }
    
}