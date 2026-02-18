## ADDED Requirements

### Requirement: Supabase JWT contains standard claims

Supabase JWTs SHALL contain aud, sub, email, user_metadata, iat, and exp claims.

#### Scenario: JWT payload structure

- **WHEN** Supabase issues a JWT
- **THEN** it contains `aud` ("authenticated"), `sub` (user UUID), `email`, `user_metadata` (name, avatar), `iat`, and `exp`

### Requirement: Apps verify Supabase JWT signature locally

Apps SHALL verify Supabase JWT signatures using the JWT secret without calling the login service.

#### Scenario: Valid JWT accepted

- **WHEN** an app receives a request with a valid `session` cookie
- **THEN** the app verifies the HS256 signature using the Supabase JWT secret and accepts the request

#### Scenario: Invalid signature rejected

- **WHEN** an app receives a JWT with an invalid or tampered signature
- **THEN** the app rejects the request and redirects to login

#### Scenario: JWT secret fetched at startup

- **WHEN** an app starts
- **THEN** it fetches the Supabase JWT secret from Secret Manager and caches it for the process lifetime

### Requirement: Apps verify JWT audience claim

Apps SHALL verify that the JWT audience claim is "authenticated".

#### Scenario: Authenticated audience accepted

- **WHEN** a JWT has `aud: "authenticated"`
- **THEN** the app accepts the JWT

#### Scenario: Wrong audience rejected

- **WHEN** a JWT has a different audience claim
- **THEN** the app rejects the JWT and redirects to login

### Requirement: Apps verify JWT issuer claim

Apps SHALL verify that the JWT issuer claim matches the expected Supabase project.

#### Scenario: Valid issuer accepted

- **WHEN** a JWT has `iss` matching the configured Supabase project URL
- **THEN** the app accepts the JWT

#### Scenario: Unknown issuer rejected

- **WHEN** a JWT has an unexpected issuer claim
- **THEN** the app rejects the JWT and redirects to login

### Requirement: Apps verify JWT expiration

Apps SHALL reject expired JWTs.

#### Scenario: Non-expired JWT accepted

- **WHEN** an app receives a JWT with `exp` in the future
- **THEN** the app accepts the JWT

#### Scenario: Expired JWT rejected

- **WHEN** an app receives a JWT with `exp` in the past
- **THEN** the app rejects the JWT and redirects to login

### Requirement: Supabase JWT secret distributed via Secret Manager

The Supabase JWT secret SHALL be stored in Secret Manager and accessible to apps that need JWT verification.

#### Scenario: JWT secret accessible to apps

- **WHEN** an app's Cloud Run service account requests the `supabase-mklv-jwt-secret` secret
- **THEN** Secret Manager returns the JWT secret

### Requirement: Session cookie named "session"

The Supabase JWT SHALL be transmitted as an HttpOnly cookie named `session`.

#### Scenario: Cookie name consistency

- **WHEN** an app checks for authentication
- **THEN** it reads the `session` cookie from the request

### Requirement: Cookie scoping provides domain isolation

Domain isolation SHALL be enforced by browser cookie scoping, not by JWT claims.

#### Scenario: Cookie only sent to matching domain

- **WHEN** a cookie is set with `Domain=.mklv.tech`
- **THEN** the browser only sends it to `*.mklv.tech` URLs

#### Scenario: Cross-domain cookie not sent

- **WHEN** a user has cookies for both `.mklv.tech` and `.keyforge.cards`
- **THEN** visiting `app.keyforge.cards` only sends the `.keyforge.cards` cookie
