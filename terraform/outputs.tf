# outputs.tf - Define output values that will be displayed after deployment
# Outputs are useful for getting important information about created resources

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.runstack.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.runstack.location
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.runstack.name
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = azurerm_container_registry.runstack.login_server
}

output "acr_admin_username" {
  description = "Admin username for ACR"
  value       = azurerm_container_registry.runstack.admin_username
  sensitive   = true  # This won't be displayed in terminal output
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.runstack.name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.runstack.fqdn
}

output "aks_node_resource_group" {
  description = "Resource group containing AKS nodes"
  value       = azurerm_kubernetes_cluster.runstack.node_resource_group
}

# Kubernetes configuration for connecting to the cluster
output "kube_config" {
  description = "Kubernetes configuration for connecting to AKS"
  value       = azurerm_kubernetes_cluster.runstack.kube_config_raw
  sensitive   = true  # Contains sensitive information
}
