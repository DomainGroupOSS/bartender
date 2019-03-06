function get-btInstalledModule
{

    <#
        .SYNOPSIS
            Get the name and version of an already installed module
            
        .DESCRIPTION
            Get the name and version of an already installed module
            If moduleVersion is specified, ensures its installed
            Otherwise, return the latest version of the module

            Return as a moduleSpecification object
            
        .PARAMETER moduleName
            Name of the module to find

        .PARAMETER moduleVersion
            If you want to find a specific version of a module
            
        ------------
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-02-01
            
            
            Changelog:
                2019-02-01 - AA
                    
                    - Initial Script
                
                2019-03-04 - AA
                    
                    - Fixed the documentation
                    - Changed the returned object to a modulespecification object
                        - Ensured fed correct hashtable
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$moduleName,
        [version]$moduleVersion
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        #Array of what we want to select
        #Easier to do this when we want custom params

        $modSelect = @(
            'GUID',
            @{
                Name='ModuleName'
                Expression = {$_.Name}
            },
            @{
                Name='ModuleVersion'
                Expression={$_.Version}
            }
        )

        $allVersions = get-module -listAvailable -name $moduleName|select-object $modSelect
        if($($allVersions|measure-object).count -ge 1)
        {
            write-verbose 'Modules found'
            if($ModuleVersion)
            {
                write-verbose 'Checking for specific version'
                $found = $allVersions|Where-Object{$_.ModuleVersion -eq $moduleVersion}|Select-Object -first 1
                if($found)
                {
                    write-verbose 'Found specific Version'
                    $selectedMod =  $found
                }else{
                    Throw "Module $moduleName was found on this machine but the version: $moduleVersion is not present"
                }
            }else{
                write-verbose 'Getting Latest Version'
                $selectedMod = $allVersions|Sort-Object ModuleVersion -Descending|Select-Object -first 1
            }
        }else{
            throw "No Modules found with the name $moduleName. Please install them first"
        }
        if($selectedMod)
        {
            Write-Debug "$($selectedMod|format-list|out-string)"
            $hashtable = @{
                guid = $selectedMod.guid
                modulename = $selectedMod.moduleName
                requiredversion = $selectedMod.moduleVersion
                #moduleVersion = $selectedMod.moduleVersion # Use moduleVersion or RequiredVersion, but not both
            }
            [Microsoft.PowerShell.Commands.ModuleSpecification]::new($hashtable)
        }
        
    }
    
}