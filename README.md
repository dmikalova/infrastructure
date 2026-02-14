# Infrastructure

This repo contains [Terramate](https://terramate.io/) stacks with [OpenTofu](https://opentofu.org/) for managing personal infrastructure. Secrets are encrypted with [SOPS](https://github.com/mozilla/sops) and [Age](https://github.com/FiloSottile/age).

## Structure

```txt
├── gcp/                    # Google Cloud Platform stacks
├── github/                 # GitHub repository management
├── secrets/                # SOPS-encrypted secrets
└── terraform/
    └── modules/            # Reusable OpenTofu modules
```

## Usage

```bash
# Generate all Terramate files (from repo root)
terramate generate

# Plan all stacks
terramate run -- tofu init
terramate run -- tofu plan

# Apply all stacks
terramate run -- tofu apply

# Run only on changed stacks (git-aware)
terramate run --changed -- tofu plan

# Run in a specific stack
cd github/dmikalova
tofu init && tofu plan
```

## Features

- GitHub repositories with branch rulesets and signed commits
- GCP infrastructure with Workload Identity Federation
- Encrypted secrets with SOPS and Age
- State stored in GCS bucket `mklv-infrastructure-tfstate`
