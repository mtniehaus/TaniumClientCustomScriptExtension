param(
    [Parameter(Mandatory=$true)] [string] $Operation
)

# Get the passed-in settings
$script:HandlerEnvironment = Get-Content "HandlerEnvironment.json" | ConvertFrom-Json
# TODO: build the right file name based on the handler environment: ConfigFolder + seqNo + .settings
$script:Settings = Get-Content "TaniumClient.settings" | ConvertFrom-Json

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

    # Find the right version
    $version = "7.4.10.1060"
    $versionDetails = $m.manifest.platforms.windows.versions.PSObject.properties | Where-Object { $_.Name -eq $version }

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