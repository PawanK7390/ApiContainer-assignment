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
  default = "Standard_B1s"  # Small VM eligible for free-tier usage
}
