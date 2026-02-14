# Root Terramate configuration
# Common globals - providers are configured per directory using these versions

terramate {
  config {
    # Allow git to have unsaved changes when running plan/apply
    disable_safeguards = ["git"]
  }
}

globals {
  # GCS state bucket shared by all stacks
  state_bucket = "mklv-infrastructure-tfstate"

  # GCP Configuration
  gcp = {
    project_id         = "mklv-infrastructure"
    region             = "us-west1"
    service_account_id = "tofu-ci@mklv-infrastructure.iam.gserviceaccount.com"
  }

  # Module sources and versions
  module_versions = {
    fabric = {
      source  = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules"
      version = "v52.0.0"
    }
  }

  # Provider versions (shared across all directories)
  provider_versions = {
    github      = "~> 6.0"
    google      = "~> 7.0"
    google-beta = "~> 7.0"
    random      = "~> 3.0"
    sops        = "~> 0.3"
    supabase    = "~> 1.7"
  }
}
