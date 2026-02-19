# Why

GitHub repository management currently uses Terragrunt with state stored in
DigitalOcean. To enable WIF-based deploys, the repo configuration must be
accessible from GCP Terramate stacks. Migrating to Terramate aligns GitHub
management with the rest of GCP infrastructure and removes the DigitalOcean
dependency.

## What Changes

- Migrate GitHub repo configs from `github/*/terragrunt.hcl` to Terramate stacks
  at `github/` (same location, different tooling)
- Move state from DigitalOcean Spaces to GCS via state pull/push
- Remove obsolete Tekton workflows dependency and GPG/SSH keys
- Delete screeptorio owner and repos
- Delete e91e63 repos (module merged into
  `terraform/modules/github/repositories`)
- Migrate cddc39 repos to dmikalova owner
- Add `email-unsubscribe` repo to dmikalova
- Add `github-meta` repo to dmikalova (reusable CI/CD workflows and repo
  standards)

## Capabilities

### New Capabilities

- `github-repos`: GitHub repository management via Terramate. Defines repos for
  dmikalova with state in GCS.

### Modified Capabilities

None - no existing specs.

## Impact

- **State migration**: Terraform state moves from DO Spaces to GCS bucket
- **Tooling**: `terragrunt` commands become `terramate run -- tofu` commands
- **Dependencies**: Removes dependency on DigitalOcean Tekton workflows
- **Repo consolidation**: cddc39 repos move to dmikalova, screeptorio and e91e63
  deleted
- **Risk**: State migration must preserve resource addresses to avoid recreation
