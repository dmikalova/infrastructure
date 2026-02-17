## Architecture

### Multi-Domain Single Service with Supabase Auth

One Cloud Run service handles authentication for multiple domain families, using Supabase Auth for OAuth and session management:

```
                    ┌─────────────────────────────────────┐
                    │         login (Cloud Run)           │
                    │         + Supabase Auth             │
                    │                                     │
   login.mklv.tech ─┼──▶  Host: login.mklv.tech          │
                    │     → Supabase signInWithOAuth     │
                    │     → Google One Tap (automatic)   │
                    │     → Cookie: Domain=.mklv.tech     │
                    │                                     │
login.cddc39.tech ──┼──▶  Host: login.cddc39.tech        │
                    │     → Supabase Auth for cddc39     │
                    │     → Cookie: Domain=.cddc39.tech   │
                    │                                     │
login.keyforge.cards┼──▶  Host: login.keyforge.cards     │
                    │     → Supabase Auth for keyforge   │
                    │     → Cookie: Domain=.keyforge.cards│
                    └─────────────────────────────────────┘
```

The app inspects the `Host` header to determine which domain family the request is for, then issues domain-scoped cookies. Browser security enforces cookie isolation.

**Supabase Auth provides:**

- Google OAuth integration with One Tap for automatic sign-in
- User management via `auth.users` table
- JWT issuance and validation
- Session refresh handling

### Authentication Flow

```
┌──────────┐     ┌──────────┐     ┌─────────────────────────┐     ┌──────────┐
│  User    │     │  App     │     │  Login Portal           │     │ Supabase │
│ Browser  │     │ (e.g.    │     │  (login.mklv.tech)      │     │   Auth   │
│          │     │  email-  │     │                         │     │          │
│          │     │  unsub)  │     │                         │     │          │
└────┬─────┘     └────┬─────┘     └────────────┬────────────┘     └────┬─────┘
     │                │                        │                       │
     │  1. Visit app  │                        │                       │
     │───────────────▶│                        │                       │
     │                │                        │                       │
     │  2. No session │                        │                       │
     │◀───────────────│                        │                       │
     │  Redirect to login.mklv.tech           │                       │
     │                │                        │                       │
     │  3. Load login page                     │                       │
     │────────────────────────────────────────▶│                       │
     │                │                        │                       │
     │  4. Show Google One Tap / Sign In       │                       │
     │◀───────────────────────────────────────│                       │
     │                │                        │                       │
     │  5. User clicks / auto-signs in         │                       │
     │────────────────────────────────────────▶│                       │
     │                │                        │                       │
     │  6. signInWithOAuth (Google)            │                       │
     │                │                        │──────────────────────▶│
     │                │                        │                       │
     │  7. OAuth redirect dance                │                       │
     │◀───────────────────────────────────────────────────────────────▶│
     │                │                        │                       │
     │  8. Callback with Supabase session      │                       │
     │────────────────────────────────────────▶│◀──────────────────────│
     │                │                        │                       │
     │  9. Set domain-scoped cookie            │                       │
     │    session=<supabase-jwt>               │                       │
     │    Domain=.mklv.tech                    │                       │
     │    Redirect to returnUrl                │                       │
     │◀───────────────────────────────────────│                       │
     │                │                        │                       │
     │ 10. Visit app  │  (JWT cookie sent)    │                       │
     │───────────────▶│                        │                       │
     │                │                        │                       │
     │ 11. Verify JWT │  (using Supabase secret)                      │
     │    - signature ✓                        │                       │
     │    - not expired ✓                      │                       │
     │                │                        │                       │
     │ 12. Serve page │                        │                       │
     │◀───────────────│                        │                       │
```

### Google One Tap Flow

Google One Tap provides automatic sign-in for returning users:

1. Login page loads Google Identity Services script
2. If user has a Google session, One Tap automatically signs in (no click required)
3. Credential sent to Supabase via `signInWithIdToken`
4. Supabase creates/updates user, returns JWT
5. User redirected to original page

