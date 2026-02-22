# Cloud Run Warming

## ADDED Requirements

### Requirement: Warming endpoint discovers services via label

The system SHALL provide an endpoint at `/api/warm` that discovers Cloud Run
services with `warm=true` label and invokes their health endpoints.

#### Scenario: Services with warm label discovered

- **WHEN** the warming endpoint is invoked
- **THEN** it calls Cloud Run Admin API to list services with `warm=true` label
- **AND** returns the list of discovered service names

#### Scenario: Services without warm label excluded

- **WHEN** a Cloud Run service does not have `warm=true` label
- **THEN** it is not included in the warming cycle

### Requirement: Warming endpoint hits health endpoints in parallel

The system SHALL invoke each discovered service's `/health` endpoint using
the service's internal URL (`*.run.app`).

#### Scenario: Health endpoints invoked via internal URL

- **WHEN** warming discovers a service with URI `https://app-xyz.a.run.app`
- **THEN** it makes a GET request to `https://app-xyz.a.run.app/health`

#### Scenario: Multiple services warmed in parallel

- **WHEN** warming discovers 4 services
- **THEN** all 4 health checks are invoked concurrently
- **AND** the total time is approximately the slowest single health check

#### Scenario: Individual failures do not stop warming

- **WHEN** one service's health check fails or times out (5s)
- **THEN** the failure is logged with service name and error
- **AND** other services are still warmed
- **AND** the response includes the failed service in error list
- **AND** no retry is attempted

### Requirement: Warming response includes status summary

The system SHALL return a JSON response with the warming results.

#### Scenario: Successful warming response

- **WHEN** all health checks succeed
- **THEN** response includes `{"success": true, "services": [...], "errors": []}`

#### Scenario: Partial failure response

- **WHEN** some health checks fail
- **THEN** response includes `{"success": false, "services": [...], "errors": [...]}`

### Requirement: Cloud Scheduler invokes warming every 10 minutes

The system SHALL configure a Cloud Scheduler job to invoke `/api/warm` on
the mklv.tech service every 10 minutes.

#### Scenario: Scheduler job configured

- **WHEN** the mklv stack is applied
- **THEN** a Cloud Scheduler job exists with schedule `*/10 * * * *`
- **AND** the job targets `https://mklv.tech/api/warm`

#### Scenario: Scheduler uses service account authentication

- **WHEN** the scheduler job invokes the warming endpoint
- **THEN** it authenticates using OIDC with the mklv service account

### Requirement: Warming service has Cloud Run viewer permission

The system SHALL grant `roles/run.viewer` to the mklv service account to
enable service discovery.

#### Scenario: Service account can list services

- **WHEN** the mklv service calls Cloud Run Admin API
- **THEN** the request succeeds with the granted viewer permission
- **AND** only services in the same project are visible
