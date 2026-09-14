US1 — Create a release

As a release manager, 
I want to create a release record with its name, version, product, and release date, 
so that I have a place to attach quality data.

AC: POST /releases with valid payload returns 201 and the created release with an ID.
AC: POST /releases with a version that already exists for that product returns 409 Conflict.
AC: Missing required field (name, version, product, or date) returns 400 with a field-level error.
AC: Duplicate version for the same product is allowed (versions aren't necessarily unique across products) — [flag: confirm this assumption below].

US2 — View releases

As a release manager, 
I want to list all releases and view one in detail, 
so I can find the one I'm assessing.

AC: GET /releases returns all releases, newest release date first.
AC: GET /releases/{id} returns 404 if the ID doesn't exist.

US3 — Enter quality metrics

As a QE lead, 
I want to enter automated test %, regression pass %, and defect counts for a release, 
so the system can assess its risk.

AC: Percentages must be 0–100; defect counts must be ≥ 0 — otherwise 400.
AC: Metrics can be updated any number of times before... [depends on the "finalized" question below].
AC: Metrics cannot be edited while the release is in ASSESSED state; a POST /releases/{id}/reopen action moves it back to DRAFT for editing.

US4 — Get a risk assessment

As a release manager, 
I want the system to calculate a risk score and recommendation from a release's current metrics, 
so I know whether it's safe to ship.

AC: Triggering assessment with complete metrics returns a score 0–100, a status per risk area, and one of APPROVE / APPROVE WITH CONDITIONS / BLOCK.
AC: Triggering assessment with incomplete metrics (e.g., no security data yet) returns a clear "incomplete" state rather than a misleadingly confident score.
AC: After a successful assessment, the release transitions from DRAFT → ASSESSED.

US5 — View the dashboard

As a release manager, 
I want to see a release's full risk breakdown in one view, 
so I can explain the decision to stakeholders.

AC: Dashboard shows overall score, recommendation, and per-area status in the box-chart layout from the spec doc.
