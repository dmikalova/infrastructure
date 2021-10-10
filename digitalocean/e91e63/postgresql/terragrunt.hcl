dependency "project" {
  config_path = "../project/"
}

dependency "vpc" {
  config_path = "../vpc/"
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  postgresql_conf = {
    node_count             = 1
    node_droplet_size_slug = "s-2vcpu-2gb"
    region                 = dependency.vpc.outputs.info.region
    size                   = "db-s-1vcpu-1gb"
    version                = "13"
    vpc_uuid               = dependency.vpc.outputs.info.id
  }
  project_info = dependency.project.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-postgresql.git///modules/cluster/"
}
