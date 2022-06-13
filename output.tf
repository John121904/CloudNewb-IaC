output "vm_out" {
  description = "The VM generated"
  value       = module.vm.vm_out
  sensitive = true
}