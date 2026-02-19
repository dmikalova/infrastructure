# Login Service

## ADDED Requirements

## Requirement: Service handles multiple domains via Host header

The login service SHALL determine the target domain by inspecting the HTTP
`Host` header on incoming requests, supporting login.mklv.tech,
login.cddc39.tech, and login.keyforge.cards from a single deployment.

### Scenario: Request to login.mklv.tech

- **WHEN** a request arrives with `Host: login.mklv.tech`
- **THEN** the service processes authentication for the `mklv.tech` domain
  family

### Scenario: Request to login.keyforge.cards

- **WHEN** a request arrives with `Host: login.keyforge.cards`
- **THEN** the service processes authentication for the `keyforge.cards` domain
  family

### Scenario: Unknown host rejected

- **WHEN** a request arrives with an unrecognized Host header
- **THEN** the service returns a 400 Bad Request error

## Requirement: Service uses Supabase Auth for Google OAuth

The login service SHALL use Supabase Auth's `signInWithOAuth` for Google
authentication instead of implementing OAuth directly.

### Scenario: OAuth initiated via Supabase

- **WHEN** a user clicks "Sign in with Google"
- **THEN** the service calls
  `supabase.auth.signInWithOAuth({ provider: 'google' })` with appropriate
  redirect URL

### Scenario: OAuth callback handled by Supabase

- **WHEN** Google redirects back after authentication
- **THEN** Supabase handles the callback and returns a session with JWT

## Requirement: Service supports Google One Tap for automatic sign-in

The login service SHALL integrate Google One Tap with automatic sign-in enabled
(`auto_select: true`) for seamless returning user authentication.

### Scenario: Automatic sign-in for returning user

- **WHEN** a user visits the login page with exactly one active Google session
- **AND** the user has previously signed in to this app
- **THEN** the service automatically signs them in without requiring any click

### Scenario: One Tap prompt for new user

- **WHEN** a user visits the login page with an active Google session
- **AND** the user has not previously signed in to this app
- **THEN** the Google One Tap prompt is displayed for user confirmation

### Scenario: One Tap credential processed via Supabase

- **WHEN** One Tap provides a credential (automatic or user-confirmed)
- **THEN** the service calls `supabase.auth.signInWithIdToken` with the Google
  credential

### Scenario: Fallback to standard OAuth

- **WHEN** One Tap is not available or user dismisses it
- **THEN** the user can click "Sign in with Google" for standard OAuth flow

## Requirement: Service issues domain-scoped session cookie

The login service SHALL set the Supabase JWT as an HttpOnly cookie scoped to the
target domain.

### Scenario: Cookie scoped to domain family

- **WHEN** authentication completes for `mklv.tech`
- **THEN** the session cookie is set with `Domain=.mklv.tech`

### Scenario: Cookie security attributes

- **WHEN** a session cookie is set
- **THEN** it includes `HttpOnly`, `Secure`, `SameSite=Lax`, and `Path=/`

## Requirement: Service redirects to returnUrl after login

The login service SHALL redirect users back to their original destination after
successful authentication.

### Scenario: Return to original app

- **WHEN** the login page was accessed with
  `?returnUrl=https://email-unsubscribe.mklv.tech/dashboard`
- **THEN** after successful login, the user is redirected to that URL

### Scenario: Return to domain root without returnUrl

- **WHEN** the login page was accessed without a returnUrl parameter
- **THEN** after successful login, the user is redirected to the domain root
  (e.g., `https://mklv.tech`)

### Scenario: returnUrl validated against domain

- **WHEN** returnUrl points to a different domain family
- **THEN** the service ignores it and redirects to the domain root

## Requirement: Service tracks per-domain login records

The login service SHALL maintain per-domain login records for audit purposes.

### Scenario: Domain login record created

- **WHEN** a user logs in to a domain for the first time
- **THEN** a `domain_logins` record is created with the user's Supabase ID and
  domain

### Scenario: Domain login record updated

- **WHEN** a user logs in to a domain they've used before
- **THEN** the `domain_logins` record's `last_login_at` is updated

## Requirement: Service uses Supabase for user management

The login service SHALL rely on Supabase Auth's `auth.users` table for user
identity management.

### Scenario: User created by Supabase

- **WHEN** a new user completes Google OAuth
- **THEN** Supabase creates the user in `auth.users` with their Google identity

### Scenario: User metadata available

- **WHEN** a user is authenticated
- **THEN** their email, name, and avatar are available from Supabase's
  `user_metadata`

### Scenario: JWT expiration set to 7 days

- **WHEN** the service creates a JWT
- **THEN** the `exp` claim is set to 7 days from the current time

## Requirement: Service provides logout endpoint

The login service SHALL provide a `/logout` endpoint that clears the session and
invalidates the Supabase session.

### Scenario: Logout clears session cookie

- **WHEN** a user visits `/logout`
- **THEN** the session cookie is cleared (Max-Age=0) with the same domain scope

### Scenario: Logout invalidates Supabase session

- **WHEN** a user logs out
- **THEN** the service calls `supabase.auth.signOut()` to invalidate the session

### Scenario: Logout redirects to domain root

- **WHEN** logout completes
- **THEN** the user is redirected to the domain root or returnUrl if provided

## Requirement: Service detects already signed in users

The login service SHALL detect users who already have a valid session and
redirect them without showing the login UI.

### Scenario: Valid session redirects immediately

- **WHEN** a user visits the login page with a valid session cookie
- **THEN** the service verifies the JWT and redirects to returnUrl or domain
  root

### Scenario: Invalid session shows login UI

- **WHEN** a user visits the login page without a valid session
- **THEN** the login UI with Google sign-in options is displayed

## Requirement: Service handles authentication errors gracefully

The login service SHALL display user-friendly error messages when authentication
fails.

### Scenario: OAuth error displayed to user

- **WHEN** Google OAuth fails (cancelled, access denied, network error)
- **THEN** the service displays a friendly error message without revealing
  technical details

### Scenario: Supabase error handled

- **WHEN** Supabase returns an error during authentication
- **THEN** the service displays a generic error and allows retry

## Requirement: Service provides health check endpoint

The login service SHALL provide a `/health` endpoint for Cloud Run health
probes.

### Scenario: Health check returns OK

- **WHEN** a request is made to `/health`
- **THEN** the service returns HTTP 200 OK
