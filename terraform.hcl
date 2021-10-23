locals {
  credentials = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/terraform/credentials.sops.json"))
}

generate "backend" {
  contents = templatefile("${get_parent_terragrunt_dir()}/terraform/backend.tf", {
    path = path_relative_to_include(),
  })
  if_exists = "overwrite"
  path      = "backend.tf"
}

terraform {
  extra_arguments "credentials" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      DIGITALOCEAN_TOKEN = local.credentials.DIGITALOCEAN_TOKEN
      GITLAB_TOKEN       = local.credentials.GITLAB_TOKEN
    }
  }
  extra_arguments "spaces" {
    commands = [get_terraform_command()]
    env_vars = {
      AWS_ACCESS_KEY_ID     = local.credentials.DIGITALOCEAN_SPACES_KEY
      AWS_SECRET_ACCESS_KEY = local.credentials.DIGITALOCEAN_SPACES_SECRET
    }
  }
}
