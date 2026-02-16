# Root Terramate configuration
# Common globals - providers are configured per directory using these versions

terramate {
  config {
    # Allow git to have unsaved changes when running plan/apply
    disable_safeguards = ["git"]
    experiments = ["scripts"]
  }
}

script "apply" {
  description = "Tofu deployment"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "apply"
    description = "Run tofu apply"
    commands = [
      [let.provisioner, "init"],
      [let.provisioner, "apply"],
    ]
  }
}

script "cicd" {
  description = "Non-interactive tofu deployment for CI/CD"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "cicd"
    description = "Run tofu apply with auto-approve"
    commands = [
      [let.provisioner, "init"],
      [let.provisioner, "validate"],
      [let.provisioner, "apply", "-auto-approve"],
    ]
  }
}

script "lock" {
  description = "Update provider lock files for all platforms"
  lets {
    provisioner = "tofu"
  }
  job {
    name        = "lock"
    description = "Run tofu providers lock for darwin and linux"
    commands = [
      [let.provisioner, "init"],
      [let.provisioner, "providers", "lock", "-platform=darwin_arm64", "-platform=linux_amd64"],
    ]
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
    namecheap   = "~> 2.0"
    postgresql  = "~> 1.25"
    random      = "~> 3.0"
    sops        = "~> 0.3"
    supabase    = "~> 1.7"
  }
}
