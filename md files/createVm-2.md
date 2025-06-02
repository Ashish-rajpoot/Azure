You're right — by default, when you use `New-AzVM` without specifying a public IP configuration, Azure creates a **VM with only private access**.

If your goal is to create a **Windows Server VM with a public IP** (e.g., to connect via RDP on port 3389), you need to explicitly **create and associate a public IP address** with the VM’s network interface (NIC).

---

### ✅ Here’s a full PowerShell script to create a **Windows Server VM with a Public IP**, open ports 80 and 3389:

```powershell
# Set variables
$resourceGroup = "shell-rg"
$location = "eastus"
$vmName = "cloudvm01"
$ipName = "$vmName-ip"
$nicName = "$vmName-nic"
$vnetName = "$vmName-vnet"
$subnetName = "$vmName-subnet"
$nsgName = "$vmName-nsg"
$publicIpSku = "Basic"

# Get credentials
$username = "cloudadmin"
$password = Read-Host -Prompt "Enter password" -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential ($username, $password)

# Create resource group (if not already created)
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create Public IP
$publicIp = New-AzPublicIpAddress -Name $ipName -ResourceGroupName $resourceGroup `
    -Location $location -AllocationMethod Static -Sku $publicIpSku

# Create Virtual Network and Subnet
$vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup `
    -Location $location -AddressPrefix "10.0.0.0/16" `
    -Subnet @(New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.0.0/24")

# Create Network Security Group and Rules
$nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Protocol "Tcp" -Direction "Inbound" `
    -Priority 1000 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" `
    -DestinationPortRange 3389 -Access Allow

$nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Protocol "Tcp" -Direction "Inbound" `
    -Priority 1010 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" `
    -DestinationPortRange 80 -Access Allow

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
    -Name $nsgName -SecurityRules $nsgRuleRDP, $nsgRuleHTTP

# Get subnet and associate NSG
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -Location $location `
    -SubnetId $subnet.Id -NetworkSecurityGroupId $nsg.Id -PublicIpAddressId $publicIp.Id

# Create VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_D2s_v3" |
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate |
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter" -Version "latest" |
    Add-AzVMNetworkInterface -Id $nic.Id

# Create the VM
New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
```

---

### 🔑 What This Script Does:

- Creates a **virtual network** and **subnet**.
- Creates a **public IP address**.
- Opens **port 3389 (RDP)** and **port 80 (HTTP)** in the **NSG**.
- Creates and links all resources, then deploys the VM.

---

### ✅ After Success:

You can get the public IP to connect via RDP:

```powershell
(Get-AzPublicIpAddress -ResourceGroupName $resourceGroup -Name $ipName).IpAddress
```

Let me know if you want to use a different VM size or customize this further!
