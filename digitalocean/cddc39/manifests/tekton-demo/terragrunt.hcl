dependency "container_registry" {
  config_path = "../../../dmikalova/container-registry/"
}

dependency "deploy_key" {
  config_path = find_in_parent_folders("gitlab/deploy-key/")
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  container_registry_info = dependency.container_registry.outputs.info
  tekton_conf             = {}
  git_conf = {
    domain          = "gitlab.com"
    namespace       = "default"
    private_key_pem = dependency.deploy_key.outputs.info.private_key_pem
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-tekton-pipelines.git///modules/demo/"
}
