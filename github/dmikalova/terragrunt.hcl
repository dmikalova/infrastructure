include "terraform" {
  path = find_in_parent_folders("terraform.hcl")
}

inputs = {
  conf = {
    owner = "dmikalova"
    repositories = {
      brocket = {
        description = "A run-or-raise script for declarative window navigation"
        visibility  = "public"
      },
      dotfiles = {
        description = "personal dotfiles"
      },
      infrastructure = {
<<<<<<< HEAD
        description      = "terragrunt infrastructure configuration"
        visibility = "public"
=======
        description = "terragrunt infrastructure configuration"
        visibility  = "public"
>>>>>>> e1cf96e7ae3ded9cebe9df8f1042009a3bfa6d6b
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
