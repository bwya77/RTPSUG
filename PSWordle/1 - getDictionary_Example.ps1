function Get-PSWordleDictionary {
    Begin {
        $Platform = [System.Environment]::OSVersion.Platform
    }
    Process {
        if ($Platform -eq "Unix") {
            #Get dictionary file
            # The Select-String cmdlet uses regular expression matching to search for text patterns in input strings and files. 
            $dictionary = Select-String "^[a-z]{5}$" "/Users/bradleywyatt/Documents/Git Repos/GitHub/RTPSUG/PSWordle/src/dictionary.txt"
        }
        #If we are on Windows
        Else {
            #Get dictionary file
            $dictionary = Select-String "^[a-z]{5}$" "$PSScriptRoot\src\dictionary.txt"
        }
    }
    End {
        #Output all the matching strings from the dictionary file
        $dictionary
    }
}