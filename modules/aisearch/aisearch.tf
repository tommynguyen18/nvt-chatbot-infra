# ------------- AI SEARCH -------------

resource "azurerm_search_service" "search" {
  name                = var.name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = var.sku
  replica_count       = var.replica_count
  partition_count     = var.partition_count
  semantic_search_sku = "standard"
}