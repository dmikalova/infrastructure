dependency "project" {
  config_path = "../project/"
}

dependency "kubernetes" {
  config_path = "../kubernetes/"
}

dependency "vpc" {
  config_path = "../vpc/"
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  load_balancer_conf = {
    droplet_tag       = dependency.kubernetes.outputs.info.worker_droplet_tag
    http_target_port  = 32080
    https_target_port = 32443
    region            = dependency.vpc.outputs.info.region
    size              = "lb-small"
    vpc_id            = dependency.vpc.outputs.info.id
  }
  project_info = dependency.project.outputs.info
}

terraform {
  source = "git@github.com:e91e63/terraform-digitalocean-networking.git//modules/load-balancer/"
}
