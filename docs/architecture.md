# ReleaseGuard — Architecture

## Overview

ReleaseGuard is a modular monolith: a single Spring Boot deployable with clean internal
boundaries (controller → service → risk engine → repository), backed by PostgreSQL and
fronted by a React SPA. A modular monolith was chosen deliberately over microservices —
appropriate for a solo-built portfolio project of this scope, while still demonstrating
separation of concerns. The boundary between the risk engine and the rest of the API is
kept explicit so it can be independently unit tested. So a future split into a separate
service remains possible if scaling ever required it.

## Components

- **Browser client (React SPA)** — release list, release detail/dashboard, and forms for
  creating releases and entering quality metrics.
- **Spring Boot REST API** — owns validation, orchestration, and (from Milestone 8) auth.
  Exposes the `/releases` resource.
- **Risk engine** — a distinct package/module inside the Spring Boot app. Takes a release's
  metrics and produces a score, per-area status, and a recommendation. Kept free of any
  dependency on the web framework or database so it can be tested in complete isolation.
- **PostgreSQL** — the single source of truth for releases, quality metrics, and risk
  assessments.
- **GitHub Actions** (Milestone 5+) — build, test, security scan, and produce a Docker image.
- **AWS: ECS / RDS / CloudWatch** (Milestone 7+) — production deployment target, using the
  same container image built by CI, configured via environment variables/Spring profiles
  rather than a separate build.

## Data model shape (see `docs/db-schema.md` for full ERD)

Risk scoring is modeled as its own `risk_assessments` entity — not fields bolted onto
`releases` — even though Milestone 1 only stores the current assessment. This reserves the
seam for a future score-history/audit-trail feature without requiring a redesign later.

Each release carries a lifecycle status: `DRAFT → ASSESSED → (reopen) → DRAFT`. Metrics are
editable only in `DRAFT`; generating an assessment moves the release to `ASSESSED` and locks
metrics until an explicit reopen action.

## Non-functional constraints

- **Stateless API** — no server-side session state so that the API can scale horizontally on
  ECS later without architectural change.
- **Single source of truth** — PostgreSQL only; no caching layer at this scale.
- **Idempotency** — updates and risk recalculation are safe to repeat with the same input.
- **Auth deferred, not ignored** — no auth through Milestone 6; the data model assumes an
  eventual `owner`/`user` concept on releases so it isn't retrofitted badly later.
- **Build once, promote everywhere** — local (Docker Compose) and AWS (ECS/RDS) run the
  same container image; environment differences are configuration only.
- **Local reproducibility** — Milestones 1–6 run entirely via `docker compose up`, with no
  cloud dependency or cost.

## Technology choices

| Layer | Choice | Why |
|---|---|---|
| Frontend | React | |
| Backend | Java 21 + Spring Boot 3.x | Current LTS Java + current Spring major version, rather than legacy Java 8/11 + Spring Boot 2 |
| Database | PostgreSQL | |
| Schema migrations | Flyway | Versioned, auditable schema history — relevant given the compliance domain |
| API docs | springdoc-openapi | Live, interactive API spec generated from code, not a static doc |
| Testing | JUnit + Mockito, Testcontainers | Testcontainers runs a real disposable PostgreSQL in integration tests instead of mocking the DB or using H2 |
| API testing | Postman | |
| Logging | Structured JSON logs (local) | Sets up the observability story ahead of CloudWatch in Milestone 7 |
| CI/CD | GitHub Actions | |
| Containerization | Docker | |
| Cloud | AWS (ECS, RDS, CloudWatch) | Milestone 7+ |
| IaC | Terraform | Milestone 7+ |
| Security scanning | OWASP dependency check | Milestone 8 |
| AI assistance | GitHub Copilot | Used to implement reviewed requirements, not to generate the app wholesale |

## Diagram

![ReleaseGuard architecture](../assets/architecture-diagram.png)

*(See the "Lessons learned" section of the main README for how this design evolved.)*
