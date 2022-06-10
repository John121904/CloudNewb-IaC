# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# # Create a resource group
# resource "azurerm_resource_group" "example" {
#   name     = "${var.prefix}-resources"
#   location = "${var.location}"
# }

module "naming" {
  source = "Azure/naming/azurerm"
  prefix = ["cloudnewb"]
}
resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group.name
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  #name                = "${var.prefix}-network"
  name                = module.naming.virtual_network.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "internal" {
  #name                 = "internal"
  name                 = module.naming.subnet.name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a NIC
resource "azurerm_network_interface" "main" {
  #name                = "${var.prefix}-nic"
  name                = module.naming.network_interface.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a VM
resource "azurerm_virtual_machine" "main" {
  #name                  = "${var.prefix}-vm"
  name                  = module.naming.linux_virtual_machine.name
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_A1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
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

# Create App Service plan
resource "azurerm_service_plan" "example" {
  #name                = "${var.prefix}-appserviceplan"
  name                = module.naming.app_service_plan.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Create App Service
resource "azurerm_linux_web_app" "example" {
  #name                = "${var.prefix}-app-service"
  name                = module.naming.app_service.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_service_plan.example.location
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}