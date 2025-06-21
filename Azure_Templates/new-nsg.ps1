$rgName = Read-Host("provide Resource group name")
$location = (Get-AzResourceGroup -Name $rgName -ErrorAction Stop).Location
$nsgName = Read-Host("provide NSG name")

New-AzNetworkSecurityGroup -Name $nsgName -Location $location -ResourceGroupName $rgName


# $rgName = Read-Host("provide Resource group name")
# try {
#     $location = (Get-AzResourceGroup -Name $rgName -ErrorAction Stop).Location
#     $nsgName = Read-Host("provide NSG name")
#     New-AzNetworkSecurityGroup -Name $nsgName -Location $location -ResourceGroupName $rgName -ErrorAction Stop
# } catch {
#     Write-Host "An error occurred: $_"
#     exit
# }