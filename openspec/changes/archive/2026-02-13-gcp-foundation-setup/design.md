# Context

The infrastructure repository currently uses Terragrunt with DigitalOcean,
following Gruntwork's "live repo" pattern where deployed infrastructure is
defined declaratively. The repo uses SOPS for secrets, S3 compatible remote
state (DigitalOcean Spaces), and multi-level includes for shared configuration.

Google Cloud Platform provides native Cloud Run integration, Artifact Registry,
and Secret Manager - ideal for the email-unsubscribe project's containerized
deployment. Terramate offers modern IaC orchestration with better code
generation capabilities than Terragrunt.

**Stakeholders**: Single developer/operator **Constraints**: Must coexist with
existing DigitalOcean infrastructure; minimal ongoing cost

## Goals / Non-Goals

**Goals:**

- Establish minimal GCP foundation for Cloud Run workloads
- Set up Terramate alongside Terragrunt (coexistence, not replacement)
- Create reusable patterns following Fabric's minimal approach
- Enable secure single-user access with service account for CI/CD

**Non-Goals:**

- Migrating existing DigitalOcean resources to GCP
- Full Fabric implementation (organization hierarchy, multi-environment)
- VPC networking (not needed for Cloud Run + external Supabase)
- Multi-user IAM or organization-level policies
- Kubernetes/GKE setup (Cloud Run only)

## Decisions

### 1. Terramate Stack Structure

**Decision**: Separate infrastructure foundation from deployed projects

```
gcp/
├── terramate.tm.hcl           # Root config, globals
├── infra/
│   └── baseline/              # Single stack: project, APIs, IAM, budget, state bucket
└── project/
    └── email-unsubscribe/     # Deployed project stacks
```

**Rationale**: Separates foundational infrastructure (`infra/`) from deployed
workloads (`project/<name>/`). Single baseline stack is sufficient for
individual user - no need to split project/IAM when there's only one service
account. Uses off-the-shelf Fabric modules sourced directly from GitHub.

**Alternatives considered**:

- Separate baseline/iam stacks - unnecessary complexity for single-user setup
- Flat structure (baseline at gcp/ root) - mixes foundation with deployments

### 2. Fabric Modules

**Decision**: Use Google Cloud Foundation Fabric modules directly from GitHub

**Foundation Modules** (for `gcp/infra/baseline/`):

- `project` - GCP project with API enablement, IAM, and disabled default Compute
  SA
- `iam-service-account` - CI/CD service account with role bindings
- `gcs` - Cloud Storage for OpenTofu state bucket
- `billing-account` - Budget alerts with email notifications

**Workload Modules** (for `gcp/project/<name>/`):

- `cloud-run-v2` - Cloud Run service deployment
- `artifact-registry` - Container image storage (gcr.io is deprecated)
- `secret-manager` - Runtime secrets (Supabase keys, API tokens)

**Optional Modules** (future use):

- `net-vpc` - VPC if private GCP resources needed later
- `dns` - Custom domain DNS management
- `certificate-manager` - HTTPS certificates for custom domains
- `kms` - Customer-managed encryption keys
- `logging-bucket` - Centralized logging

**Source**:
`github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/<module>?ref=v52.0.0`

**Rationale**: Fabric modules are production-tested, well-documented, and follow
Google best practices. Avoids maintaining custom modules for standard
infrastructure patterns. Pin to specific versions for reproducibility.

**Alternatives considered**:

- Custom modules in `terraform/modules/gcp/` - unnecessary maintenance burden
  for standard patterns
- Google provider resources directly - more verbose, less consistent, no
  built-in best practices
- OpenTofu Registry modules - Fabric is more comprehensive and opinionated for
  GCP

### 3. GCP Project Configuration

**Decision**: Single project with direct billing account link, no organization

**Rationale**: Organization requires Google Workspace or Cloud Identity setup.
For a personal project, standalone project is simpler. Can migrate to org later
if needed.

**APIs to enable**: Cloud Run, Artifact Registry, Secret Manager, IAM, Cloud
Billing (for budget alerts)

**Security hardening**:

- Disable default Compute Engine service account (not using VMs)
- Budget alerts at 50%, 80%, 100% thresholds with email notification

### 4. IAM Strategy

**Decision**: Two principals - owner account and OpenTofu service account

- Owner: Full access for manual operations and initial bootstrap
- Service account: Limited roles for CI/CD (Cloud Run Admin, Artifact Registry
  Writer, Secret Manager Accessor)

**Rationale**: Least privilege for automation while maintaining break-glass
access. Service account key stored in SOPS like existing secrets.

**Alternatives considered**:

- Workload Identity Federation - better security but adds complexity for initial
  setup
- Owner-only - no separation between manual and automated access

### 5. Networking

**Decision**: No VPC required - Cloud Run uses managed networking

Cloud Run has built-in internet egress and doesn't require VPC configuration for
external services. Since the database is Supabase (external, accessed over HTTPS
with API keys), no private networking is needed.

**When to add VPC later**:

- Connecting to private GCP resources (Cloud SQL, Memorystore)
- Static egress IP for allowlisting
- VPC Service Controls

**Rationale**: Simplest viable setup. Add VPC only when private GCP resources
are introduced.

### 6. State Backend

**Decision**: GCS bucket for OpenTofu state, bootstrapped via local-then-remote
migration

**Bootstrap approach**:

1. Create state bucket with OpenTofu using local state
2. Add GCS backend configuration
3. Run `tofu init -migrate-state` to move state to GCS
4. Bucket has `prevent_destroy = true` lifecycle rule

**Rationale**: Keep GCP state in GCP. Solves chicken/egg problem without manual
Console steps. Prevent-destroy ensures state bucket cannot be accidentally
removed.

### 7. Secrets Management

**Decision**: SOPS for deploy-time secrets, Secret Manager for runtime secrets
(created per workload)

- SOPS: GCP service account key (`secrets/gcp.sops.json`)
- Secret Manager: Supabase credentials, API tokens (created in
  `gcp/project/<name>/` stacks, not foundation)

**Rationale**: Consistent with existing pattern. Secrets belong with the
workloads that use them, not in foundation.

### 8. Observability

**Decision**: Use Cloud Run's built-in Cloud Monitoring + Cloud Logging
(automatic, no setup)

- Metrics: request count, latency, CPU, memory - automatic
- Logs: stdout/stderr automatically sent to Cloud Logging
- Dashboards: Metrics Explorer or connect Grafana

**Future option**: Managed Service for Prometheus (GMP) if you need PromQL
queries or custom metrics. Not needed initially - Cloud Run's automatic metrics
are sufficient.

## Risks / Trade-offs

| Risk                                                | Mitigation                                                   |
| --------------------------------------------------- | ------------------------------------------------------------ |
| Two IaC tools increase cognitive load               | Clear separation: Terragrunt for DO, Terramate for GCP       |
| No organization limits future governance options    | Document migration path; structure allows org adoption later |
| Service account key in SOPS (not Workload Identity) | Short-term simplicity; add WIF in future iteration           |
| Single region limits availability                   | Acceptable for personal project; add regions as needed       |

## Migration Plan

1. **Bootstrap** (local state):
   - Create GCP project via Console (one-time manual step)
   - Run `gcp/infra/baseline/` with local state to create state bucket + service
     account
   - Add GCS backend config, run `tofu init -migrate-state`
   - Generate service account key, store in `secrets/gcp.sops.json`

2. **Validation**:
   - Verify APIs enabled and default Compute SA disabled
   - Test service account permissions
   - Confirm budget alerts configured

3. **Rollback**: `tofu destroy` on baseline (state bucket protected by
   prevent_destroy)
