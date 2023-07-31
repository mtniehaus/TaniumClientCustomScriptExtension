# Requirements:
# 1.  Install Az module using "install-module Az -AllowClobber"
# 2.  Connect-AzAccount
# 3.  Fill in the values and paths below.
# 4.  Run this script.
$resourceGroup = "test-server_group"
$location = "eastus"
$vmName = "test-server"
$taniumInit = "C:\Users\Administrator\Downloads\tanium-init.dat"

# Encode the tanium-init.dat as base64
$initContent = Get-Content $taniumInit -Encoding Byte -Raw
$encodedInitContent = [convert]::ToBase64String($initContent)

$fileUris = @("https://raw.githubusercontent.com/mtniehaus/TaniumClientCustomScriptExtension/main/TaniumClient.ps1")
$settings = @{"fileUris" = $fileUris};
$protectedSettings = @{"manifestVersion" = "3"; "clientVersion" = "7.4.10.1060"; "taniumInit" = $encodedInitContent; "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File TaniumClient.ps1 install"};

# Create the script extension
Set-AzVMExtension -ResourceGroupName $resourceGroup `
    -Location $location `
    -VMName $vmName `
    -Name "InstallTaniumClient" `
    -Publisher "Microsoft.Compute" `
    -ExtensionType "CustomScriptExtension" `
    -TypeHandlerVersion "1.10" `
    -Settings $settings `
    -ProtectedSettings $protectedSettings;
