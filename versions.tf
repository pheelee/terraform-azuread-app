terraform {
  required_version = ">=1.7"
  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "~>0.12"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
    }
  }
}
