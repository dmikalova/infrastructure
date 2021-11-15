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
      kubectl    = "alpine/k8s:1.20.7"
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
      data = {
        age    = local.credentials.age
        docker = dependency.container_registry.outputs.info
        git    = dependency.deploy_key.outputs.info
        terraform_remote_state = {
          access_key_id     = local.credentials.digitalocean.DIGITALOCEAN_SPACES_KEY
          secret_access_key = local.credentials.digitalocean.DIGITALOCEAN_SPACES_SECRET
        }
      }
    }
    webhooks = {
      middlewares = [dependency.middleware_public.outputs.info]
    }
  }
}

locals {
  credentials = {
    age          = jsondecode(sops_decrypt_file(find_in_parent_folders("age.sops.json")))
    digitalocean = jsondecode(sops_decrypt_file(find_in_parent_folders("digitalocean.sops.json")))
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-tekton-pipelines.git///"
}
