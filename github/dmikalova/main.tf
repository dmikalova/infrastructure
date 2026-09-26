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
  # Every repository gets the conformance bot (mklv-conform) unless it sets
  # conform = false. Rolling out a few at a time: remove a repository's
  # conform = false once it is ready, unless a comment says it never will be.
  repositories = {
    brocket = {
      conform     = false
      description = "run-or-raise script for declarative window navigation"
    }
    diatom = {
      conform     = false
      description = "priority-queued agent loop harness"
    }
    dmikalova = {
      # Never conformed: the profile README, not a code project.
      conform     = false
      description = "personal profile"
      topics      = ["dmikalova-dev"]
    }
    dotfiles = {
      # Never conformed: configuration files, not a code project.
      conform     = false
      description = "personal dotfiles"
    }
    email-unsubscribe = {
      description = "Gmail inbox cleanup automation"
      topics      = ["mklv-deploy", "mklv-tech"]
    }
    infrastructure = {
      conform     = false
      description = "terramate infrastructure configuration"
      topics      = ["infra-deploy", "mklv-deploy"]
    }
    "keyforge.cards" = {
      description = "landing pages for keyforge.cards and its subdomains"
      topics      = ["keyforge-cards", "mklv-deploy"]
    }
    lists = {
      conform     = false
      description = "manage lists"
    }
    login = {
      description = "centralized login portal for multi-domain authentication"
      topics      = ["mklv-deploy", "mklv-tech"]
    }
    "mklv.tech" = {
      description = "warming service and landing page for mklv.tech"
      topics      = ["mklv-deploy", "mklv-tech"]
    }
    project-standards = {
      description = "standards every project follows, and the automation that keeps them in conformance"
      topics      = ["mklv-deploy"]
    }
    recipes = {
      conform     = false
      description = "manage recipes"
    }
    synths = {
      # Never conformed: notes, not a code project.
      conform     = false
      description = "personal notes and resources on eurorack synths"
    }
    tasks = {
      description = "manage tasks"
      topics      = ["mklv-deploy", "mklv-tech"]
    }
    vex = {
      description = "a KeyForge-style card game engine in Go, playable in the browser"
      topics      = ["mklv-deploy", "mklv-tech"]
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
