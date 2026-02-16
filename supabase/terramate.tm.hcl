# Supabase stacks - generate Terraform config using centralized provider versions

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
        sops = {
          source  = "nobbs/sops"
          version = global.provider_versions.sops
        }
        supabase = {
          source  = "supabase/supabase"
          version = global.provider_versions.supabase
        }
      }
    }

    locals {
      repo_root   = terramate.stack.path.to_root
      modules_dir = abspath("${path.root}/${local.repo_root}/terraform/modules")
      gcp_region  = global.gcp.region
      project_id  = global.gcp.project_id
    }

    provider "google" {
      impersonate_service_account = global.gcp.service_account_id
      project                     = local.project_id
      region                      = local.gcp_region
    }

    provider "sops" {}

    provider "supabase" {
      access_token = provider::sops::file("${local.repo_root}/secrets/supabase.sops.json").data.SUPABASE_ACCESS_TOKEN
    }
  }
}
