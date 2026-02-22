# Cloud Run Service

## ADDED Requirements

### Requirement: Startup CPU boost enabled by default

The system SHALL enable `startup_cpu_boost` on all Cloud Run services to
reduce cold start latency.

#### Scenario: CPU boost configured in service template

- **WHEN** a Cloud Run service is created via the cloud-run-app module
- **THEN** `startup_cpu_boost = true` is set in the service configuration

#### Scenario: CPU boost applies during cold start

- **WHEN** a Cloud Run service scales from zero
- **THEN** additional CPU is allocated during container startup
- **AND** normal CPU limits apply after startup completes

### Requirement: Warm label for service discovery

The system SHALL add a `warm=true` label to Cloud Run services by default
to enable centralized warming.

#### Scenario: Warm label added by default

- **WHEN** a Cloud Run service is created via the cloud-run-app module
- **THEN** the service has label `warm=true`

#### Scenario: Warm label can be disabled

- **WHEN** `warm = false` is passed to the cloud-run-app module
- **THEN** the `warm` label is set to `false`
- **AND** the service is excluded from centralized warming

### Requirement: GCS bucket always created

The system SHALL always create a private GCS bucket for each Cloud Run
service at `mklv-<app-name>`.

#### Scenario: Bucket created automatically

- **WHEN** a Cloud Run service is created via the cloud-run-app module
- **THEN** a GCS bucket named `mklv-<app-name>` is created
- **AND** the bucket has public access prevention enforced

#### Scenario: Bucket name exposed as environment variable

- **WHEN** the Cloud Run service starts
- **THEN** the `BUCKET_NAME` environment variable contains `mklv-<app-name>`

#### Scenario: Service account has bucket access

- **WHEN** the Cloud Run service is created
- **THEN** its service account has `roles/storage.objectAdmin` on the bucket

## REMOVED Requirements

### Requirement: Public bucket for static frontend assets

**Reason**: Apps moving to server-side rendering. Static assets served directly
from Hono container.

**Migration**: Remove `public_bucket = true` from app stacks. Serve static
assets from `src/public/` directory in application code.

### Requirement: Private bucket optional configuration

**Reason**: Simplified to always create bucket. GCS buckets are free until
data is stored.

**Migration**: Remove `private_bucket = true` from app stacks. Bucket is
created automatically. Update code to use `BUCKET_NAME` env var instead of
`PRIVATE_BUCKET_NAME`.
