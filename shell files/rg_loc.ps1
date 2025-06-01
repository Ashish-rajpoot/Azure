$rgname = Read-Host "Enter the resource group name"
$location = Read-Host "Enter the Location Name"

New-AzResourceGroup -Name $rgname -Location $location

#print on console
Write-Host $rgname "has been created sucessfully"