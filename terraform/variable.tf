variable "subscription_id" {
  description = "Azure subscription ID"
  default     = "eea7dd66-806c-47a7-912f-2e3f1af71f5e"
}

variable "sp_object_id" {
  description = "Object ID of the Jenkins service principal"
  default     = "f8173b09-63e7-4a11-a03c-923cf0d2ecfe" 
}

variable "location" {
  default = "EastUS2"
}

variable "resource_group_name" {
  default = "rg-assignment"
}

variable "acr_name" {
  default = "pk7390docker"
}

variable "aks_name" {
  default = "aks-kapoorApps"
}

variable "node_count" {
  default = 1
}

variable "node_vm_size" {
  default = "Standard_B2s"
}
