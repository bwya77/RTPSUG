function Get-PSWordleLeaderboardUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $userName,
        [Parameter(Mandatory)]
        [string]
        $Uri

    )
    begin
    {
        $Param = @{
            Uri = $Uri
            Body = @{
                "Request"  = "CheckUser"
                "Username" = $username
            }
        }
    }
    Process
    {
        $Results = Invoke-WebRequest @Param
    }
    End 
    {
        $Results.Content
    }
}