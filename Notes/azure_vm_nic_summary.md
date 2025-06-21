
# Azure CLI Summary: Virtual Machine (VM) and Network Interface (NIC)

## 🖥️ Azure Virtual Machine (VM)

### ✅ Key CLI Commands:
| Command              | Purpose                                      |
|----------------------|----------------------------------------------|
| `az vm create`       | Creates a new virtual machine                |
| `az vm delete`       | Deletes an existing VM                       |
| `az vm show`         | Displays information about a VM              |
| `az vm list`         | Lists all VMs in a subscription or group     |
| `az vm start`        | Starts a stopped/deallocated VM              |
| `az vm stop`         | Stops a VM (retains resources)               |
| `az vm deallocate`   | Fully stops the VM and releases compute      |
| `az vm restart`      | Restarts a VM                                |
| `az vm update`       | Updates VM settings                          |
| `az vm disk attach`  | Attaches a disk to a VM                      |
| `az vm disk detach`  | Detaches a disk from a VM                    |
| `az vm nic add`      | Adds a NIC to a VM                           |
| `az vm nic remove`   | Removes a NIC from a VM                      |

## 🌐 Azure Network Interface (NIC)

### ✅ Key CLI Commands:
| Command                   | Purpose                                      |
|---------------------------|----------------------------------------------|
| `az network nic create`   | Creates a NIC in a VNet and Subnet           |
| `az network nic delete`   | Deletes a NIC                                |
| `az network nic show`     | Shows NIC details                            |
| `az network nic list`     | Lists NICs in the subscription or group      |
| `az network nic update`   | Updates NIC settings (IP, NSG, etc.)         |

---

## 🔁 VM and NIC Association Logic in Azure

### 💡 Key Understanding:

1. ✅ **Automatic NIC Creation**  
   When you create a VM using:
   ```bash
   az vm create ...
   ```
   If you **do not specify `--nics`**, Azure **automatically creates a NIC** and attaches it to the VM using default settings (VNet, Subnet, Public IP, NSG).

2. ✅ **Using a Custom NIC**  
   If you want more control (custom VNet/Subnet, NSG, static IP, etc.):
   - You must **first create the NIC** manually using:
     ```bash
     az network nic create ...
     ```
   - Then, use it during VM creation:
     ```bash
     az vm create --nics <my-custom-nic> ...
     ```

3. 🔄 **Changing NIC of an Existing VM**
   - Yes, it is **possible to change the NIC** after the VM is created.
   - You must:
     ```bash
     az vm deallocate --resource-group MyRG --name MyVM
     ```
   - Then remove the old NIC and add the new one:
     ```bash
     az vm nic remove --resource-group MyRG --vm-name MyVM --nics OldNIC
     az vm nic add --resource-group MyRG --vm-name MyVM --nics NewNIC
     ```
   - Finally, start the VM again:
     ```bash
     az vm start --resource-group MyRG --name MyVM
     ```
