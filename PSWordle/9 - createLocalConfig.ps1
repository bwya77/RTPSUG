function Get-ConfigFile {
    Begin {
        if ([System.Environment]::OSVersion.Platform -eq "Unix") {
            [string]$configFile = "$env:HOME\PSWordle\config.json"
        }
        Else {
            [string]$configFile = "$env:APPDATA\PSWordle\config.json"
        }
    }
    Process {
        if (-not(Test-Path -Path $configFile)) {
            #New-Item -ItemType Directory -Path $configFile -Force | Out-Null
            New-Item -ItemType File -Path $configFile -Force | Out-Null
        }
    }
    End {
        $configFile
    }
}