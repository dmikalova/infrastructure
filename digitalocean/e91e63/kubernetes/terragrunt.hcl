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
  kubernetes_conf = {
    node_pool_worker = {
      node_droplet_size_slug = "s-2vcpu-4gb"
    }
    region   = dependency.vpc.outputs.info.region
    version  = "1.21"
    vpc_uuid = dependency.vpc.outputs.info.id
  }
  project_info = dependency.project.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-kubernetes.git///modules/cluster/"
}
