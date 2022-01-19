function Get-PSWordleLeaderBoard {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Uri = "https://funpswordle.azurewebsites.net/api/wordleleaderboard?code=LesznI7agk9vyt3pEu1YCb4ehbo4Mz1lQHewvRfgaw/FNOPXQMiSLg=="
    )
    begin{
        $Platform = [System.Environment]::OSVersion.Platform
    }
    process{
        $Param = @{
            Uri  = $Uri
            Body = @{
                "Request" = "Results"
            }
        }
        $Results = Invoke-WebRequest @Param
    }
    end {
        #Get the results back which come back as JSON, convert to a object
        if ($Platform -eq "Unix") {
            $Results.Content | ConvertFrom-Json | select-object PlayerTag, @{N="Score"; E={[int32]$_.Score}} | sort-object Score -Descending
        }
        Else
        {
            $data = $Results.Content | ConvertFrom-Json 
            $data | select-object PlayerTag, @{N="Score"; E={[int32]$_.Score}} | sort-object Score -Descending
        }
    }
}