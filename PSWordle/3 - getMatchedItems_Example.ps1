# We want to know if there are correctly guessed letter later in the word and that are present in the word multiple times
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
        # Keeps the index value of correctly guessed letters (ex: '0 4' would mean the first and 3rd letter were guessed correctly)
        [array]$changechars = @()
        [int]$count = -1
        # Create a string for out outputted text
        [string]$guessNew = ""
    }
    Process {
        0..4 | ForEach-Object {
            $count++
            # If the guessed letter equals the letter in the word, it is in the correct spot
            if ($guess[$_] -eq $word[$_]) {
                $changechars += $count
            }
        }
        [int]$count = -1
        # Iterate through the guessed letters
        $Guess.ToCharArray() | ForEach-Object {
            $Count++
            # If the current characters index is a correctly guessed letter, store the letter in a new string
            if ($count -in $changechars) {
                $guessNew += $_
            }
            # If the current characters index value is not in the $changechars array, then replace the letter with a *
            Else {
                $guessNew += "*"
            }
        }
    }
    End {
        $guessNew.toupper()
    }
}
# Example 1: There are two D's in the word, 3 in the guess. The 2 D's are in the correct place so the first D in the guess should be excluded as there are no more D's in the word
# Output should be **DD*
Get-MatchedItems -Guess "DADDY" -Word "KIDDO"
# Example 2: The word and guess contain 2 S's. One S is in the correct spot
# Output should be ****S
Get-MatchedItems -Guess "STARS" -Word "OUSTS"
# Example 3: The word contains 1 D. The guess contains 3 D's. The 3rd D is in the correct spot so the other D's should be excluded
# Output should be ***D*
Get-MatchedItems -Guess "DADDY" -Word "ABODE"
