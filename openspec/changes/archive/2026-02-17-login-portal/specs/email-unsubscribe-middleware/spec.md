# Email Unsubscribe Middleware

## ADDED Requirements

## Requirement: Middleware verifies Supabase JWT locally

The email-unsubscribe auth middleware SHALL verify Supabase JWT session cookies
locally using the JWT secret from Secret Manager.

### Scenario: Valid JWT allows request

- **WHEN** a request includes a valid `session` cookie with correct HS256
  signature and non-expired `exp`
- **THEN** the middleware extracts user info and allows the request to proceed

### Scenario: Invalid JWT redirects to login

- **WHEN** a request includes an invalid or expired JWT
- **THEN** the middleware redirects to the login service with a returnUrl
  parameter

## Requirement: Middleware reads JWT secret from environment

The middleware SHALL read the Supabase JWT secret from the `SUPABASE_JWT_SECRET`
environment variable.

### Scenario: JWT secret available at startup

- **WHEN** the Cloud Run service starts
- **THEN** the `SUPABASE_JWT_SECRET` environment variable contains the secret
  from Secret Manager

## Requirement: Middleware validates audience claim

The middleware SHALL verify that the JWT audience claim is "authenticated".

### Scenario: Valid audience accepted

- **WHEN** a JWT has `aud: "authenticated"`
- **THEN** the middleware accepts the JWT

### Scenario: Invalid audience rejected

- **WHEN** a JWT has a different audience claim
- **THEN** the middleware rejects the JWT and redirects to login

## Requirement: Middleware sets user context

The middleware SHALL extract user information from the Supabase JWT and make it
available to route handlers.

### Scenario: User info available in context

- **WHEN** a valid JWT is verified
- **THEN** the middleware sets `userId` (from `sub`), `email`, and `expiresAt`
  in the request context

### Scenario: User metadata extracted

- **WHEN** a valid JWT contains `user_metadata`
- **THEN** the middleware can access `name` and `avatar_url` from the metadata

## Requirement: Middleware uses configurable login URL

The middleware SHALL use the `LOGIN_URL` environment variable or derive it from
`SESSION_DOMAIN`.

### Scenario: Redirect URL constructed

- **WHEN** a user needs to authenticate
- **THEN** the middleware redirects to
  `https://login.{SESSION_DOMAIN}/login?returnUrl={currentUrl}`

## Requirement: Middleware preserves skip auth for development

The middleware SHALL continue to support `SKIP_AUTH=true` for local development.

### Scenario: Auth skipped in dev mode

- **WHEN** `SKIP_AUTH=true` is set
- **THEN** the middleware sets a mock user context and allows the request
  without JWT verification

## Requirement: Cloud Run service has JWT secret access

The email-unsubscribe Cloud Run service account SHALL have access to the
Supabase JWT secret.

### Scenario: Secret access granted

- **WHEN** the login infrastructure is applied
- **THEN** the email-unsubscribe service account is granted `secretAccessor`
  role on `supabase-mklv-jwt-secret`
