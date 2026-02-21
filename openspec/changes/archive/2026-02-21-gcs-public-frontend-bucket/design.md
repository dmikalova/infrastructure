# GCS Public Frontend Bucket: Design

## Context

The Email Unsubscribe app currently serves both the Vue.js frontend and API from
a single Cloud Run instance. Cold starts cause 300-800ms delays that affect
perceived performance. Since the frontend is a static SPA with no server-side
rendering, it can be served from GCS for instant loads.

Current infrastructure includes a private GCS bucket for Playwright traces. This
design adds a separate public bucket for frontend assets, maintaining security
isolation between public and private content.

## Goals / Non-Goals

**Goals:**

- Serve static frontend assets from GCS with instant response times
- Enable versioned deployments with rollback capability
- Implement lifecycle policy to retain 5 versions for up to 90 days
- Maintain security isolation from private traces bucket

**Non-Goals:**

- Cloud CDN integration (overkill for personal use, can add later)
- Custom domain via load balancer (future enhancement)
- Modifying the existing traces bucket

## Decisions

### 1. Add public bucket to cloud-run-app module

**Decision**: Modify the cloud-run-app module to create both private and public
buckets by default, rather than creating a separate resource per-app.

**Rationale**: Consistency across apps. Every app may need both private storage
(traces, uploads) and public assets (frontend, static files). Module-level
implementation ensures consistent naming, IAM, and lifecycle policies.

**Buckets created**:

- `mklv-${app_name}-private` - Private (renamed from `-storage`)
- `mklv-${app_name}-public` - Public, new

**Alternatives considered**:

- Separate resource per app: Rejected, leads to duplication and inconsistency
- Single bucket with path-based ACLs: Rejected due to security risk

### 2. Object versioning with lifecycle rules

**Decision**: Enable object versioning with lifecycle rules:

- Delete noncurrent versions when 5+ newer versions exist
- Delete noncurrent versions older than 90 days

**Rationale**: Provides rollback capability while preventing unbounded storage
growth. The 5-version limit ensures recent deployments are available for quick
rollback. The 90-day limit catches any edge cases.

**Alternatives considered**:

- No versioning: Rejected, loses rollback capability
- Versioning without lifecycle: Rejected, unbounded storage growth

### 3. Bucket location

**Decision**: Place bucket in `US-WEST1` (Oregon).

**Rationale**: Matches existing infrastructure location and is closest to the
user (Washington state). Single-region storage is cheaper than multi-region
and sufficient for personal use.

### 4. IAM permissions

**Decision**:

- App service account: `roles/storage.objectAdmin` on both buckets
- CI service account: `roles/storage.objectAdmin` on public bucket only

**Rationale**: App needs full access to both for runtime operations. CI only
needs to deploy frontend assets to public bucket.

## Risks / Trade-offs

**Risk**: Public bucket could be crawled/indexed by search engines.
**Mitigation**: Add robots.txt to frontend build to control indexing.

**Risk**: Egress costs if traffic unexpectedly high.
**Mitigation**: Monitor billing alerts. At $0.12/GB, would need significant
traffic to matter. Can add CDN later if needed.

**Risk**: CORS issues when frontend calls API on different origin.
**Mitigation**: Cloud Run API already configured for cross-origin requests from
the app domain.
