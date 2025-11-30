terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "rganton49245"
    storage_account_name = "taskboardstorageanton123"
    container_name = "taskboardcontaineranton123"
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "07428d78-50fc-42a4-8a54-05d6c5db739e"
}

resource "azurerm_resource_group" "antonrg" {
  name     = var.resource_group_name}
  location = var.resource_group_location
}

resource "azurerm_service_plan" "antonsp" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.antonrg.name
  location            = azurerm_resource_group.antonrg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_mssql_server" "antonserver" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.antonrg.name
  location                     = azurerm_resource_group.antonrg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "database" {
  name                 = var.sql_database_name
  server_id            = azurerm_mssql_server.antonserver.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "S0"
  zone_redundant       = false
  geo_backup_enabled   = false
  storage_account_type = "Local"

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_firewall_rule" "antonfw" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.antonserver.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_linux_web_app" "antonwa" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.antonrg.name
  location            = azurerm_service_plan.antonsp.location
  service_plan_id     = azurerm_service_plan.antonsp.id

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.antonserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.database.name};User ID=${azurerm_mssql_server.antonserver.administrator_login};Password=${azurerm_mssql_server.antonserver.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }
}

resource "azurerm_app_service_source_control" "nakovrepo" {
  app_id                 = azurerm_linux_web_app.antonwa.id
  repo_url               = var.repo_url
  branch                 = "main"
  use_manual_integration = true
}
