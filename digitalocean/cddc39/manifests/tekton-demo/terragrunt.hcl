dependency "container_registry" {
  config_path = find_in_parent_folders("dmikalova/container-registry")
}

dependency "deploy_key" {
  config_path = find_in_parent_folders("gitlab/deploy-key")
}

dependency "tekton" {
  config_path = find_in_parent_folders("e91e63/services/tekton")
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  container_registry_info = dependency.container_registry.outputs.info
  tekton_conf = {
    age_keys_file_base64 = local.age_keys_file_base64
  }
  git_conf = {
    domain          = "gitlab.com"
    namespace       = "default"
    private_key_pem = dependency.deploy_key.outputs.info.private_key_pem
  }
}

locals {
  age_keys_file_base64 = jsondecode(sops_decrypt_file("${get_terragrunt_dir()}/age-keys.sops.json")).file_base64
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-tekton-pipelines.git///modules/demo/"
}
