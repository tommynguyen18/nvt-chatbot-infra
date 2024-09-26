resource "azurerm_linux_web_app" "app" {
  name                = var.service_name
  resource_group_name = var.rg_name
  location            = var.location
  service_plan_id     = var.appservice_plan_id

  site_config {
    always_on         = var.always_on
    app_command_line = var.app_command_line
    application_stack {
      docker_image_name = var.docker_image_name
      docker_registry_url = var.docker_registry_url
    }
  }

  
  app_settings = var.app_settings
}