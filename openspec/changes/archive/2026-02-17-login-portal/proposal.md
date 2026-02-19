# Why

Apps like email-unsubscribe already have middleware that redirects
unauthenticated users to a login page, but this login service doesn't exist yet.
Without a centralized login portal, each app would need to implement its own
authentication — duplicating OAuth flows, session management, and cookie
handling. A shared login service provides single sign-on for all apps across
multiple domain families (mklv.tech, cddc39.tech, keyforge.cards) using
domain-scoped session cookies.

## What Changes

- Create a new `login` repository with a Deno web app that uses Supabase Auth
  for Google OAuth
- Supports Google One Tap for automatic sign-in of returning users
- Single Cloud Run service handles multiple domains (login.mklv.tech,
  login.cddc39.tech, login.keyforge.cards) via domain mappings
- Issues Supabase JWT session cookies scoped per-domain (browser security
  enforces isolation)
- Apps verify Supabase JWTs locally using the JWT secret — no API call per
  request
- Per-domain login tracking in Supabase for audit purposes
- Logout endpoint clears session cookie and invalidates Supabase session
- Already signed in detection redirects users with valid sessions immediately
- User-friendly error handling for OAuth and authentication failures
- Deploy as Cloud Run service with multiple domain mappings
- Add infrastructure stack `gcp/apps/login` with Cloud Run, Supabase database
  for login tracking

## Capabilities

### New Capabilities

- `login-service`: Deno web app using Supabase Auth for Google OAuth with One
  Tap support, domain-scoped cookie issuance
- `jwt-auth`: Supabase JWT-based session tokens verified locally by apps using
  shared JWT secret
- `login-infra`: Infrastructure stack for deploying the login service (Cloud Run
  with multiple domain mappings, Supabase app-database for login tracking,
  CI/CD)
- `auth-security`: Security requirements for the authentication system — secrets
  handling, cookie security, input validation, audit trails

### Modified Capabilities

- `email-unsubscribe-middleware`: Update existing auth middleware to verify
  Supabase JWTs locally instead of API call stub

## Security Tenets

These principles guide all authentication design decisions:

1. **No secrets exposed**: JWT secrets, tokens, and credentials never appear in
   client code, logs, or error messages
2. **Conventional flows**: Use Supabase Auth's standard PKCE OAuth flow — no
   custom crypto or non-standard patterns
3. **Defense in depth**: Cookie attributes (HttpOnly, Secure, SameSite), URL
   validation, JWT verification all work together
4. **Least privilege**: Services only access the secrets they need; database
   credentials scoped per-service
5. **Minimal data**: Only store what's necessary; rely on Supabase's
   `auth.users` for identity, not duplicated PII
6. **Audit trail**: Login events tracked for accountability; Supabase maintains
   its own auth audit log

Any change to authentication code must be evaluated against these tenets.

## Impact

- **New repo**: `dmikalova/login` — Deno app with Supabase Auth, Google One Tap,
  login UI
- **Infrastructure**: New stack `gcp/apps/login` (Cloud Run + multiple domain
  mappings + Supabase app-database)
- **GitHub**: New repo resource in `github/dmikalova/main.tf`, CI/CD workflow
  reference to `deno-cloudrun.yaml`
- **Supabase**: Configure Google OAuth provider and One Tap in Supabase
  Dashboard
- **Secrets**: Apps gain access to existing `supabase-mklv-jwt-secret` for JWT
  verification
- **DNS**: Domain mappings for login.mklv.tech, login.cddc39.tech,
  login.keyforge.cards (domain-setup already complete)
- **email-unsubscribe**: Update middleware to verify Supabase JWTs, update
  `SESSION_DOMAIN` to `mklv.tech`

## Out of Scope

- **Local dev auth story**: Apps need a way to run locally without the login
  portal. Noted for follow-up proposal — this proposal should anticipate it
  (e.g., dev mode flag) but not implement.
- **App directory/launcher**: Login redirects to returnUrl or domain root (e.g.,
  mklv.tech), not to a multi-app dashboard.
- **Refresh token flow**: Supabase handles session management; can configure
  refresh behavior later if needed.
