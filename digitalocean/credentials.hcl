locals {
  credentials = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/credentials.sops.json"))
}

terraform {
  extra_arguments "credentials-digitalocean" {
    commands = get_terraform_commands_that_need_vars()
    env_vars = {
      DIGITALOCEAN_TOKEN       = local.credentials.DIGITALOCEAN_TOKEN
      SPACES_ACCESS_KEY_ID     = local.credentials.DIGITALOCEAN_SPACES_KEY
      SPACES_SECRET_ACCESS_KEY = local.credentials.DIGITALOCEAN_SPACES_SECRET
    }
  }
}
