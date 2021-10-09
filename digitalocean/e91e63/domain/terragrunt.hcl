dependencies {
  paths = [
    "../services/cert-manager/"
  ]
}

dependency "digitalocean" {
  config_path = "../secrets/digitalocean"
}

dependency "kubernetes" {
  config_path = "../kubernetes/"
}

dependency "profile" {
  config_path = "../secrets/profile"
}

dependency "load_balancer" {
  config_path = "../load-balancer/"
}

include "provider_kubernetes" {
  path = find_in_parent_folders("terraform/providers/kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform/remote_state.hcl")
}

inputs = {
  cert_issuer_conf = {
    email                 = dependency.profile.outputs.info.email,
    personal_access_token = dependency.digitalocean.outputs.info.personal_access_token,
  }
  k8s_info           = dependency.kubernetes.outputs.info
  load_balancer_info = dependency.load_balancer.outputs.info
  project_conf       = read_terragrunt_config(find_in_parent_folders("project.hcl")).inputs
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git//modules/domain/"
}
