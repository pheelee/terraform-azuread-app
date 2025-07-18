# Entra ID App Registrations Module

This module enables you to create a app registration in Microsoft Entra ID by abstracting some parts that can be error prone.
If you need more flexibility you can write the configuration from scratch.

## Example

```hcl
data "azuread_client_config" "me" {}
data "azuread_application_published_app_ids" "well_known" {}

resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

resource "azuread_group" "miniflux" {
  display_name     = "AZA-Miniflux"
  security_enabled = true
  owners           = [data.azuread_client_config.me.object_id]
  members = [
    redacted
  ]
}

module "miniflux_entraid" {
  source                            = "app.terraform.io/irbech/app/azuread"
  version                           = "~>0.1"
  display_name                      = "miniflux"
  graph_app_role_ids                = azuread_service_principal.msgraph.app_role_ids
  graph_oauth2_permission_scope_ids = azuread_service_principal.msgraph.oauth2_permission_scope_ids
  graph_oauth2_scopes               = ["openid", "profile", "email"]
  web_redirect_uris                 = ["https://mflux.example.com/oauth2/oidc/callback"]
  allowed_user_group_ids            = [azuread_group.miniflux.object_id]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.7 |
| azuread | ~>3.0 |
| time | ~>0.12 |

## Providers

| Name | Version |
|------|---------|
| azuread | ~>3.0 |
| time | ~>0.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.graph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.roles](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_delegated_permission_grant.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_delegated_permission_grant) | resource |
| [time_rotating.secret](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [azuread_client_config.me](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_service_principal.graph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_user\_group\_ids | IDs of the users and groups that are allowed to access the app. If not specified the app is allowed for all users and groups | `list(string)` | `[]` | no |
| app\_roles | Defines app roles with IDs of users and/or groups that are allowed to access the app | `map(list(string))` | `{}` | no |
| display\_name | Displayname of the app | `string` | n/a | yes |
| graph\_app\_role\_ids | Pass azuread\_service\_principal.msgraph.app\_role\_ids here | `map(string)` | n/a | yes |
| graph\_app\_roles | App roles for Microsoft Graph API to grant | `list(string)` | `[]` | no |
| graph\_oauth2\_permission\_scope\_ids | Pass azuread\_service\_principal.msgraph.oauth2\_permission\_scope\_ids here | `map(string)` | n/a | yes |
| graph\_oauth2\_scopes | OAuth2 scopes for Microsoft Graph API to grant | `list(string)` | `[]` | no |
| requested\_access\_token\_version | Version of the access token | `number` | `1` | no |
| secret\_lifetime | Lifetime of the secret in days | `number` | `90` | no |
| sign\_in\_audience | Sign-in audience of the app | `string` | `"AzureADMyOrg"` | no |
| spa\_redirect\_uris | List of redirect URIs with type spa | `list(string)` | `[]` | no |
| tags | Tags of the app | `list(string)` | <pre>[<br/>  "HideApp",<br/>  "WindowsAzureActiveDirectoryIntegratedApp"<br/>]</pre> | no |
| web\_redirect\_uris | List of redirect URIs with type web | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| client\_id | Client ID of the app |
| client\_secret | Client secret of the app |
<!-- END_TF_DOCS -->