output "vm_out" {
  description = "The VM generated"
  value = azurerm_virtual_machine.main.name
}

output "private_ip" {
  description = "Display private IP address"
  value = azurerm_network_interface.main.private_ip_address
}