dependency "cert_issuer" {
  config_path = "../manifests/cert-issuer/"
}

dependency "load_balancer" {
  config_path = "../load-balancer/"
}

dependency "project" {
  config_path = "../project/"
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  cert_issuer_info   = dependency.cert_issuer.outputs.info
  domain_conf        = { name = "e91e63.tech" }
  load_balancer_info = dependency.load_balancer.outputs.info
  project_info       = dependency.project.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-networking.git///modules/domain/"
}
