# main.tf - Main Terraform configuration
# This file defines the core infrastructure for RunStack

terraform {
  # Specify the minimum Terraform version required
  required_version = ">= 1.0"
  
  # Define required providers (cloud services we'll use)
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group (like a container for all our Azure resources)
resource "azurerm_resource_group" "runstack" {
  name     = var.resource_group_name
  location = var.location

  # Tags help organize and track resources
  tags = {
    Environment = var.environment
    Project     = "RunStack"
    ManagedBy   = "Terraform"
  }
}

# Create an Azure Container Registry (ACR) for storing Docker images
resource "azurerm_container_registry" "runstack" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.runstack.name
  location            = azurerm_resource_group.runstack.location
  sku                 = "Basic"  # Start with Basic tier for learning
  admin_enabled       = false   # Match your existing setup

  tags = {
    Environment = var.environment
    Project     = "RunStack"
    ManagedBy   = "Terraform"
  }
}

# Create a Kubernetes cluster (AKS)
resource "azurerm_kubernetes_cluster" "runstack" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.runstack.location
  resource_group_name = azurerm_resource_group.runstack.name
  dns_prefix          = "${var.aks_cluster_name}-dns"  # Match existing: runstackcluster-dns

  # Default node pool configuration
  default_node_pool {
    name       = "main"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  # Use system-assigned identity (simpler for beginners)
  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    Project     = "RunStack"
    ManagedBy   = "Terraform"
  }
}

# Grant AKS permission to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.runstack.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                           = azurerm_container_registry.runstack.id
  skip_service_principal_aad_check = true
}
