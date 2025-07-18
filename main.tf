locals {
  object_to_app_role = merge([
    for role, objects in var.app_roles : {
      for obj in objects :
      role => obj
    }
  ]...)
}

resource "time_rotating" "secret" {
  rotation_days = var.secret_lifetime
}

data "azuread_client_config" "me" {}
data "azuread_service_principal" "graph" {
  client_id = "00000003-0000-0000-c000-000000000000"
}

resource "azuread_application" "app" {
  display_name     = var.display_name
  tags             = var.tags
  sign_in_audience = var.sign_in_audience
  owners           = [data.azuread_client_config.me.object_id]
  api {
    requested_access_token_version = var.sign_in_audience == "AzureADandPersonalMicrosoftAccount" ? 2 : var.requested_access_token_version
  }
  dynamic "web" {
    for_each = length(var.web_redirect_uris) > 0 ? [1] : []
    content {
      redirect_uris = var.web_redirect_uris
    }
  }
  dynamic "single_page_application" {
    for_each = length(var.spa_redirect_uris) > 0 ? [1] : []
    content {
      redirect_uris = var.spa_redirect_uris
    }
  }
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    dynamic "resource_access" {
      for_each = var.graph_oauth2_scopes
      content {
        id   = var.graph_oauth2_permission_scope_ids[resource_access.value]
        type = "Scope"
      }
    }
    dynamic "resource_access" {
      for_each = var.graph_app_roles
      content {
        id   = var.graph_app_role_ids[resource_access.value]
        type = "Role"
      }
    }
  }
  dynamic "app_role" {
    for_each = keys(var.app_roles)
    content {
      enabled              = true
      allowed_member_types = ["User"]
      description          = "App role ${app_role.value}"
      display_name         = app_role.value
      id                   = format("00000000-0000-0000-00cf-000000000%03d", index(keys(var.app_roles), app_role.value) + 1)
      value                = app_role.value
    }
  }
}

resource "azuread_app_role_assignment" "roles" {
  for_each            = local.object_to_app_role
  app_role_id         = azuread_application.app.app_role_ids[each.key]
  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.app.object_id
}

resource "azuread_service_principal" "app" {
  client_id                    = azuread_application.app.client_id
  owners                       = [data.azuread_client_config.me.object_id]
  app_role_assignment_required = length(var.allowed_user_group_ids) > 0
}

resource "azuread_app_role_assignment" "app" {
  count               = length(var.allowed_user_group_ids)
  app_role_id         = "00000000-0000-0000-0000-000000000000"
  principal_object_id = var.allowed_user_group_ids[count.index]
  resource_object_id  = azuread_service_principal.app.object_id
}

resource "azuread_service_principal_delegated_permission_grant" "app" {
  count                                = length(var.graph_oauth2_scopes) > 0 ? 1 : 0
  resource_service_principal_object_id = data.azuread_service_principal.graph.object_id
  service_principal_object_id          = azuread_service_principal.app.object_id
  claim_values                         = var.graph_oauth2_scopes
}

resource "azuread_app_role_assignment" "graph" {
  for_each            = toset(var.graph_app_roles)
  app_role_id         = lookup(var.graph_app_role_ids, each.value)
  principal_object_id = azuread_service_principal.app.object_id
  resource_object_id  = data.azuread_service_principal.graph.object_id
}


resource "azuread_application_password" "app" {
  application_id = azuread_application.app.id
  rotate_when_changed = {
    rotation = time_rotating.secret.id
  }
}
