# Why

The infrastructure lacks domain management - apps like email-unsubscribe are
only accessible via auto-generated Cloud Run URLs. Custom domains provide
professional URLs, enable SSL certificates, and allow consistent subdomains per
app (e.g., email-unsubscribe.mklv.tech).

## What Changes

- Transfer cddc39.tech and dmikalova.dev from Squarespace to Namecheap
- Cancel e91e63.tech (no longer needed)
- Register new domains: mklv.tech and keyforge.cards on Namecheap
- Create GCP Cloud DNS managed zones for all four active domains
- Configure Namecheap to delegate DNS to GCP Cloud DNS nameservers (automated
  via Terraform remote state)
- Update Cloud Run app module to automatically create DNS records and SSL
  certificates for app subdomains
- Each app gets `<app-name>.<domain>` subdomain (e.g.,
  email-unsubscribe.mklv.tech)

## Capabilities

### New Capabilities

- `domain-registration`: Reusable Terraform module (`namecheap/domain`) for
  Namecheap-managed domain NS delegation to GCP Cloud DNS. Initial domains:
  cddc39.tech, dmikalova.dev, mklv.tech, keyforge.cards. Nameservers are read
  automatically from GCP Cloud DNS remote state.
- `cloud-dns-zones`: Reusable Terraform module (`gcp/cloud-dns-zone`) for GCP
  Cloud DNS managed zones. One zone per domain.
- `cloud-run-custom-domain`: Extension to cloud-run-app module for automatic
  subdomain DNS records and SSL certificate provisioning

### Modified Capabilities

<!-- No existing capabilities are being modified -->

## Impact

- **Registrar**: Namecheap for domain registration, with NS delegation automated
  via Terraform
- **GCP**: Cloud DNS zones (4 zones × ~$0.20/zone/month + $0.40/million queries)
- **Secrets**: Namecheap API credentials needed in SOPS
  (`secrets/namecheap.sops.json`)
- **Cloud Run**: Domain mapping and SSL certificate resources added to app
  module
- **terraform/modules**: New reusable modules: `namecheap/domain`,
  `gcp/cloud-dns-zone` — adding a new domain requires adding it to
  `gcp/infra/domains`; Namecheap picks it up automatically via remote state
- **Namecheap stack**: Disabled by default (`disable = true`) since the
  Namecheap API requires IP whitelisting — run locally only
