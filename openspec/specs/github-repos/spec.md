# github-repos

GitHub repository management via Terramate with state in GCS.

## Overview

Manages GitHub repositories for dmikalova owner using OpenTofu with Terramate orchestration. State stored in Google Cloud Storage alongside GCP infrastructure state.

## Structure

```
github/
├── terramate.tm.hcl      # GitHub-specific provider config, GCS backend gen
└── dmikalova/
    ├── stack.tm.hcl      # Stack definition
    └── main.tf           # Repository definitions via local module
```

## Repositories Managed

| Repository        | Description                                              |
| ----------------- | -------------------------------------------------------- |
| brocket           | run-or-raise script                                      |
| dmikalova         | personal profile                                         |
| dotfiles          | personal dotfiles                                        |
| email-unsubscribe | Gmail inbox cleanup automation                           |
| github-meta       | reusable workflows, Dagger pipelines, and repo standards |
| infrastructure    | terramate infrastructure configuration                   |
| lists             | manage lists                                             |
| recipes           | manage recipes                                           |
| synths            | personal synth notes                                     |
| todos             | manage todos                                             |

## Provider Configuration

- **GitHub Provider**: Uses token from `secrets/github.sops.json`
- **SOPS Provider**: Decrypts secrets at plan/apply time
- **Backend**: GCS bucket `mklv-infrastructure-tfstate` with prefix `tfstate/github/`

## Local Module

Repository definitions use `terraform/modules/github/repositories` local module, which wraps `github_repository` resources with standard defaults:

- Visibility: public (default)
- Features: issues, projects disabled by default
- Branch protection: none (personal repos)

## Usage

```bash
# Generate Terramate files
cd github/dmikalova
terramate generate

# Plan changes
terramate run -- tofu plan

# Apply changes
terramate run -- tofu apply
```

## Adding New Repos

Add entry to `repositories` map in `github/dmikalova/main.tf`:

```hcl
repositories = {
  # ... existing repos ...
  new-repo = { description = "new repo description" }
}
```