For first-time users or when One Tap isn't available, falls back to standard OAuth redirect flow.

**Configuration:**

```javascript
google.accounts.id.initialize({
  client_id: GOOGLE_CLIENT_ID,
  callback: handleCredentialResponse,
  auto_select: true, // Enable automatic sign-in without user interaction
  cancel_on_tap_outside: false, // Keep prompt visible even if user clicks elsewhere
});

google.accounts.id.prompt(); // Show One Tap UI
```

The `auto_select: true` setting enables FedCM (Federated Credential Management) automatic sign-in when:

- User has exactly one Google session in the browser
- User hasn't opted out of auto sign-in
- User previously consented to sign in with this app

## JWT Design

### Supabase JWT Structure

Supabase issues JWTs with this structure:

```json
{
  "aud": "authenticated",
  "exp": 1739715600,
  "iat": 1739712000,
  "iss": "https://<project-ref>.supabase.co/auth/v1",
  "sub": "user-uuid",
  "email": "david@example.com",
  "app_metadata": {
    "provider": "google",
    "providers": ["google"]
  },
  "user_metadata": {
    "full_name": "David Mikalova",
    "avatar_url": "https://..."
  },
  "role": "authenticated"
}
```

### Custom Claims for Domain

The login portal adds a domain claim via Supabase's `app_metadata` or by wrapping the Supabase JWT:

**Option 1: Custom wrapper JWT** (simpler verification)

```json
{
  "sub": "user-uuid",
  "email": "david@example.com",
  "name": "David Mikalova",
  "domain": "mklv.tech",
  "supabase_jwt": "<original-supabase-jwt>",
  "iat": 1739712000,
  "exp": 1739715600
}
```

**Option 2: Pass Supabase JWT directly, verify domain at app level**

Apps check the request origin matches their expected domain, relying on cookie scoping for isolation.

**Decision: Option 2** — Keep it simple. Supabase JWT passed directly, cookie scoping provides domain isolation. Apps don't need to verify a domain claim since the cookie is only sent to the correct domain family.

### Verification

Apps verify Supabase JWTs locally using the JWT secret:

1. **Signature** — Using Supabase JWT secret (HS256)
2. **Audience** — Must be "authenticated"
3. **Expiration** — `exp` not passed

### Key Management

- **JWT Secret**: Supabase project's JWT secret, stored in Secret Manager
- **Algorithm**: HS256 (HMAC with SHA-256) — Supabase's default
- **Rotation**: Managed by Supabase; update Secret Manager if rotated

## Cookie Configuration

```
session=<jwt>
Domain=.mklv.tech      (scoped to domain family, set dynamically per request)
Path=/
HttpOnly               (JS can't read it)
Secure                 (HTTPS only)
SameSite=Lax           (sent on navigation, blocked for cross-site POST)
Max-Age=604800         (7 days)
```

**Why SameSite=Lax**: Allows top-level navigation redirects (login → app) while blocking cross-site POST for CSRF protection. `Strict` would break the redirect flow.

## Database Schema

Supabase Auth manages users in `auth.users`. For per-domain audit tracking, the login service maintains a separate table in its app schema:

```sql
-- Per-domain login records (audit trail + multi-tenant)
-- References Supabase auth.users via user_id
CREATE TABLE domain_logins (
  user_id UUID NOT NULL,  -- References auth.users(id)
  domain TEXT NOT NULL,
  first_login_at TIMESTAMPTZ DEFAULT NOW(),
  last_login_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, domain)
);

-- Index for domain-scoped queries
CREATE INDEX idx_domain_logins_domain ON domain_logins(domain);
```

When a user logs in via Supabase Auth:

1. Supabase creates/updates `auth.users` record
2. Login service upserts `domain_logins` record for the specific domain
3. Updates `last_login_at`

This allows:

