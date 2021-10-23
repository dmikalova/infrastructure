locals {
  credentials = jsondecode(sops_decrypt_file("${get_parent_terragrunt_dir()}/terraform/credentials.sops.json"))
}

generate "backend" {
  // contents = templatefile("${get_parent_terragrunt_dir()}/terraform/backend.tf", {
  //   path = path_relative_to_include(),
  // })
  contents = <<EOF
terraform {
  backend "s3" {
    bucket                      = "e91e63"
    encrypt                     = true
    endpoint                    = "https://sfo3.digitaloceanspaces.com"
    key                         = "tfstates/${path_relative_to_include()}/terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
EOF
  if_exists = "overwrite"
  path      = "backend.tf"
}

// remote_state {
//   backend = "s3"
//   config = {
//     bucket                      = "e91e63"
//     encrypt                     = true
//     endpoint                    = "https://sfo3.digitaloceanspaces.com"
//     key                         = "tfstates/${path_relative_to_include()}/terraform.tfstate"
//     region                      = "us-east-1"
//     skip_region_validation      = true
//     skip_credentials_validation = true
//     skip_metadata_api_check     = true
//   }
//   generate = {
//     if_exists = "overwrite"
//     path      = "backend.tf"
//   }
// }

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
