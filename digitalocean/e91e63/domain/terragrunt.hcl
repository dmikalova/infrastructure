dependency "cert_issuer" {
  config_path = "../manifests/cert-issuer"
}

dependency "load_balancer" {
  config_path = "../load-balancer/"
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  cert_issuer_info   = dependency.cert_issuer.outputs.info
  load_balancer_info = dependency.load_balancer.outputs.info
  project_conf       = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git//modules/domain/"
}
