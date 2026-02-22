# Review: mklv-warm-endpoint

## Summary

The design is well-scoped with clear decisions. Main areas to address:
dependency ordering for bucket migration, and ensuring Cloud Run API is enabled.
The security model is appropriate for the warming use case.

## Security

- [x] **Warming endpoint is unauthenticated** - Acceptable. Health checks are
      already public, warming is idempotent, and there's no sensitive data exposed.
      The endpoint only triggers GET requests to other public health endpoints.

- [x] **Cloud Run viewer permission is project-scoped** - Good. The mklv service
      account can only view services in its own project, not cross-project.

- [x] **Scheduler uses OIDC authentication** - Good. Even though the endpoint is
      public, using OIDC means we could add auth later without changing scheduler.

## Patterns

- [x] **Module reuse** - Using existing cloud-run-app module is correct. Changes
      are additive (startup_cpu_boost, warm label, bucket always).

- [x] **Alphabetized variables** - Need to ensure new variables are added in
      alphabetical order per AGENTS.md conventions.

- [x] **Stack dependencies** - mklv stack will depend on baseline and platform
      like other app stacks.

## Alternatives

- [x] **Cloud Run Admin API vs Run Jobs API** - Using Admin API to list services
      is correct. Run Jobs API is for batch jobs, not service discovery.

- [x] **@google-cloud/run npm package** - Will use this library for cleaner API
      calls and future extensibility. **ADDRESS**

## Simplifications

- [x] **Always create bucket** - Good simplification. Removes conditional logic
      and configuration burden.

- [x] **Convention-based /health path** - Good. Avoids label proliferation.

- [x] **Bucket migration ordering** - New bucket must exist before copying data.
      Terraform creates new bucket, then manual copy, then delete old.
      **Design already addresses this in Phase 2.**

- [x] **Warming timeout handling** - Each service health check gets 5s timeout.
      No retries - just log failure and continue. **ADDRESS**

- [x] **Error logging for warming failures** - Log which services failed and why
      for debugging. **ADDRESS**

- [x] **lifecycle_rules for new bucket format** - Need to migrate lifecycle
      rules from private_bucket_lifecycle_rules to new bucket variable name.
      **Design mentions bucket has lifecycle rules support.**

## Valuable Additions

- [ ] **Warming metrics/observability** - Could track cold start frequency to
  verify warming is effective. **DEFER** - Not needed.

- [ ] **Warming endpoint returns timing** - Could include response times for
  each service to help identify slow apps. **DEFER** - Not needed.
Items that WILL be addressed in this change:

1. Add per-service timeout (5s), no retries in warming implementation
2. Log warming failures with service name and error
3. Verify Cloud Run Admin API is enabled in baseline
4. Use @google-cloud/run package for API calls
5. Create MKLV favicon with superimposed letters

## Deferred Items

Items acknowledged but intentionally deferred:

1. Warming metrics dashboard - not needed
2. Response timing in warming endpoint - not needed

## Updates Required

No changes needed to proposal or design. The review identified implementation
details that will be handled in the tasks phase.
