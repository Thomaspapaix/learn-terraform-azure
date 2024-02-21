# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
}

//Aplcation container registry
resource "azurerm_container_registry" "acr" {
  name                = "crappprodheroe001"
  resource_group_name = var.azurerm_resource_group
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}

// Service plan
resource "azurerm_service_plan" "sp" {
  name                = "service-plan-prod-001"
  resource_group_name = var.azurerm_resource_group
  location            = var.location
  os_type             = "Linux"
  sku_name            = "F1"
}

// Frontend-Backend application
resource "azurerm_linux_web_app" "alwaf" {
  name                = "app-frontendheroe-prod"
  resource_group_name = var.azurerm_resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.sp.id

  site_config {
    always_on = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.tc.id]
  }
}

resource "azurerm_linux_web_app" "alwab" {
  name                = "app-backendheroe-prod"
  resource_group_name = var.azurerm_resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.sp.id

  site_config {
    always_on = true
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.tc.id]
  }
}


//id arc
resource "azurerm_user_assigned_identity" "tc" {
  name                = "user-assigned-identity-prod"
  resource_group_name = var.azurerm_resource_group
  location            = var.location
  tags = {
    environment = "prod"
    department  = "IT"
    project     = "heroeprod"
  }
}

resource "azurerm_role_assignment" "tc-acr" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_user_assigned_identity.tc.principal_id
  skip_service_principal_aad_check = true
}

//Storage account
# resource "azurerm_storage_account" "sa" {
#   name                     = "heroe001"
#   resource_group_name      = var.azurerm_resource_group
#   location                 = var.location
#   account_tier             = "Standard"
#   account_replication_type = "Standard_LRS"

#   tags = {
#     environment = "staging"
#   }
# }

# resource "azurerm_storage_container" "sc" {
#   name                  = "heroetfstate"
#   storage_account_name  = azurerm_storage_account.sa.name
#   container_access_type = "private"
# }
