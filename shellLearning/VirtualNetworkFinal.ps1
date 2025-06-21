# ─────────────────────────────────────────────────────────────
# Function Definition (must be declared before usage)
function New-VirtualNetwork {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$vnetName,

        [Parameter(Mandatory = $true)]
        [string]$rgName,

        [Parameter(Mandatory = $true)]
        [string]$location,

        [Parameter(Mandatory = $true)]
        [ValidatePattern("^\d{1,3}(\.\d{1,3}){3}/\d{1,2}$")]
        [string]$addressPrefix,

        [Parameter(Mandatory = $true)]
        [string]$subnetName,

        [Parameter(Mandatory = $true)]
        [ValidatePattern("^\d{1,3}(\.\d{1,3}){3}/\d{1,2}$")]
        [string]$subnetPrefix
    )

    try {
        Write-Verbose "Creating Virtual Network '$vnetName' in resource group '$rgName' at location '$location'"
        Write-Verbose "VNet Address Prefix: $addressPrefix"
        Write-Verbose "Subnet Name: $subnetName, Prefix: $subnetPrefix"

        $subnet = New-AzVirtualNetworkSubnetConfig `
            -Name $subnetName `
            -AddressPrefix $subnetPrefix

        $vnet = New-AzVirtualNetwork `
            -Name $vnetName `
            -ResourceGroupName $rgName `
            -Location $location `
            -AddressPrefix $addressPrefix `
            -Subnet $subnet `
            -ErrorAction Stop

        Write-Verbose "✅ Virtual Network '$vnetName' created successfully."
        return $vnet
    }
    catch {
        Write-Error "❌ Failed to create Virtual Network '$vnetName'. Error: $($_.Exception.Message)"
        return $null
    }
}


function NetworkSecurityRuleConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$nsrcName,

        [Parameter(Mandatory = $true)]
        [ValidateRange(100, 4096)]
        [int]$nsrcPriority,

        [Parameter(Mandatory = $true)]
        [ValidatePattern('^\d+(-\d+)?$')]
        [string]$nsrcDestinationPortRange,

        [ValidateSet("Tcp", "Udp", "*")]
        [string]$Protocol = "Tcp",

        [ValidateSet("Inbound", "Outbound")]
        [string]$Direction = "Inbound"
    )

    try {
        Write-Verbose "Creating network security rule: $nsrcName"
        Write-Verbose "Priority: $nsrcPriority, Port: $nsrcDestinationPortRange, Protocol: $Protocol, Direction: $Direction"

        $nsrc = New-AzNetworkSecurityRuleConfig `
            -Name $nsrcName `
            -Protocol $Protocol `
            -Direction $Direction `
            -Priority $nsrcPriority `
            -SourceAddressPrefix "*" `
            -SourcePortRange "*" `
            -DestinationAddressPrefix "*" `
            -DestinationPortRange $nsrcDestinationPortRange `
            -Access "Allow" `
            -ErrorAction Stop

        return $nsrc
    }
    catch {
        Write-Error "❌ Error while creating network security rule '$nsrcName': $_"
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
