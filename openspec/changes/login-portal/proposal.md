## Why

Apps like email-unsubscribe already have middleware that redirects unauthenticated users to a login page, but this login service doesn't exist yet. Without a centralized login portal, each app would need to implement its own authentication — duplicating OAuth flows, session management, and cookie handling. A shared login service at `login.mklv.tech` provides single sign-on for all apps under the `mklv.tech` domain using a shared session cookie.

## What Changes

- Create a new `mklv-login` repository with a Deno web app that handles Google OAuth login and session management
- The login portal issues a session cookie scoped to `.mklv.tech` so all subdomains can read it
- Provides a session validation API endpoint that app middleware calls to verify session tokens
- Internal apps (e.g., email-unsubscribe) auto-redirect to login; future public apps can show a landing page first
- Deploy as a Cloud Run service at `login.mklv.tech` (depends on domain-setup change for DNS)
- Add infrastructure stack `gcp/apps/mklv-login` with Cloud Run, Supabase database for sessions, and secrets

## Capabilities

### New Capabilities

- `login-service`: Deno web app handling Google OAuth, session creation, cookie issuance, and session validation API
- `session-management`: Session storage in Supabase, cookie scoped to `.mklv.tech`, expiration/refresh, and validation endpoint for app middleware
- `login-infra`: Infrastructure stack for deploying the login service (Cloud Run, app-database, secrets, CI/CD)

### Modified Capabilities

<!-- No existing capabilities are being modified — email-unsubscribe already has the middleware expecting this service -->

## Impact

- **New repo**: `dmikalova/mklv-login` — Deno app with Google OAuth, session store, login UI
- **Infrastructure**: New stack `gcp/apps/mklv-login` (Cloud Run + Supabase app-database + secrets)
- **GitHub**: New repo resource in `github/dmikalova/main.tf`, CI/CD workflow reference to `deno-cloudrun.yaml`
- **GCP**: OAuth consent screen update to include `login.mklv.tech` redirect URI
- **Secrets**: Google OAuth client ID/secret for the login app in SOPS
- **DNS**: Requires `domain-setup` change to be completed first for `login.mklv.tech` subdomain
- **email-unsubscribe**: Middleware needs `SESSION_DOMAIN` updated from `cddc39.tech` to `mklv.tech`
