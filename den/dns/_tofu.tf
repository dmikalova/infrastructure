// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.8"
  backend "gcs" {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/den/dns"
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
  }
}
locals {
  gcp_region         = "us-west1"
  modules_dir        = abspath("${path.root}/${local.repo_root}/tofu/modules")
  project_id         = "mklv-infrastructure"
  repo_root          = "../.."
  service_account_id = "tofu-ci@mklv-infrastructure.iam.gserviceaccount.com"
  state_bucket       = "mklv-infrastructure-tfstate"
}
provider "google" {
  impersonate_service_account = local.service_account_id
  project                     = local.project_id
  region                      = local.gcp_region
}
provider "sops" {
}
