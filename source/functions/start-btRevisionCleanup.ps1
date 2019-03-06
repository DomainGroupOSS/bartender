function start-btRevisionCleanup
{

    <#
        .SYNOPSIS
            Clean-up bt revisions folder
            
        .DESCRIPTION
            Remove any previous revisions to try and keep the size down
            By default keep the last 5
            
            
        .PARAMETER path
            The path of your bartender module
            Defaults to current working directory
        
        .EXAMPLE
            start-btRevisionCleanup
            
            #### DESCRIPTION
            Remove previous revisions
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-12-03
            
            
            Changelog:

                2019-01-30
                    
                    - Initial Script
                    - Now we are dealing with revisions, we need a way to not keep creeping the revisions up
                    
         .COMPONENT
            Bartender

        .INPUTS
           null

        .OUTPUTS
            custom object
    #>

    [CmdletBinding()]
    PARAM(
        [string]$path = (Get-Item -Path ".\").FullName,
        [string]$configFile = 'btconfig.xml',
        [int]$revisions
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"


        $defaultRevisions = 5
        $invocationPath = $path

        $scriptVars = @{}
        $scriptVars.configFilePath = "$invocationPath\$($configFile)"
        $scriptVars.revisionPath = "$invocationPath\rev" 
        
    }
    
    process{
        $scriptVars.config = Import-Clixml $scriptVars.configFilePath -ErrorAction Stop
        Write-Verbose "$($scriptvars.config|Out-String)"
        if(!$scriptVars.config.version -or !$scriptVars.config.moduleName -or !$scriptVars.config.moduleAuthor -or !$scriptVars.config.companyName)
        {
            throw "Config file was not found.`nUse new-btproject for a new project."
        }
        
        if($revisions -ge 1)
        {
            write-verbose 'Using revision param count'
        }else{
            write-verbose 'Reading revision count from config'
            $revisions = $scriptVars.config.revisionCount
            if(!$revisions)
            {
                write-verbose "Revision count not found, using default of $defaultRevisions"
                $revisions = $defaultRevisions
                try{
                    $scriptVars.config.revisionCount = $defaultRevisions
                }catch{
                    $scriptVars.config|add-member -MemberType NoteProperty -Name revisionCount -Value $defaultRevisions
                }
                
                write-verbose 'Saving default to config file'
                Export-Clixml -Path $scriptVars.configFilePath -InputObject $scriptVars.config
                write-verbose 'Config file updated'
            }
        }
        if(!$revisions)
        {
            throw 'Something wrong with Revision counter'
        }
        write-verbose "Revisions set to: $revisions"

        #If we parse a version from the name, then we can sort properly
        #That way if the dates are all strange from a git view, it wont matter
        #And name itself might be odd, consider version 1.1,10.1,2.1,20.1 and the order that would be in
        $versionSelect = @{
            name ='version'
            expression = {[version]::Parse($($_.name))}
        }

        write-verbose 'Getting revisions'
        #Use * so we can still pipe it to remove-item
        $childItems = get-childItem $scriptVars.revisionPath|select-object *,$versionSelect|where-object{$null -ne $_.version}
        $currentCount = $($childItems|measure-object).count
        $removeCount = $currentCount - $revisions
        if($removeCount -ge 1)
        {
            write-verbose "Need to remove $removeCount versions"
            $childItems|sort-object -property version|select-object -first $removeCount|remove-item -Force -Recurse
        }else{
            write-verbose 'No revisions to remove'
        } 
    }
    
}