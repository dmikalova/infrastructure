# GitHub repositories for dmikalova
#
# This stack manages all repositories under the dmikalova GitHub account.
# State is stored in GCS bucket mklv-infrastructure-tfstate.

locals {
  github_secrets = provider::sops::file("${local.repo_root}/secrets/github.sops.json").data
  gpg_secrets    = provider::sops::file("${local.repo_root}/secrets/gpg.sops.json").data
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
      topics      = ["dmikalova-dev"]
    }
    dotfiles = {
      description = "personal dotfiles"
    }
    email-unsubscribe = {
      description = "Gmail inbox cleanup automation"
      topics      = ["mklv-deploy", "mklv-tech"]
    }
    github-meta = {
      description = "reusable workflows, Dagger pipelines, and repo standards"
      topics      = ["mklv-deploy"]
    }
    infrastructure = {
      description = "terramate infrastructure configuration"
      topics      = ["infra-deploy", "mklv-deploy"]
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
  secrets = {
    PKG_READ_TOKEN = local.github_secrets.PKG_READ_TOKEN
  }
}

data "github_user" "current" {
  username = ""
}

resource "github_user_gpg_key" "main" {
  armored_public_key = base64decode(local.gpg_secrets.public_key_base64)
}
