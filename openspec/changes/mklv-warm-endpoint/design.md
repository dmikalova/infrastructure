# Design: mklv-warm-endpoint

## Context

Cloud Run services scale to zero after ~15 minutes of inactivity for cost
savings. Cold starts add 500ms-2s latency. Cloud Scheduler can invoke endpoints
but costs money after 3 jobs (one per endpoint).

Current state:

- `email-unsubscribe`: Uses public_bucket for Vue frontend, private_bucket for
  Playwright traces, Vite compilation in CI
- `login`: No buckets, Vue compiled in CI, served from container
- `todos`: No buckets, Vue compiled in CI, served from container

All apps would benefit from simplified architecture: serve Vue directly
from Hono (browser compilation), eliminate Vite build step.

## Goals / Non-Goals

**Goals:**

- Reduce cold start latency with CPU boost and warming
- Simplify infrastructure by removing public bucket complexity
- Single warming job for all Cloud Run services
- New mklv.tech landing page + warming endpoint

**Non-Goals:**

- CDN/edge caching (adds complexity, minimal benefit for low traffic)
- Per-service warming configuration (uniform approach preferred)
- Migrating away from scale-to-zero (cost savings still valuable)

## Decisions

### Decision 1: Warming endpoint discovers services via labels

**Approach**: Cloud Run services opt-in with `warm=true` label. mklv.tech calls
Cloud Run Admin API to list services with this label, then hits each service's
internal URL (`*.run.app`) at `/health`.

**Alternatives considered**:

- Hard-coded list: Requires infra changes for each new app
- Terraform output consumed by scheduler: Adds coupling, still static
- Service Directory: Overkill, adds cost
- Dynamic discovery without labels: Would warm everything including test services

**Rationale**: Label-based opt-in is explicit, self-maintaining, and uses
existing Cloud Run metadata. Internal URLs are returned directly by the API
and avoid DNS dependencies. `/health` path is a convention all apps follow.

### Decision 2: Single Cloud Scheduler job at 10-minute interval

**Approach**: One scheduler job hits `/api/warm`, which fans out to all services.

**Alternatives considered**:

- Per-service scheduler jobs: Hits 3-job free tier limit quickly
- Lambda/Cloud Function cron: Additional service to manage

**Rationale**: Stays within free tier, centralizes warming logic in application
code where it's easier to modify.

### Decision 3: startup_cpu_boost enabled by default

**Approach**: Add `startup_cpu_boost = true` to Cloud Run service template.

**Alternatives considered**:

- Optional parameter: Extra config burden for every app
- Always-on higher CPU: Higher cost

**Rationale**: CPU boost only applies during startup, no ongoing cost increase.
All apps benefit from faster cold starts.

### Decision 4: Always create bucket, remove public_bucket option

**Approach**: Every Cloud Run app gets a private GCS bucket at
`mklv-<app-name>`. Remove `public_bucket` and `private_bucket` options entirely.

**Alternatives considered**:

- Keep bucket optional: Extra config for something that costs nothing
- Keep public_bucket as optional: Adds maintenance burden for unused feature

**Rationale**: GCS buckets are free until you store data. Always creating one
removes configuration complexity. Apps can use it for traces, uploads, etc.
without infra changes.

### Decision 5: mklv.tech serves static landing page from Hono

**Approach**: Deno/Hono app with static HTML in src/public/ directory. Favicon
with stylized "MKLV" letters superimposed.

**Alternatives considered**:

- GCS bucket with Cloud CDN: Overkill for simple landing page
- Firebase Hosting: Another service to manage

**Rationale**: Consistent with other apps. Can add dynamic features later
without architecture change.

### Decision 6: Remove Vue compilation, keep Vue for SSR

**Approach**: Apps serve Vue templates directly from Hono on each request.
No separate Vite build step. Vue runs in the browser, not compiled ahead of time.

**Alternatives considered**:

- Keep Vite compilation: Adds build complexity, separate static asset hosting
- Full SSR with hydration: More complexity than needed for simple apps

**Rationale**: Simplest architecture. Vue SFCs can still be used but served
as-is. Browser handles compilation. Slightly slower initial load but eliminates
build pipeline entirely.

## Risks / Trade-offs

**[Risk] Service discovery requires extra IAM permission**
→ Grant `roles/run.viewer` to mklv service account. Scoped to single project.

**[Risk] Warming endpoint could time out with many services**
→ Current count is 4 services. Health checks are fast (~100ms). Fan out
in parallel. Can add timeout handling if needed.

**[Risk] Bucket rename requires data migration**
→ Manual migration step with clear commands. Data is traces (non-critical).
Migrate from `mklv-email-unsubscribe-private` to `mklv-email-unsubscribe`.

**[Trade-off] 10-minute interval means occasional cold starts**
→ Acceptable. Most users won't notice 500ms delay on first request.
More frequent warming increases cost.

## Migration Plan

### Phase 1: Infrastructure (this PR)

1. Update cloud-run-app module (add startup_cpu_boost, add warm label, always
   create bucket, remove public_bucket/private_bucket options)
2. Create mklv.tech repo in github/dmikalova
3. Create gcp/apps/mklv stack with Cloud Run + scheduler
4. Update email-unsubscribe stack (remove bucket options, auto-creates now)
5. Existing apps automatically get `warm=true` label via module default
6. Run `tofu plan` in all affected stacks to verify

### Phase 2: Apply infrastructure

1. `tofu apply` in terraform/modules (if needed)
2. `tofu apply` in gcp/apps/mklv (creates new service)
3. `tofu apply` in gcp/apps/email-unsubscribe (creates new bucket, removes old)
4. Migrate email-unsubscribe bucket data manually
5. Delete old buckets manually

### Phase 3: App repos (separate PRs)

1. Deploy mklv.tech app code (landing page + warming endpoint)
2. Update email-unsubscribe: remove Vite build, rename api/ → src/
3. Update login: remove Vite build, rename api/ → src/
4. Update todos: remove Vite build, merge api/ + src/ into src/
5. Update github-meta: remove Vue compilation from workflow

### Rollback

- Module changes: Revert commit, re-add public/private bucket options
- Bucket migration: Restore from bucket versioning
- mklv.tech: Can be deleted independently

## Open Questions

~~1. **Should warming endpoint require authentication?**~~
Resolved: No auth. Health checks are public, warming is idempotent.

~~2. **What should the landing page show?**~~
Resolved: Simple "mklv.tech" branding with links to apps. MKLV favicon.
