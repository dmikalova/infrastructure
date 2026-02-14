# cddc39 GitHub organization
#
# This stack manages the cddc39 GitHub organization and its repositories.
# Currently empty - repositories were transferred to dmikalova.

locals {
  owner_email = provider::sops::file("${local.repo_root}/secrets/dmikalova.sops.json").data.email
}

resource "github_organization_settings" "org" {
  billing_email                            = local.owner_email
  default_repository_permission            = "none"
  description                              = "cddc39 GitHub organization"
  has_organization_projects                = false
  has_repository_projects                  = false
  members_can_create_internal_repositories = false
  members_can_create_pages                 = false
  members_can_create_private_pages         = false
  members_can_create_private_repositories  = false
  members_can_create_public_pages          = false
  members_can_create_public_repositories   = false
  members_can_create_repositories          = false
  members_can_fork_private_repositories    = false
  name                                     = "cddc39"
  web_commit_signoff_required              = false
}

module "repositories" {
  source = "${local.modules_dir}/github/repositories"

  owner        = "cddc39"
  repositories = {}
}
