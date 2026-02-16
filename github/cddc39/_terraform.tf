// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.8"
  backend "gcs" {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/github/cddc39"
  }
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
locals {
  modules_dir = "${local.repo_root}/terraform/modules"
  repo_root   = "../.."
}
provider "github" {
  owner = "cddc39"
  token = provider::sops::file("${local.repo_root}/secrets/github.sops.json").data.GITHUB_TOKEN
}
provider "sops" {
}
