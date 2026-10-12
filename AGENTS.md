# Infrastructure Repository

Conventions specific to this Terramate + OpenTofu infrastructure repository.

## IaC Tools

- **Infrastructure**: Terramate + OpenTofu (tofu CLI)
- **Secrets**: SOPS with Age encryption

## Variable Naming

Use descriptive suffixes to indicate the type or format of values. Use prefixes
to disambiguate providers/systems (e.g., `gcp_region`, `aws_region`).

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

**Region variables** must always include a service prefix to avoid ambiguity
(e.g., `gcp_region`, `supabase_region`, `aws_region`). Never use a bare `region`
variable.

## OpenTofu Commands

Agents may freely run `init` and `plan` commands to validate changes:

```bash
# In a specific stack
cd gcp/infra/baseline
tofu init
tofu plan

# Across all stacks
terramate script run apply
```

**Never run `tofu apply`** - do not execute it or ask to execute it. Instead,
inform the user:

> Run `tofu apply` in `path/to/stack` to apply these changes.

**Never use `-lock=false`** - if a state lock error occurs, inform the user and
let them resolve it.

## File Structure

- `gcp/` - Terramate stacks for GCP infrastructure
- `github/` - Terramate stacks for GitHub repository management
- `secrets/` - SOPS-encrypted secrets (`*.sops.json`)
- `docs/adr/` - Architecture decision records. Read these before changing how a
  stack is wired; they record why, which the code cannot.

## Stack Dependencies

When creating a new Terramate stack, always define `after` to declare
dependencies on other stacks:

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

When adding new GCP resources, check if the CI service account (`tofu-ci`) in
`gcp/infra/baseline/main.tf` has the required IAM roles. Add missing roles
proactively if they're clearly needed for the new resource type.

| Resource Type       | Required Role                   |
| ------------------- | ------------------------------- |
| Artifact Registry   | `roles/artifactregistry.admin`  |
| Cloud Run           | `roles/run.admin`               |
| IAM Service Account | `roles/iam.serviceAccountAdmin` |
| Secret Manager      | `roles/secretmanager.admin`     |
| Storage Bucket      | `roles/storage.admin`           |

## Module Design

- Use existing modules from `tofu/modules/` when available
- Prefer opinionated defaults derived from existing inputs over extra variables
- If a value can be computed from inputs the module already has, compute it internally

## Resource Block Ordering

Within each resource/data/module block, order content as follows:

1. **Instance arguments** at the top: `for_each`, `count`, `provider`, `source`
   (with blank line after)
2. **Single-line arguments** (alphabetized)
3. **Nested blocks** in the middle (alphabetized by block type)
4. **Meta-arguments** at the bottom: `depends_on`, `lifecycle`

```hcl
resource "google_example" "main" {
  for_each = var.items

  name       = "example"
  project_id = local.project_id

  config_block {
    enabled = true
    value   = "foo"
  }

  lifecycle {
    prevent_destroy = true
  }
}
```

## Comments

Use simple `# Title` comments for sections. Do not use banner-style comments.

## Secrets and Sensitive Data

**This is a public repository.** Never hardcode:

- Account/billing IDs
- Email addresses or other PII
- API keys, tokens, or passwords
- Project IDs that reveal organizational structure

Instead, read all sensitive values from SOPS files using the SOPS provider.
Declare secret files in top-level locals, then access individual secrets where
needed:

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

| File                      | Contains                                |
| ------------------------- | --------------------------------------- |
| `age.sops.json`           | Age keypair used to decrypt these files |
| `den.sops.json`           | Secrets for den that have no provider   |
| `discord.sops.json`       | Webhook URLs                            |
| `dmikalova.sops.json`     | Personal info (email)                   |
| `gcp.sops.json`           | GCP billing account ID                  |
| `github.sops.json`        | GitHub tokens                           |
| `gpg.sops.json`           | GPG signing key                         |
| `namecheap.sops.json`     | Namecheap API credentials               |
| `ssh.sops.json`           | SSH keys                                |
| `supabase.sops.json`      | Supabase access token and org ID        |
| `tailscale.sops.json`     | Tailscale API credentials               |
| `traefik-users.sops.json` | Traefik basic-auth users                |

Files are grouped by the provider that issues the secret. A Tailscale key
belongs in `tailscale.sops.json` whatever reads it. `den.sops.json` holds only
secrets that den itself defines, such as a disk passphrase or an application
password.

**If a required value is missing from SOPS**, prompt the user to add it rather
than hardcoding.

### Secret Manager secrets are JSON, grouped by reader

SOPS files are grouped by **issuer**. Secret Manager secrets are grouped by
**reader**, because an IAM grant is per secret: everything one identity may
read belongs in one secret, and nothing it may not read may be in there too.

Always use the `secret-manager-project-secret` module, which stores a JSON
object. Name the secret after the reader, and keep the keys inside identical to
the SOPS keys they came from.

```hcl
module "discord_webhooks" {
  source = "${local.modules_dir}/gcp/secret-manager-project-secret"

  project_id = local.project_id
  secret_id  = "discord"
  data       = local.discord_secrets
}
```

Rules that follow from this:

- One secret per reader, not one per value. Two values with the same reader are
  two keys in one secret, so the reader makes one call and carries one grant.
- Two readers means two secrets, even for the same provider. `tailscale-ci-den`
  and `tailscale-den` are separate because different identities read them.
- A JSON object with one key is still correct. The shape is what lets a second
  value land as a key rather than as a new secret with a new grant.
- Read secrets back with the `secret-manager-secret-data` module. Its `json`
  output decodes **every** secret it is given, and Terraform evaluates module
  outputs whether or not you reference them, so one bare-string secret in the
  map fails the whole plan.
- `secret-manager-secret` stores bare strings and predates this rule. Do not
  use it for anything new. The remaining users are `sops-age-key` and
  `github-token`, whose consumers read the raw value outside Terraform.

Renaming a secret is a cross-repo change: consumers read them by name with
`gcloud secrets versions access`. Grep the sibling repos before renaming, and
apply the infrastructure change only once the consumers are merged.
