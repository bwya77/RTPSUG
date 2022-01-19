Function New-PSWordleGame {
    Begin {
        #Get a new random word
        $Word = New-PSWordleWord
        #Get Dictionary words
        $dictionaryWords = Get-PSWordleDictionary
        #Int counter to keep track of the number of times we have tried to guess the word
        [int]$guessCount = 1
        $wordleShare = "", "", "", "", "", "", ""
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
            If ($notLetters.count -gt 0) {
                #If we have letters that are NOT in the word, display to the user the letters that are NOT in the word in alphabetical order
                Write-Host "Not in the word: $($notLetters | Sort-Object)" -ForegroundColor DarkGray
            }
            #Prompt the user for a guess
            [string]$guess = (Read-Host "($guessCount) Guess a 5-letter word").ToUpper()
            
            #If you guess is the word, you win
            if ($guess -eq $word.Line) {
                #If we are running on PWSH then we can use emojis
                if ($PSVersionTable.PSEdition -eq "Core") {
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
                #continue statement immediately returns the program flow to the top of a program loop
                Write-Host "Your guess must be 5 letters!" -ForegroundColor Red; continue 
            }
            #If the guess appears to not be a valid word
            if ($guess -notin $dictionaryWords.Line) {
                #continue statement immediately returns the program flow to the top of a program loop
                Write-Host "That word is not in our dictionary, please try again." -ForegroundColor Red ; continue 
            }
            #Get all letters that have been guessed in the correct spots
            [string]$Matches = Get-MatchedItems -Guess $Guess -Word $Word.line
            #for (<Init>; <Condition>; <Repeat>) { <Body> }
            #for 5 loops, do the following ( start at 0, while the number is less than 5 run the block, afterwards increment the number by 1)
            for ($pos = 0; $pos -lt 5; $pos++) {
                $shareImage = "⬛️"                
                #See how many instances of the guessed letter there are in the word
                [int32]$Appearances = ($Word.line[0..4] -eq $guess[$pos]).count
                #If we have correctly guessed the letter in the correct position
                if ($guess[$pos] -eq $word.Line[$pos]) {
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
                    elseif (($guess[0..$pos] -eq $guess[$pos]).Count -le ($word.Line.ToCharArray() -eq $guess[$pos]).Count) {
                        Write-Host -ForegroundColor Yellow $guess[$pos] -NoNewLine; $shareImage = "🟨" 
                    }
                    Else {
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
                # Take the share image (line of emojis) previous line (previous line because we are ahead by 1 each loop) and add to the shareimage array
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