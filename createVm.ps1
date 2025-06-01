$rgname = Read-Host "Enter resource group name"
$name = Read-Host "Enter Vm name"
$image = Read-Host "image name"
$location = Read-Host "enter location name"
$ceredential = Read-Host "Enter ceredential name"
$port = Read-Host "enter port number"
$publicipaddress =  Read-Host "Enter public ip address"


New-AzVM -Credential $ceredential -Image $image -Location $loction -Name $name -OpenPorts $port -PublicIpAddressName $publicipaddress -ResourceGroupName $rgname