dependency "groups" {
  config_path = find_in_parent_folders("groups")
}

dependency "users" {
  config_path = find_in_parent_folders("users")
}

include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    groups = dependency.groups.outputs.info
    users  = dependency.users.outputs.info
    projects = {
      basic-auth = {
        description      = "Go service that provides basic auth for Ambassador"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      brocket = {
        description      = "A run-or-raise script for declarative window navigation"
        namespace        = "dmikalova"
        visibility_level = "public"
      },
      chrome-plugin-page-block = {
        description = "Chrome plugin that blocks pages"
        namespace   = "dmikalova"
      },
      dotfiles = {
        description = "My dotfiles"
        namespace   = "dmikalova"
      },
      ergodox-ez-serial-scanner = {
        description = "ergodox-ez serial scanner"
        namespace = "dmikalova"
      },
      ergodox-ez-sketch = {
        description = "ergodox-ez sketch"
        namespace = "dmikalova"
      },
      infrastructure = {
        description      = "root terragrunt infrastructure modules"
        namespace        = "dmikalova"
        visibility_level = "public"
      },
      lists = {
        description = "create personal lists"
        namespace        = "cddc39"
        visibility_level = "public"
      },
      nucamp = {
        description = "nucamp practice"
        namespace = "dmikalova"
      },
      practice = {
        description = "Practice work for reference"
        namespace   = "dmikalova"
      },
      qmk_firmware = {
        description = "keyboard controller firmware for Atmel AVR and ARM USB families"
        namespace   = "dmikalova"
      },
      rem = {
        description = "An app for spaced repetition flashcards."
        namespace   = "cddc39"
      },
      rem-vue = {
        description = "An app for spaced repetition flashcards."
        namespace   = "cddc39"
      },
      rurl = {
        description = "A site that redirects to a random url from a list."
        namespace   = "cddc39"
      },
      screeps = {
        description = "a screeps repo"
        namespace = "screeptorio"
      },
      screeps-bot = {
        description = "a bot to play screeps"
        namespace = "screeptorio"
      },
      screeps-mongo-docker = {
        description = "docker container to deploy screeps server"
        namespace = "screeptorio"
      },
      terraform-digitalocean-account-baseline = {
        description      = "Terraform modules for managing Digital Ocean accounts"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      terraform-digitalocean-kubernetes = {
        description      = "Terraform modules for deploying a Digital Ocean Kubernetes cluster"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      terraform-digitalocean-networking = {
        description      = "Terraform modules for managing Digital Ocean networking resources"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      terraform-digitalocean-postgresql = {
        description      = "Terraform modules for managing Digital Ocean PostgreSQL databases"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      terraform-digitalocean-spaces = {
        description      = "Terraform modules for Digital Ocean spaces"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      terraform-gitlab-projects = {
        description      = "Terraform modules for managing Gitlab Projects and related resources"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      terraform-kubernetes-manifests = {
        description      = "Terraform modules for managing Kubernetes manifests"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      terraform-tekton-pipelines = {
        description      = "Terraform modules for building reusable Tekton pipelines"
        namespace        = "e91e63"
        visibility_level = "public"
      },
      todo = {
        description      = "An automated todo list"
        namespace        = "cddc39"
        topics           = ["javascript"]
        visibility_level = "public"
      },
      toto = {
        description = "a todo list app"
        namespace        = "cddc39"
        visibility_level = "public"
      },
      zshrc = {
        description = "Personal ZSH configuration"
        namespace   = "dmikalova"
      },
    }
  }
}

terraform {
  source = "git@gitlab.com:e91e63/terraform-gitlab-projects.git///modules/projects"
}
