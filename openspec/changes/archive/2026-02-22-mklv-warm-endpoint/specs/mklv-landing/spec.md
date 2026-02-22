# MKLV Landing Page

## ADDED Requirements

### Requirement: Landing page at root URL

The system SHALL serve a landing page at `https://mklv.tech/` with branding
and links to applications.

#### Scenario: Landing page loads

- **WHEN** a user visits `https://mklv.tech/`
- **THEN** an HTML page is served with "mklv.tech" branding

#### Scenario: Landing page includes app links

- **WHEN** the landing page is rendered
- **THEN** it includes links to email-unsubscribe, login, and todos apps

### Requirement: MKLV favicon

The system SHALL serve a favicon with stylized "MKLV" letters superimposed
on each other.

#### Scenario: Favicon served

- **WHEN** a browser requests `/favicon.ico`
- **THEN** an ICO or SVG file is served with the MKLV design

#### Scenario: Favicon referenced in HTML

- **WHEN** the landing page HTML is rendered
- **THEN** it includes a `<link rel="icon">` tag pointing to the favicon

### Requirement: Health endpoint

The system SHALL provide a `/health` endpoint for warming and monitoring.

#### Scenario: Health check succeeds

- **WHEN** a GET request is made to `/health`
- **THEN** a 200 response with `{"status": "ok"}` is returned

### Requirement: Static assets served from Hono

The system SHALL serve static assets from the `src/public/` directory using
Hono's static file middleware.

#### Scenario: Static files served

- **WHEN** a request is made for `/style.css`
- **AND** `src/public/style.css` exists
- **THEN** the file is served with appropriate content-type

#### Scenario: Non-existent static files return 404

- **WHEN** a request is made for `/nonexistent.js`
- **THEN** a 404 response is returned
