// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  required_version = ">= 1.8"
  backend "gcs" {
    bucket = "mklv-infrastructure-tfstate"
    prefix = "tfstate/supabase/mklv"
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
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.7"
    }
  }
}
locals {
  gcp_region  = "us-west1"
  modules_dir = abspath("${path.root}/${local.repo_root}/terraform/modules")
  project_id  = "mklv-infrastructure"
  repo_root   = "../.."
}
provider "google" {
  impersonate_service_account = "tofu-ci@mklv-infrastructure.iam.gserviceaccount.com"
  project                     = local.project_id
  region                      = local.gcp_region
}
provider "sops" {
}
provider "supabase" {
  access_token = provider::sops::file("${local.repo_root}/secrets/supabase.sops.json").data.SUPABASE_ACCESS_TOKEN
}
