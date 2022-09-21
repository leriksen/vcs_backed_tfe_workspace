locals {
  tags = {
    default = "tag"
  }
}

terraform {
  cloud {
    organization = "lab3-wbc-2"
    workspaces {
      name = "vcs"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "tfc" {
  location = "australiasoutheast"
  name     = "tfc"
  tags     = local.tags
}

resource "azurerm_key_vault" "tfc" {
  location            = azurerm_resource_group.tfc.location
  name                = "lab3-wbc-2-dev-tfc"
  resource_group_name = azurerm_resource_group.tfc.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags
}

resource "azurerm_key_vault_access_policy" "agent" {
  key_vault_id       = azurerm_key_vault.tfc.id
  object_id          = data.azurerm_client_config.current.object_id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
}

resource "null_resource" "introspec" {
  provisioner "local-exec" {
    command = "whoami && env"
  }
}