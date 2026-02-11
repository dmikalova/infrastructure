stack {
  name        = "GCP Baseline"
  description = "GCP project foundation: APIs, IAM, budget, state bucket"
  id          = "gcp-infra-baseline"
}

# Stack-specific globals
globals {
  # Budget configuration
  budget_amount = 10 # Monthly budget in USD

  # Service account for CI/CD
  ci_service_account_name = "terraform-ci"

  # Owner email for notifications - loaded from SOPS via direnv
  owner_email = tm_getenv("OWNER_EMAIL")
}

# Generate tfvars from Terramate globals
generate_hcl "_terramate.auto.tfvars" {
  content {
    project_id              = global.project_id
    region                  = global.region
    billing_account         = global.billing_account
    ci_service_account_name = global.ci_service_account_name
    state_bucket_name       = global.state_bucket
    budget_amount           = global.budget_amount
  }
}
