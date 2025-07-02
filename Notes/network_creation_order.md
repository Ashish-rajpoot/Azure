# Azure Network Setup Order

- Create **Resource Group**
- Create **Public IP Address** (optional, if VM needs external access)
- Create **Virtual Network (VNet)**
- Create **Subnet** inside the VNet
- Create **Network Security Group (NSG)** (optional, for traffic rules)
- Create **Network Interface (NIC)** and:
  - Attach to the Subnet
  - Associate with Public IP (if created)
  - Associate with NSG (if created)
- Create **Virtual Machine (VM)** and attach the NIC to it
