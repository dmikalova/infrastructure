## Context

Four domains are managed: cddc39.tech and dmikalova.dev were transferred from Squarespace to Namecheap. mklv.tech and keyforge.cards were registered new on Namecheap. e91e63.tech was cancelled on Squarespace. GCP Cloud DNS provides authoritative DNS for all domains. The Namecheap Terraform stack automates NS delegation by reading nameservers from GCP Cloud DNS remote state. The Namecheap stack is disabled by default since the API requires IP whitelisting.

## Goals / Non-Goals

**Goals:**

- Transfer cddc39.tech and dmikalova.dev from Squarespace to Namecheap
- Register mklv.tech and keyforge.cards on Namecheap
- Cancel e91e63.tech on Squarespace
- Create GCP Cloud DNS managed zones for all four active domains
- Delegate DNS from Namecheap to GCP Cloud DNS nameservers (automated via remote state)
- Extend the cloud-run-app module to automatically provision custom domains with SSL
- Each app gets `<app-name>.mklv.tech` (e.g., `email-unsubscribe.mklv.tech`, `login.mklv.tech`)

**Non-Goals:**

- Namecheap CDN or other features (Namecheap is registrar-only, DNS is GCP Cloud DNS)
- Email routing or MX records (can be added later)
- Multi-region DNS failover
- Zero-downtime migration (domains were not in active use, downtime was acceptable)

## Decisions

### 1. Namecheap as registrar, GCP Cloud DNS as authoritative DNS

**Decision**: Use Namecheap for domain registration. Delegate all DNS to GCP Cloud DNS. NS delegation is automated — the Namecheap stack reads nameservers from GCP Cloud DNS remote state.

**Alternatives considered**:

- _Cloudflare for registration and DNS_: Was initially implemented but switched to Namecheap. Cloudflare worked but Namecheap was preferred.
- _Keep Squarespace, point NS to GCP_: Squarespace has no Terraform provider — can't manage registration as code.

**Rationale**: Namecheap's Terraform provider manages NS delegation. GCP Cloud DNS keeps all runtime DNS in GCP alongside the apps. Reading nameservers from remote state means adding a domain to `gcp/infra/domains` is all that's needed — Namecheap picks it up automatically.

### 2. Domain mapping via `google_cloud_run_domain_mapping`

**Decision**: Use `google_cloud_run_domain_mapping` resource in the cloud-run-app module. The domain is determined by a topic on the GitHub repo (e.g., `mklv.tech`), which flows into the app's infra stack. Apps on `mklv.tech` get `<app-name>.mklv.tech`, apps on `keyforge.cards` get `<app-name>.keyforge.cards`.

**Alternatives considered**:

- _Global external HTTPS load balancer with NEG_: More powerful (multi-region, CDN) but massive complexity increase for a personal project. ~$18/month for the forwarding rule alone.
- _Cloud Run custom domains via `gcloud` CLI_: Not Terraform-managed.
- _Hardcode domain per app stack_: Works but doesn't scale. A topic/label on the repo is the source of truth.

**Rationale**: Domain mappings are free, simple, and handle SSL certificate provisioning automatically. Using repo topics as the source of truth (similar to existing `mklv-deploy` pattern) keeps domain assignment declarative and extensible.

### 3. Stack structure: dedicated `gcp/infra/domains` stack, Namecheap in separate stack

**Decision**:

- Cloud DNS zones go in `gcp/infra/domains/` stack — the source of truth for managed domains
- Namecheap registrar config goes in `namecheap/domains/` stack (disabled by default due to API IP whitelisting)
- Domain mappings stay in each app's stack via the cloud-run-app module
- Domain list lives only in `gcp/infra/domains/main.tf` — Namecheap reads it via remote state

**Alternatives considered**:

- _Add to `gcp/infra/platform/`_: Platform handles artifact registry — mixing in DNS reduces focus. Stacks should be scoped to one concern.
- _Duplicate domain list across stacks_: Was initially done via Terramate global but removed — single source of truth in GCP domains is better.
- _Inline resources without modules_: Works for a fixed set but doesn't scale. A module per domain makes adding future domains a one-liner.

**Rationale**: Reusable modules mean adding a new domain requires only adding it to `gcp/infra/domains/main.tf`. The Namecheap stack picks it up automatically via remote state. The disabled-by-default Namecheap stack is run locally only.

### 4. Namecheap API credentials in SOPS

**Decision**: Create `secrets/namecheap.sops.json` with API key, API user, client IP, and username.

**Rationale**: Follows the existing pattern (gcp.sops.json, supabase.sops.json). The Namecheap API requires IP whitelisting, so the stack is disabled by default and run locally.

### 5. DNS records: CNAME to `ghs.googlehosted.com`

**Decision**: Cloud Run domain mappings require a CNAME record pointing to `ghs.googlehosted.com`. The cloud-run-app module will create the Cloud DNS record set when `custom_domain` is provided.

**Rationale**: This is the documented approach for Cloud Run custom domains. Google manages SSL certificates automatically via the domain mapping resource.

## Risks / Trade-offs

- **Domain transfer timing**: Squarespace → Namecheap transfer takes up to 5-7 days. → Acceptable since domains were not in active use.
- **SSL certificate provisioning delay**: Google-managed SSL certs can take 15-60 minutes to provision after domain mapping. → Cloud Run URLs continue to work as fallback.
- **Namecheap API IP whitelisting**: The API requires whitelisted IPs, so the stack can't run in CI. → Stack is disabled by default, run locally with `--disable-safeguards=disabled-stacks`.
- **CI service account permissions**: Need to add `roles/dns.admin` to the tofu-ci SA and enable `dns.googleapis.com` API. → Straightforward additions to baseline.

## Migration Plan

1. **Prep Namecheap account**:
   - Create Namecheap account
   - Enable API access and whitelist IP
   - Add credentials to `secrets/namecheap.sops.json`

2. **Prep GCP infrastructure**:
   - Enable `dns.googleapis.com` API in baseline
   - Add `roles/dns.admin` to tofu-ci SA
   - Create Cloud DNS zones for cddc39.tech, dmikalova.dev, mklv.tech, and keyforge.cards in `gcp/infra/domains/`

3. **Transfer and register domains on Namecheap**:
   - Register new domains: mklv.tech and keyforge.cards
   - Transfer cddc39.tech and dmikalova.dev from Squarespace
   - Cancel e91e63.tech on Squarespace (manual)
   - Run Namecheap stack to automate NS delegation to GCP Cloud DNS

4. **Create Namecheap Terraform stack**:
   - Create `namecheap/domains/` stack reading domain list from GCP remote state
   - Stack disabled by default, run locally only

5. **Enable app custom domains**:
   - Add domain topic to GitHub repos (e.g., `domain:mklv.tech`)
   - Add `custom_domain` variable to cloud-run-app module
   - Add DNS record + domain mapping resources
   - Update email-unsubscribe stack with domain from repo topic

## Domain Purposes

| Domain         | Purpose                                         |
| -------------- | ----------------------------------------------- |
| mklv.tech      | Primary app domain — apps get `<app>.mklv.tech` |
| keyforge.cards | KeyForge-related apps and services              |
| dmikalova.dev  | Personal portfolio for job applications         |
| cddc39.tech    | Unused — parked                                 |

## Open Questions

<!-- None at this time -->
