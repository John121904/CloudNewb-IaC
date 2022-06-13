output "vm_out" {
  description = "The VM generated"
  value       = module.vm.vm_out
}

output "private_ip" {
  description = "Display private IP address"
  value = module.vm.private_ip
}