function New-PSWordleUser {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $userName
    )
    Begin {

    }
    Process {
        While ($true) {
            Write-Host "Checking online to see if that username is available"
            $Check = Get-PSWordleLeaderboardUser -username $userName -Uri "https://funpswordle.azurewebsites.net/api/wordleleaderboard?code=LesznI7agk9vyt3pEu1YCb4ehbo4Mz1lQHewvRfgaw/FNOPXQMiSLg=="

            # It's returning a string not a boolean so I need to format the IF statement this way
            if ($Check -eq "True") {
                Write-Host "That username is already taken! Please enter a new one." -ForegroundColor Yellow
                $userName = Read-Host -Prompt "Please enter a new UserName "
            }
            else {
                Write-Host "Success! Username is available" -ForegroundColor Green; break
            }
        }
    }
    End {
        Set-ConfigItem -ConfigItemName username -ConfigItemValue $username
        $userName
    }
}