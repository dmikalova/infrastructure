include {
  path = find_in_parent_folders()
}

inputs = {
  networks = local.digitalocean.networks
}

locals {
  digitalocean = read_terragrunt_config(find_in_parent_folders("digitalocean.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-account-baseline.git///"
}
