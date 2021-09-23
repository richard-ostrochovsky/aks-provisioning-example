variable "project" {
        type = string
}

variable "environment" {
        type = string
}

locals {
	azure_RG_name = "${var.project}-${var.environment}-AKS"
	azure_AKS_instance0_name = "${local.azure_RG_name}-0"
}

variable "azure_tenant_id" {
	type = string
}

variable "azure_identity_type" {
	type = string
	default = "SystemAssigned"
}

variable "azure_region" {
        type = string
        default = "westeurope"
}

variable "aks_node_vm_size" {
	type = string
	default = "Standard_B2S"
}

variable "k8s_version" {
  type = string
  default = "1.21.2"
}

variable "aks_auto_scaling" {
  type = bool
  default = "false"
}

variable "aks_node_pool" {
	type = string
	default = "default" 
}

variable "aks_node_count" {
	type = string
	default = 1
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  tenant_id = var.azure_tenant_id
  features {}
}

resource "azurerm_resource_group" "AKS_instance0" {
  name		= local.azure_RG_name
  location	= var.azure_region

  tags = {
	Name		= local.azure_RG_name
	Project		= var.project
  	Environment	= var.environment
  }
}

resource "azurerm_kubernetes_cluster" "instance0" {
  name                = local.azure_AKS_instance0_name
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.AKS_instance0.name
  dns_prefix          = local.azure_AKS_instance0_name

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size
    availability_zones = [ "1", "2", "3" ]
    enable_auto_scaling = var.aks_auto_scaling

    node_labels = {
      Project = var.project
      Environment = var.environment
    }

  }

  identity {
    type = var.azure_identity_type
  }

  kubernetes_version = var.k8s_version

  tags = {
    Name = local.azure_AKS_instance0_name
    Project = var.project
    Environment = var.environment
  }
}

