$location = "eastus"
$deploymentName = "DeployMyResourceGroup"
$rg_template = ".\rg-template.json"

$storage_template = ".\storage_template.json"


New-AzDeployment -Name $deploymentName -Location $location -TemplateFile $rg_template
New-AzDeployment -Name $deploymentName -Location $location -TemplateFile $storage_template

