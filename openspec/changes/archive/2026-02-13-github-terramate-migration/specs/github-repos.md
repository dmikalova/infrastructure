# github-repos (delta)

Changes from this migration:

## New Capability

This is a new capability - no prior spec exists. See
[spec.md](../../../specs/github-repos/spec.md) for full documentation.

## Key Differences from Previous Setup

| Aspect         | Before (Terragrunt)                    | After (Terramate)                             |
| -------------- | -------------------------------------- | --------------------------------------------- |
| Orchestration  | Terragrunt                             | Terramate                                     |
| State backend  | DigitalOcean Spaces (S3)               | GCS bucket                                    |
| Module source  | `e91e63/terraform-github-repositories` | Local `terraform/modules/github/repositories` |
| Owners managed | dmikalova, cddc39, e91e63, screeptorio | dmikalova only                                |
| GPG/SSH keys   | Managed for Tekton CI                  | Removed (using WIF)                           |

## Consolidated Repos

All repos now under `dmikalova`:

- **Kept**: brocket, dmikalova, dotfiles, infrastructure, synths
- **Added**: email-unsubscribe, github-meta
- **Transferred from cddc39**: lists, recipes, todos
- **Deleted**: all screeptorio repos, all e91e63 terraform-\* repos