- Supabase manages user identity (email, metadata, providers)
- Per-domain audit trail (when did this user first/last use this domain?)
- Future: per-domain permissions, preferences, or access control

## Supabase Auth Configuration

### Google OAuth Provider

Configure in Supabase Dashboard → Authentication → Providers → Google:

- **Client ID**: From Google Cloud Console
- **Client Secret**: From Google Cloud Console
- **Authorized redirect URI**: `https://<project-ref>.supabase.co/auth/v1/callback`

### Google One Tap

Enable in Supabase Dashboard → Authentication → Providers → Google:

- **Skip nonce check**: Enable for One Tap (required)
- **Client ID**: Same as OAuth client

One Tap requires additional setup in Google Cloud Console:

- Add authorized JavaScript origins for each login domain
- Configure consent screen for production use

### Site URL and Redirect URLs

Configure in Supabase Dashboard → Authentication → URL Configuration:

```
Site URL: https://login.mklv.tech

Redirect URLs:
- https://login.mklv.tech/**
- https://login.cddc39.tech/**
- https://login.keyforge.cards/**
- http://localhost:8000/**
```

## Infrastructure Components

### Cloud Run Service

- **Name**: `login`
- **Image**: From Artifact Registry, deployed via CI/CD
- **Domain mappings**: login.mklv.tech, login.cddc39.tech, login.keyforge.cards
- **Public access**: Yes (unauthenticated invoke allowed)

### Secrets in Secret Manager

| Secret                     | Purpose                    | Access               |
| -------------------------- | -------------------------- | -------------------- |
| `supabase-mklv-url`        | Supabase project URL       | login service + apps |
| `supabase-mklv-anon-key`   | Supabase anon key (public) | login service + apps |
| `supabase-mklv-jwt-secret` | JWT verification secret    | login service + apps |
| `login-database-url`       | Supabase connection string | login service        |

**Note**: The Supabase JWT secret is already stored from the Supabase project setup. No custom OAuth credentials needed — Supabase handles the Google OAuth integration.

### Supabase Database

Uses existing `app-database` module pattern for the `domain_logins` table:

- Schema: `login`
- Role: `login-role`
- Connection via pooler (IPv4-compatible)

## App Integration

### Middleware Changes (email-unsubscribe)

Replace API call stub with Supabase JWT verification:

```typescript
import { verify } from "djwt"; // Deno JWT library
import { decode } from "base64"; // For decoding JWT secret

const SUPABASE_JWT_SECRET = Deno.env.get("SUPABASE_JWT_SECRET");

async function validateSession(token: string): Promise<SessionData | null> {
  try {
    // Supabase uses HS256 with the JWT secret
    const key = await crypto.subtle.importKey(
      "raw",
      new TextEncoder().encode(SUPABASE_JWT_SECRET),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["verify"],
    );

    const payload = await verify(token, key, { algorithms: ["HS256"] });

    // Verify audience is "authenticated"
    if (payload.aud !== "authenticated") {
      return null;
    }

    return {
      userId: payload.sub,
      email: payload.email,
      expiresAt: new Date(payload.exp * 1000),
    };
  } catch {
    return null;
  }
}
```

### Environment Variables for Apps

| Variable              | Value                     | Source               |
| --------------------- | ------------------------- | -------------------- |
| `SUPABASE_JWT_SECRET` | Supabase JWT secret       | Secret Manager       |
| `SESSION_DOMAIN`      | `mklv.tech`               | Hardcoded or config  |
| `LOGIN_URL`           | `https://login.mklv.tech` | Hardcoded or derived |

## Local Development

**Out of scope for this change**, but the design anticipates:

- `SKIP_AUTH=true` environment variable already exists in email-unsubscribe
- Login service can run locally on `localhost:8000` with Supabase local dev or cloud project
- Apps can mock session by setting a fake JWT cookie in dev mode

Follow-up proposal should formalize the local dev auth story.

## Service Endpoints

