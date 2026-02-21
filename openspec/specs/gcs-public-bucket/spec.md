# GCS Public Bucket Specification

## Requirements

### Requirement: Public bucket serves static content

The system SHALL create a GCS bucket configured for public static website hosting
with the bucket name `mklv-email-unsubscribe-frontend`.

#### Scenario: Bucket serves index.html as main page

- **WHEN** a request is made to the bucket URL without a path
- **THEN** the bucket serves `index.html`

#### Scenario: Bucket serves index.html for SPA routing

- **WHEN** a request is made to a non-existent path (e.g., `/dashboard`)
- **THEN** the bucket serves `index.html` (SPA client-side routing)

#### Scenario: Public read access

- **WHEN** an unauthenticated user requests any object in the bucket
- **THEN** the object is served without authentication

### Requirement: Object versioning enabled

The system SHALL enable object versioning on the bucket to support deployment
rollbacks.

#### Scenario: New upload creates new version

- **WHEN** a file is uploaded that already exists in the bucket
- **THEN** the existing file becomes a noncurrent version
- **AND** the new file becomes the current version

#### Scenario: Previous version accessible

- **WHEN** a deployment needs to be rolled back
- **THEN** noncurrent versions can be restored as the current version

### Requirement: Lifecycle policy limits version retention

The system SHALL configure lifecycle rules to automatically delete old versions:

- Delete noncurrent versions when more than 5 newer versions exist
- Delete noncurrent versions older than 90 days

#### Scenario: Version limit enforced

- **WHEN** a 6th version of a file is uploaded
- **THEN** the oldest noncurrent version is deleted
- **AND** at most 5 versions remain (1 current + 4 noncurrent)

#### Scenario: Age limit enforced

- **WHEN** a noncurrent version is older than 90 days
- **THEN** that version is deleted regardless of version count

### Requirement: Bucket location matches infrastructure

The system SHALL create the bucket in the `US-WEST1` region to match existing
infrastructure and minimize latency.

#### Scenario: Bucket created in correct region

- **WHEN** the bucket is provisioned
- **THEN** the bucket location is `US-WEST1`
