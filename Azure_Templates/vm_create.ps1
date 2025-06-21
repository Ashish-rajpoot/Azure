# Define variables
$location = "eastus"
$resourceGroupName = "my-rg"
$mainDeploymentName = "mainDeployment" # Name for the consolidated deployment

# Assuming your combined template is named 'full_infrastructure_template.json'
$fullInfrastructureTemplate = ".\full_infrastructure_template.json"

# Parameters for the VM (example values - you'd use secure inputs in production)
$vmAdminUsername = "azureadmin"
$vmAdminPassword = "YourSecurePassword123!" # !! REPLACE with a strong, secure password !!

# 1. Deploy the Resource Group (Subscription-Level Deployment - if it doesn't exist)
# This assumes 'my-rg' is created by a separate template or manually.
# If 'my-rg' is guaranteed to exist, you can skip this step.
# If you want to define the RG in this template, then this main template would be deployed at Subscription scope.
# For simplicity, let's assume 'my-rg' is already created by a previous step or template.

# 2. Deploy the entire infrastructure into the specified Resource Group (Resource Group-Level Deployment)
Write-Host "Deploying full infrastructure into Resource Group '$resourceGroupName'..."
New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
    -TemplateFile $fullInfrastructureTemplate `
    -DeploymentName $mainDeploymentName `
    -TemplateParameterObject @{
    vmName        = "myWebAppVM"; # Example VM name
    adminUsername = $vmAdminUsername;
    adminPassword = $vmAdminPassword;
    location      = $location; # Pass the location to the template
} `
    -Verbose