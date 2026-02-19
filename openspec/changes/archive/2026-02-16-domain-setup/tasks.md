# 1. Cloudflare Account and Secrets

- [x] 1.1 Create Cloudflare account
- [x] 1.2 Generate scoped API token (domain registration + DNS settings
      permissions)
- [x] 1.3 Create `secrets/cloudflare.sops.json` with the API token

## 2. GCP Baseline Updates

- [x] 2.1 Enable `dns.googleapis.com` API in `gcp/infra/baseline/main.tf`
- [x] 2.2 Add `roles/dns.admin` to the `tofu-ci` service account in
      `gcp/infra/baseline/main.tf`
- [x] 2.3 Run `tofu plan` in `gcp/infra/baseline` to verify

## 3. Terramate Globals for Cloudflare

- [x] 3.1 Add Cloudflare provider version to `terramate.tm.hcl` globals
- [x] 3.2 Create `cloudflare/terramate.tm.hcl` with code generation for
      `_terraform.tf` (Cloudflare provider, SOPS provider, GCS backend)

## 4. Cloud DNS Zone Module

- [x] 4.1 Create `terraform/modules/gcp/cloud-dns-zone/variables.tf` with
      `domain` and `gcp_project_id` inputs
- [x] 4.2 Create `terraform/modules/gcp/cloud-dns-zone/main.tf` with
      `google_dns_managed_zone` resource
- [x] 4.3 Create `terraform/modules/gcp/cloud-dns-zone/outputs.tf` outputting
      zone name and nameservers

## 5. GCP Domains Stack

- [x] 5.1 Create `gcp/infra/domains/stack.tm.hcl` with
      `after = ["/gcp/infra/baseline"]`
- [x] 5.2 Create `gcp/infra/domains/main.tf` calling `gcp/cloud-dns-zone` module
      for cddc39.tech, dmikalova.dev, mklv.tech, kfrg.tech
- [x] 5.3 Run `tofu init` and `tofu plan` in `gcp/infra/domains` to verify

## 6. Cloudflare Domain Module

- [x] 6.1 Create `terraform/modules/cloudflare/domain/variables.tf` with
      `domain` and `cloudflare_account_id` inputs
- [x] 6.2 Create `terraform/modules/cloudflare/domain/main.tf` with
      `cloudflare_registrar_domain` resource
- [x] 6.3 Create `terraform/modules/cloudflare/domain/outputs.tf`

## 7. Domain Registration and Transfer

- [x] 7.1 ~~Register mklv.tech on Cloudflare~~ Registered on Namecheap
- [x] 7.2 ~~Register kfrg.tech on Cloudflare~~ Registered keyforge.cards on
      Namecheap instead
- [x] 7.3 ~~Unlock cddc39.tech at Squarespace and get auth code~~ Transferred to
      Namecheap
- [x] 7.4 ~~Initiate cddc39.tech transfer to Cloudflare~~ Transferred to
      Namecheap
- [x] 7.5 ~~Unlock dmikalova.dev at Squarespace and get auth code~~ Transferred
      to Namecheap
- [x] 7.6 ~~Initiate dmikalova.dev transfer to Cloudflare~~ Transferred to
      Namecheap
- [x] 7.7 ~~Cancel e91e63.tech on Squarespace (manual)~~ Done
- [x] 7.8 ~~Configure all four domains to delegate NS to GCP Cloud DNS
      nameservers~~ Automated via Namecheap stack reading GCP remote state

## 8. ~~Cloudflare~~ Namecheap Domains Stack

- [x] 8.1 Create `cloudflare/domains/stack.tm.hcl` with
      `after = ["/gcp/infra/domains"]`
- [x] 8.2 Create `cloudflare/domains/main.tf` calling `cloudflare/domain` module
      for each domain, passing account ID from SOPS
- [x] 8.3 ~~Import existing domain registrations into state~~ Not needed —
      Namecheap stack applied fresh
- [x] 8.4 ~~Run `tofu plan` in `cloudflare/domains` to verify~~ Ran `tofu apply`
      in `namecheap/domains`

## 9. Cloud Run Custom Domain Support

- [x] 9.1 Add `custom_domain` and `dns_zone_name` optional variables to
      `terraform/modules/gcp/cloud-run-app/variables.tf`
- [x] 9.2 Add `google_cloud_run_domain_mapping` resource to
      `terraform/modules/gcp/cloud-run-app/main.tf` (conditional on
      `custom_domain`)
- [x] 9.3 Add `google_dns_record_set` CNAME to `ghs.googlehosted.com` in the
      cloud-run-app module (conditional on `custom_domain`)

## 10. App Domain Assignment

- [x] 10.1 Add `mklv.tech` topic to the email-unsubscribe repo in
      `github/dmikalova/main.tf`
- [x] 10.2 Update `gcp/apps/email-unsubscribe/main.tf` to pass
      `custom_domain = "email-unsubscribe.mklv.tech"` and `dns_zone_name` to the
      cloud-run-app module
- [x] 10.3 Run `tofu plan` in `gcp/apps/email-unsubscribe` to verify domain
      mapping and DNS record

## 11. cddc39.tech Redirect

- [x] 11.1 ~~Configure DNS or Cloud Run redirect from cddc39.tech to mklv.tech~~
      Not needed — domain will sit unused
