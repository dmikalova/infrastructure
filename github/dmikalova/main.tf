# GitHub repositories for dmikalova
#
# This stack manages all repositories under the dmikalova GitHub account.
# State is stored in GCS bucket mklv-infrastructure-tfstate.

locals {
  gpg_public_key = base64decode(provider::sops::file("${local.repo_root}/secrets/gpg.sops.json").data.public_key_base64)
}

module "repositories" {
  source = "${local.modules_dir}/github/repositories"

  owner = "dmikalova"
  repositories = {
    brocket = {
      description = "run-or-raise script for declarative window navigation"
    }
    dmikalova = {
      description = "personal profile"
    }
    dotfiles = {
      description = "personal dotfiles"
    }
    email-unsubscribe = {
      description = "Gmail inbox cleanup automation"
    }
    github-meta = {
      description = "reusable workflows, Dagger pipelines, and repo standards"
    }
    infrastructure = {
      description = "terramate infrastructure configuration"
    }
    lists = {
      description = "manage lists"
    }
    recipes = {
      description = "manage recipes"
    }
    synths = {
      description = "personal notes and resources on eurorack synths"
    }
    todos = {
      description = "manage todos"
    }
  }
}

resource "github_user_gpg_key" "main" {
  armored_public_key = local.gpg_public_key
}
