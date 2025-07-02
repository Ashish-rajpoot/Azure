$def_name = "alex"
$rg_name = "$def_name-rg"
$location = 'eastus'
$vnet_name = "$rg_name-vnet"
$vnet_add_prefix = "10.0.0.0/16"
$subnet_1 = "frontend-subnet"
$sub_add_prefix = "10.0.1.0/24"
$pip_name = "mypublic-ip"
$pip_sku = "Standard"

$nsg_name = "$def_name-nsg"

$nic_name = "$def_name-nic"

$vm_name = "$def_name-vm"
$vm_win_image = "2022-datacenter-azure-edition"
$storage_sku = "Standard_LRS"
#####
# rg
# vnet
# subnet
# pip
# nsg
# nsg_rule
# nic
# vm


az group create --name $rg_name --location $location

az network vnet create `
    --resource-group $rg_name `
    --name $vnet_name `
    --location $location `
    --address-prefix $vnet_add_prefix

az network subnet create `
    --resource-group $rg_name `
    --name $subnet_1 `
    --vnet-name $vnet_name `
    --address-prefix $sub_add_prefix

az network public-ip create `
    --resource-group $rg_name `
    --name $pip_name `
    --location $location `
    --sku $pip_sku `
    --version "IPV4" `

az network nsg create `
    --resource-group $rg_name `
    --name $nsg_name `
    --location $location

az network nsg rule create `
    --resource-group $rg_name `
    --nsg-name $nsg_name `
    --name "ALLOW-HTTP" `
    --protocol "TCP" `
    --priority "1000" `
    --source-address-prefix "*" `
    --source-port-range "*" `
    --destination-address-prefix "*" `
    --destination-port-range "80" `
    --access "Allow" `
    --direction "Inbound"

az network nic create `
    --resource-group $rg_name `
    --name $nic_name `
    --vnet-name $vnet_name `
    --subnet $subnet_1 `
    --public-ip-address $pip_name `
    --network-security-group $nsg_name

az vm create `
    --resource-group $rg_name `
    --name $vm_name `
    --image $vm_win_image `
    --admin-username "cloudadmin" `
    --admin-password "sharepoint142@" `
    --storage-sku $storage_sku `
    --nics $nic_name `

