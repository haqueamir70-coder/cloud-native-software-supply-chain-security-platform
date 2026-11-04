variable "resource_group_name" {
  description = "Dedicated resource group for the supply-chain AKS lab."
  type        = string
  default     = "rg-supply-chain-lab"
}
variable "location" {
  description = "Azure region for the lab."
  type        = string
  default     = "East US"
}
variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
  default     = "aks-supply-chain-lab"
}
variable "node_vm_size" {
  description = "System node pool VM size. Check regional quota and pricing before apply."
  type        = string
  default     = "Standard_D2s_v5"
}
variable "node_count" {
  description = "Initial system node count."
  type        = number
  default     = 1
}
variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default = {
    project     = "cloud-native-supply-chain-security"
    environment = "lab"
    managed-by  = "terraform"
  }
}