| Endpoint    | Method | Purpose                                              |
| ----------- | ------ | ---------------------------------------------------- |
| `/login`    | GET    | Show login page or redirect if already signed in     |
| `/callback` | GET    | Handle OAuth callback from Supabase                  |
| `/logout`   | GET    | Clear session cookie, sign out of Supabase, redirect |
| `/health`   | GET    | Health check for Cloud Run probes (returns 200 OK)   |

### Logout Flow

```
┌──────────┐                    ┌─────────────────────────┐     ┌──────────┐
│  User    │                    │  Login Portal           │     │ Supabase │
│ Browser  │                    │  (login.mklv.tech)      │     │   Auth   │
└────┬─────┘                    └────────────┬────────────┘     └────┬─────┘
     │                                       │                       │
     │  1. Visit /logout                     │                       │
     │──────────────────────────────────────▶│                       │
     │                                       │                       │
     │                                       │  2. supabase.auth.signOut()
     │                                       │──────────────────────▶│
     │                                       │                       │
     │  3. Clear cookie (Max-Age=0)          │                       │
     │     Domain=.mklv.tech                 │                       │
     │     Redirect to domain root           │                       │
     │◀──────────────────────────────────────│                       │
```

### Already Signed In Detection

When a user visits `/login` with a valid session cookie:

1. Login page checks for existing `session` cookie
2. Verifies JWT signature, audience, and expiration
3. If valid, redirects immediately to `returnUrl` or domain root
4. If invalid/expired, clears cookie and shows login UI

This avoids showing the login page to already-authenticated users.

### Error Handling

Authentication errors display user-friendly messages without revealing technical details:

| Error Type             | User Message                                                |
| ---------------------- | ----------------------------------------------------------- |
| OAuth cancelled        | "Sign in was cancelled. Please try again."                  |
| OAuth access denied    | "Unable to sign in. Please check your Google account."      |
| Supabase network error | "Unable to connect. Please check your internet connection." |
| Supabase auth error    | "Sign in failed. Please try again."                         |
| Invalid returnUrl      | (Silent) Redirect to domain root instead                    |

All errors allow retry via a "Try Again" button that returns to the login UI.

## Security Design

Security is paramount for authentication. This section documents how the design addresses each security tenet.

### No Secrets Exposed

| Risk                      | Mitigation                                                |
| ------------------------- | --------------------------------------------------------- |
| JWT secret in client code | Server-side verification only; secret never in browser JS |
| Secrets in logs           | No logging of tokens, cookies, or credentials             |
| Secrets in errors         | Generic error messages; no debugging info in responses    |
| Secrets in source control | All secrets in SOPS or Secret Manager, never committed    |

### Conventional Flows

The design uses **Supabase Auth's standard OAuth implementation**:

- PKCE (Proof Key for Code Exchange) enabled by default
- State parameter validated automatically
- Google One Tap follows Google Identity Services best practices
- No custom cryptographic code — Supabase handles JWT signing

### Defense in Depth

