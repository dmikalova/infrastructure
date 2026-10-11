# Infrastructure

This repo contains [Terramate](https://terramate.io/) stacks with
[OpenTofu](https://opentofu.org/) for managing personal infrastructure. Secrets
are encrypted with [SOPS](https://github.com/mozilla/sops) and
[Age](https://github.com/FiloSottile/age).

## Structure

```txt
├── gcp/                    # Google Cloud Platform stacks
├── github/                 # GitHub repository management
├── secrets/                # SOPS-encrypted secrets
└── tofu/
    └── modules/            # Reusable OpenTofu modules
```

## Setup

Do these two steps once on a new machine. Both failures look like unrelated
errors, so check them first when a stack does not plan.

### SOPS age key

The stacks read `secrets/*.sops.json` through the SOPS provider. The decryption
key is an age private key. Without it, `tofu plan` fails with:

```txt
Invalid value for "file" parameter: failed to decrypt file: Error getting data
key: 0 successful groups required, got 0.
```

The key lives in Bitwarden. The shell exports `SOPS_AGE_KEY_FILE`, which points
at `~/.config/sops/key.txt`. Put the key there:

1. Create the directory:

   ```bash
   mkdir -p ~/.config/sops
   chmod 700 ~/.config/sops
   cp ~/Downloads/key.txt ~/.config/sops/key.txt
   chmod 600 ~/.config/sops/key.txt
   sops -d secrets/github.sops.json | head
   ```

### Google Cloud credentials

State lives in the GCS bucket `mklv-infrastructure-tfstate`. OpenTofu reads it
with Application Default Credentials:

```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project mklv-infrastructure
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
