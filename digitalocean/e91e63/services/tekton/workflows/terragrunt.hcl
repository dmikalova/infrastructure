dependency "container_registry" {
  config_path = find_in_parent_folders("dmikalova/container-registry")
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
      git_repo_infra_url = "git@github.com:dmikalova/infrastructure.git"
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
        name        = "github"
        event_types = ["push"]
      }
    }
    namespace = dependency.tekton.outputs.info.namespace
    secrets = {
      data = {
        age    = local.secrets.age
        docker = dependency.container_registry.outputs.info
        git_ssh_key = {
          domain             = "github.com"
          known_hosts        = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
          private_key_base64 = local.secrets.ssh.private_key_base64
        }
        gpg = local.secrets.gpg
        terraform_remote_state = {
          access_key_id     = local.secrets.digitalocean.DIGITALOCEAN_SPACES_KEY
          secret_access_key = local.secrets.digitalocean.DIGITALOCEAN_SPACES_SECRET
        }
      }
    }
    webhooks = {
      middlewares = [dependency.middleware_public.outputs.info]
    }
  }
}

locals {
  secrets = {
    age          = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/age.sops.json")))
    digitalocean = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/digitalocean.sops.json")))
    ssh          = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/ssh.sops.json")))
    gpg          = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/gpg.sops.json")))
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-tekton-pipelines.git///"
}
