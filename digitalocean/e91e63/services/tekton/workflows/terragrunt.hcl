dependency "container_registry" {
  config_path = find_in_parent_folders("dmikalova/container-registry")
}

dependency "deploy_key" {
  config_path = find_in_parent_folders("gitlab/projects/deploy-key")
}

dependency "middleware_public" {
  config_path = find_in_parent_folders("traefik/middlewares/public")
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
    bindings = {
      git_repo_infra_url = "git@gitlab.com:dmikalova/infrastructure.git"
    }
    images = {
      alpine     = "alpine"
      cypress    = "cypress/base:16.5.0"
      kaniko     = "gcr.io/kaniko-project/executor:v1.7.0"
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
      age    = local.credentials_age
      docker = dependency.container_registry.outputs.info
      git    = dependency.deploy_key.outputs.info
      terraform_remote_state = {
        access_key_id     = local.credentials_digitalocean.DIGITALOCEAN_SPACES_KEY
        secret_access_key = local.credentials_digitalocean.DIGITALOCEAN_SPACES_SECRET
      }
    }
    webhooks = {
      middlewares = [ dependency.middleware_public.outputs.info ]
    }
  }
}

locals {
  credentials_age          = jsondecode(sops_decrypt_file(find_in_parent_folders("age.sops.json")))
  credentials_digitalocean = jsondecode(sops_decrypt_file(find_in_parent_folders("credentials-digitalocean.sops.json")))
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-tekton-pipelines.git//modules/workflows/"
}
