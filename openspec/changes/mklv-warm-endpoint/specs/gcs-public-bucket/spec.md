# GCS Public Bucket

## REMOVED Requirements

### Requirement: Public bucket serves static content

**Reason**: Apps moving to server-side rendering. Frontend assets now served
directly from Hono container instead of separate GCS bucket.

**Migration**: Update application to serve static files from `src/public/`
directory using Hono's static file middleware. Remove `public_bucket = true`
from infrastructure stack.

### Requirement: Object versioning enabled

**Reason**: No longer needed as public bucket is removed.

**Migration**: N/A - feature removed entirely.

### Requirement: Lifecycle policy limits version retention

**Reason**: No longer needed as public bucket is removed.

**Migration**: N/A - feature removed entirely.

### Requirement: Bucket location matches infrastructure

**Reason**: No longer needed as public bucket is removed.

**Migration**: N/A - feature removed entirely.
