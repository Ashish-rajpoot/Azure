Absolutely! You can add checks for each resource to see if it exists, and only create it if it does **not** already exist. This way, your script becomes idempotent and skips creation for existing resources.

Here’s how you can wrap each resource creation with an `if` statement:

---

### Example with `if` condition:

```powershell
# Check and create Resource Group
if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Output "Creating Resource Group: $resourceGroup"
    New-AzResourceGroup -Name $resourceGroup -Location $location
} else {
    Write-Output "Resource Group $resourceGroup already exists. Skipping creation."
}

# Check and create Public IP
if (-not (Get-AzPublicIpAddress -Name $ipName -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Output "Creating Public IP: $ipName"
    $publicIp = New-AzPublicIpAddress -Name $ipName -ResourceGroupName $resourceGroup `
        -Location $location -AllocationMethod Static -Sku $publicIpSku
} else {
    Write-Output "Public IP $ipName already exists. Skipping creation."
    $publicIp = Get-AzPublicIpAddress -Name $ipName -ResourceGroupName $resourceGroup
}

# Check and create Virtual Network
if (-not (Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Output "Creating Virtual Network: $vnetName"
    $vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup `
        -Location $location -AddressPrefix "10.0.0.0/16" `
        -Subnet @(New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix "10.0.0.0/24")
} else {
    Write-Output "Virtual Network $vnetName already exists. Skipping creation."
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup
}

# Check and create Network Security Group
if (-not (Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Output "Creating Network Security Group: $nsgName"
    $nsgRuleRDP = New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Protocol "Tcp" -Direction "Inbound" `
        -Priority 1000 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" `
        -DestinationPortRange 3389 -Access Allow

    $nsgRuleHTTP = New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Protocol "Tcp" -Direction "Inbound" `
        -Priority 1010 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" `
        -DestinationPortRange 80 -Access Allow

    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
        -Name $nsgName -SecurityRules $nsgRuleRDP, $nsgRuleHTTP
} else {
    Write-Output "Network Security Group $nsgName already exists. Skipping creation."
    $nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup
}

# Check and create Network Interface
if (-not (Get-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Output "Creating Network Interface: $nicName"
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
    $nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup -Location $location `
        -SubnetId $subnet.Id -NetworkSecurityGroupId $nsg.Id -PublicIpAddressId $publicIp.Id
} else {
    Write-Output "Network Interface $nicName already exists. Skipping creation."
    $nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroup
}
```

---

### VM creation note

For the VM itself, you might want to check if it exists and skip or update it:

```powershell
if (-not (Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue)) {
    Write-Output "Creating VM: $vmName"

    # VM config (as before)
    $vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_D2s_v3" |
        Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate |
        Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter" -Version "latest" |
        Add-AzVMNetworkInterface -Id $nic.Id

    $vmConfig = Set-AzVMSecurityProfile -VM $vmConfig -SecurityType "Standard"

    New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
} else {
    Write-Output "VM $vmName already exists. Skipping creation."
}
```

---

### Summary

- Use `Get-*` commands with `-ErrorAction SilentlyContinue` to check resource existence.
- Use `if (-not ...)` to create only if missing.
- Store existing resources in variables so later steps can use them.

---

If you want, I can help you build a full script with these checks included! Would you like that?
