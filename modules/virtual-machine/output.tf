output "vm_out" {
  description = "The VM generated"
  value = azurerm_virtual_machine.main
  sensitive = true
}