provider "random" {
  version = "2.3.0"
}

provider "kubernetes" {
  config_path = var.k8s_config_file_path
}

provider "helm" {
  kubernetes {
    config_path = var.k8s_config_file_path
  }
}