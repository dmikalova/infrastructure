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
| `_region`  | Cloud regions (with prefix)    | `gcp_region`, `supabase_region`       |
| `_secret`  | Secret values                  | `client_secret`                       |
| `_token`   | Auth tokens                    | `access_token`                        |
| `_url`     | URLs                           | `api_url`, `webhook_url`              |
| `_yaml`    | YAML strings                   | `config_yaml`                         |

**Region variables** must always include a service prefix to avoid ambiguity (e.g., `gcp_region`, `supabase_region`, `aws_region`). Never use a bare `region` variable.

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

**Never use `-lock=false`** - if a state lock error occurs, inform the user and let them resolve it.

## File Structure

- `gcp/` - Terramate stacks for GCP infrastructure
- `github/` - Terramate stacks for GitHub repository management
- `secrets/` - SOPS-encrypted secrets (`*.sops.json`)
- `openspec/` - Change specifications and design docs

## Stack Dependencies

When creating a new Terramate stack, always define `after` to declare dependencies on other stacks. This ensures correct ordering during `terramate run`:

```hcl
stack {
  name = "My Stack"
  id   = "my-stack"

  after = [
    "/gcp/infra/baseline",
    "/gcp/infra/platform",
  ]
}
```

Common dependency patterns:

- Most GCP stacks depend on `/gcp/infra/baseline` (APIs, project setup)
- App stacks depend on `/gcp/infra/platform` (container registry)
- App stacks depend on `/gcp/infra/workload-identity-federation` (CI/CD auth)

## CI Service Account Permissions

When adding new GCP resources, check if the CI service account (`tofu-ci`) in `gcp/infra/baseline/main.tf` has the required IAM roles. Add missing roles proactively if they're clearly needed for the new resource type. Don't add speculative permissions.

Common resources and their required roles:

| Resource Type       | Required Role                   |
| ------------------- | ------------------------------- |
| Artifact Registry   | `roles/artifactregistry.admin`  |
| Cloud Run           | `roles/run.admin`               |
| IAM Service Account | `roles/iam.serviceAccountAdmin` |
| Secret Manager      | `roles/secretmanager.admin`     |
| Storage Bucket      | `roles/storage.admin`           |

## Conventions

- Keep lists, variables, and table entries in alphabetical order
- Prefer hardcoding single-use values inline over creating variables/locals
- Use Terramate globals for values shared across stacks
- Secrets are read via SOPS provider (`data.sops_file`) directly in OpenTofu
- Generated files are prefixed with `_` (e.g., `_providers.tf`, `_backend.tf`)
- Always use existing modules from `terraform/modules/` when available instead of writing inline resources

## Module Design

Prefer opinionated defaults derived from existing inputs over extra variables. If a value can be computed from inputs the module already has, compute it internally instead of requiring callers to pass it.

For example, if a module has `app_name` and `domain`, derive the subdomain (`${app_name}.${domain}`) and DNS zone name (`replace(domain, ".", "-")`) internally rather than exposing `custom_domain` and `dns_zone_name` variables.

## Comments

Use simple `# Title` comments for sections. Do not use banner-style comments:

```hcl
# Good
# Service Account

# Bad
# -----------------------------------------------------------------------------
# Service Account
# -----------------------------------------------------------------------------
```

If a file needs many sections, consider splitting it into multiple grouped `.tf` files instead.

## Documenting Standards

When the user asks to fix something "across the repo", add the fix as a documented standard in this file. This ensures the convention is captured for future work and prevents regression.

## Resource Block Ordering

Within each resource/data/module block, order content as follows:

1. **Instance arguments** at the top: `for_each`, `count`, `provider`, `source` (with blank line after)
2. **Single-line arguments** (alphabetized)
3. **Nested blocks** in the middle (alphabetized by block type)
4. **Meta-arguments** at the bottom: `depends_on`, `lifecycle`

Within nested blocks, also alphabetize arguments.

```hcl
resource "google_example" "main" {
  for_each = var.items

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

Instead, read all sensitive values from SOPS files using the SOPS provider. Declare secret files in top-level locals, then access individual secrets where needed:

```hcl
locals {
  gcp_secrets    = provider::sops::file("${local.repo_root}/secrets/gcp.sops.json").data
  github_secrets = provider::sops::file("${local.repo_root}/secrets/github.sops.json").data
}

resource "example" "main" {
  billing_account_id = local.gcp_secrets.BILLING_ACCOUNT_ID
  github_token       = local.github_secrets.PKG_READ_TOKEN
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
