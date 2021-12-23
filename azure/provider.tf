terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.61.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
  required_version = ">= 0.13"
}


provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}
