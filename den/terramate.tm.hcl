# den stacks - generate Terraform config using centralized provider versions

generate_hcl "_tofu.tf" {
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
      }
    }

    locals {
      gcp_region         = global.gcp.region
      modules_dir        = abspath("${path.root}/${local.repo_root}/tofu/modules")
      project_id         = global.gcp.project_id
      repo_root          = terramate.stack.path.to_root
      service_account_id = global.gcp.service_account_id
    }

    provider "google" {
      impersonate_service_account = local.service_account_id
      project                     = local.project_id
      region                      = local.gcp_region
    }

    provider "sops" {}
  }
}
