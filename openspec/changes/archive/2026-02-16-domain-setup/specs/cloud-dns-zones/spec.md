# Cloud Dns Zones

## ADDED Requirements

## Requirement: Reusable Cloud DNS zone module

The system SHALL provide a reusable Terraform module at
`terraform/modules/gcp/cloud-dns-zone` that creates a single GCP Cloud DNS
managed zone for a given domain.

### Scenario: Create a managed zone

- **WHEN** the module is called with a domain name and GCP project ID
- **THEN** it creates a `google_dns_managed_zone` resource for that domain

### Scenario: Module outputs nameservers

- **WHEN** the zone is created
- **THEN** the module outputs the assigned nameserver records for use by the
  registrar delegation

## Requirement: GCP domains stack

The system SHALL have a `gcp/infra/domains/` Terramate stack that creates Cloud
DNS zones by calling the `gcp/cloud-dns-zone` module once per domain.

### Scenario: All four domains have zones

- **WHEN** the stack is applied
- **THEN** it creates managed zones for cddc39.tech, dmikalova.dev,
  keyforge.cards, and mklv.tech

### Scenario: Stack declares dependencies

- **WHEN** the stack is created
- **THEN** it declares `after` dependency on `/gcp/infra/baseline` (for APIs and
  SA permissions)

## Requirement: DNS API enabled in baseline

The system SHALL enable the `dns.googleapis.com` API in the `gcp/infra/baseline`
stack.

### Scenario: API is enabled

- **WHEN** baseline is applied
- **THEN** `dns.googleapis.com` is listed in the enabled project services

## Requirement: CI service account has DNS permissions

The system SHALL grant `roles/dns.admin` to the `tofu-ci` service account in
`gcp/infra/baseline`.

### Scenario: SA can manage DNS zones and records

- **WHEN** `tofu plan` or `tofu apply` runs for DNS resources
- **THEN** the CI service account has sufficient permissions to create and
  modify Cloud DNS zones and record sets

## Requirement: cddc39.tech is parked

The domain cddc39.tech SHALL be registered but unused — no redirect or active
DNS records are required.
