# Create Resource Group

new-azresourcegroup -Name test-rg -Location canadacentral

# Create window machine

new-azResourceGroupDeployment -ResourceGroupName "test-rg" -TemplateFile "template.json" -TemplateParameterFile "parameters.json"

# Delete Resource group

remove-azresourcegroup -Name test-rg -Force
