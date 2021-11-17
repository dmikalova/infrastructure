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
      chrome-plugin-page-block = {
        description = "Chrome plugin that blocks pages"
      },
      dotfiles = {
        description = "personal dotfiles"
      },
      ergodox-ez-serial-scanner = {
        description = "ergodox-ez serial scanner"
      },
      ergodox-ez-sketch = {
        description = "ergodox-ez sketch"
      },
      infrastructure = {
        description      = "terragrunt infrastructure configuration"
        visibility_level = "public"
      },
      nucamp = {
        description = "nucamp practice"
      },
      practice = {
        description = "Practice work for reference"
      },
      qmk_firmware = {
        description = "keyboard controller firmware for Atmel AVR and ARM USB families"
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
