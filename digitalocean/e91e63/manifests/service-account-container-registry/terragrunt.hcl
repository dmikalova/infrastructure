dependency "container_registry" {
  config_path = "../../../dmikalova/container-registry/"
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

inputs = {
  container_registry_info = dependency.container_registry.outputs.info
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-digitalocean-kubernetes.git//modules/service-account-container-registry/"
}