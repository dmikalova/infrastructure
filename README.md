# Infrastructure

[![maintained by dmikalova](https://img.shields.io/static/v1?&color=ccff90&label=maintained%20by&labelColor=424242&logo=&logoColor=fff&message=dmikalova&&style=flat-square)](https://github.com/dmikalova)
[![terramate](https://img.shields.io/static/v1?&color=00BFA5&label=%20&labelColor=424242&logo=&logoColor=fff&message=terramate&&style=flat-square)](https://terramate.io/)
[![opentofu](https://img.shields.io/static/v1?&color=FFDA18&label=%20&labelColor=424242&logo=opentofu&logoColor=fff&message=opentofu&&style=flat-square)](https://opentofu.org/)
[![sops](https://img.shields.io/static/v1?&color=fff&label=%20&labelColor=424242&logo=sops&logoColor=fff&message=sops&&style=flat-square)](https://github.com/mozilla/sops)

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
# Generate Terramate files
terramate generate

# Run OpenTofu in a stack
cd github/dmikalova
tofu init
tofu plan
tofu apply
```

## Features

- GitHub repositories with branch rulesets and signed commits
- GCP infrastructure with Workload Identity Federation
- Encrypted secrets with SOPS and Age
- State stored in GCS bucket `mklv-infrastructure-tfstate`
