function Set-ConfigItem {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $configItemName,
        [Parameter()]
        [string]
        $configItemValue,
        [Parameter()]
        [string]
        $configFile
    )
    begin {
        if ([System.Environment]::OSVersion.Platform -eq "Unix") {
            [string]$configFile = "$env:HOME\PSWordle\config.json"
        }
        Else {
            [string]$configFile = "$env:APPDATA\PSWordle\config.json"
        }
    }
    Process {
        $myObject = [PSCustomObject]@{
            $configItemName = $configItemValue
        }
        #export myObject to JSON
        $myObject | ConvertTo-Json | Out-File $configFile -Force
    }
}