# GCP stacks - generate Terraform config using centralized provider versions

generate_hcl "_terraform.tf" {
  content {
    terraform {
      required_version = ">= 1.8"

      backend "gcs" {
        bucket = global.state_bucket
        prefix = "tfstate/${terramate.stack.path.relative}"
      }

      required_providers {
        google = {
          source  = "hashicorp/google"
          version = global.provider_versions.google
        }
        google-beta = {
          source  = "hashicorp/google-beta"
          version = global.provider_versions.google-beta
        }
        postgresql = {
          source  = "cyrilgdn/postgresql"
          version = global.provider_versions.postgresql
        }
        random = {
          source  = "hashicorp/random"
          version = global.provider_versions.random
        }
        sops = {
          source  = "nobbs/sops"
          version = global.provider_versions.sops
        }
      }
    }

    locals {
      repo_root          = tm_replace(terramate.root.path.fs.absolute, "\\", "/")
      modules_dir        = "${local.repo_root}/terraform/modules"
      gcp_region         = global.gcp.region
      project_id         = global.gcp.project_id
      service_account_id = global.gcp.service_account_id
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

    provider "sops" {}
  }
}
