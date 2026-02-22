# Tasks: mklv-warm-endpoint

## 1. Cloud Run App Module Updates

- [ ] 1.1 Add `startup_cpu_boost` to google_cloud_run_v2_service resource
      (default true)
- [ ] 1.2 Add `warm` label variable (default true) and apply to service labels
- [ ] 1.3 Remove `public_bucket` variable and all public bucket resources
- [ ] 1.4 Remove `private_bucket` variable, make bucket unconditional
- [ ] 1.5 Rename bucket from `mklv-<app>-private` to `mklv-<app>`
- [ ] 1.6 Rename `PRIVATE_BUCKET_NAME` env var to `BUCKET_NAME`
- [ ] 1.7 Remove `private_bucket_lifecycle_rules`, add `bucket_lifecycle_rules`
- [ ] 1.8 Update module outputs (remove public*bucket*_, rename private*bucket*_)
- [ ] 1.9 Run `tofu plan` in module directory to verify syntax

## 2. Create mklv.tech GitHub Repository

- [ ] 2.1 Add `mklv.tech` to github/dmikalova/main.tf repositories map
- [ ] 2.2 Set topics: `["mklv-deploy", "mklv-tech"]`
- [ ] 2.3 Run `tofu plan` in github/dmikalova to verify

## 3. Create mklv Stack Infrastructure

- [ ] 3.1 Create `gcp/apps/mklv/` Terramate stack directory
- [ ] 3.2 Add stack.tm.hcl with dependencies on baseline, platform, wif
- [ ] 3.3 Add \_terraform.tf with required providers (google, sops)
- [ ] 3.4 Create main.tf using cloud-run-app module for mklv.tech
- [ ] 3.5 Add `roles/run.viewer` IAM binding for mklv service account
- [ ] 3.6 Add Cloud Scheduler job for `/api/warm` every 10 minutes
- [ ] 3.7 Configure scheduler with OIDC auth using mklv service account
- [ ] 3.8 Set `warm = false` for mklv itself (avoid self-warming loop)
- [ ] 3.9 Run `tofu plan` in gcp/apps/mklv to verify

## 4. Verify Cloud Run API Enabled

- [ ] 4.1 Check gcp/infra/baseline for `run.googleapis.com` in enabled APIs
- [ ] 4.2 Add `run.googleapis.com` if not present
- [ ] 4.3 Run `tofu plan` in gcp/infra/baseline to verify

## 5. Update email-unsubscribe Stack

- [ ] 5.1 Remove `public_bucket = true` from cloud_run module call
- [ ] 5.2 Remove `private_bucket = true` from cloud_run module call
- [ ] 5.3 Remove `ci_service_account` parameter (was for public bucket)
- [ ] 5.4 Rename `private_bucket_lifecycle_rules` to `bucket_lifecycle_rules`
- [ ] 5.5 Run `tofu plan` in gcp/apps/email-unsubscribe to verify

## 6. Update login and todos Stacks

- [ ] 6.1 Run `tofu plan` in gcp/apps/login (should get new bucket + labels)
- [ ] 6.2 Run `tofu plan` in gcp/apps/todos (should get new bucket + labels)
- [ ] 6.3 Verify plans show bucket creation and warm label addition

## 7. Validate All Stacks

- [ ] 7.1 Run `terramate run -- tofu init` across all affected stacks
- [ ] 7.2 Run `terramate run -- tofu plan` to see consolidated changes
- [ ] 7.3 Review plans for any unexpected deletions or modifications

## 8. Manual Steps (Post-PR Merge)

**Note: Do not run `tofu apply` - these are manual steps for the user.**

After PR is merged:

1. `tofu apply` in gcp/infra/baseline (if APIs added)
2. `tofu apply` in github/dmikalova (creates mklv.tech repo)
3. Clone mklv.tech repo and deploy initial app code
4. `tofu apply` in gcp/apps/mklv (creates Cloud Run + scheduler)
5. `tofu apply` in gcp/apps/email-unsubscribe (creates new bucket, removes old)
6. Migrate bucket data:
   ```bash
   gcloud storage cp -r gs://mklv-email-unsubscribe-private/* gs://mklv-email-unsubscribe/
   gcloud storage rm -r gs://mklv-email-unsubscribe-private
   gcloud storage rm -r gs://mklv-email-unsubscribe-public
   ```
7. `tofu apply` in gcp/apps/login (creates bucket, adds labels)
8. `tofu apply` in gcp/apps/todos (creates bucket, adds labels)

## 9. Follow-up PRs (App Repos)

**Note: These are separate PRs in other repositories.**

- [ ] 9.1 Create mklv.tech app: landing page, warming endpoint, MKLV favicon
- [ ] 9.2 Add @google-cloud/run dependency for service discovery
- [ ] 9.3 Warming endpoint: 5s timeout per service, no retries, log failures
- [ ] 9.4 Update email-unsubscribe: remove Vite, rename api/ → src/
- [ ] 9.5 Update login: remove Vite, rename api/ → src/
- [ ] 9.6 Update todos: remove Vite, merge api/ + src/ → src/
- [ ] 9.7 Update github-meta: remove Vue compilation from GHA workflow
