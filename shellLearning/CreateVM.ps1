# ─────────────────────────────────────────────────────────────
# Function Definitions

function Get-UserDecision {
    try {
        $response = Read-Host
        return $response.Trim().ToUpper() -eq "Y"
    }
    catch {
        Write-Error "Error during decision prompt: $($_.Exception.Message)"
        return $false
    }
}

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
        Write-Error "❌ Failed to create Virtual Network '$vnetName'. Error: $($_.Exception.Message)"
        return $null
    }
}

function New-NetworkSecurityRuleConfiguration {
    param (
        $nsrcName, $nsrcPriority, $nsrcDestinationPortRange
    )

    try {
        Write-Host "Creating Network Security Rule '$nsrcName'..."
        return New-AzNetworkSecurityRuleConfig `
            -Name $nsrcName `
            -Protocol "Tcp" `
            -Direction "Inbound" `
            -Priority $nsrcPriority `
            -SourceAddressPrefix "*" `
            -SourcePortRange "*" `
            -DestinationAddressPrefix "*" `
            -DestinationPortRange $nsrcDestinationPortRange `
            -Access Allow `
            -ErrorAction Stop
    }
    catch {
        Write-Error "❌ Error creating rule '$nsrcName': $($_.Exception.Message)"
    }
}

function New-NetworkSecurityGroup {
    param (
        $nsgName, $rgName, $location, $rules
    )

    try {
        $ruleObjects = @()
        foreach ($rule in $rules) {
            $ruleObj = New-NetworkSecurityRuleConfiguration `
                -nsrcName $rule.Name `
                -nsrcPriority $rule.Priority `
                -nsrcDestinationPortRange $rule.Port
            if ($ruleObj -is [Microsoft.Azure.Commands.Network.Models.PSSecurityRule]) {
                $ruleObjects += $ruleObj
            }
            else {
                Write-Warning "Invalid rule object skipped: $($ruleObj | Out-String)"
            }

        }

        Write-Output "Creating NSG '$nsgName'..."
        return New-AzNetworkSecurityGroup `
            -Name $nsgName `
            -ResourceGroupName $rgName `
            -Location $location `
            -SecurityRules $ruleObjects `
            -ErrorAction Stop
    }
    catch {
        Write-Error "❌ Failed to create NSG '$nsgName'. Error: $($_.Exception.Message)"
    }
}

function Get-Subnet {
    param (
        $subnetName, $vnetName, $rgName
    )
    try {
        $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -ErrorAction Stop
        return Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
    }
    catch {
        Write-Error "❌ Subnet '$subnetName' not found in VNet '$vnetName': $($_.Exception.Message)"
    }
}

function New-PublicIpAddress {
    param (
        $pipName, $rgName, $location, $allocationMethod, $sku
    )
    try {
        Write-Output "Creating Public IP '$pipName'..."
        return New-AzPublicIpAddress `
            -Name $pipName `
            -ResourceGroupName $rgName `
            -Location $location `
            -AllocationMethod $allocationMethod `
            -Sku $sku `
            -ErrorAction Stop
    }
    catch {
        Write-Error "❌ Failed to create Public IP '$pipName': $($_.Exception.Message)"
    }
}

function New-NetworkInterface {
    param (
        $nicName, $rgName, $location, $subnetId, $pipAddress
    )
    try {
        Write-Output "Creating NIC '$nicName'..."
        return New-AzNetworkInterface `
            -Name $nicName `
            -ResourceGroupName $rgName `
            -Location $location `
            -SubnetId $subnetId `
            # -NetworkSecurityGroup $nsgId `
            -PublicIpAddress $pipAddress `
            -ErrorAction Stop
    }
    catch {
        Write-Error "❌ Failed to create NIC '$nicName': $($_.Exception.Message)"
    }
}

function New-Credentials {
    try {
        $user = Read-Host "Enter username"
        $password = Read-Host "Enter password" -AsSecureString
        return New-Object System.Management.Automation.PSCredential ($user, $password)
    }
    catch {
        Write-Error "❌ Failed to create credentials: $($_.Exception.Message)"
    }
}

function New-VmConfig {
    param (
        $vmName, $vmSize, $PublisherName, $Offer, $SKU, $nicId,
        $OSDiskName, $OSDiskSizeinGB
    )

    try {
        $cred = New-Credentials
        $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
        $vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred
        $vmConfig = Set-AzVMOSDisk -VM $vmConfig -StorageAccountType "Premium_LRS" -Caching ReadWrite -Name $OSDiskName -DiskSizeInGB $OSDiskSizeinGB -CreateOption FromImage
        $vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName $PublisherName -Offer $Offer -Skus $SKU -Version "latest"
        $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nicId
        return $vmConfig
    }
    catch {
        Write-Error "❌ Failed to create VM config for '$vmName': $($_.Exception.Message)"
    }
}

# ─────────────────────────────────────────────────────────────
# Main Script Logic

# Define static or input-based values
# $rgName = "my-rg"
# $location = "eastus"
$rgName = Read-Host "Enter Resource Group Name";
$location = Read-Host "Enter location"
$vmName = "vm-$rgName"
$vnetName = "myVnet$rgName"
$addressPrefix = "10.0.0.0/16"
$subnetName = "slb$rgName"
$subnetPrefix = "10.0.2.0/24"
$OSDiskName = "$vmName-osdisk"
$NICName = "$vmName-nic"
$NSGName = "$vmName-NSG"    
$OSDiskSizeinGB = 128
$VMSize = "Standard_B2ms"
# $securityTypeStnd = "Standard"
$PublisherName = "MicrosoftWindowsServer"
$Offer = "WindowsServer"
# $SKU = "2019-Datacenter-Core"
$SKU = "2022-Azure-Edition"

$rules = @(
    @{ Name = "AllowHTTP"; Priority = 100; Port = "80" },
    @{ Name = "AllowHTTPS"; Priority = 200; Port = "443" },
    @{ Name = "AllowSSH"; Priority = 300; Port = "22" }
)

# Resource Group Check/Create
$rg = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Host "Resource Group '$rgName' does not exist. Create it (Y/N)"
    if (Get-UserDecision ) {
        try {
            New-AzResourceGroup -Name $rgName -Location $location -ErrorAction Stop | Out-Null
            Write-Output "✅ Resource Group '$rgName' created."
        }
        catch {
            Write-Error "❌ Failed to create Resource Group: $($_.Exception.Message)"
            exit
        }
    }
    else {
        Write-Output "⛔ Skipped Resource Group creation. Exiting."
        exit
    }
}
else {
    Write-Output "✅ Resource Group '$rgName' already exists."
}

# Create VNet
$vnet = New-VirtualNetwork $vnetName $rgName $location $addressPrefix $subnetName $subnetPrefix
if (-not $vnet) {
    Write-Error "❌ Virtual Network creation failed. Exiting."
    exit
}
Write-Output "✅ Virtual Network '$($vnet.Name)' created successfully."

# Create NSG
$nsg = New-NetworkSecurityGroup -nsgName $NSGName -rgName $rgName -location $location -rules $rules
if (-not $nsg) {
    Write-Error "❌ NSG creation failed. Exiting."
    exit
}
Write-Output "✅ NSG '$($nsg.Name)' created successfully."

# Create Public IP
$publicIp = New-PublicIpAddress -pipName "$vmName-pip" -rgName $rgName -location $location -allocationMethod "Dynamic" -sku "Basic"
if (-not $publicIp) {
    Write-Error "❌ Public IP creation failed. Exiting."
    exit
}
Write-Output "✅ Public IP '$($publicIp.Name)' created successfully."

# Get Subnet ID
$subnet = Get-Subnet -subnetName $subnetName -vnetName $vnetName -rgName $rgName
if (-not $subnet) {
    Write-Error "❌ Subnet retrieval failed. Exiting."
    exit
}

# Create NIC
$nic = New-NetworkInterface `
    -nicName $NICName `
    -rgName $rgName `
    -location $location `
    -subnetId $subnet.Id `
    -pipAddressId $publicIp

if (-not $nic -or -not $nic) {
    Write-Error "❌ NIC creation failed. Exiting."
    exit
}
Write-Output "✅ NIC '$($nic.Name)' created successfully."

# Create VM configuration
$vmConfig = New-VmConfig `
    -vmName $vmName `
    -vmSize $VMSize `
    -PublisherName $PublisherName `
    -Offer $Offer `
    -SKU $SKU `
    -nicId $nic.Id `
    -OSDiskName $OSDiskName `
    -OSDiskSizeinGB $OSDiskSizeinGB

if (-not $vmConfig) {
    Write-Error "❌ VM configuration failed. Exiting."
    exit
}
Write-Output "✅ VM configuration created."

# Create the Virtual Machine
try {
    Write-Output "Deploying VM '$vmName'..."
    New-AzVM -ResourceGroupName $rgName -Location $location -VM $vmConfig -ErrorAction Stop
    Write-Output "✅ VM '$vmName' successfully deployed."
}
catch {
    Write-Error "❌ Failed to deploy VM '$vmName': $($_.Exception.Message)"
    remove-AzResourceGroup -Name $rgName -Force
}
