variable "project" {
	type = string
}

variable "env" {
	type = string
}

variable "location" {
	type = string
	default = "westeurope"
}

variable "vmsize" {
	type = string
	default = "Standard_B2S"
}

variable "nodecount" {
	type = string
	default = 1
}

variable "nodepool" {
	type = string
	default = "default" 
}

variable "identity" {
	type = string
	default = "SystemAssigned"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resourceGroup" {
  name     = format("RG_AKS_%s_%s", var.project, var.env)
  location = var.location

  tags = {
    environment = var.env
  }
}

resource "azurerm_kubernetes_cluster" "K8Scluster" {
  name                = format("AKS_%s_%s", var.project, var.env)
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name
  dns_prefix          = format("AKS-%s-%s", var.project, var.env)

  default_node_pool {
    name       = "default"
    node_count = var.nodecount
    vm_size    = var.vmsize
  }

  identity {
    type = var.identity
  }

  tags = {
    Environment = var.env
  }
}

