# GCS Public Frontend Bucket: Proposal

## Why

Cloud Run cold starts cause 300-800ms delays for the Email Unsubscribe app. Since
the Vue.js frontend is a static SPA with no server-side rendering, serving it
from a GCS bucket provides instant page loads while the API warms up in the
background.

## What Changes

- Add a new public GCS bucket for serving static frontend assets
- Enable object versioning with lifecycle policy to retain 5 versions for 90 days
- Deploy frontend builds to versioned paths for rollback capability
- Keep existing private traces bucket separate for security isolation

## Capabilities

### New Capabilities

- `gcs-public-bucket`: Public GCS bucket with website hosting, object versioning,
  and lifecycle policies for static frontend deployment

### Modified Capabilities

None - this is additive infrastructure that doesn't change existing capabilities.

## Impact

- **Infrastructure**: New GCS bucket resource in `gcp/apps/email-unsubscribe/`
- **CI/CD**: Email-unsubscribe workflow needs updated to deploy frontend to bucket
- **DNS**: May need CNAME or load balancer for custom domain (future enhancement)
- **Cost**: Minimal (~$0.02/GB storage, ~$0.12/GB egress)
