## Context

The infrastructure repo uses Terramate + OpenTofu to manage GCP resources. Currently, CI runs via a manually-created service account (`tofu-ci`) with broad permissions. App repos (like `email-unsubscribe`) need to deploy containers to Cloud Run but shouldn't have infrastructure-level access.

GitHub Actions supports OIDC tokens that GCP can trust via Workload Identity Federation, eliminating the need for service account keys stored in GitHub secrets.

Current state:

- GCP project `mklv-infrastructure` exists with required APIs enabled
- `tofu-ci` service account handles infrastructure operations
- No WIF configuration exists
- No Cloud Run services deployed yet

## Goals / Non-Goals

**Goals:**

- Enable keyless GitHub Actions → GCP authentication via WIF
- Separate permissions: infra repo gets broad access, app repos get deploy-only access
- Define a repeatable pattern for Cloud Run services that app repos can deploy to
- Store app secrets in Secret Manager, accessible to both Cloud Run runtime and GHA deploys
- Support local development: all workflows runnable with `gcloud auth application-default login`

**Non-Goals:**

- Migrating `tofu-ci` to use WIF (keep existing key-based auth for now)
- Multi-environment support (staging/prod) - single environment for now
- Custom domains or load balancers for Cloud Run - use default URLs
- VPC connectors or private networking

## Decisions

### 1. WIF Pool and Provider Structure

**Decision:** Single pool "github" with single provider "github-oidc". Service account bindings are per-repo, not per-owner.

**Alternatives considered:**

- Owner-level binding (`repository_owner == 'dmikalova'`): Simpler but would grant access to any new repo automatically, and theoretically could allow fork-based attacks if GitHub's OIDC token structure changes
- Separate pools per repo: Unnecessary complexity - the pool/provider is shared, only bindings differ

**Rationale:** Per-repo bindings provide explicit control over which repos can authenticate. The list of authorized repos is derived from repos defined in `github/` Terramate stacks, ensuring infrastructure code is the source of truth.

```hcl
# Example: explicit repo bindings on deploy SA
members = [
  "principalSet://iam.googleapis.com/${pool}/attribute.repository/dmikalova/email-unsubscribe",
  "principalSet://iam.googleapis.com/${pool}/attribute.repository/dmikalova/other-app",
  # Add repos as they're created in github/ configs
]
```

### 2. Service Account Separation

**Decision:** Two service accounts with distinct scopes:

| Service Account         | Used By                    | Permissions                   |
| ----------------------- | -------------------------- | ----------------------------- |
| `github-actions-infra`  | `dmikalova/infrastructure` | Broad: same as `tofu-ci`      |
| `github-actions-deploy` | All app repos              | Minimal: `run.developer` only |

**Alternatives considered:**

- Single shared SA: Simpler but violates least privilege - a compromised app repo could modify infrastructure
- Per-app SA: More isolated but creates management overhead as app count grows
- `run.admin` for deploy SA: Would allow modifying service config and IAM - too permissive

**Rationale:** Two SAs provide meaningful security boundary. The deploy SA has minimal permissions:

- `run.developer`: Can deploy new revisions and manage traffic, but cannot modify service configuration, IAM, or delete services
- No `secretmanager.secretAccessor`: Secrets are injected by Cloud Run at runtime (configured by Terraform), not read by GHA
- All service/IAM changes must go through Terraform in the infra repo

### 3. WIF Attribute Mapping

**Decision:** Map `repository`, `repository_owner`, `ref`, and `actor` from GitHub's OIDC token.

```hcl
attribute_mapping = {
  "google.subject"             = "assertion.sub"
  "attribute.actor"            = "assertion.actor"
  "attribute.repository"       = "assertion.repository"
  "attribute.repository_owner" = "assertion.repository_owner"
  "attribute.ref"              = "assertion.ref"
}
```

**Rationale:** These attributes enable per-repo IAM conditions. The `repository` attribute is essential for explicit repo bindings. The `ref` attribute could restrict prod deploys to main branch only (not implementing now but preserving option).

### 4. Infra SA Binding Condition

**Decision:** Restrict `github-actions-infra` to exactly `dmikalova/infrastructure` repo.

```hcl
members = [
  "principalSet://iam.googleapis.com/${pool}/attribute.repository/dmikalova/infrastructure"
]
```

**Rationale:** The infra SA has powerful permissions. Binding to the exact repo prevents other repos from impersonating it.

