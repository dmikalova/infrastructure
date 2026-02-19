# Why

GitHub Actions needs to deploy containers to GCP Cloud Run without storing
long-lived service account keys. Workload Identity Federation (WIF) enables
keyless authentication by trusting GitHub's OIDC tokens, improving security and
eliminating key rotation overhead.

## Prerequisites

- `github-terramate-migration`: GitHub repo management must be migrated to
  Terramate before WIF can reference repo list
- `supabase-setup`: Supabase project and DATABASE_URL secret must exist before
  Cloud Run service can start

## What Changes

- Create a Workload Identity Pool and OIDC provider for GitHub Actions
- Create service accounts with scoped permissions:
  - `github-actions-infra`: For the infrastructure repo (broad permissions for
    tofu apply)
  - `github-actions-deploy`: For app repos (limited to Cloud Run deployment and
    secret access)
- Define Cloud Run service for `email-unsubscribe` as the first deployed app
- Store application secrets in GCP Secret Manager, accessible to both Cloud Run
  and GHA via WIF

## Capabilities

### New Capabilities

- `github-wif`: Workload Identity Federation setup enabling GitHub Actions to
  authenticate to GCP without service account keys. Covers pool creation, OIDC
  provider configuration, service accounts, and IAM bindings.
- `cloud-run-service`: Pattern for defining Cloud Run services that app repos
  deploy to. Infra manages service shape (CPU, memory, env vars, secrets), app
  workflows manage image versions.

### Modified Capabilities

None - no existing specs.

## Impact

- **GCP resources**: New IAM resources (WIF pool, provider, service accounts),
  new Cloud Run service, new Secret Manager secrets
- **GitHub Actions**: App repos will use WIF for deployment (requires
  `id-token: write` permission)
- **Security**: No more service account keys in GitHub secrets; short-lived
  tokens only; deploy SA has minimal permissions
- **Workflow**: Infra repo must be applied before app repos can deploy (creates
  chicken-egg dependency for new services)
