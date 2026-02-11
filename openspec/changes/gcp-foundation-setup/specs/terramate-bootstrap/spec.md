## ADDED Requirements

### Requirement: Terramate root configuration
The `gcp/` directory SHALL contain a `terramate.tm.hcl` file that configures Terramate for the GCP stacks.

#### Scenario: Root config exists
- **WHEN** Terramate commands are run from `gcp/`
- **THEN** the root configuration is loaded from `terramate.tm.hcl`
- **AND** global settings apply to all stacks under `gcp/`

### Requirement: Stack discovery
Terramate SHALL discover stacks under `gcp/infra/` and `gcp/project/` directories automatically.

#### Scenario: Baseline stack discovered
- **WHEN** `terramate list` is run from `gcp/`
- **THEN** `gcp/infra/baseline` appears in the stack list

#### Scenario: Workload stacks discovered
- **WHEN** a new project directory is created (e.g., `gcp/project/email-unsubscribe/`)
- **THEN** it appears in the stack list after adding stack configuration

### Requirement: Global variables
Terramate SHALL define global variables for shared configuration (project ID, region, Fabric module version).

#### Scenario: Globals accessible in stacks
- **WHEN** a stack references `global.project_id`
- **THEN** it receives the configured GCP project ID
- **AND** `global.region` provides the default region (us-central1)
- **AND** `global.fabric_version` provides the pinned Fabric module version

### Requirement: Code generation for backend
Terramate SHALL generate the GCS backend configuration for each stack.

#### Scenario: Backend generated
- **WHEN** `terramate generate` is run
- **THEN** each stack receives a `_backend.tf` file with GCS backend configuration
- **AND** the state key is unique per stack (based on stack path)

### Requirement: Code generation for providers
Terramate SHALL generate the Google provider configuration for each stack.

#### Scenario: Provider generated
- **WHEN** `terramate generate` is run
- **THEN** each stack receives a `_providers.tf` file with the Google provider
- **AND** the provider uses the project and region from globals

### Requirement: Stack ordering
Terramate SHALL respect stack dependencies when running commands.

#### Scenario: Baseline runs first
- **WHEN** `terramate run -- terraform apply` is executed
- **THEN** `gcp/infra/baseline` is applied before any workload stacks
- **AND** workload stacks can depend on baseline outputs

### Requirement: Directory structure separation
The `gcp/` directory SHALL separate infrastructure foundation from deployed workloads.

#### Scenario: Foundation in infra/
- **WHEN** viewing the `gcp/` directory
- **THEN** `gcp/infra/` contains only foundation stacks (baseline)
- **AND** `gcp/project/<name>/` directories contain workload stacks

### Requirement: Coexistence with Terragrunt
Terramate in `gcp/` SHALL not interfere with Terragrunt in `digitalocean/`.

#### Scenario: Independent tooling
- **WHEN** Terramate commands are run from `gcp/`
- **THEN** no changes occur to `digitalocean/` resources
- **AND** Terragrunt commands in `digitalocean/` are unaffected
