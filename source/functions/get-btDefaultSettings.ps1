function get-btDefaultSettings
{

    <#
        .SYNOPSIS
            Retrieve the current users default BT Settings
            
        .DESCRIPTION
            Retrieve the current users default BT Settings
            
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
                write-verbose 'bt path not found, no settings saved'

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
                write-verbose 'Existing saved defaults imported'
                return $btDefaultSettings
            }catch{
                write-error $error[0]
                throw 'Unable to import defaults settings'
            }
        }else{
            write-verbose 'Previous settings not found'
        }
    }
    
}