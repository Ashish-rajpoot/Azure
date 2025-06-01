Sure! Here's a Markdown version of your HTML content, preserving the structure, headings, code blocks, and instructions:

````markdown
# 🔧 Azure VM Creation Script (PowerShell)

---

### 🔹 Step 1: Login to Azure

```powershell
Connect-AzAccount
```
````

---

### 🔹 Step 2: List Image Offers

```powershell
Get-AzVMImageOffer -Location "eastus" -PublisherName "MicrosoftWindowsServer"
```

---

### 🔹 Step 3: List Image SKUs

```powershell
Get-AzVMImageSku -Location "eastus" -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer"
```

---

### 🔹 Step 4: Create Credentials (Choose one method)

**🔸 Option 1: Interactive Prompt**

```powershell
$cred = Get-Credential
```

**🔸 Option 2: Inline Scripted Credentials**

```powershell
$Username = "azureuser"
$Password = ConvertTo-SecureString "YourP@ssw0rd!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($Username, $Password)
```

---

### 🔹 Step 5: Create VM with Multiple Open Ports

```powershell
New-AzVM `
  -Name "MyVM" `
  -ResourceGroupName "my-rg" `
  -Location "eastus" `
  -Credential $cred `
  -Image "MicrosoftWindowsServer:WindowsServer:2022-datacenter:latest" `
  -OpenPorts 80,443,3389 `
  -PublicIpAddressName "MyVM-PublicIP"
```

---

_Copy the commands and run them in your Azure PowerShell session._

```

---

If you want me to save it as an `.md` file or help with anything else, just ask!
```