Multiple layers protect against attacks:

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Cookie Security                                    │
│   HttpOnly     → XSS can't read cookie                     │
│   Secure       → HTTPS only                                 │
│   SameSite=Lax → Blocks cross-site POST (CSRF)             │
│   Domain scope → Browser isolates per domain family         │
├─────────────────────────────────────────────────────────────┤
│ Layer 2: JWT Verification                                   │
│   Signature    → Validates token authenticity               │
│   Audience     → Must be "authenticated"                    │
│   Expiration   → Rejects expired tokens                     │
├─────────────────────────────────────────────────────────────┤
│ Layer 3: Input Validation                                   │
│   returnUrl    → Validated against domain allowlist         │
│   Host header  → Must match known domains                   │
├─────────────────────────────────────────────────────────────┤
│ Layer 4: Infrastructure                                     │
│   HTTPS        → Cloud Run enforces TLS                     │
│   Secrets      → Secret Manager with IAM controls           │
└─────────────────────────────────────────────────────────────┘
```

### Least Privilege

| Secret                     | Access                                      |
| -------------------------- | ------------------------------------------- |
| `supabase-mklv-jwt-secret` | Login service, apps that verify JWTs        |
| `login-database-url`       | Login service only                          |
| `supabase-mklv-url`        | Login service, apps needing Supabase client |
| App database URLs          | Each app's service account only             |

### Minimal Data

- **User identity**: Stored in Supabase `auth.users` (managed by Supabase)
- **Login tracking**: Only `user_id`, `domain`, timestamps — no PII duplication
- **JWTs**: Standard claims only; no secrets in payload

### Audit Trail

- Supabase maintains `auth.audit_log_entries` for all auth events
- `domain_logins` table tracks per-domain login history
- Cloud Run logs capture request metadata (without sensitive data)

### Threat Model

| Threat                      | Protection                            |
| --------------------------- | ------------------------------------- |
| **XSS steals session**      | HttpOnly cookie; JS cannot access     |
| **CSRF initiates actions**  | SameSite=Lax blocks cross-site POST   |
| **Token theft via network** | Secure flag; HTTPS enforced           |
| **Open redirect**           | returnUrl validated against allowlist |
| **Token forgery**           | HMAC signature verification           |
| **Replay attack**           | JWT expiration + timestamp validation |
| **Session fixation**        | New token issued on each login        |
| **User enumeration**        | Generic error messages                |

## Testing Strategy

### Test Categories

```
┌─────────────────────────────────────────────────────────────┐
│ Unit Tests (run by default, no external deps)               │
│   tests/unit/domain_test.ts     Domain parsing, validation  │
│   tests/unit/handlers_test.ts   returnUrl validation        │
│   tests/unit/cookie_test.ts     Cookie attribute generation │
│   tests/unit/templates_test.ts  Template rendering          │
├─────────────────────────────────────────────────────────────┤
│ Integration Tests (requires database)                       │
│   tests/integration/db_test.ts  Domain login upsert         │
├─────────────────────────────────────────────────────────────┤
│ E2E Tests (manual or Playwright)                            │
│   OAuth flow end-to-end                                     │
│   Google One Tap (requires real browser)                    │
│   Cookie scoping across domains                             │
└─────────────────────────────────────────────────────────────┘
```

### Unit Test Coverage

| Module       | Tests                                                                    |
| ------------ | ------------------------------------------------------------------------ |
| domain.ts    | - `SUPPORTED_DOMAINS` includes all expected domains                      |
|              | - `getRootDomain` extracts TLD correctly (mklv.tech, keyforge.cards)     |
|              | - `getCookieDomain` adds leading dot                                     |
|              | - `parseDomainFromHost` handles subdomains, returns null for unsupported |
| handlers.ts  | - `isValidReturnUrl` accepts valid relative URLs                         |
|              | - `isValidReturnUrl` accepts same-domain absolute URLs                   |
|              | - `isValidReturnUrl` rejects javascript:, data: URLs                     |
|              | - `isValidReturnUrl` rejects external domain URLs                        |
|              | - `decodeJwtPayload` extracts sub from valid JWT                         |
|              | - `decodeJwtPayload` returns null for malformed tokens                   |
| cookie.ts    | - Cookie string generation with correct attributes                       |
|              | - Domain scoping matches expected pattern                                |
| templates.ts | - Placeholder substitution works correctly                               |
|              | - `escapeHtml` escapes dangerous characters                              |
|              | - `jsValue` handles null and strings correctly                           |

### Test Commands

```bash
# Run unit tests (default, no deps required)
deno task test

# Run unit tests with coverage
deno task test:coverage

# Run all tests (unit + integration)
deno task test:all
```

### CI/CD Integration

Unit tests run on every PR and push:

```yaml
- name: Run tests
  run: deno task test
```

Integration tests run in deployment pipeline after database is available.
