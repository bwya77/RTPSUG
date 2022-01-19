function Set-PSWordleScore {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $User,
        [Parameter(Mandatory)]
        [int]
        $Score,
        [Parameter(Mandatory)]
        [string]
        $Uri
    )
    Begin {
        $Param = @{
            Uri  = $Uri
            Body = @{
                "Request"  = "CheckUser"
                "Username" = $user
            }
        }
        $Results = Invoke-WebRequest @Param 
    }
    Process {
        #If our user is currently on the leaderboard we need to adjust the score
        if ($Results.Content -eq 'True') {
            $ModifiedDateTime = get-date -Format yyyyMMdd:HHmmss
            $Param = @{
                Uri   = $Uri
                Body = @{
                    "Request"          = "AddUser"
                    "Username"         = $User
                    "Score"            = $Score
                    "ModifiedDateTime" = $ModifiedDateTime
                    "IsPresent"        = "true"
                }
            }
            $Results = Invoke-WebRequest @Param 
        }
        #if our user is not currently on the leaderboard, we can just add their score
        else {
            $CreatedDateTime = get-date -Format yyyyMMdd:HHmmss
            $Param = @{
                Uri = $Uri
                Body = @{
                    "Request"          = "AddUser"
                    "Username"         = $User
                    "Score"            = $Score
                    "ModifiedDateTime" = $CreatedDateTime
                    "CreatedDateTime"  = $CreatedDateTime
                    "IsPresent"        = "false"
                }
            }
            $Results = Invoke-WebRequest @Param 
        }
    }
    End
    {
        $Results.Content
    }
}