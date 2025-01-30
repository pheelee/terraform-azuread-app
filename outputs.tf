output "client_id" {
  description = "Client ID of the app"
  value       = azuread_application.app.client_id
}
output "client_secret" {
  description = "Client secret of the app"
  value       = azuread_application_password.app.value
  sensitive   = true
}
