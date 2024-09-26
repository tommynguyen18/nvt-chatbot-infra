resource "azurerm_cognitive_account" "docuintel" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  kind                = "FormRecognizer"

  sku_name = "S0"
}