variable "display_name" {
  type        = string
  description = "Displayname of the app"
}

variable "sign_in_audience" {
  type        = string
  description = "Sign-in audience of the app"
  default     = "AzureADMyOrg"
  validation {
    condition     = contains(["AzureADMyOrg", "AzureADMultipleOrgs", "AzureADandPersonalMicrosoftAccount", "PersonalMicrosoftAccount"], var.sign_in_audience)
    error_message = "Sign-in audience must be one of AzureADMyOrg or AzureADandPersonalMicrosoftAccount"
  }
}

variable "secret_lifetime" {
  type        = number
  description = "Lifetime of the secret in days"
  default     = 90
}

variable "tags" {
  type        = list(string)
  description = "Tags of the app"
  default     = ["HideApp", "WindowsAzureActiveDirectoryIntegratedApp"]
}

variable "web_redirect_uris" {
  type        = list(string)
  description = "List of redirect URIs with type web"
  default     = []
}

variable "spa_redirect_uris" {
  type        = list(string)
  description = "List of redirect URIs with type spa"
  default     = []
}

variable "graph_oauth2_permission_scope_ids" {
  type        = map(string)
  description = "Pass azuread_service_principal.msgraph.oauth2_permission_scope_ids here"
}

variable "graph_app_role_ids" {
  type        = map(string)
  description = "Pass azuread_service_principal.msgraph.app_role_ids here"
}

variable "graph_oauth2_scopes" {
  type        = list(string)
  description = "OAuth2 scopes for Microsoft Graph API to grant"
  default     = []
}

variable "graph_app_roles" {
  type        = list(string)
  description = "App roles for Microsoft Graph API to grant"
  default     = []
}

variable "allowed_user_group_ids" {
  type        = list(string)
  description = "IDs of the users and groups that are allowed to access the app. If not specified the app is allowed for all users and groups"
  default     = []
}

variable "requested_access_token_version" {
  type        = number
  description = "Version of the access token"
  default     = 1
}
