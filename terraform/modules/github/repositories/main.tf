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
  has_issues   = false
  has_projects = false
  has_wiki     = false

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
