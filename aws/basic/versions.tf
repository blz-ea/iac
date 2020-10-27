terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
    okta = {
      source = "oktadeveloper/okta"
    }
  }
  required_version = ">= 0.13"
}
