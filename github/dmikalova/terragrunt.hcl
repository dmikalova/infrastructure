dependency "workflows" {
  config_path = find_in_parent_folders("digitalocean/e91e63/services/tekton/workflows")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    gpg = {
      public_key_base64 = local.gpg.public_key_base64
    }
    owner = "dmikalova"
    repositories = {
      brocket = {
        description = "run-or-raise script for declarative window navigation"
        visibility  = "public"
      },
      dmikalova = {
        description = "personal profile"
        visibility  = "public"
      },
      dotfiles = {
        description = "personal dotfiles"
        visibility  = "public"
      },
      infrastructure = {
        description = "terragrunt infrastructure configuration"
        visibility  = "public"
      },
      synths = {
        description = "personal notes and resources on eurorack synths"
        visibility  = "public"
      },
    }
    ssh = {
      public_key_base64 = local.ssh.public_key_base64
      title             = "id_infrastructure"
    }
  }
  workflows_info = dependency.workflows.outputs.info
}

locals {
  gpg = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/gpg.sops.json")))
  ssh = jsondecode(sops_decrypt_file(find_in_parent_folders("secrets/ssh.sops.json")))
}

terraform {
  source = "git@github.com:e91e63/terraform-github-repositories.git///modules/repositories"
}
