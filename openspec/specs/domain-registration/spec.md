# Domain Registration

## ADDED Requirements

## Requirement: Reusable Namecheap domain module

The system SHALL provide a reusable Terraform module at
`terraform/modules/namecheap/domain` that manages NS delegation for a single
domain on Namecheap.

### Scenario: Delegate a domain to external nameservers

- **WHEN** the module is called with a domain name and nameservers
- **THEN** it creates a `namecheap_domain_records` resource with mode OVERWRITE
  delegating to the provided nameservers

### Scenario: Adding a new domain requires only a GCP change

- **WHEN** a new domain is added to `gcp/infra/domains`
- **THEN** the Namecheap stack picks it up automatically via remote state

## Requirement: Namecheap domains stack

The system SHALL have a `namecheap/domains/` Terramate stack that manages NS
delegation for all domains by reading the domain list and nameservers from GCP
Cloud DNS remote state.

### Scenario: Domains are delegated to GCP Cloud DNS

- **WHEN** the stack is applied
- **THEN** it manages NS delegation for all domains in the GCP domains stack
  (cddc39.tech, dmikalova.dev, mklv.tech, keyforge.cards)

### Scenario: Stack declares dependencies

- **WHEN** the stack is created
- **THEN** it declares `after` dependency on `/gcp/infra/domains`

### Scenario: Stack is disabled by default

- **WHEN** `terramate run` is executed
- **THEN** the Namecheap stack is skipped because `disable = true` (API requires
  IP whitelisting)

## Requirement: Namecheap provider authentication via SOPS

The system SHALL authenticate the Namecheap provider using credentials stored in
`secrets/namecheap.sops.json`.

### Scenario: Credentials are read from SOPS

- **WHEN** the Namecheap provider is configured
- **THEN** it reads API key, API user, client IP, and username from
  `secrets/namecheap.sops.json` via the SOPS provider

## Requirement: Namecheap provider in Terramate globals

The system SHALL add the Namecheap provider version to the top-level Terramate
globals and generate provider configuration for Namecheap stacks.

### Scenario: Provider version is defined globally

- **WHEN** a Namecheap stack needs the provider
- **THEN** the version is defined in `terramate.tm.hcl` globals alongside other
  provider versions

### Scenario: Namecheap stacks get generated terraform config

- **WHEN** a stack is under `namecheap/`
- **THEN** Terramate generates `_terraform.tf` with the Namecheap provider, SOPS
  provider, and GCS backend
