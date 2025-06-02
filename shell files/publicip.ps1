$rgname = Read-Host "enter rg-name"
$location =  Read-Host "enter location"
$publicIpName = "$rgname-pip"
$dnsPrefix = "$rgname-dns"

New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $rgName -AllocationMethod Static -DomainNameLabel $dnsPrefix -Location $location