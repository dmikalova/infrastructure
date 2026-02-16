// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.8"
  backend "gcs" {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/namecheap/domains"
  }
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.0"
    }
    sops = {
      source  = "nobbs/sops"
      version = "~> 0.3"
    }
  }
}
locals {
  modules_dir  = "${local.repo_root}/terraform/modules"
  repo_root    = "/Users/david.mikalova/Code/github.com/dmikalova/infrastructure"
  state_bucket = "mklv-infrastructure-tfstate"
}
provider "namecheap" {
  api_key   = provider::sops::file("${local.repo_root}/secrets/namecheap.sops.json").data.NAMECHEAP_API_KEY
  api_user  = provider::sops::file("${local.repo_root}/secrets/namecheap.sops.json").data.NAMECHEAP_USER_NAME
  user_name = provider::sops::file("${local.repo_root}/secrets/namecheap.sops.json").data.NAMECHEAP_USER_NAME
}
provider "sops" {
}
