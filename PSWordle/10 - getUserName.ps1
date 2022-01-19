function Get-ConfigItem {
    param (
        [Parameter()]
        [string]
        $configItem,
        [Parameter()]
        [string]
        $configFile
    )
    Process {
        #get the configured username
        $userName = (Get-Content -Raw -Path $configFile -erroraction:SilentlyContinue | ConvertFrom-Json).$configItem
    }
    End {
        $userName
    }
}