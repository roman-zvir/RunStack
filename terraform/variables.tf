# variables.tf - Define input variables for flexibility
# Variables make your Terraform configuration reusable and customizable

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "runstack"  # Updated to match your existing RG
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "France Central"  # Updated to match Azure policy restrictions
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "runstackregistry"  # Updated to match your existing ACR
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 characters long and contain only alphanumeric characters."
  }
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "runstackcluster"  # Updated to match your existing AKS
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2  # Start with 2 nodes for high availability
  
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "vm_size" {
  description = "Size of the virtual machines in the node pool"
  type        = string
  default     = "Standard_A2_v2"  # Match your existing setup
}
