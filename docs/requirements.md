# ReleaseGuard — Requirements

## Functional requirements

### FR1 — Release management
- Create, view, update, and delete a release: name, version, product, release date.
- List all releases, sorted by release date (most recent first).
- Release version must be unique per product — creating a release with a version that
  already exists for that product returns a conflict error.
- Each release has a lifecycle status: `DRAFT` → `ASSESSED` → (reopen) → `DRAFT`.

### FR2 — Quality metrics capture
- Attach quality metrics to a release: automated test %, regression pass %, critical
  defect count, high defect count, production defect leakage.
- Metrics are editable only while the release is in `DRAFT` status.
- A release in `ASSESSED` status must be explicitly reopened (returning it to `DRAFT`)
  before its metrics can be edited again.

### FR3 — Risk scoring
- On demand, compute a weighted risk score (0–100) from: quality, security, regression,
  defects, data migration, and compliance.
- Each risk area gets an individual status (pass/warning/fail) in addition to
  contributing to the overall score.
- If metrics are incomplete (e.g., no security data yet), the system returns a clear
  "incomplete" state rather than a misleadingly confident score.
- A successful assessment transitions the release from `DRAFT` to `ASSESSED`.

### FR4 — Recommendation engine
- Map the overall score/status combination to a recommendation: `APPROVE`,
  `APPROVE WITH CONDITIONS`, or `BLOCK`.
- Recommendation logic must be explainable — able to state which risk areas drove the
  outcome, not just output a number.

### FR5 — Dashboard
- View a single release's full risk breakdown (per-area status, overall score, and
  recommendation) in one readable view.

### FR6 — Risk assessment as a first-class entity (seam reserved for future history)
- Risk scoring is modeled as its own `risk_assessments` entity, not fields on `releases`.
- Milestone 1 stores only the current assessment per release. Full score-history/audit
  trail (multiple assessments per release over time) is explicitly deferred to a later
  milestone, but the schema is designed so that adding it later requires no redesign —
  only a change from "update in place" to "insert new row."

## Non-functional requirements

- **NFR1 — Correctness of scoring:** risk calculation is deterministic and unit-testable
  in isolation from the web layer.
- **NFR2 — Data integrity:** required fields validated at the API layer; invalid metric
  values (e.g., negative percentages, out-of-range values) rejected with a clear
  field-level error.
- **NFR3 — Auditability:** schema migrations are tracked and versioned (Flyway); scoring
  inputs/outputs are never silently overwritten.
- **NFR4 — Testability:** the risk engine has no direct dependency on the web framework
  or database, so it can be tested with plain unit tests.
- **NFR5 — Local reproducibility:** the whole app runs via `docker compose up` with no
  external/cloud dependency for Milestones 1–6.
- **NFR6 — API discoverability:** live OpenAPI docs available at a `/swagger-ui` endpoint.
- **NFR7 — Performance (soft target):** risk calculation completes in well under 100ms
  per release.

## Explicit non-goals (for now)

- Authentication/authorization — deferred to Milestone 8. The data model assumes an
  eventual `owner`/`user` concept on releases, but no auth is enforced through Milestone 6.
- Multi-tenant support — out of scope entirely; single-user/local-demo assumption.
- Full audit/history trail — seam reserved (see FR6), not built in Milestone 1.
