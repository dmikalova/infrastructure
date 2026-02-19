# Gcp Baseline

## ADDED Requirements

## Requirement: GCP project with billing

The baseline stack SHALL create a GCP project linked to a billing account using
the Fabric `project` module.

### Scenario: Project creation

- **WHEN** the baseline stack is applied
- **THEN** a GCP project is created with a unique project ID
- **AND** the project is linked to the specified billing account

## Requirement: Required APIs enabled

The baseline stack SHALL enable the following GCP APIs: Cloud Run, Artifact
Registry, Secret Manager, IAM, Cloud Billing.

### Scenario: API enablement

- **WHEN** the baseline stack is applied
- **THEN** all required APIs are enabled on the project
- **AND** workload stacks can immediately use Cloud Run, Artifact Registry, and
  Secret Manager

## Requirement: Default Compute SA disabled

The baseline stack SHALL disable the default Compute Engine service account for
security hardening.

### Scenario: Compute SA disabled

- **WHEN** the baseline stack is applied
- **THEN** the default Compute Engine service account is disabled
- **AND** no VMs can be created using default credentials

## Requirement: CI/CD service account

The baseline stack SHALL create a service account for CI/CD automation using the
Fabric `iam-service-account` module with least-privilege roles.

### Scenario: Service account creation

- **WHEN** the baseline stack is applied
- **THEN** a service account named `tofu-ci` (or similar) is created
- **AND** it has roles: Cloud Run Admin, Artifact Registry Writer, Secret
  Manager Accessor

### Scenario: Service account key generation

- **WHEN** the service account is created
- **THEN** a JSON key can be generated and stored in `secrets/gcp.sops.json`
- **AND** the key is encrypted with SOPS before committing

## Requirement: Budget alerts configured

The baseline stack SHALL create budget alerts using the Fabric `billing-account`
module with thresholds at 50%, 80%, and 100%.

### Scenario: Budget threshold notifications

- **WHEN** project spending reaches 50%, 80%, or 100% of budget
- **THEN** email notifications are sent to the owner account

### Scenario: Budget amount configurable

- **WHEN** the baseline stack is configured
- **THEN** the monthly budget amount is specified as a variable (e.g., $10)

## Requirement: OpenTofu state bucket

The baseline stack SHALL create a GCS bucket for OpenTofu state using the Fabric
`gcs` module with deletion protection.

### Scenario: State bucket creation

- **WHEN** the baseline stack is applied with local state
- **THEN** a GCS bucket is created for remote state storage
- **AND** the bucket has versioning enabled

### Scenario: State bucket protection

- **WHEN** the state bucket is created
- **THEN** it has `prevent_destroy = true` lifecycle rule
- **AND** `tofu destroy` fails if it would delete the bucket

### Scenario: State migration

- **WHEN** the state bucket exists
- **THEN** running `tofu init -migrate-state` moves local state to GCS
- **AND** subsequent applies use the remote backend

## Requirement: Fabric module versioning

The baseline stack SHALL source Fabric modules from GitHub with pinned version
refs.

### Scenario: Module source format

- **WHEN** Fabric modules are referenced
- **THEN** the source uses format
  `github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/<module>?ref=v52.0.0`
- **AND** the version is consistent across all module references
