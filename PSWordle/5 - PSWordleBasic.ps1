function Get-PSWordleDictionary {
    Begin {
        $Platform = [System.Environment]::OSVersion.Platform
    }
    Process {
        if ($Platform -eq "Unix") {
            #Get dictionary file
            $dictionary = Select-String "^[a-z]{5}$" "/Users/bradleywyatt/Documents/Git Repos/GitHub/RTPSUG/PSWordle/src/dictionary.txt"
        }
        #If we are on Windows
        Else {
            #Get dictionary file
            $dictionary = Select-String "^[a-z]{5}$" "$PSScriptRoot\src\dictionary.txt"
        }
    }
    End {
        $dictionary
    }
}
function New-PSWordleWord {
    begin {
        #Figure out what platform we're on
        $Platform = [System.Environment]::OSVersion.Platform
        #If we are on Unix
        if ($Platform -eq "Unix") {
            #Get 5 letter words from the files
            $words = Select-String "^[a-z]{5}$" "/Users/bradleywyatt/Documents/Git Repos/GitHub/RTPSUG/PSWordle/src/words.txt"   
        }
        #If we are on Windows
        Else {
            #Get 5 letter words from the files
            $words = Select-String "^[a-z]{5}$" "$PSScriptRoot\src\words.txt"
        }
    }
    process {
        #Get a random word from the word list
        Get-Random $Words
    }
}
Function Get-MatchedItems {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Guess,
        [Parameter()]
        [string]
        $Word
    )
    Begin {
        [array]$changechars = @()
        [int]$count = -1
        [string]$guessNew = ""
    }
    Process {
        0..4 | ForEach-Object {
            $count++
            if ($guess[$_] -eq $word[$_]) {
                $changechars += $count
            }
        }
        [int]$count = -1
        
        $Guess.ToCharArray() | ForEach-Object {
            $Count++
            if ($count -in $changechars) {
                $guessNew += $_
            }
            Else {
                $guessNew += "*"
            }
        }
    }
    End {
        $guessNew.toupper()
    }
}
Function New-PSWordleGame {
    Begin {
        #Get a new random word
        $Word = New-PSWordleWord
        #Get Dictionary words
        $dictionaryWords = Get-PSWordleDictionary
        #Int counter to keep track of the number of times we have tried to guess the word
        [int]$guessCount = 1
        $wordleShare = "", "", "", "", "", "", ""
        #For hard mode, keep an array of correctly guessed letters
        [array]$correctLetters = @()
        #Create a variable to hold the letters that have been guessed
        [array]$guessedLetters = @()
        #Create a empty hashtable / dictionary that will hold letters that are NOT in the word
        [string[]]$notLetters = @()
            #region <start> New game prompt and directions
            "
 _  _   __  ____  ____  __    ____ 
/ )( \ /  \(  _ \(    \(  )  (  __)
\ /\ /(  O ))   / ) D (/ (_/\ ) _) 
(_/\_) \__/(__\_)(____/\____/(____)
                       "
"The WORDLE word is 5 characters long."
Write-Host -ForegroundColor Green "GREEN" -NoNewline; Write-Host " means the letter is in the word and in the correct spot"
Write-Host -ForegroundColor Yellow "YELLOW" -NoNewline; Write-Host " means the letter is in the word but in the wrong spot"
Write-Host -ForegroundColor DarkGray "GRAY" -NoNewline; Write-Host " means the letter is not in the word"
        #region <end>
    }
    Process {
        while ($true) {
            If ($notLetters.count -gt 0)
            {
                Write-Host "Not in the word: $($notLetters | Sort-Object)" -ForegroundColor DarkGray
            }
            #Clear the guessed letter array
            $guessedLetters = @()
            #Prompt the user for a guess
            [string]$guess = (Read-Host "($guessCount) Guess a 5-letter word").ToUpper()
            
            #If you guess is the word, you win
            if ($guess -eq $word.Line) {
                #If we are running on PWSH then we can use emojis
                if ($PSVersionTable.PSEdition -eq "Core")
                {
                    Write-Host
                    Write-Host "🎉💥 You Win! 💥🎉" -ForegroundColor Green; $wordleShare[$guessCount] = "🟩" * 5; break
                }
                #If we are running on Windows PowerShell then we can't use emojis
                else {
                    Write-Host
                    Write-Host "You Win!" -ForegroundColor Green; $wordleShare[$guessCount] = "*" * 5; break
                }
            }
            #If your guess is too short or too long
            if ($guess.Length -ne 5) {
                Write-Host "Your guess must be 5 letters!" -ForegroundColor Red; continue 
            }
            #If the guess appears to not be a valid word
            if ($guess -notin $dictionaryWords.Line) {
                Write-Host "That word is not in our dictionary, please try again." -ForegroundColor Red ; continue 
            }
            #Get all letters that have been guessed in the correct spots
            [string]$Matches = Get-MatchedItems -Guess $Guess -Word $Word.line
            #for (<Init>; <Condition>; <Repeat>) { <Body> }
            #for 5 loops, do the following ( start at 0, while the number is less than 5 run the block, afterwards increment the number by 1)
            for ($pos = 0; $pos -lt 5; $pos++) {
                $shareImage = "⬛️"
                #Add guessed letters to the array
                
                #region <start> Reduce letter false positives
                $guessedLetters += $guess[$pos]
                #See how many instances of the guessed letter there are in the word
                [int32]$Appearances = ($Word.line[0..4] -eq $guess[$pos]).count
                #If we have guessed the letter more than it appears in the word
                    if ($guess[$pos] -eq $word.Line[$pos]) {
                        #Add the letter to the correct letters array
                        $correctLetters += $guess[$pos]

 
                        Write-Host -ForegroundColor Green $guess[$pos] -NoNewLine; $shareImage = "🟩" 
                    }
                    #If the letter is in the word, but not in the correct position, we have guessed the letter, but not the correct position
                    elseif ($guess[$pos] -in $word.Line.ToCharArray()) {
                        # If the letter only appears once, and its in the $Matches string indicating that its in the correct spot, then any other instance of the letter is incorrect
                        if (($Appearances -eq 1) -and ($Matches.ToCharArray() -contains $guess[$pos])) {
                            Write-Host -ForegroundColor DarkGray $guess[$pos] -NoNewLine; $shareImage = "⬛️" 
                        }
                        # Get the letters from the guessed word up until the current letter and then see how many times the current character appears
                        # Then get the times the current letter appears in the word
                        # If the guessed letter is stil lower than the total times it shows up in the word, then its valid but in the wrong spot
                        elseif(($guess[0..$pos] -eq $guess[$pos]).Count -le ($word.Line.ToCharArray() -eq $guess[$pos]).Count) {
                            #Add the letter to the correct letters array
                            $correctLetters += $guess[$pos]
                            Write-Host -ForegroundColor Yellow $guess[$pos] -NoNewLine; $shareImage = "🟨" 
                        }
                        Else {
                            #Add the letter to the correct letters array
                            $correctLetters += $guess[$pos]
                            Write-Host -ForegroundColor DarkGray $guess[$pos] -NoNewLine; $shareImage = "⬛️" 
                        }
                    }
                    else {
                        Write-Host -ForegroundColor DarkGray $($guess[$pos]) -NoNewLine 
                        if (-not($notLetters -contains $guess[$pos])) {
                            #Add our guessed letter to the array
                            $notLetters += $guess[$pos]
                        }
                    }
                
                $wordleShare[$guessCount - 1] += $shareImage 
            }
    
            $guessCount++
            if ($guessCount -eq 7) {
                #If you did not guess the word in 6 guesses, replace the guess counter with a X
                [string]$guessCount = "X"
                Write-Host; Write-Host "Too many guesses! The right word was: '$($word.Line.toupper())'"
                break 
            }
            Write-Host
        }
    }
    End {
        #If we are running on PWSH or Windows PowerShell, if Windows PowerShell we cannot display emojis
        if ($PSVersionTable.PSEdition -eq "Core") {
            Write-Host "PSWORDLE $($word.LineNumber) $guessCount/6`r`n"
            $wordleShare | Where-Object { $_ }
        }
        Else {
            #Display the line number the wordle word was found on as well as how many guesses it took
            Write-Host "PSWORDLE $($word.LineNumber) $guessCount/6`r`n"
        }
    }
}