# ------------- AZURE WEBAPP -------------
resource "azurerm_service_plan" "plan" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku
}