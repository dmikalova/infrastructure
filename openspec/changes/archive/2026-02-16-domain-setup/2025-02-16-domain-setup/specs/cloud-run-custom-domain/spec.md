## ADDED Requirements

### Requirement: Optional custom domain on cloud-run-app module

The `cloud-run-app` module SHALL accept an optional `custom_domain` variable. When provided, it creates a domain mapping and DNS record for the app.

#### Scenario: App with custom domain

- **WHEN** `custom_domain` is set (e.g., `email-unsubscribe.mklv.tech`)
- **THEN** the module creates a `google_cloud_run_domain_mapping` resource and a CNAME record in Cloud DNS pointing to `ghs.googlehosted.com`

#### Scenario: App without custom domain

- **WHEN** `custom_domain` is not set or empty
- **THEN** the module does not create any domain mapping or DNS resources, and the app is only accessible via its Cloud Run URL

### Requirement: DNS record set in Cloud DNS

The module SHALL create a `google_dns_record_set` CNAME record in the appropriate Cloud DNS managed zone when `custom_domain` is provided.

#### Scenario: CNAME points to Google hosted services

- **WHEN** a custom domain is configured
- **THEN** a CNAME record for `<app-name>.<domain>` pointing to `ghs.googlehosted.com.` is created in the matching Cloud DNS zone

#### Scenario: Module accepts DNS zone name

- **WHEN** `custom_domain` is provided
- **THEN** the module also accepts a `dns_zone_name` variable identifying which Cloud DNS managed zone to create the record in

### Requirement: SSL certificate is Google-managed

The domain mapping SHALL use Google-managed SSL certificates that are automatically provisioned and renewed.

#### Scenario: Certificate is provisioned

- **WHEN** a domain mapping is created
- **THEN** Google provisions an SSL certificate for the custom domain (may take 15-60 minutes)

#### Scenario: HTTPS works after provisioning

- **WHEN** the SSL certificate is active
- **THEN** the app is accessible via `https://<custom_domain>`

### Requirement: Domain is determined by GitHub repo topic

Each app's custom domain SHALL be derived from a topic on the GitHub repository (e.g., `mklv.tech`), flowing into the app's infrastructure stack.

#### Scenario: App repo has domain topic

- **WHEN** a GitHub repo has the topic `mklv.tech`
- **THEN** the app's infra stack sets `custom_domain = "<app-name>.mklv.tech"`

#### Scenario: App repo has no domain topic

- **WHEN** a GitHub repo has no domain topic
- **THEN** the app's infra stack does not set `custom_domain` and no domain mapping is created

#### Scenario: Different domain topics map to different domains

- **WHEN** a repo has topic `keyforge.cards`
- **THEN** the app gets `<app-name>.keyforge.cards`
