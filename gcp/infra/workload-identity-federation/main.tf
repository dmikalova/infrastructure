# Workload Identity Federation for GitHub Actions
#
# Enables keyless authentication from GitHub Actions to GCP.
# Creates WIF pool, OIDC provider, and service accounts.

# Read GitHub stack outputs to get list of repos with deploy access
data "terraform_remote_state" "github_dmikalova" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "tfstate/github/dmikalova"
  }
}

locals {
  # Filter repos by mklv-deploy topic
  deploy_repos = [
    for name, repo in try(data.terraform_remote_state.github_dmikalova.outputs.repositories, {}) :
    repo.full_name if contains(try(repo.topics, []), "mklv-deploy")
  ]
  state_bucket = "mklv-infrastructure-tfstate"
}

# Workload Identity Pool for GitHub Actions
resource "google_iam_workload_identity_pool" "github" {
  display_name              = "GitHub Actions"
  project                   = local.project_id
  workload_identity_pool_id = "github"
}

# OIDC Provider trusting GitHub Actions tokens
resource "google_iam_workload_identity_pool_provider" "github_oidc" {
  display_name = "GitHub OIDC"
  project      = local.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"

  # Only allow tokens from dmikalova repos
  attribute_condition = "assertion.repository_owner == \"dmikalova\""

  attribute_mapping = {
    "attribute.actor"            = "assertion.actor"
    "attribute.ref"              = "assertion.ref"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "google.subject"             = "assertion.sub"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Service account for infrastructure repo (broad permissions like tofu-ci)
resource "google_service_account" "github_actions_infra" {
  account_id   = "github-actions-infra"
  description  = "GitHub Actions service account for infrastructure repo"
  display_name = "GitHub Actions Infra"
  project      = local.project_id
}

# Grant infra SA same roles as tofu-ci
resource "google_project_iam_member" "infra_sa_roles" {
  member  = "serviceAccount:${google_service_account.github_actions_infra.email}"
  project = local.project_id
  role    = each.value

  for_each = toset([
    "roles/artifactregistry.writer",
    "roles/billing.projectManager",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/run.admin",
    "roles/secretmanager.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
  ])
}

# Allow infrastructure repo to impersonate infra SA via WIF
resource "google_service_account_iam_member" "infra_sa_wif_binding" {
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/dmikalova/infrastructure"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.github_actions_infra.name
}

# Allow infra SA to impersonate tofu-ci SA (CI uses same provider config as local)
resource "google_service_account_iam_member" "infra_sa_impersonate_tofu_ci" {
  member             = "serviceAccount:${google_service_account.github_actions_infra.email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  service_account_id = "projects/${local.project_id}/serviceAccounts/tofu-ci@${local.project_id}.iam.gserviceaccount.com"
}

# Service account for app repos (minimal permissions)
resource "google_service_account" "github_actions_deploy" {
  account_id   = "github-actions-deploy"
  description  = "GitHub Actions service account for app deployment"
  display_name = "GitHub Actions Deploy"
  project      = local.project_id
}

# Grant deploy SA only run.developer role
resource "google_project_iam_member" "deploy_sa_run_developer" {
  member  = "serviceAccount:${google_service_account.github_actions_deploy.email}"
  project = local.project_id
  role    = "roles/run.developer"
}

# Allow repos with deploy_access to impersonate deploy SA via WIF
resource "google_service_account_iam_member" "deploy_sa_wif_bindings" {
  for_each = toset(local.deploy_repos)

  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value}"
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.github_actions_deploy.name
}
