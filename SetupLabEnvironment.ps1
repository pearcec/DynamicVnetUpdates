<#

Basic template script for creating a VM. Update/change OS values,
VM series, etc. as needed. 

#>

# 
# Variables
#
$rgName = "VmTestLab"
$locName = "westus"
$storageAccountName = "vmdisks01a"
$storageSku = "Standard_LRS"
$storageKind = "Storage"
$vnetName = "vnet1"
$subnetName = "subnet1"
$ipName = "pip1"
$nicName = "nic1"
$vmSize = "Standard_D2"
$vmName = "vm1"
$compName = "vm1"
$blobPath = "vhds/vm1osDisk.vhd"
$osDiskName = "vm1osdisk"
$publisherName = "MicrosoftWindowsServer"
$offerName = "WindowsServer"
$skuName = "2012-R2-Datacenter"

#
# Resource Group Creation
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Locating resource group..."
$rg = Get-AzureRmResourceGroup -Name $rgName -ErrorAction SilentlyContinue
if ($rg -eq $null){
    $now = [DateTime]::Now
    Write-Output "[LOG $now]: Creating resource group..."
    $rg = New-AzureRMResourceGroup -Name $rgName -Location $locName
} else {
    $now = [DateTime]::Now
    Write-Output "[LOG $now]: Resource group already exists..."
}

#
# Create storage account for VM disks/etc.
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Locating storage account..."
if (Test-AzureName -Storage -Name $storageAccountName){
    $now = [DateTime]::Now
    Write-Output "[LOG $now]: Storage account already exists..."
    $storageAcc = Get-AzureRmStorageAccount -Name $storageAccountName -ResourceGroupName $rgName
} else {
    $now = [DateTime]::Now
    Write-Output "[LOG $now]: Creating storage account..."
    $storageAcc = New-AzureRmStorageAccount `
        -ResourceGroupName $rgName `
        -Name $storageAccountName `
        -SkuName $storageSku `
        -Location $locName `
        -Kind $storageKind
}

#
# Create a VNET with a single subnet
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Locating VNET..."
$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -ErrorAction SilentlyContinue
if ($vnet -eq $null){
    $now = [DateTime]::Now
    Write-Output "[LOG $now]: Creating VNET/subnet..."
    $singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
    $vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $locName -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet
} else {
    $now = [DateTime]::Now
    Write-Output "[LOG $now]: VNET already exists..."
}

#
# Create Public IP address and a NIC
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Creating PIP and NIC..."
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $locName -AllocationMethod Dynamic
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

#
# Gather local admin credentials / set any secrets
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Requesting local admin credentials..."
$cred = Get-Credential -Message "Type the name and password of the local administrator account:"

#
# Create VM configuration object
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Creating VM configuration..."
$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $compName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $publisherName -Offer $offerName -Skus $skuName -Version "latest"

#
# Attach NIC
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Configuring NIC..."
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

#
# Attach OS + Data disks
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Configuring OS + data disks..."
$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + $blobPath
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption fromImage

#
# Create the new VM
#
$now = [DateTime]::Now
Write-Output "[LOG $now]: Submitting VM for creation..."
New-AzureRmVM -ResourceGroupName $rgName -Location $locName -VM $vm
$now = [DateTime]::Now
Write-Output "[LOG $now]: Done!"
