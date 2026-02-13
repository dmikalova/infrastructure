# Terramate configuration for GitHub repository management
# Separate from GCP stacks - uses GCS for state but manages GitHub resources

# Generate GCS backend configuration
generate_hcl "_backend.tf" {
  content {
    terraform {
      backend "gcs" {
        bucket = "mklv-infrastructure-tfstate"
        prefix = "tfstate/github/${terramate.stack.path.basename}"
      }
    }
  }
}

# Generate GitHub and SOPS provider configuration
generate_hcl "_providers.tf" {
  content {
    terraform {
      required_version = ">= 1.0"

      required_providers {
        github = {
          source  = "integrations/github"
          version = "~> 6.0"
        }
        sops = {
          source  = "nobbs/sops"
          version = "~> 0.3"
        }
      }
    }

    provider "github" {
      owner = global.github_owner
      token = provider::sops::file("${terramate.root.path.fs.absolute}/secrets/github.sops.json").data.GITHUB_TOKEN
    }

    provider "sops" {}
  }
}
