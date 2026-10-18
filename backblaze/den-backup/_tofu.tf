// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.8"
  backend "gcs" {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/backblaze/den-backup"
  }
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.14"
    }
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
}
provider "b2" {
  application_key    = provider::sops::file("${local.repo_root}/secrets/backblaze.sops.json").data.MASTER_APPLICATION_KEY
  application_key_id = provider::sops::file("${local.repo_root}/secrets/backblaze.sops.json").data.MASTER_APPLICATION_KEY_ID
}
provider "google" {
  impersonate_service_account = local.service_account_id
  project                     = local.project_id
  region                      = local.gcp_region
}
provider "sops" {
}
