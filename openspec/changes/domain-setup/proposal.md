## Why

The infrastructure lacks domain management - apps like email-unsubscribe are only accessible via auto-generated Cloud Run URLs. Custom domains (mklv.tech, cddc39.tech) provide professional URLs, enable SSL certificates, and allow consistent subdomains per app (e.g., email-unsubscribe.mklv.tech).

## What Changes

- Register/transfer mklv.tech and cddc39.tech to a Terraform-friendly registrar (Cloudflare recommended)
- Create GCP Cloud DNS managed zones for both domains
- Configure registrar to delegate DNS to GCP Cloud DNS nameservers
- Update Cloud Run app module to automatically create DNS records and SSL certificates for app subdomains
- Each app gets `<app-name>.<domain>` subdomain (e.g., email-unsubscribe.mklv.tech)

## Capabilities

### New Capabilities

- `domain-registration`: Terraform-managed domain registration with Cloudflare provider, delegating DNS to GCP
- `cloud-dns-zones`: GCP Cloud DNS managed zones for mklv.tech and cddc39.tech
- `cloud-run-custom-domain`: Extension to cloud-run-app module for automatic subdomain DNS records and SSL certificate provisioning

### Modified Capabilities

<!-- No existing capabilities are being modified -->

## Impact

- **Registrar**: New Cloudflare account/provider for domain registration (or existing registrar with NS delegation)
- **GCP**: Cloud DNS zones (~$0.20/zone/month + $0.40/million queries)
- **Secrets**: Cloudflare API token needed in SOPS if using Cloudflare provider
- **Cloud Run**: Domain mapping and SSL certificate resources added to app module
- **terraform/modules**: New modules for `cloudflare/domain`, `gcp/cloud-dns-zone`
- **gcp/apps/terramate.tm.hcl**: Update to include subdomain configuration
