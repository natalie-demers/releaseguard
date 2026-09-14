# ReleaseGuard — User Stories (Milestone 1)

## US1 — Create a release

**As a** release manager,
**I want to** create a release record with its name, version, product, and release date,
**so that** I have a place to attach quality data.

**Acceptance criteria:**
- `POST /releases` with a valid payload returns `201 Created` and the created release,
  including its generated ID and `DRAFT` status.
- A request missing any required field (name, version, product, or date) returns
  `400 Bad Request` with a field-level error.
- A request with a version that already exists for the same product returns
  `409 Conflict`.

## US2 — View releases

**As a** release manager,
**I want to** list all releases and view one in detail,
**so that** I can find the one I'm assessing.

**Acceptance criteria:**
- `GET /releases` returns all releases, ordered by release date (most recent first).
- `GET /releases/{id}` returns the full release detail.
- `GET /releases/{id}` returns `404 Not Found` if the ID doesn't exist.

## US3 — Enter quality metrics

**As a** QE lead,
**I want to** enter automated test %, regression pass %, and defect counts for a release,
**so that** the system can assess its risk.

**Acceptance criteria:**
- Percentages must be between 0–100; defect counts must be ≥ 0 — otherwise
  `400 Bad Request`.
- Metrics can be created/updated any number of times while the release is in `DRAFT`.
- Attempting to edit metrics while the release is in `ASSESSED` status returns
  `409 Conflict`.

## US4 — Get a risk assessment

**As a** release manager,
**I want** the system to calculate a risk score and recommendation from a release's
current metrics,
**so that** I know whether it's safe to ship.

**Acceptance criteria:**
- Triggering an assessment with complete metrics returns a score (0–100), a status per
  risk area, and one of `APPROVE` / `APPROVE WITH CONDITIONS` / `BLOCK`.
- Triggering an assessment with incomplete metrics returns a clear "incomplete" state
  rather than a misleadingly confident score.
- A successful assessment moves the release's status from `DRAFT` to `ASSESSED`.

## US5 — View the dashboard

**As a** release manager,
**I want to** see a release's full risk breakdown in one view,
**so that** I can explain the decision to stakeholders.

**Acceptance criteria:**
- The dashboard shows overall score, recommendation, and per-area status in the box-chart
  layout defined in the architecture spec.
- Attempting to view the dashboard for a release with no assessment yet shows a clear
  "not yet assessed" state instead of an error.

## US6 — Reopen a release for edits

**As a** release manager,
**I want to** reopen an already-assessed release,
**so that** I can update its metrics after new information comes in (e.g., a fix landed,
a new defect was found) and get a fresh assessment.

**Acceptance criteria:**
- `POST /releases/{id}/reopen` on a release in `ASSESSED` status moves it back to `DRAFT`.
- Calling reopen on a release already in `DRAFT` status returns `409 Conflict` (nothing
  to reopen).
- Reopening does not delete the prior assessment result — it remains visible on the
  dashboard, marked as stale, until a new assessment is generated.
