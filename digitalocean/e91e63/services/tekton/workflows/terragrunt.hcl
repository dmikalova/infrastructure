dependency "container_registry" {
  config_path = find_in_parent_folders("dmikalova/container-registry")
}

dependency "deploy_key" {
  config_path = find_in_parent_folders("gitlab/deploy-key")
}

include "domain" {
  path = find_in_parent_folders("e91e63/domain.hcl")
}

include "kubernetes" {
  path = find_in_parent_folders("kubernetes.hcl")
}

dependency "tekton" {
  config_path = find_in_parent_folders("tekton")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    images = {
      alpine     = "alpine"
      cypress    = "cypress/base:16.5.0"
      kaniko     = "gcr.io/kaniko-project/executor:v1.6.0"
      node       = "node:16-alpine"
      terragrunt = "alpine/terragrunt"
    }
    interceptors = {
      git = {
        name        = "gitlab"
        event_types = ["Push Hook"]
      }
    }
    namespace = dependency.tekton.outputs.info.namespace
    secrets = {
      age    = local.age_credentials
      docker = dependency.container_registry.outputs.info
      git    = dependency.deploy_key.outputs.info
      terraform_remote_state = {
        access_key_id     = local.digitalocean_credentials.DIGITALOCEAN_SPACES_KEY
        secret_access_key = local.digitalocean_credentials.DIGITALOCEAN_SPACES_SECRET
      }
    }
  }
}

locals {
  age_credentials          = jsondecode(sops_decrypt_file("${get_terragrunt_dir()}/age.sops.json"))
  digitalocean_credentials = jsondecode(sops_decrypt_file(find_in_parent_folders("credentials.sops.json")))
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-tekton-pipelines.git//modules/workflows/"
}

// inputs = {
//   container_registry_info = dependency.container_registry.outputs.info
//   tekton_conf = {
//     age_keys_file_base64       = local.age_keys_file_base64,
//     digitalocean_spaces_key    = local.digitalocean_credentials.DIGITALOCEAN_SPACES_KEY,
//     digitalocean_spaces_secret = local.digitalocean_credentials.DIGITALOCEAN_SPACES_SECRET,
//   }
//   git_conf = {
//     domain          = "gitlab.com"
//     namespace       = "default"
//     private_key_pem = dependency.deploy_key.outputs.info.private_key_pem
//   }
//   gitlab_project_info = dependency.gitlab_projects.outputs.info["cddc39/todo"]
// }
