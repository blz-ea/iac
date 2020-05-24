variable "env" {
  type = string
  default = ""
  description = "Variable that defines current environment, if not set Terraform's environment will be used"
}

locals {
    vars_folder_path = abspath("../vars")
    terraform_env = abspath("./.terraform/environment")

    env = var.env != "" ? var.env : (fileexists(local.terraform_env) ? file(local.terraform_env) : "default")
    # Merge default configuration with environment configuration
    workspace = merge(yamldecode(file("${local.vars_folder_path}/default.yml")), yamldecode(file("${local.vars_folder_path}/${local.env}.yml")))
}
