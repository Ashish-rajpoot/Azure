# Azure PowerShell Cmdlets Reference

This document lists various Azure PowerShell cmdlets from the `Az.Compute` module and some others, with brief descriptions.

---

## Common Cmdlets Overview

| Name                      | Category | Module              | Synopsis                                       |
| ------------------------- | -------- | ------------------- | ---------------------------------------------- |
| `Get-AzVMPublicIPAddress` | Function | PSCloudShellUtility | Retrieves VM public IP addresses.              |
| `Invoke-AzVMCommand`      | Function | PSCloudShellUtility | Executes commands on Azure VMs.                |
| `Get-AzVmNsg`             | Function | PSCloudShellUtility | Retrieves network security groups.             |
| `Get-AzVM`                | Cmdlet   | Az.Compute          | Gets the properties of a virtual machine.      |
| `New-AzVM`                | Cmdlet   | Az.Compute          | Creates a virtual machine.                     |
| `Remove-AzVM`             | Cmdlet   | Az.Compute          | Deletes a virtual machine.                     |
| `Start-AzVM`              | Cmdlet   | Az.Compute          | Starts an Azure virtual machine.               |
| `Stop-AzVM`               | Cmdlet   | Az.Compute          | Stops an Azure virtual machine.                |
| `Update-AzVM`             | Cmdlet   | Az.Compute          | Updates the state of an Azure virtual machine. |

---

## VM Extension Related Cmdlets

| Name                            | Synopsis                                   |
| ------------------------------- | ------------------------------------------ |
| `Get-AzVMExtension`             | Gets properties of VM extensions.          |
| `Set-AzVMExtension`             | Updates or adds an extension to a VM.      |
| `Remove-AzVMExtension`          | Removes an extension from a VM.            |
| `Get-AzVMCustomScriptExtension` | Gets info about a custom script extension. |
| `Set-AzVMCustomScriptExtension` | Adds a custom script extension to a VM.    |

---

## VM Scale Set (VMSS) Cmdlets

| Name            | Synopsis                                  |
| --------------- | ----------------------------------------- |
| `Get-AzVmss`    | Gets properties of a VM scale set.        |
| `New-AzVmss`    | Creates a VM scale set.                   |
| `Remove-AzVmss` | Removes a VM scale set or VM inside VMSS. |
| `Start-AzVmss`  | Starts the VMSS or VMs within the VMSS.   |
| `Stop-AzVmss`   | Stops the VMSS or VMs within the VMSS.    |
| `Update-AzVmss` | Updates the state of a VMSS.              |

---

## Disk and Storage Related Cmdlets

| Name                        | Synopsis                                       |
| --------------------------- | ---------------------------------------------- |
| `Add-AzVMDataDisk`          | Adds a data disk to a VM.                      |
| `Remove-AzVMDataDisk`       | Removes a data disk from a VM.                 |
| `ConvertTo-AzVMManagedDisk` | Converts VM blob-based disks to managed disks. |
| `Set-AzVMOSDisk`            | Sets OS disk properties on a VM.               |

---

## Networking Cmdlets

| Name                       | Synopsis                                 |
| -------------------------- | ---------------------------------------- |
| `Add-AzVMNetworkInterface` | Adds a network interface to a VM.        |
| `Get-AzVMPSRemoting`       | Gets PowerShell remoting settings on VM. |

---

## Diagnostic and Monitoring Cmdlets

| Name                           | Synopsis                                        |
| ------------------------------ | ----------------------------------------------- |
| `Get-AzVMBootDiagnosticsData`  | Gets boot diagnostics data for a VM.            |
| `Get-AzVMDiagnosticsExtension` | Gets settings of diagnostics extension on a VM. |
| `Set-AzVMDiagnosticsExtension` | Configures the diagnostics extension on a VM.   |

---

## Miscellaneous Cmdlets

| Name                    | Synopsis                |
| ----------------------- | ----------------------- |
| `Invoke-AzVMRunCommand` | Runs a command on a VM. |
| `Restart-AzVM`          | Restarts an Azure VM.   |
| `Save-AzVMImage`        | Saves a VM as an image. |

---

For a complete list and detailed documentation, refer to the official Microsoft docs:  
[Azure PowerShell Az.Compute module](https://learn.microsoft.com/en-us/powershell/module/az.compute/)

---

_Generated summary based on command list provided._
