param(
    [Parameter(Mandatory=$true)] [string] $Operation
)

function Install-TaniumClient {

    # Download the right TCM manifest version
    $tcmVersion = $script:publicSettings.manifestVersion
    switch ($tcmVersion) {
        "1" {
            $tcmManifest = "https://content.tanium.com/files/tcm/tcm-manifest.json.signed"
        }
        "2" {
            $tcmManifest = "https://content.tanium.com/files/tcm/tcm-manifest.v2.json.signed"
        }
        "3" {
            $tcmManifest = "https://content.tanium.com/files/tcm/tcm-manifest.v3.json.signed"
        }
    }
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36") 
    $webClient.Headers.Add("Content-Type","application/octet-stream")
    $tcmDest = "$($env:TEMP)\tcm-manifest.json"
    $webClient.DownloadFile($tcmManifest, $tcmDest)

    # Process the manifest (remove the signing hash)
    $tcmManifest = ((Get-Content $tcmDest) -replace "<!--hash=.*-->", "") | ConvertFrom-Json

    # Find the right version
    $version = $script:publicSettings.clientVersion
    $versionDetails = $tcmManifest.manifest.platforms.windows.versions.PSObject.properties | Where-Object { $_.Name -eq $version }

    # Download the installer
    $installerDest = "$($env:TEMP)\SetupClient.exe"
    Write-Host "Downloading from $($versionDetails.value.url)"
    $webClient.DownloadFile($versionDetails.value.url, $installerDest)
    
    # Extract the tanium-init.dat
    $tiEncoded = $script:publicSettings.taniumInit
    $taniumInit = [Convert]::FromBase64String($tiEncoded)
    $taniumInit | Out-File -FilePath "$($env:TEMP)\tanium-init.dat"

    # Do the install
    Write-Host "Installing Tanium Client"
    & "$($env:TEMP)\SetupClient.exe" /S /KeyPath=$($env:TEMP)\tanium-init.dat | Out-Null

    # Clean up temporary files
    Remove-Item "$($env:TEMP)\tcm-manifest.json"
    Remove-Item "$($env:TEMP)\SetupClient.exe"
    Remove-Item "$($env:TEMP)\tanium-init.dat"
}

function Uninstall-TaniumClient {
    # Find the uninstall command in the registry
    $uninstallCommand = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Tanium Client" -Name "UninstallString"

    # Run the uninstall
    Write-Host "Uninstalling Tanium Client using command: $uninstallCommand /s"
    & "$uninstallCommand" /s | Out-Null
}

# Main

# Get the settings
$handlerEnvironment = Get-Content "..\..\HandlerEnvironment.json" | ConvertFrom-Json
$settings = Get-Content "$($handlerEnvironment.handlerEnvironment.configFolder)\0.settings" | ConvertFrom-Json
$script:publicSettings = $settings.runtimeSettings[0].handlerSettings.publicSettings
$script:protectedSettings = $settings.runtimeSettings[0].handlerSettings.protectedSettings

# Do the appropriate operation
Write-Host "Operation: $Operation"
switch ($Operation) {
    "install" {
        Install-TaniumClient
    }
    "uninstall" {
        Uninstall-TaniumClient
    }
    "update" {
        Write-Host "Update not implemented"
    }
    "enable" {
        Write-Host "Enable not implemented"
    }
    "disable" {
        Write-Host "Disable not implemented"
    }
    default {
        Write-Host "Invalid operation specified: $Operation"
    }
}
