dependencies {
  paths = [
    "../../e91e63/services/cert-manager/"
  ]
}

dependency "kubernetes" {
  config_path = "../../e91e63/kubernetes/"
}

dependency "load_balancer" {
  config_path = "../../e91e63/load-balancer/"
}

include "provider_kubernetes" {
  path = find_in_parent_folders("terraform/providers/kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  domain_conf        = { name = "cddc39.tech" }
  load_balancer_info = dependency.load_balancer.outputs.info
  k8s_info           = dependency.kubernetes.outputs.info
  project_conf       = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git///modules/domain/"
}
