// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.8"
  backend "gcs" {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/gcp/infra/baseline"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
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
  modules_dir        = "${local.repo_root}/terraform/modules"
  project_id         = "mklv-infrastructure"
  repo_root          = "/Users/david.mikalova/Code/github.com/dmikalova/infrastructure"
  service_account_id = "tofu-ci@mklv-infrastructure.iam.gserviceaccount.com"
}
provider "google" {
  impersonate_service_account = local.service_account_id
  project                     = local.project_id
  region                      = local.gcp_region
}
provider "google-beta" {
  impersonate_service_account = local.service_account_id
  project                     = local.project_id
  region                      = local.gcp_region
}
provider "sops" {
}
