# GCS Public Frontend Bucket: Tasks

## 1. Rename Private Bucket in Module

- [x] 1.1 Rename `google_storage_bucket.app` to `google_storage_bucket.private`
      in `terraform/modules/gcp/cloud-run-app/main.tf`
- [x] 1.2 Update bucket name from `${var.gcp_project_id}-${var.app_name}-storage`
      to `mklv-${var.app_name}-private`
- [x] 1.3 Update all references to the bucket (IAM bindings, outputs)

## 2. Add Public Bucket to Module

- [x] 2.1 Add `google_storage_bucket.public` resource with:
  - Name: `mklv-${var.app_name}-public`
  - Location: `var.gcp_region`
  - Website configuration (main_page_suffix and not_found_page = "index.html")
  - Object versioning enabled
  - No `public_access_prevention` (allow public access)
- [x] 2.2 Add lifecycle rules for version retention:
  - Delete noncurrent versions when `num_newer_versions > 4` (keeps 5 total)
  - Delete noncurrent versions older than 90 days
- [x] 2.3 Add CORS configuration for SPA (allow GET from any origin)

## 3. Configure Public Access

- [x] 3.1 Add `google_storage_bucket_iam_member` granting
      `roles/storage.objectViewer` to `allUsers` for public read
- [x] 3.2 Add `google_storage_bucket_iam_member` granting
      `roles/storage.objectAdmin` to Cloud Run service account

## 4. Add CI/CD Permissions

- [x] 4.1 Add module variable for CI service account (optional)
- [x] 4.2 Add IAM binding for CI service account to write to public bucket
      (`roles/storage.objectAdmin`) when provided

## 5. Add Module Outputs

- [x] 5.1 Update output for private bucket name (renamed)
- [x] 5.2 Add output for public bucket name
- [x] 5.3 Add output for public bucket URL

## 6. Update email-unsubscribe App Code

- [x] 6.1 Update `api/storage.ts` to use `PRIVATE_BUCKET_NAME` env var

## 7. Migrate Existing Data

- [x] 7.1 After `tofu apply` creates new buckets, migrate data:

```bash
gcloud storage cp -r gs://mklv-infrastructure-email-unsubscribe-storage/* gs://mklv-email-unsubscribe-private/
```

- [x] 7.2 Verify data migrated correctly
- [x] 7.3 Delete old bucket manually (has ~50 trace files)

## 8. Validate

- [x] 8.1 Run `tofu init` in `gcp/apps/email-unsubscribe/`
- [x] 8.2 Run `tofu plan` and verify expected resources:
  - 1 renamed bucket (private)
  - 1 new bucket (public)
  - IAM bindings for both

**Note**: `tofu apply` is a manual step, not included in tasks.
