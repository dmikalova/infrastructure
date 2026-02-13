// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.0"
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
  project_id         = "mklv-infrastructure"
  service_account_id = "tofu-ci@mklv-infrastructure.iam.gserviceaccount.com"
}
provider "google" {
  impersonate_service_account = local.service_account_id
  region                      = local.gcp_region
}
provider "google-beta" {
  impersonate_service_account = local.service_account_id
  region                      = local.gcp_region
}
provider "sops" {
}
