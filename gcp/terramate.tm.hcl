terramate {
  config {
    # Enable code generation
    experiments = ["code-generation"]
  }
}

# Global variables shared across all stacks
globals {
  # GCP Configuration - loaded from SOPS via direnv
  billing_account = tm_getenv("GCP_BILLING_ID")
  project_id      = tm_getenv("GCP_PROJECT_ID")
  region          = "us-west1"

  # Fabric module version
  fabric_version = "v52.0.0"
  fabric_source  = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules"

  # State bucket configuration
  state_bucket = "${global.project_id}-tfstate"
}

# Generate GCS backend configuration for each stack
generate_hcl "_backend.tf" {
  content {
    terraform {
      backend "gcs" {
        bucket = global.state_bucket
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
          version = "~> 5.0"
        }
        google-beta = {
          source  = "hashicorp/google-beta"
          version = "~> 5.0"
        }
      }
    }

    provider "google" {
      project = global.project_id
      region  = global.region
    }

    provider "google-beta" {
      project = global.project_id
      region  = global.region
    }
  }
}
