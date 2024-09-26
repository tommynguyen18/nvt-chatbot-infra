output "AZURE_COSMOSDB_ENDPOINT" {
  value     = azurerm_cosmosdb_account.account.endpoint
  sensitive = true
}

output "AZURE_COMOSDB_CONNECTION_STRING" {
  value = azurerm_cosmosdb_account.account.primary_sql_connection_string
  sensitive = true
}