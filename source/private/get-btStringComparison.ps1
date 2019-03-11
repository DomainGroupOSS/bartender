function get-btStringComparison
{
    <#
        .SYNOPSIS
            Make a comparison between two strings
            See how many characters are the same by counting them up

        .DESCRIPTION

            Compare String1 to String2
            Group each string by the number of characters
            Compare the comparison
            Work out how similar the character composition is of both strings
            
            Works with the group-object function
            As such, provides a very efficient way of comparing string similarity
            It can compare two files of ~ 200,000 chars each, in about 6 seconds
            
        .PARAMETER string1
            the first string to compare

        .PARAMETER string2
            the second string to compare


        .EXAMPLE
            get-btStringComparison -string1 $(get-content $file1) -string2 $(get-content $file2)


            
        #### DESCRIPTION
            Find out how similar two files are
            
            
        #### OUTPUT
            Copy of the output of this line
            
            
        .OUTPUTS
            TotalChars1 TotalChars2 Difference DiffPercent
            ----------- ----------- ---------- -----------
                210269      210269          0           0
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: 2019-03-11
            
            
            Changelog:
                2019-03-11 - AA
                    - Changed Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$string1,
        [ValidateNotNullOrEmpty()]
        [string]$string2
    )
    $length1 = $string1.Length
    $length2 = $string2.Length
    $charArr1 = $string1.ToCharArray()
    $charArr2 = $string2.ToCharArray()
    $charArrU = $charArr1 + $charArr2 |Select-object -Unique
    $summary1 = $charArr1|group-object|select-object name,count
    $summary2 = $charArr2|group-object|select-object name,count
    $summaryAll = foreach($char in $charArrU)
    {
        $c1 = $($summary1|where-object {$_.name -eq $char}).Count
        $c2 = $($summary2|where-object {$_.name -eq $char}).Count
        $diff = $c2 - $c1
        if($diff -lt 0)
        {
            #FlipToPos
            $diff = $diff * -1
        }
        [psCustomObject]@{
            char = $char
            count1 = $c1
            count2 = $c2
            diff = $diff
        }
    }

    $totals = [pscustomobject]@{
        TotalChars1 = $length1
        TotalChars2 = $length2
        Difference = $($summaryAll.diff|measure-object -sum).Sum
        DiffPercent = [math]::round($($($summaryAll.diff|measure-object -sum).Sum / $(@($length1,$lenght2)|measure-object -maximum).Maximum)*100,2)
    }

    $totals
    
}