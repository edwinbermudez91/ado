variable "resource_group_name" {
  type        = string
  description = "Nombre del grupo de recursos"
  default     = "RG-POC-INM"
}

variable "location" {
  type        = string
  description = "Ubicación de Azure para desplegar los recursos"
  default     = "eastus"
}

variable "admin_username" {
  type        = string
  description = "Nombre de usuario administrador para las VMs"
  default     = "azdevops"
}

variable "admin_password" {
  type        = string
  description = "Contraseña para el usuario administrador de las VMs"
  sensitive   = true
}

variable "vm_size_gitlab" {
  type        = string
  description = "Tamaño de VM para el servidor GitLab"
  default     = "Standard_B2ms"
}

variable "vm_size_dev_prod" {
  type        = string
  description = "Tamaño de VM para los servidores de Dev y Prod"
  default     = "Standard_B1ms"
}
