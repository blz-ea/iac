terraform {
  required_providers {
    docker = {
      source = "terraform-providers/docker"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.13"
}
