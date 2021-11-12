locals {
  credentials_digitalocean = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/credentials-digitalocean.sops.json"))
}

terraform {
  extra_arguments "credentials-digitalocean" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      DIGITALOCEAN_TOKEN       = local.credentials_digitalocean.DIGITALOCEAN_TOKEN
      SPACES_ACCESS_KEY_ID     = local.credentials_digitalocean.DIGITALOCEAN_SPACES_KEY
      SPACES_SECRET_ACCESS_KEY = local.credentials_digitalocean.DIGITALOCEAN_SPACES_SECRET
    }
  }
}
