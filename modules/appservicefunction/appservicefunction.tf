# Create the Function App
resource "azurerm_linux_function_app" "function" {
  name                       = var.service_name
  location                   = var.location
  resource_group_name        = var.rg_name
  service_plan_id            = var.appservice_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  site_config {
    application_stack {
      docker {
        image_name   = var.image_name
        image_tag    = var.image_tag
        registry_url = var.registry_url
      }
    }
    always_on = true
  }

  app_settings = var.app_settings
}