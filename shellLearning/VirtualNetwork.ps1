# ─────────────────────────────────────────────────────────────
# Function Definition (must be declared before usage)
function New-VirtualNetwork {
    param (
        $vnetName, $rgName, $location, $addressPrefix, $subnetName, $subnetPrefix
    )

    try {
        Write-Output "Creating Virtual Network '$vnetName' with subnet '$subnetName'..."
        $subnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetPrefix
        return New-AzVirtualNetwork -Name $vnetName `
            -ResourceGroupName $rgName `
            -Location $location `
            -AddressPrefix $addressPrefix `
            -Subnet $subnet `
            -ErrorAction Stop
    }
    catch {
        Write-Output "❌ Failed to create Virtual Network '$vnetName'. Error: $($_.Exception.Message)"
        return $null
    }
}
# ─────────────────────────────────────────────────────────────
# Main Script Logic

# Prompt user for input
$rgname = Read-Host "Enter resource group name"
$location = Read-Host "Enter Azure location (e.g., eastus)"
$vnetName = "$rgname-vnet"
$addressPrefix = "10.0.0.0/16"
$subnetName = "default"
$subnetPrefix = "10.0.0.0/24"

# Check if Resource Group exists
$rg = Get-AzResourceGroup -Name $rgname -ErrorAction SilentlyContinue

if (-not $rg) {
    Write-Output "Resource Group '$rgname' does not exist. Would you like to create it? (Y/N)"
    $response = Read-Host
    if ($response.Trim().ToUpper() -eq "Y") {
        try {
            New-AzResourceGroup -Name $rgname -Location $location -ErrorAction Stop | Out-Null
            Write-Output "✅ Resource Group '$rgname' created."
        }
        catch {
            Write-Output "❌ Failed to create Resource Group '$rgname'. Error: $($_.Exception.Message)"
            exit
        }
    }
    else {
        Write-Output "⛔ Resource Group creation skipped. Exiting."
        exit
    }
}
else {
    Write-Output "✅ Resource Group '$rgname' already exists."
}

# Create VNet
$vnet = New-VirtualNetwork $vnetName $rgname $location $addressPrefix $subnetName $subnetPrefix

if ($vnet) {
    Write-Output "✅ Virtual Network '$($vnet.Name)' is ready."
}
else {
    Write-Output "❌ Virtual Network creation failed."
}
