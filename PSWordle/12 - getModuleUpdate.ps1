function Get-PSWordleUpdate {
    begin {
        [string]$version = "0.0.8"
        try { 
            [string]$PublishedVersion = (Invoke-RestMethod "https://raw.githubusercontent.com/bwya77/PSModules/main/PSWordle/version.txt").Trim()
        } 
        catch {
            $_.Exception.Response.StatusCode.Value__
        }
    }
    Process {
        if (($version -ne $PublishedVersion) -and ($PublishedVersion.count -gt 0)) {
            [string]$Message = "A new version of PSWordle is available! 
Current version: $version
Published version: $PublishedVersion
Please run Update-Module -Name PSwordle to grab the latest version.

Note: You can hide the update message by including the -IgnoreUpdates parameter when starting a new game"
        }
    }
    End {
        $Message
    }
}