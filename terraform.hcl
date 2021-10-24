locals {
  credentials_digitalocean = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/digitalocean/credentials.sops.json"))
  credentials_gitlab = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/gitlab/credentials.sops.json"))
}

remote_state {
  backend = "s3"
  config = {
    bucket                      = "e91e63"
    encrypt                     = true
    endpoint                    = "https://sfo3.digitaloceanspaces.com"
    key                         = "tfstates/${path_relative_to_include()}/terraform.tfstate"
    region                      = "us-east-1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
  }
  generate = {
    if_exists = "overwrite"
    path      = "backend.tf"
  }
}

terraform {
  extra_arguments "credentials" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      DIGITALOCEAN_TOKEN = local.credentials_digitalocean.DIGITALOCEAN_TOKEN
      GITLAB_TOKEN       = local.credentials_gitlab.GITLAB_TOKEN
    }
  }
}
