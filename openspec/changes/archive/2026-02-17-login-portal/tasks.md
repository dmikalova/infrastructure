# 1. Repository Setup

- [x] 1.1 Add `login` repository resource to `github/dmikalova/main.tf`
- [x] 1.2 Apply GitHub stack to create repository
- [x] 1.3 Clone repository and initialize Deno project with `deno.jsonc`
- [x] 1.4 Create basic app structure: `src/main.ts`, `src/app.ts`,
      `src/routes.ts`

## 2. Infrastructure Stack

- [x] 2.1 Create `gcp/apps/login/` stack directory with `stack.tm.hcl`
- [x] 2.2 Add Cloud Run service using `cloud-run-app` module
- [x] 2.3 Add domain mappings for login.mklv.tech, login.keyforge.cards
      (cddc39.tech deferred)
- [x] 2.4 Add DNS CNAME records for each domain mapping
- [x] 2.5 Add `app-database` module for login schema with `domain_logins` table
- [x] 2.6 Grant login service access to Supabase secrets (`supabase-mklv-url`,
      `supabase-mklv-publishable-key`, `login-supabase-jwt-key`)
- [x] 2.7 Store database URL in Secret Manager as `login-database-url`
- [x] 2.8 Run `tofu plan` to verify infrastructure configuration
- [x] 2.9 Apply infrastructure stack

## 3. Email-unsubscribe JWT Secret Access

- [x] 3.1 Grant email-unsubscribe service account access to
      `login-supabase-jwt-key`
- [x] 3.2 Add `SUPABASE_JWT_KEY` environment variable to email-unsubscribe Cloud
      Run

## 4. Login Service Core

- [x] 4.1 Add Supabase client initialization with URL and anon key from
      environment
- [x] 4.2 Implement Host header parsing to determine domain family
- [x] 4.3 Create domain allowlist constant (mklv.tech, cddc39.tech,
      keyforge.cards)
- [x] 4.4 Return 400 for unrecognized Host headers

## 5. OAuth Flow

- [x] 5.1 Create `/login` route that renders login page
- [x] 5.2 Implement "Sign in with Google" button using Supabase
      `signInWithOAuth`
- [x] 5.3 Create `/callback` route for OAuth callback handling
- [x] 5.4 Extract Supabase JWT from session after successful auth

## 6. Google One Tap

- [x] 6.1 Add Google Identity Services script to login page
- [x] 6.2 Initialize One Tap with `auto_select: true` and
      `cancel_on_tap_outside: false`
- [x] 6.3 Implement credential callback that calls
      `supabase.auth.signInWithIdToken`
- [x] 6.4 Handle One Tap dismissal with fallback to standard OAuth button

## 7. Session Cookie Management

- [x] 7.1 Create cookie utility to set session cookie with domain scope
- [x] 7.2 Set cookie attributes: HttpOnly, Secure, SameSite=Lax, Path=/,
      Max-Age=604800
- [x] 7.3 Derive cookie domain from Host header (e.g., login.mklv.tech →
      .mklv.tech)

## 8. Redirect Handling

- [x] 8.1 Parse `returnUrl` query parameter on login page
- [x] 8.2 Validate returnUrl against domain family allowlist
- [x] 8.3 Reject javascript: URLs and external domains
- [x] 8.4 Redirect to returnUrl or domain root after successful login

## 9. Domain Login Tracking

- [x] 9.1 Create database client with connection pool
- [x] 9.2 Implement `upsertDomainLogin` function for domain_logins table
- [x] 9.3 Call upsert after successful authentication with user_id and domain
- [x] 9.4 Add database migration SQL for domain_logins table and index

## 10. Email-unsubscribe Middleware Update

- [x] 10.1 Import JWT verification library (`djwt`)
- [x] 10.2 Implement `validateSession` function using HS256 with
      SUPABASE_JWT_SECRET
- [x] 10.3 Verify JWT audience is "authenticated"
- [x] 10.4 Verify JWT issuer matches expected Supabase project URL
- [x] 10.5 Verify JWT expiration with minimal clock skew tolerance
- [x] 10.6 Extract user info (sub, email, expiresAt) and set in request context
- [x] 10.7 Update redirect URL to use
      `https://login.{SESSION_DOMAIN}/login?returnUrl=...`
- [x] 10.8 Preserve SKIP_AUTH=true for local development

## 11. Security Hardening

- [x] 11.1 Ensure JWT secret is never logged or included in error responses
- [x] 11.2 Sanitize all error messages to be generic (no secret or JWT details)
- [x] 11.3 Verify no secrets in client-side JavaScript bundles

## 12. Logout Flow

- [x] 12.1 Create `/logout` route handler
- [x] 12.2 Clear session cookie (set Max-Age=0 with same domain scope)
- [x] 12.3 Call `supabase.auth.signOut()` to invalidate Supabase session
- [x] 12.4 Redirect to domain root or returnUrl after logout

## 13. Already Signed In Detection

- [x] 13.1 Check for valid session cookie on login page load
- [x] 13.2 If valid JWT exists, redirect immediately to returnUrl or domain root
- [x] 13.3 Only show login UI if no valid session exists

## 14. Error Handling

- [x] 14.1 Create error page template with user-friendly messaging
- [x] 14.2 Handle Supabase Auth errors (network, invalid response)
- [x] 14.3 Handle Google OAuth errors (user cancelled, access denied)
- [x] 14.4 Add `/health` endpoint returning 200 OK for Cloud Run probes

## 15. Supabase Configuration (Manual)

- [x] 15.1 Configure Google OAuth provider in Supabase Dashboard
- [x] 15.2 Enable Google One Tap with "Skip nonce check" in Supabase Dashboard
- [x] 15.3 Add redirect URLs for all login domains and localhost
- [x] 15.4 Configure JavaScript origins in Google Cloud Console for each login
      domain

## 16. Unit Tests

- [x] 16.1 Create test setup with `@std/assert`
- [x] 16.2 Test `SUPPORTED_DOMAINS` includes all expected domains
- [x] 16.3 Test `getRootDomain` extracts TLD correctly
- [x] 16.4 Test `getCookieDomain` adds leading dot
- [x] 16.5 Test `parseDomainFromHost` handles subdomains and unsupported hosts
- [x] 16.6 Test `isValidReturnUrl` accepts valid URLs, rejects dangerous ones
- [x] 16.7 Test `decodeJwtPayload` extracts claims and handles malformed tokens
- [x] 16.8 Test `escapeHtml` and `jsValue` utilities
- [x] 16.9 Test health endpoint returns 200

## 17. End-to-End Testing (Manual)

- [ ] 17.1 Test Host header routing for all three domains
- [ ] 17.2 Test OAuth flow end-to-end
- [ ] 17.3 Test Google One Tap automatic sign-in for returning users
- [ ] 17.4 Test cookie scoping (verify cookies isolated per domain family)
- [ ] 17.5 Test returnUrl validation (valid, external, javascript: URLs)
- [ ] 17.6 Test email-unsubscribe middleware with new JWT verification
- [ ] 17.7 Test logout clears session and redirects correctly
- [ ] 17.8 Test already signed in redirect behavior
- [ ] 17.9 Test error handling for OAuth failures
