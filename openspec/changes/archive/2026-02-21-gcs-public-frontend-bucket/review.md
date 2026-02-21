# GCS Public Frontend Bucket: Review

## Summary

The design is straightforward with sound security choices. The public bucket
should be added to the cloud-run-app module so each app gets both private and
public buckets by default.

## Security

- [x] **Public bucket separate from private traces**: Correctly addressed in
      design. Separate buckets prevent accidental exposure via IAM misconfiguration.
- [x] **allUsers for public read**: Appropriate for static content. No sensitive
      data in frontend assets.

No security concerns identified.

## Patterns

- [x] **Bucket naming convention**: Should follow symmetric pattern:
  - Private: `mklv-${app_name}-private` (renamed from `-storage`)
  - Public: `mklv-${app_name}-public` (new)
- [x] **Module modification**: The cloud-run-app module should be updated to
      create both buckets by default. Each app gets:
  - A private storage bucket (renamed from -storage to -private)
  - A public bucket for static assets
  - App service account can write to both
  - CI service account can write to public bucket
- [x] **Migration**: Existing `-storage` bucket data must be migrated to
      `-private` bucket before destroying the old bucket.

## Alternatives

- [x] **Firebase Hosting**: Simpler for static sites with built-in CDN. However,
      GCS provides more control and aligns with existing infrastructure patterns.
      **Defer**: Not needed for personal use.

No changes needed.

## Simplifications

No simplifications identified. The design is already minimal.

## Missing Considerations

- [x] **CORS configuration**: The bucket may need CORS headers for fonts or API
      preflight requests. GCS supports bucket-level CORS configuration.
      **Action**: Add CORS configuration for common SPA scenarios.
- [x] **Cache-Control headers**: Static assets should have appropriate caching.
      **Defer**: Can set via object metadata during upload, not infrastructure.
- [x] **CI/CD deployment step**: Need to add `gsutil rsync` or similar to deploy
      frontend to bucket.
      **Action**: Document in tasks, but actual CI/CD changes are in app repo.

## Valuable Additions

- [x] **robots.txt**: Mentioned in design as risk mitigation.
      **Defer**: App-level concern, not infrastructure.

## Action Items

1. Update cloud-run-app module to create public bucket alongside private bucket
2. Add CORS configuration for public bucket
3. Grant app service account write access to both buckets
4. Grant CI service account write access to public bucket

## Deferred Items

1. Cache-Control headers (set during deployment)
2. robots.txt (app-level concern)
3. Firebase Hosting alternative

## Updates Required

**Design**: Update to reflect module modification approach instead of separate
resource. Both buckets created by cloud-run-app module.
