output "resource_group_name" {
  description = "Resource group created for the lab."
  value       = azurerm_resource_group.lab.name
}
output "aks_cluster_name" {
  description = "AKS cluster name."
  value       = azurerm_kubernetes_cluster.lab.name
}
output "aks_get_credentials_command" {
  description = "Command to configure kubectl."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.lab.name} --name ${azurerm_kubernetes_cluster.lab.name}"
}
output "oidc_issuer_url" {
  description = "AKS OIDC issuer URL for future workload identity federation."
  value       = azurerm_kubernetes_cluster.lab.oidc_issuer_url
}
