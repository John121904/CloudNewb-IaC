

# Create "naming" Module 
# Ref: https://registry.terraform.io/modules/Azure/naming/azurerm/latest
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = ["cloudnewb"]
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
  name                = module.naming.virtual_network.name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "internal" {
  name                 = module.naming.subnet.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a NIC
resource "azurerm_network_interface" "main" {
  name                = module.naming.network_interface.name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a VM
resource "azurerm_virtual_machine" "main" {
  name                  = module.naming.linux_virtual_machine.name_unique
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_A1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = module.naming.managed_disk.name_unique
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

