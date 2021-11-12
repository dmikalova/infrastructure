dependency "project" {
  config_path = "../project/"
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  project_info = dependency.project.outputs.info
  vpc_conf = {
    ip_range = local.ip_range
    region   = local.region
  }
}

locals {
  digitalocean_conf = read_terragrunt_config(find_in_parent_folders("digitalocean.hcl"))
  ip_range          = local.ip_ranges["e91e63"]
  ip_ranges         = local.digitalocean_conf.inputs.networks.vpcs[local.region]
  region            = "sfo3"
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git///modules/vpc/"
}
