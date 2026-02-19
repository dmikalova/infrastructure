# Why

The current infrastructure uses Terragrunt with DigitalOcean, but GCP offers
better Cloud Run integration and a more complete ecosystem for the
email-unsubscribe project. Terramate provides a cleaner alternative to
Terragrunt with better code generation and orchestration. Setting up a minimal
GCP foundation first enables incremental migration without disrupting existing
DigitalOcean deployments.

## What Changes

- Add Terramate as the new IaC orchestration tool (coexisting with Terragrunt)
- Create GCP project foundation following minimal Fabric patterns
- Set up secure single-user access with CI/CD service account
- Configure budget alerts for cost management
- Enable required GCP APIs (Cloud Run, Artifact Registry, Secret Manager)
- Establish patterns for future resource modules

## Capabilities

### New Capabilities

- `gcp-baseline`: GCP project with APIs, CI/CD service account, budget alerts,
  and state bucket
- `terramate-bootstrap`: Terramate configuration, code generation, and stack
  structure

### Modified Capabilities

(none - this is a new foundation, not modifying existing capabilities)

## Impact

- **New directories**: `gcp/infra/` for foundation stacks, `gcp/project/<name>/`
  for deployments
- **New dependencies**: Fabric modules sourced from
  `github.com/GoogleCloudPlatform/cloud-foundation-fabric`
- **New tooling**: Terramate CLI required alongside Terragrunt
- **Dependencies**: GCP project with billing account, domain for DNS (optional)
- **Existing infra**: No changes to DigitalOcean resources - coexistence by
  design
- **Future work**: Enables Cloud Run deployment of email-unsubscribe project
