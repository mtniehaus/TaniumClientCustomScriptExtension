param(
    [Parameter(Mandatory=$true)] [string] $Operation
)

function Install-TaniumClient {

    # Download the right TCM manifest version
    $tcmVersion = "1"
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
    $tcmDest = "$($env:TEMP)\tcm-manifest.json"
    $webClient.DownloadFile($tcmManifest, $tcmDest)

    # Process the manifest (remove the signing hash)
    $tcmManifest = ((Get-Content $tcmDest) -replace "<!--hash=.*-->", "") | ConvertFrom-Json

    # Find the right version
    $version = "7.4.10.1060"
    $versionDetails = $tcmManifest.manifest.platforms.windows.versions.PSObject.properties | Where-Object { $_.Name -eq $version }

    # Download the installer
    $installerDest = "$($env:TEMP)\SetupClient.exe"
    $webClient.DownloadFile($versionDetails.value.url, $installerDest)
    
    # Extract the tanium-init.dat

    # Do the install
}

function Uninstall-TaniumClient {
    # Find the uninstall command in the registry
    
    # Run the uninstall
}

# Main

# Get the settings
$handlerEnvironment = Get-Content "..\..\HandlerEnvironment.json" | ConvertFrom-Json
$settings = Get-Content "$($handlerEnvironment.handlerEnvironment.configFolder)\0.settings" | ConvertFrom-Json
$script:publicSettings = $settings.runtimeSettings[0].handlerSettings.publicSettings
$script:protectedSettings = $settings.runtimeSettings[0].handlerSettings.protectedSettings
$script:publicSettings | Out-Host
$script:protectedSettings | Out-Host

# Do the appropriate operation
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
