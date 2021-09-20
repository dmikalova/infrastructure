inputs = {
  groups = {
    cddc39 = {
      description = "Services"
    },
    e91e63 = {
      description = "Terraform modules that deploy a Digital Ocean Kubernetes cluster"
    }
    screeptorio = {
      description = "Screeps private server"
    }
  }
  projects = {
    brocket = {
      // TODO change default branch to main
      default_branch   = "master"
      description      = "A run-or-raise script for declarative window navigation",
      namespace        = "dmikalova"
      visibility_level = "public"
    },
    chrome-plugin-page-block = {
      default_branch = "master"
      description    = "Chrome plugin that blocks pages"
      namespace      = "dmikalova"
    },
    dotfiles = {
      default_branch = "master"
      description    = "My dotfiles"
      namespace      = "dmikalova"
    },
    ergodox-ez-serial-scanner = {
      default_branch = "master"
      namespace      = "dmikalova"
    },
    ergodox-ez-sketch = {
      default_branch = "master"
      namespace      = "dmikalova"
    },
    infrastructure = {
      default_branch = "master"
      description    = "root terragrunt infrastructure modules",
      namespace      = "dmikalova"
    },
    lists = {
      default_branch   = "master"
      namespace        = "dmikalova",
      note             = "Need to clear container registry to move to cddc39 group"
      visibility_level = "public"
    },
    nucamp = {
      default_branch = "master"
      namespace      = "dmikalova"
    },
    practice = {
      default_branch = "master"
      description    = "Practice work for reference",
      namespace      = "dmikalova"
    },
    qmk_firmware = {
      default_branch = "master"
      description    = "keyboard controller firmware for Atmel AVR and ARM USB families"
      namespace      = "dmikalova"
    },
    screeps = {
      default_branch = "master"
      namespace      = "dmikalova",
      note           = "Need to clear container registry to move to screeptorio group"
    },
    terraform-digitalocean-account-baseline = {
      default_branch   = "master"
      description      = "Terraform modules for managing Digital Ocean accounts"
      namespace        = "e91e63"
      visibility_level = "public"
    }
    terraform-digitalocean-kubernetes = {
      default_branch   = "master"
      description      = "Terraform modules for deploying a Digital Ocean Kubernetes cluster"
      namespace        = "e91e63"
      visibility_level = "public"
    },
    terraform-digitalocean-metadata = {
      default_branch   = "master"
      description      = "Configuration storage for values needed before Consul KV is available"
      namespace        = "e91e63"
      visibility_level = "public"
    },
    terraform-digitalocean-networking = {
      default_branch   = "master"
      description      = "Terraform modules for managing Digital Ocean networking resources"
      namespace        = "e91e63"
      visibility_level = "public"
    },
    terraform-digitalocean-postgresql = {
      description      = "Terraform modules for managing Digital Ocean PostgreSQL databases"
      namespace        = "e91e63"
      visibility_level = "public"
    },
    terraform-gitlab-projects = {
      default_branch   = "master"
      description      = "Terraform modules for managing Gitlab Projects and related resources"
      namespace        = "dmikalova",
      visibility_level = "public"
    },
    toto = {
      default_branch = "master"
      namespace      = "dmikalova",
      note           = "Need to clear container registry to move to cddc39 group"
    },
    zshrc = {
      default_branch = "master"
      description    = "Personal ZSH configuration"
      namespace      = "dmikalova"
    },
  }
  users = {
    "dmikalova" = {
      namespace_id = 368066
    }
  }
}
