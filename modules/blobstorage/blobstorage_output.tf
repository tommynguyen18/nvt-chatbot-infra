output "BLOB_SAS_TOKEN" {
  value = data.azurerm_storage_account_blob_container_sas.sas.sas
  sensitive = true
}

output "BLOB_CONNECTION_STRING" {
    value = azurerm_storage_account.storage.primary_connection_string
    sensitive = true
}

output "BLOB_URL" {
    value = azurerm_storage_account.storage.primary_blob_endpoint
    sensitive = true
}
output  "BLOB_ADMIN_TOKEN" {
    value = azurerm_storage_account.storage.primary_access_key
}

output "BLOB_CONTAINER_NAME" {
  value = azurerm_storage_container.container.name
}

output "BLOB_ACCOUNT_NAME" {
  value = azurerm_storage_account.storage.name
}