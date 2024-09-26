output "AZURE_SEARCH_ENDPOINT" {
  value     = "https://${azurerm_search_service.search.name}.search.windows.net"
}

output "AZURE_SEARCH_KEY" {
  value = azurerm_search_service.search.primary_key
}