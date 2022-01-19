function New-PSWordleWord {
    begin {
        #Figure out what platform we're on
        $Platform = [System.Environment]::OSVersion.Platform
        #If we are on Unix
        if ($Platform -eq "Unix") {
            #Get 5 letter words from the files
            # The Select-String cmdlet uses regular expression matching to search for text patterns in input strings and files. 
            $words = Select-String "^[a-z]{5}$" "/Users/bradleywyatt/Documents/Git Repos/GitHub/RTPSUG/PSWordle/src/words.txt"   
        }
        #If we are on Windows
        Else {
            #Get 5 letter words from the files
            $words = Select-String "^[a-z]{5}$" "$PSScriptRoot\src\words.txt"
        }
    }
    process {
        #Get a random word from the word list and ouput it
        Get-Random $Words
    }
}