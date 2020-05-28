# Terraform module for Docker Registry #

## Usage ##

```terraform
module "registry" {

  dependencies = var.dependencies

  labels = []
  env = []
  ports = [
    "5000:5000"
  ]

  source = "../../../modules/terraform/docker/registry"
}
```

## References ##

- [https://hub.docker.com/_/registry](https://hub.docker.com/_/registry)
