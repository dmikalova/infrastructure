# Todos Infra: Review

## Summary

Straightforward infrastructure change following established patterns. The
cloud-run-app module handles most complexity. Main consideration is ensuring
the Supabase publishable key secret is properly configured for Realtime.

## Security

- [x] **Secrets via Secret Manager**: All sensitive values stored in Secret
      Manager, not hardcoded. **Address**: Already handled by module.

- [x] **Supabase publishable key exposure**: Publishable key is designed to be
      public, with RLS policies controlling access. **Address**: Acceptable for
      single-user app.

## Patterns

- [x] **Follows email-unsubscribe pattern**: Stack structure matches existing
      apps. **Address**: Already aligned.

- [x] **Uses standard modules**: cloud-run-app and app-database modules handle
      all infrastructure. **Address**: Already aligned.

## Alternatives

No alternatives identified - using established modules is correct choice.

## Simplifications

- [x] **No sidecars or scheduled jobs**: Unlike email-unsubscribe, todos doesn't
      need browser automation or scheduled tasks. **Address**: Simpler configuration.

## Missing Considerations

- [x] **Supabase publishable key secret**: Need to ensure the publishable key is
      available in secrets/supabase.sops.json. **Address**: Verified exists as
      SUPABASE_PUBLISHABLE_KEY.

## Valuable Additions

None - keeping scope minimal for initial deployment.

## Action Items

1. ~~Verify SUPABASE_PUBLISHABLE_KEY exists in supabase.sops.json~~ ✓ Verified

## Deferred Items

None.

## Updates Required

None - proposal and design are sufficient.
