// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.8"
  backend "gcs" {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/tailscale/tailnet"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    sops = {
      source  = "nobbs/sops"
      version = "~> 0.3"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.29"
    }
  }
}
locals {
  gcp_region         = "us-west1"
  modules_dir        = abspath("${path.root}/${local.repo_root}/tofu/modules")
  project_id         = "mklv-infrastructure"
  repo_root          = "../.."
  service_account_id = "tofu-ci@mklv-infrastructure.iam.gserviceaccount.com"
}
provider "google" {
  impersonate_service_account = local.service_account_id
  project                     = local.project_id
  region                      = local.gcp_region
}
provider "tailscale" {
  oauth_client_id     = provider::sops::file("${local.repo_root}/secrets/tailscale.sops.json").data.TAILSCALE_OAUTH_CLIENT_ID
  oauth_client_secret = provider::sops::file("${local.repo_root}/secrets/tailscale.sops.json").data.TAILSCALE_OAUTH_CLIENT_SECRET
  scopes = [
    "all",
  ]
}
provider "sops" {
}
