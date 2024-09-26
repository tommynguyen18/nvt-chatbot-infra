output "FORM_RECOGNIZER_ENDPOINT" {
    value = azurerm_cognitive_account.docuintel.endpoint
  sensitive = true
}

output "FORM_RECOGNIZER_KEY" {
  value = azurerm_cognitive_account.docuintel.primary_access_key
  sensitive = true
}