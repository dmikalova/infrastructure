// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    sops = {
      source  = "nobbs/sops"
      version = "~> 0.3"
    }
  }
}
provider "github" {
  owner = "dmikalova"
  token = provider::sops::file("/Users/david.mikalova/Code/github.com/dmikalova/infrastructure/secrets/github.sops.json").data.GITHUB_TOKEN
}
provider "sops" {
}
