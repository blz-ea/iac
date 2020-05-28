# Terraform module for Maria DB Docker Container #

## Usage ##

```terraform
module "mariadb" {
  dependencies = []
  
  env = [
    "MYSQL_DATABASE=<database_name>",
    "MYSQL_ROOT_PASSWORD=<root_password>",
  ]

  ports = [
    "3306:3306"
  ]

  labels    = []
  links     = []
  version   = "latest"
  source    = "../../../modules/terraform/docker/mariadb"
}
```

## References ##

- [https://hub.docker.com/_/mariadb](https://hub.docker.com/_/mariadb)
