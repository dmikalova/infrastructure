include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    owner = "dmikalova"
    repositories = {
      brocket = {
        description      = "A run-or-raise script for declarative window navigation"
        visibility_level = "public"
      },
      dotfiles = {
        description = "personal dotfiles"
      },
      infrastructure = {
        description      = "terragrunt infrastructure configuration"
        visibility_level = "public"
      },
      synths = {
        description = "personal notes and resources on eurorack synths"
      },
      zshrc = {
        description = "Personal ZSH configuration"
      },
    }
  }
}

terraform {
  source = "git@github.com:e91e63/terraform-github-repositories.git///modules/repositories"
}
