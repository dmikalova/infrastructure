# Proposal: mklv-warm-endpoint

## Why

Cloud Run scale-to-zero saves costs but causes slow cold starts. A single
warming job that hits all app health endpoints provides consistent latency
without per-app Cloud Scheduler costs (free tier: 3 jobs). Additionally, the
current infrastructure has complexity from separate Vue compilation and public
buckets that should be consolidated into server-rendered apps.

## What Changes

### New: mklv.tech service

- Create `mklv.tech` GitHub repo with Deno/Hono app
- Deploy as Cloud Run service at `mklv.tech`
- Landing page at `/` with simple branding and app links
- Favicon with stylized "MKLV" letters superimposed
- Warming endpoint at `/api/warm` that:
  - Discovers Cloud Run services with `warm=true` label
  - Hits each service's internal URL at `/health`
  - Returns status summary
- Single Cloud Scheduler job hits `/api/warm` every 10 minutes

### Infrastructure Module Updates

- **cloud-run-app module**: Add `startup_cpu_boost` option (enabled by default)
- **cloud-run-app module**: Add `warm` label option (default true) for service
  discovery
- **cloud-run-app module**: Remove `public_bucket` and `private_bucket` options
- **cloud-run-app module**: Always create bucket at `mklv-<app-name>` (free
  until data stored)

### App Infrastructure Changes

- **email-unsubscribe**: Remove `public_bucket = true`, `private_bucket = true`
  (bucket created automatically now)
- **login**: Remove any public bucket config, use server-rendered
- **todos**: Remove any public bucket config, use server-rendered

### App Code Changes (separate PRs)

- **email-unsubscribe**: Remove Vite build, keep Vue (browser compiles), rename
  api/ → src/
- **login**: Remove Vite build, keep Vue, rename api/ → src/
- **todos**: Remove Vite build, keep Vue, merge api/ and src/ into src/
- **github-meta**: Update GHA workflow to remove Vue compilation step

## Capabilities

### New Capabilities

- `cloud-run-warming`: Cloud Scheduler-triggered endpoint that discovers and
  warms all Cloud Run services
- `mklv-landing`: Public landing page for mklv.tech domain

### Modified Capabilities

- `cloud-run-service`: Add startup_cpu_boost, add warm label, always create
  bucket (remove public_bucket/private_bucket options)
- `gcs-public-bucket`: **DEPRECATED** - removing this capability entirely

## Impact

### Infrastructure

- `terraform/modules/gcp/cloud-run-app/` - module changes
- `gcp/apps/email-unsubscribe/` - remove bucket options (auto-created now)
- `gcp/apps/login/` - no changes (bucket auto-created now)
- `gcp/apps/todos/` - no changes (bucket auto-created now)
- `github/dmikalova/` - add mklv.tech repo
- New stack: `gcp/apps/mklv/` - Cloud Run service + scheduler

### Migration

After `tofu apply` creates `mklv-email-unsubscribe` bucket:

```bash
# Copy data from old private bucket to new bucket
gcloud storage cp -r gs://mklv-email-unsubscribe-private/* gs://mklv-email-unsubscribe/

# Delete old buckets
gcloud storage rm -r gs://mklv-email-unsubscribe-private
gcloud storage rm -r gs://mklv-email-unsubscribe-public
```

### External Dependencies

- Cloud Scheduler API (already enabled)
- Cloud Run Admin API for service discovery (new permission for mklv service
  account)

### App Repos (follow-up work)

- `email-unsubscribe`: Remove Vite build step, rename api/ → src/, serve Vue
  templates directly (browser compilation)
- `login`: Remove Vite build step, rename api/ → src/, serve Vue templates
  directly
- `todos`: Remove Vite build step, merge api/ and src/ into single src/, serve
  Vue templates directly
- `github-meta`: Update GHA workflow to remove Vue compilation step
