output "gitlab_public_ip" {
  value       = azurerm_linux_virtual_machine.vm_gitlab.public_ip_address
  description = "Dirección IP pública del servidor de GitLab"
}

output "dev_public_ip" {
  value       = azurerm_linux_virtual_machine.vm_dev.public_ip_address
  description = "Dirección IP pública del servidor de Desarrollo (Dev)"
}

output "prod_public_ip" {
  value       = azurerm_linux_virtual_machine.vm_prod.public_ip_address
  description = "Dirección IP pública del servidor de Producción (Prod)"
}

output "ssh_connect_gitlab" {
  value       = "ssh ${var.admin_username}@${azurerm_linux_virtual_machine.vm_gitlab.public_ip_address}"
  description = "Comando para conectarse al servidor de GitLab por SSH"
}

output "ssh_connect_dev" {
  value       = "ssh ${var.admin_username}@${azurerm_linux_virtual_machine.vm_dev.public_ip_address}"
  description = "Comando para conectarse al servidor de Desarrollo por SSH"
}

output "ssh_connect_prod" {
  value       = "ssh ${var.admin_username}@${azurerm_linux_virtual_machine.vm_prod.public_ip_address}"
  description = "Comando para conectarse al servidor de Producción por SSH"
}
