# Define variables
$location = "eastus"
$resourceGroupName = "my-rg" # The name of the resource group defined in rg-template.json
$rgDeploymentName = "DeployResourceGroupTemplate" # A unique name for the RG deployment
$storageDeploymentName = "DeployStorageAccountTemplate" # A unique name for the Storage deployment
$vnetDeploymentName = "VirtualNetworkTemplate"
$pipDeploymentName = "PublicIpTemplate"

$rg_template = ".\rg-template.json"
$storage_template = ".\storage_template.json"
$vnet_template = ".\vnet_template.json"
$pip_template = ".\PublicIpTemplate.json"


# 1. Deploy the Resource Group (Subscription-Level Deployment)
# Use New-AzSubscriptionDeployment or New-AzDeployment (subscription scope)
# This creates the resource group 'my-rg'
Write-Host "Deploying Resource Group '$resourceGroupName' to subscription..."
New-AzDeployment -Name $rgDeploymentName -Location $location -TemplateFile $rg_template -Verbose

# Add a slight delay to ensure the resource group is fully provisioned before trying to deploy into it
# In a real pipeline, you might use deployment dependencies or polling for more robust checks.
Start-Sleep -Seconds 10 # Adjust as needed, or use proper dependency management if this is an issue

# 2. Deploy the Storage Account into the newly created Resource Group (Resource Group-Level Deployment)
# Use New-AzResourceGroupDeployment and specify the -ResourceGroupName
Write-Host "Deploying Storage Account into Resource Group '$resourceGroupName'..."
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $storage_template -DeploymentName $storageDeploymentName -Verbose


Write-Host "Virtual Network Resource Group '$resourceGroupName'..."
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $vnet_template -DeploymentName $vnetDeploymentName -Verbose


Write-Host "public ip..."
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $pip_template -DeploymentName $pipDeploymentName -Verbose