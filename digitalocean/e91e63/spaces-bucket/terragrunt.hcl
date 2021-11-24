dependency "project" {
  config_path = find_in_parent_folders("project")
}

dependency "vpc" {
  config_path = find_in_parent_folders("vpc")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  bucket_conf  = { region = dependency.vpc.outputs.info.region }
  project_info = dependency.project.outputs.info
}

locals {
  secrets = {
    digitalocean = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/digitalocean.sops.json")))
  }
}

terraform {
  extra_arguments "secrets-digitalocean" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      DIGITALOCEAN_TOKEN       = local.secrets.digitalocean.DIGITALOCEAN_TOKEN
      SPACES_ACCESS_KEY_ID     = local.secrets.digitalocean.DIGITALOCEAN_SPACES_KEY
      SPACES_SECRET_ACCESS_KEY = local.secrets.digitalocean.DIGITALOCEAN_SPACES_SECRET
    }
  }
  source = "git@github.com:e91e63/terraform-digitalocean-spaces.git///modules/bucket"
}
