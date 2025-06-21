# ─────────────────────────────────────────────────────────────
# Function Definition (must be declared before usage)
function createDecision {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$functionName
    )
    try {
        Write-Output "Would you like to create it? (Y/N)"
        $response = Read-Host
        if ($response.Trim().ToUpper() -eq "Y") {
            return $functionName
        }
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Output "Error while initiating '$functionName'" $($_.Exception.Message)
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
        Write-Output "❌ Failed to create Virtual Network '$vnetName'. Error: $($_.Exception.Message)"
        return $null
    }
}


function New-NetworkSecurityRuleConfiguration {
    param (
        $nsrcName, $nsrcPriority, $nsrcDestinationPortRange
    )

    try {
        Write-Output "Creating New-NetworkSecurityRuleConfiguration '$nsrcName'..."
        $nsrc = New-AzNetworkSecurityRuleConfig 
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
        return $nsrc
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Error "❌ Error while creating rule '$nsrcName': $($_.Exception.Message)"
    }
    
}

function New-NetworkSecurityGroup {
    param(
        $nsgName, $rgName, $location, $rules
    )    

    try {

        $ruleObjects = @()
        foreach ($rule in $rules) {
            $ruleObj = New-NetworkSecurityRuleConfiguration `
                -nsrcName $rule.Name `
                -nsrcPriority $rule.Priority `
                -nsrcDestinationPortRange $rule.Port `
                -ErrorAction Stop
            if ($ruleObj) {
                $ruleObjects += $ruleObj
            }
        }

        Write-Output "Creating Network Security Group '$nsgName'..."
        $nsg = New-AzNetworkSecurityGroup 
        -Name $nsgName `
            -ResourceGroupName $rgName `
            -Location $location `
            -SecurityRules $ruleObjects `
            -ErrorAction Stop
        return $nsg
    }
    catch {
        Write-Error "❌ Failed to create NSG '$nsgName'. Error: $($_.Exception.Message)"
    }
}

function Get-Subnet {
    param (
        $subnetName, $vnetName , $rgname
    )
    try {
        Write-Output "Getting Subnet with '$subnetName' and with '$vnetName'..."
        $subnet = Get-AzVirtualNetworkSubnetConfig
        -Name $subnetName `
            -VirtualNetwork @(Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rgname)
        -ErrorAction Stop
        return $subnet
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Output "No subnet found '$subnetName' under virtual Network '$vnetName'"
    }
    
}

function New-PublicIpAddress {
    [CmdletBinding()]
    param (
        $pipName, $rgName, $location, $allocationMethod, $sku
    )
        
    try {
        Write-Output "Creating public ip with name '$pipName' and under rg  '$rgName'..."
        $publicIp = New-AzPublicIpAddress 
        -Name $pipName `
            -ResourceGroupName $rgName `
            -Location $location `
            -AllocationMethod $allocationMethod `
            -Sku $sku `
            -ErrorAction Stop
        return $publicIp
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Output "Error Creating the Ip Address" $($_.Exception.Message)
    }
    
}

function New-NetworkInterface {
    param (
        $nicName, $rgName, $location, $subnetId, $nsgId, $pipAddressId
    )
    try {
        Write-Output "Creating Network Interface with name '$nicName' and under rg  '$rgName'..."
        $nic = New-AzNetworkInterface 
        -Name $nicName `
            -ResourceGroupName $rgName `
            -Location $location `
            -SubnetId $subnetId `
            -NetworkSecurityGroup $nsgId `
            -PublicIpAddressId $pipAddressId `
            -ErrorAction Stop
        return $nic
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Output "Error while creating the Network Interface " $($_.Exception.Message)
    }
    
}

function New-Credentials {
    try {
        $user = Read-Host "Enter username"
        $password = Read-Host "Enter password" -AsSecureString
        $cred = New-Object System.Management.Automation.PSCredential ($user, $password)
        return $cred
    }
    catch {
        Write-Error "Failed to create credentials: $_"
    }
}


function New-VmConfig {
    param (
        $vmName, $vmSize, $PublisherName, $Offer, $SKU, $nicId, $securityTypeStnd,
        $OSDiskName, $OSDiskSizeinGB
    )


    try {
        $cred = New-Credentials
        $vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize -SecurityType $securityTypeStnd;
        Set-AzVMOperationSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $cred;
        Set-AzVMOSDisk -VM $vmConfig -StorageAccountType "Premium_LRS" -Caching ReadWrite -Name $OSDiskName -DiskSizeInGB $OSDiskSizeinGB -CreateOption FromImage ;
        Set-AzVMSourceImage -VM $vmConfig -PublisherName $PublisherName -Offer $Offer -Skus $SKU -Version latest ;          
        Add-AzVMNetworkInterface -VM $vmConfig -Id $nicId

    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    
}
# ─────────────────────────────────────────────────────────────
# Main Script Logic

# Prompt user for input
# $rgname = Read-Host "Enter resource group name"
# $location = Read-Host "Enter Azure location (e.g., eastus)"
# $vnetName = "$rgname-vnet"
# $addressPrefix = "10.0.0.0/16"
# $subnetName = "default"
# $subnetPrefix = "10.0.0.0/24"
# $VMSize = "Standard_DS2_v2";                                                                                        
# $PublisherName = "MicrosoftWindowsServer";                                                                          
# $Offer = "WindowsServer";                                                                                           
# $SKU = "2019-Datacenter";  



$rgname = "my-rg";                                                                                      
$location = "eastus";                                                                                                    
$domainNameLabel = "d1" + $rgname;                                                                                  
$vmname = "vm" + $rgname;                                                                                           
$vnetname = "myVnet";                                                                                               
$vnetAddress = "10.0.0.0/16";                                                                                       
$subnetname = "slb" + $rgname;                                                                                      
$subnetAddress = "10.0.2.0/24";                                                                                     
$securityTypeStnd = "Standard";                                                                                     
                                                                                                                        
$OSDiskName = $vmname + "-osdisk";                                                                                  
$NICName = $vmname + "-nic";                                                                                         
$NSGName = $vmname + "-NSG";                                                                                        
$OSDiskSizeinGB = 128;                                                                                              
$VMSize = "Standard_DS2_v2";                                                                                        
$PublisherName = "MicrosoftWindowsServer";                                                                          
$Offer = "WindowsServer";                                                                                           
$SKU = "2019-Datacenter";  

$rules = @(
    @{ Name = "AllowHTTP"; Priority = 100; Port = "80" },
    @{ Name = "AllowHTTPS"; Priority = 200; Port = "443" },
    @{ Name = "AllowSSH"; Priority = 300; Port = "22" }
)


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
