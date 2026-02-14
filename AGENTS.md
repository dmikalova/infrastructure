# Agent Guidelines

Conventions for AI coding agents working with this infrastructure repository.

## Variable Naming

Use descriptive suffixes to indicate the type or format of values.
Use prefixes to disambiguate providers/systems (e.g., `gcp_region`, `aws_region`).

| Suffix     | Use for                        | Example                               |
| ---------- | ------------------------------ | ------------------------------------- |
| `_arn`     | AWS ARNs                       | `role_arn`                            |
| `_base64`  | Base64-encoded data            | `certificate_base64`                  |
| `_cidr`    | CIDR blocks                    | `vpc_cidr`                            |
| `_count`   | Counts/quantities              | `replica_count`                       |
| `_enabled` | Boolean flags                  | `monitoring_enabled`                  |
| `_id`      | Identifiers, UUIDs, opaque IDs | `billing_account_id`, `project_id`    |
| `_json`    | JSON strings                   | `policy_json`                         |
| `_key`     | API keys, encryption keys      | `api_key`, `encryption_key`           |
| `_name`    | Human-readable names           | `service_account_name`, `bucket_name` |
| `_path`    | File or resource paths         | `config_path`                         |
| `_pem`     | PEM-encoded certs/keys         | `private_key_pem`                     |
| `_port`    | Port numbers                   | `service_port`                        |
| `_secret`  | Secret values                  | `client_secret`                       |
| `_token`   | Auth tokens                    | `access_token`                        |
| `_url`     | URLs                           | `api_url`, `webhook_url`              |
| `_yaml`    | YAML strings                   | `config_yaml`                         |

## IaC Tools

- **Infrastructure**: Terramate + OpenTofu (tofu CLI)
- **Secrets**: SOPS with Age encryption

## OpenTofu Commands

Agents may freely run `init` and `plan` commands to validate changes:

```bash
# In a specific stack
cd gcp/infra/baseline
tofu init
tofu plan

# Across all stacks
terramate run -- tofu init
terramate run -- tofu plan
```

**Never run `tofu apply`** - do not execute it or ask to execute it. Instead, inform the user:

> Run `tofu apply` in `path/to/stack` to apply these changes.

## File Structure

- `gcp/` - Terramate stacks for GCP infrastructure
- `github/` - Terramate stacks for GitHub repository management
- `secrets/` - SOPS-encrypted secrets (`*.sops.json`)
- `openspec/` - Change specifications and design docs

## Conventions

- Keep lists, variables, and table entries in alphabetical order
- Prefer hardcoding single-use values inline over creating variables/locals
- Use Terramate globals for values shared across stacks
- Secrets are read via SOPS provider (`data.sops_file`) directly in OpenTofu
- Generated files are prefixed with `_` (e.g., `_providers.tf`, `_backend.tf`)

## Resource Block Ordering

Within each resource/module block, order content as follows:

1. **Single-line arguments** at the top (alphabetized)
2. **Nested blocks** in the middle (alphabetized by block type)
3. **Meta-arguments** at the bottom: `depends_on`, `count`, `for_each`, `provider`, `lifecycle`

Within nested blocks, also alphabetize arguments.

```hcl
resource "google_example" "main" {
  name       = "example"
  project_id = local.project_id

  config_block {
    enabled = true
    value   = "foo"
  }

  settings_block {
    timeout = 30
  }

  lifecycle {
    prevent_destroy = true
  }
}
```

## Secrets and Sensitive Data

**This is a public repository.** Never hardcode:

- Account/billing IDs
- Email addresses or other PII
- API keys, tokens, or passwords
- Project IDs that reveal organizational structure

Instead, read all sensitive values from SOPS files using the SOPS provider:

```hcl
locals {
  billing_account_id = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data.BILLING_ACCOUNT_ID
  owner_email        = provider::sops::file("${local.repo_root}/secrets/dmikalova.sops.json").data.email
}
```

Available SOPS files:

| File                  | Contains                         |
| --------------------- | -------------------------------- |
| `dmikalova.sops.json` | Personal info (email)            |
| `gcp.sops.json`       | GCP billing account ID           |
| `github.sops.json`    | GitHub tokens                    |
| `supabase.sops.json`  | Supabase access token and org ID |

**If a required value is missing from SOPS**, prompt the user to add it rather than hardcoding:

> The billing account ID is not in `secrets/gcp.sops.json`. Please add it:
>
> ```bash
> sops secrets/gcp.sops.json
> # Add: "BILLING_ACCOUNT_ID": "your-billing-account-id"
> ```
