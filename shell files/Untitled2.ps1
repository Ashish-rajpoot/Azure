$rgname = Read-Host "enter rg-name"
$location =  Read-Host "enter location"
$publicIpName = "$rgname-pip"
$dnsPrefix = "$rgname-dns"

 New-AzResourceGroup -Name TestResourceGroup -Location centralus
    $frontendSubnet = New-AzVirtualNetworkSubnetConfig -Name frontendSubnet -AddressPrefix "10.0.1.0/24"
    $backendSubnet  = New-AzVirtualNetworkSubnetConfig -Name backendSubnet  -AddressPrefix "10.0.2.0/24"
    New-AzVirtualNetwork -Name MyVirtualNetwork -ResourceGroupName TestResourceGroup -Location centralus -AddressPrefix "10.0.0.0/16" -Subnet $frontendSubnet,$backendSubnet



if(-not(get-AzResourceGroup -Name $rgname -ErrorAction silentlyContinue )){
Write-Output "$rgname : does not exist would you like to create"
$response= Read-Host
if($response.Trim().ToUpper() -eq "Y"){

}else{
Write-Output "Resourse Group creation skkiped"
}

}else{
Write-Output "$rgname : does not exist would you like to create"
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
