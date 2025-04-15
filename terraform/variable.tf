variable "subscription_id" {
  description = "Azure subscription ID"
  default     = "eea7dd66-806c-47a7-912f-2e3f1af71f5e"
}

variable "sp_object_id" {
  description = "Object ID of the Jenkins service principal"
  default     = "4dafa805-3ec3-4f90-b12c-96b38dc14415" # ← Replace with correct SP object ID
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
