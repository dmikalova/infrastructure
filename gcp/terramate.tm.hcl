# Global variables shared across all stacks
globals {
  # GCP Configuration
  project_id         = "mklv-infrastructure"
  region             = "us-west1"
  service_account_id = "tofu-ci@mklv-infrastructure.iam.gserviceaccount.com"

  # Fabric module version
  fabric_version = "v52.0.0"
  fabric_source  = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules"
}

# Generate GCS backend configuration for each stack
# Note: bucket is passed via -backend-config during terraform init
generate_hcl "_backend.tf" {
  content {
    terraform {
      backend "gcs" {
        prefix = "tfstate/${terramate.stack.path.relative}"
      }
    }
  }
}

# Generate Google provider configuration for each stack
generate_hcl "_providers.tf" {
  content {
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
      gcp_region         = global.region
      project_id         = global.project_id
      service_account_id = global.service_account_id
    }
    
    provider "google" {
      impersonate_service_account = local.service_account_id
      region                      = local.gcp_region
    }

    provider "google-beta" {
      impersonate_service_account = local.service_account_id
      region                      = local.gcp_region
    }

    provider "sops" {}
  }
}
