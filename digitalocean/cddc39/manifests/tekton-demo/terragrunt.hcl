dependency "container_registry" {
  config_path = find_in_parent_folders("dmikalova/container-registry")
}

dependency "deploy_key" {
  config_path = find_in_parent_folders("gitlab/deploy-key")
}

dependency "gitlab_projects" {
  config_path = find_in_parent_folders("gitlab/projects")
}

dependency "tekton" {
  config_path = find_in_parent_folders("e91e63/services/tekton")
}

include "domain" {
  path = find_in_parent_folders("e91e63/domain.hcl")
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
    age_keys_file_base64 = local.age_keys_file_base64,
    digitalocean_spaces_key = local.digitalocean_credentials.DIGITALOCEAN_SPACES_KEY,
    digitalocean_spaces_secret = local.digitalocean_credentials.DIGITALOCEAN_SPACES_SECRET,
  }
  git_conf = {
    domain          = "gitlab.com"
    namespace       = "default"
    private_key_pem = dependency.deploy_key.outputs.info.private_key_pem
  }
  gitlab_project_info = dependency.gitlab_projects.outputs.info["cddc39/todo"]
}

locals {
  age_keys_file_base64 = jsondecode(sops_decrypt_file("${get_terragrunt_dir()}/age-keys.sops.json")).file_base64
  digitalocean_credentials = jsondecode(sops_decrypt_file(find_in_parent_folders("credentials.sops.json")))
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-tekton-pipelines.git///modules/demo"
}