### 5. Deploy SA Binding Condition

**Decision:** Explicit per-repo bindings for the deploy SA. Each app repo must be individually granted access.

```hcl
members = [
  "principalSet://iam.googleapis.com/${pool}/attribute.repository/dmikalova/email-unsubscribe",
  # Add more app repos here as they're created
]
```

**Rationale:** Explicit bindings prevent unauthorized repos from deploying. When a new app repo needs deploy access, it must be added to both:

1. `github/dmikalova/` Terramate stack (creates the repo)
2. WIF deploy SA bindings (grants GCP access)

This two-step process ensures intentional access grants.

### 6. Cloud Run Service Stack Structure

**Decision:** Create a new Terramate stack per Cloud Run service at `gcp/infra/apps/<app-name>/`.

**Alternatives considered:**

- Single stack for all apps: Simpler but couples unrelated services
- Separate repo for app infra: Too much separation for current scale

**Rationale:** Per-app stacks allow independent deployment and clear ownership. The stack manages service definition, secrets, and IAM but NOT the container image version.

### 7. Container Image Management

**Decision:** Terraform defines a placeholder image; GHA deploys actual versions. Use `ignore_changes` on image.

```hcl
resource "google_cloud_run_v2_service" "app" {
  template {
    containers {
      image = "gcr.io/cloudrun/placeholder"  # GHA sets actual image
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      template[0].revision,
    ]
  }
}
```

**Alternatives considered:**

- Terraform manages image version: Creates tight coupling, requires infra PR for every deploy
- No placeholder: `tofu apply` would fail before first GHA deploy

**Rationale:** The `ignore_changes` pattern cleanly separates concerns: Terraform owns service shape, GHA owns versions. The placeholder allows `tofu apply` to succeed before any container exists.

### 8. Secret Manager Integration

**Decision:** Terraform creates secrets (empty), values populated manually or by separate process. Cloud Run references via `secret_key_ref`.

```hcl
resource "google_secret_manager_secret" "database_url" {
  secret_id = "email-unsubscribe-database-url"
  replication { auto {} }
}

# In Cloud Run service:
env {
  name = "DATABASE_URL"
  value_source {
    secret_key_ref {
      secret  = google_secret_manager_secret.database_url.id
      version = "latest"
    }
  }
}
```

**Rationale:** Terraform manages secret existence and IAM, but not values. Values come from SOPS files or manual entry. Using `latest` version simplifies rotation - update secret, redeploy picks it up.

### 9. Local Development Auth

**Decision:** All deployment commands must work with both WIF (in GHA) and Application Default Credentials (locally).

**Implementation:**

- GHA workflows use `google-github-actions/auth` for WIF
- Local development uses `gcloud auth application-default login`
- Deploy scripts/commands use standard gcloud/tofu auth chain (checks ADC first)
- No WIF-specific code paths in actual deploy logic

**Rationale:** Developers need to test deployments locally before pushing. The auth mechanism should be transparent to the deployment commands - whether credentials come from WIF or ADC, `gcloud run deploy` and `tofu apply` work identically.

## Risks / Trade-offs

| Risk                                          | Mitigation                                                        |
| --------------------------------------------- | ----------------------------------------------------------------- |
| WIF misconfiguration allows unintended access | Explicit per-repo bindings; no owner-level wildcards              |
| Deploy SA too permissive                      | `run.developer` only; no secret access, no IAM, no service config |
| `ignore_changes` causes drift confusion       | Document clearly; infra only manages shape, not versions          |
| Placeholder image fails health checks         | Use `gcr.io/cloudrun/placeholder` which returns 200 on /          |
| Secret values not in Terraform state          | Expected - values are sensitive, managed separately               |
| First deploy chicken-egg (service must exist) | Run `tofu apply` in infra before app's first GHA deploy           |

## Migration Plan

**Prerequisites:** Complete `github-terramate-migration` and `supabase-setup` changes first.

1. **Apply WIF resources** - Pool, provider, service accounts with explicit repo bindings
2. **Create Secret Manager secrets** - Secrets for DATABASE_URL (from supabase-setup), OAuth credentials, encryption key
3. **Create Cloud Run service** - `email-unsubscribe` with placeholder image
4. **Update app repo GHA** - Add WIF auth, deploy to created service
5. **Verify end-to-end** - Push to app repo, confirm deployment works

Rollback: Delete WIF resources, revert to key-based auth if needed.

## Open Questions

None - all questions resolved.
