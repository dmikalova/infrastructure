# GitHub repositories module
# Creates and manages GitHub repositories for a single owner

resource "github_repository" "repos" {
  for_each = var.repositories

  name             = each.key
  description      = each.value.description
  license_template = "apache-2.0"
  topics           = each.value.topics
  visibility       = each.value.visibility

  # Standard settings for all repos
  has_issues      = false
  has_discussions = false
  has_projects    = false
  has_wiki        = false

  # Prevent accidental deletion
  archive_on_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository_ruleset" "main" {
  for_each = var.repositories

  enforcement = "active"
  name        = "main"
  repository  = github_repository.repos[each.key].name
  target      = "branch"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true
    required_signatures     = true
  }
}

# Secrets for repos with mklv-deploy topic
locals {
  deploy_repos = [
    for name, config in var.repositories :
    name if contains(try(config.topics, []), "mklv-deploy")
  ]
  # Keys of secrets (non-sensitive)
  secret_names = nonsensitive(keys(var.secrets))
  # Create a map of repo-secret pairs
  repo_secret_keys = {
    for pair in flatten([
      for repo in local.deploy_repos : [
        for secret_name in local.secret_names : {
          key  = "${repo}:${secret_name}"
          repo = repo
          name = secret_name
        }
      ]
    ]) : pair.key => pair
  }
}

resource "github_actions_secret" "deploy_secrets" {
  for_each = local.repo_secret_keys

  plaintext_value = var.secrets[each.value.name]
  repository      = each.value.repo
  secret_name     = each.value.name
}
