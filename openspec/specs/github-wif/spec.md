## ADDED Requirements

### Requirement: Workload Identity Pool exists

The system SHALL create a Workload Identity Pool named "github" to federate GitHub Actions OIDC tokens.

#### Scenario: Pool creation

- **WHEN** Terraform applies the WIF configuration
- **THEN** a Workload Identity Pool named "github" exists in the GCP project

### Requirement: OIDC Provider configured

The system SHALL create an OIDC provider within the pool that trusts tokens from `https://token.actions.githubusercontent.com`.

#### Scenario: Provider validates GitHub tokens

- **WHEN** a GitHub Actions workflow requests an OIDC token
- **THEN** the provider accepts tokens from issuer `https://token.actions.githubusercontent.com`

#### Scenario: Standard attribute mapping

- **WHEN** the OIDC provider receives a GitHub token
- **THEN** it maps `assertion.repository` to `attribute.repository`
- **AND** it maps `assertion.repository_owner` to `attribute.repository_owner`
- **AND** it maps `assertion.ref` to `attribute.ref`
- **AND** it maps `assertion.actor` to `attribute.actor`

### Requirement: Infrastructure service account exists

The system SHALL create a service account `github-actions-infra` with broad permissions for infrastructure management.

#### Scenario: Infra SA has tofu-ci equivalent permissions

- **WHEN** the infrastructure service account is created
- **THEN** it has permissions equivalent to the existing `tofu-ci` service account

#### Scenario: Infra SA bound to infrastructure repo only

- **WHEN** configuring WIF IAM bindings for the infra SA
- **THEN** only `dmikalova/infrastructure` repository can impersonate it
- **AND** no other repositories can impersonate it

### Requirement: Deploy service account exists

The system SHALL create a service account `github-actions-deploy` with minimal permissions for Cloud Run deployment.

#### Scenario: Deploy SA has run.developer role only

- **WHEN** the deploy service account is created
- **THEN** it has the `roles/run.developer` role
- **AND** it does NOT have `roles/run.admin`
- **AND** it does NOT have `roles/secretmanager.secretAccessor`

#### Scenario: Deploy SA bound to explicit app repos

- **WHEN** configuring WIF IAM bindings for the deploy SA
- **THEN** only explicitly listed app repositories can impersonate it
- **AND** the binding is per-repository, not per-owner

### Requirement: GitHub stack outputs repo metadata with topics

The GitHub Terramate stacks SHALL output repository metadata including topics for categorization.

#### Scenario: Repo output includes topics

- **WHEN** a GitHub stack defines a repository
- **THEN** the stack outputs the full repo name (e.g., `dmikalova/email-unsubscribe`)
- **AND** includes the list of topics assigned to the repository

### Requirement: WIF stack filters by topic for deploy access

The WIF stack SHALL read GitHub stack outputs and filter repositories by topic to determine which repos get deploy SA bindings.

#### Scenario: Deploy SA bindings derived from topics

- **WHEN** the WIF stack applies
- **THEN** it reads the repositories map from GitHub stack outputs
- **AND** creates deploy SA bindings only for repos with the `mklv-deploy` topic

#### Scenario: New app repo with topic gets automatic binding

- **WHEN** a new app repository is added to a GitHub stack with `topics = ["mklv-deploy"]`
- **AND** the GitHub stack is applied
- **AND** the WIF stack is applied
- **THEN** the new repo automatically gets deploy SA access

### Requirement: GitHub Actions workflow authenticates via WIF

GitHub Actions workflows SHALL use the `google-github-actions/auth` action to authenticate via WIF.

#### Scenario: Workflow requests OIDC token

- **WHEN** a GitHub Actions workflow runs with `id-token: write` permission
- **AND** uses `google-github-actions/auth` with WIF configuration
- **THEN** it receives short-lived GCP credentials without service account keys

### Requirement: Local development uses ADC

Local development SHALL authenticate using Application Default Credentials without WIF-specific code paths.

#### Scenario: Developer runs deploy locally

- **WHEN** a developer runs `gcloud auth application-default login`
- **AND** executes deployment commands
- **THEN** the commands work identically to WIF-authenticated runs in GHA
