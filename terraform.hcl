locals {
  secrets = {
    digitalocean = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/secrets/digitalocean.sops.json"))
    github       = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/secrets/github.sops.json"))
    gitlab       = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/secrets/gitlab.sops.json"))
  }
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

// TODO: split this out with multi-level-includes
// https://github.com/gruntwork-io/terragrunt/issues/1566
terraform {
  extra_arguments "secrets" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      DIGITALOCEAN_TOKEN = local.secrets.digitalocean.DIGITALOCEAN_TOKEN
      GITHUB_TOKEN       = local.secrets.github.GITHUB_TOKEN
      GITLAB_TOKEN       = local.secrets.gitlab.GITLAB_TOKEN
    }
  }
}
