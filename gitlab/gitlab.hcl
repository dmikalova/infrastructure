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
      description      = "A run-or-raise script for declarative window navigation",
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
      namespace = "dmikalova"
    },
    ergodox-ez-sketch = {
      namespace = "dmikalova"
    },
    infrastructure = {
      description = "root terragrunt infrastructure modules",
      namespace   = "dmikalova"
    },
    lists = {
      namespace        = "dmikalova",
      note             = "Need to clear container registry to move to cddc39 group"
      visibility_level = "public"
    },
    nucamp = {
      namespace = "dmikalova"
    },
    practice = {
      description = "Practice work for reference",
      namespace   = "dmikalova"
    },
    qmk_firmware = {
      description = "keyboard controller firmware for Atmel AVR and ARM USB families"
      namespace   = "dmikalova"
    },
    screeps = {
      namespace = "dmikalova",
      note      = "Need to clear container registry to move to screeptorio group"
    },
    terraform-digitalocean-account-baseline = {
      description      = "Terraform modules for managing Digital Ocean accounts"
      namespace        = "e91e63"
      visibility_level = "public"
    }
    terraform-digitalocean-kubernetes = {
      description      = "Terraform modules for deploying a Digital Ocean Kubernetes cluster"
      namespace        = "e91e63"
      visibility_level = "public"
    },
    terraform-digitalocean-metadata = {
      description      = "Configuration storage for values needed before Consul KV is available"
      namespace        = "e91e63"
      visibility_level = "public"
    },
    terraform-digitalocean-networking = {
      description      = "Terraform modules for managing Digital Ocean networking resources"
      namespace        = "e91e63"
      visibility_level = "public"
    },
    terraform-gitlab-projects = {
      description      = "Terraform modules for managing Gitlab Projects and related resources"
      namespace        = "dmikalova",
      visibility_level = "public"
    },
    toto = {
      namespace = "dmikalova",
      note      = "Need to clear container registry to move to cddc39 group"
    },
    zshrc = {
      description = "Personal ZSH configuration"
      namespace   = "dmikalova"
    },
  }
  users = {
    "dmikalova" = {
      namespace_id = 368066
    }
  }
}
