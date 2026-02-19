# Auth Security

## ADDED Requirements

## Requirement: JWT secret never exposed to client

The Supabase JWT secret SHALL never be exposed to client-side code, logs, or
error messages.

### Scenario: Server-side verification only

- **WHEN** JWT verification is performed
- **THEN** it occurs exclusively on the server, never in browser JavaScript

### Scenario: Secret not in client bundles

- **WHEN** the login service frontend is built
- **THEN** the JWT secret is not included in any client-side JavaScript bundle

### Scenario: Secret not in error responses

- **WHEN** JWT verification fails
- **THEN** error responses do not reveal the JWT secret or debugging information
  about the secret

## Requirement: No secrets or tokens in logs

The login service and apps SHALL NOT log secrets, tokens, or sensitive user
data.

### Scenario: JWT not logged

- **WHEN** a request is processed
- **THEN** the JWT cookie value is not written to application logs

### Scenario: User credentials not logged

- **WHEN** authentication occurs
- **THEN** no passwords, tokens, or OAuth codes are written to logs

### Scenario: Error logs sanitized

- **WHEN** an error occurs during authentication
- **THEN** stack traces and error details do not include sensitive values

## Requirement: Cookie attributes prevent common attacks

Session cookies SHALL include security attributes that prevent XSS and CSRF
attacks.

### Scenario: HttpOnly prevents XSS access

- **WHEN** a session cookie is set
- **THEN** the `HttpOnly` flag is set, preventing JavaScript from reading the
  cookie

### Scenario: Secure flag enforces HTTPS

- **WHEN** a session cookie is set in production
- **THEN** the `Secure` flag is set, ensuring the cookie is only sent over HTTPS

### Scenario: SameSite prevents CSRF

- **WHEN** a session cookie is set
- **THEN** `SameSite=Lax` is set, blocking the cookie on cross-site POST
  requests while allowing navigation

## Requirement: Redirect URLs validated against allowlist

The login service SHALL validate returnUrl parameters against an allowlist of
trusted domains.

### Scenario: Valid returnUrl accepted

- **WHEN** returnUrl is a subdomain of the current domain family (e.g.,
  `*.mklv.tech` for login.mklv.tech)
- **THEN** the redirect is allowed after authentication

### Scenario: External domain rejected

- **WHEN** returnUrl points to an external domain
- **THEN** the service ignores it and redirects to the domain root instead

### Scenario: JavaScript URLs rejected

- **WHEN** returnUrl contains `javascript:` or other dangerous schemes
- **THEN** the service rejects the URL and redirects to the domain root

## Requirement: OAuth follows PKCE standard

The Supabase Auth integration SHALL use PKCE (Proof Key for Code Exchange) for
OAuth flows.

### Scenario: PKCE enabled by default

- **WHEN** OAuth is initiated via Supabase
- **THEN** Supabase uses PKCE automatically to prevent authorization code
  interception

### Scenario: State parameter validated

- **WHEN** OAuth callback is received
- **THEN** Supabase validates the state parameter to prevent CSRF attacks

## Requirement: Minimal user data stored

The login service SHALL store only the minimum user data necessary for
authentication and audit.

### Scenario: Domain login records contain only IDs and timestamps

- **WHEN** a user logs in
- **THEN** only `user_id`, `domain`, `first_login_at`, and `last_login_at` are
  stored in `domain_logins`

### Scenario: PII stored only in Supabase auth.users

- **WHEN** user email and name are needed
- **THEN** they are retrieved from Supabase `auth.users`, not duplicated in app
  tables

## Requirement: Secrets follow principle of least privilege

Secret Manager access SHALL be granted only to services that require each
specific secret.

### Scenario: JWT secret limited to apps requiring verification

- **WHEN** `supabase-mklv-jwt-secret` access is granted
- **THEN** only the login service and apps that verify JWTs have access

### Scenario: Database credentials isolated per service

- **WHEN** database connection strings are stored
- **THEN** each service has its own credentials with access only to its schema

## Requirement: JWT expiration enforced

Apps SHALL reject expired JWTs without exception.

### Scenario: Clock skew tolerance minimal

- **WHEN** checking JWT expiration
- **THEN** at most 60 seconds of clock skew is tolerated

### Scenario: Expired tokens always rejected

- **WHEN** a JWT's `exp` claim is in the past (beyond skew tolerance)
- **THEN** the request is rejected regardless of other valid claims

## Requirement: No sensitive data in JWT payload accessible to client

Supabase JWTs SHALL not contain sensitive data beyond what is necessary for
authentication.

### Scenario: Standard claims only

- **WHEN** Supabase issues a JWT
- **THEN** it contains only standard claims (sub, email, aud, exp, iat,
  user_metadata)

### Scenario: No secrets in custom claims

- **WHEN** custom app_metadata is added
- **THEN** it does not contain secrets, API keys, or sensitive permissions

## Requirement: HTTPS required for all authentication endpoints

All authentication-related endpoints SHALL require HTTPS in production.

### Scenario: HTTP redirected to HTTPS

- **WHEN** a request arrives over HTTP in production
- **THEN** Cloud Run redirects to HTTPS before processing authentication

### Scenario: Cookies not sent over HTTP

- **WHEN** the `Secure` flag is set on cookies
- **THEN** browsers do not send session cookies over unencrypted connections

## Requirement: Authentication failures reveal minimal information

Error messages for authentication failures SHALL not reveal information useful
to attackers.

### Scenario: Generic error for invalid JWT

- **WHEN** JWT verification fails
- **THEN** the response is a redirect to login, not a detailed error message

### Scenario: No user enumeration

- **WHEN** authentication fails
- **THEN** the error does not reveal whether the user exists or the specific
  reason for failure

## Requirement: Security audit trail maintained

The login service SHALL maintain an audit trail of authentication events.

### Scenario: Login timestamps recorded

- **WHEN** a user successfully authenticates
- **THEN** `last_login_at` is updated in `domain_logins`

### Scenario: Supabase audit logs available

- **WHEN** authentication events occur
- **THEN** Supabase maintains its own audit log in `auth.audit_log_entries`
