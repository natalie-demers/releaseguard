# ReleaseGuard — Database Schema

## Overview

Three tables model the core domain: `releases`, `quality_metrics`, and `risk_assessments`.
Schema changes are managed via Flyway migrations (see `db/migration/` in the codebase),
giving a versioned, auditable history of every structural change — relevant given the
compliance domain this project targets.

## Entity-relationship diagram

```mermaid
erDiagram
  RELEASES ||--|| QUALITY_METRICS : has
  RELEASES ||--o{ RISK_ASSESSMENTS : produces
  RELEASES {
    uuid id PK
    string name
    string product
    string version
    date release_date
    string status
    timestamp created_at
    timestamp updated_at
  }
  QUALITY_METRICS {
    uuid id PK
    uuid release_id FK
    int automated_test_pct
    int regression_pass_pct
    int critical_defects
    int high_defects
    int production_defect_leakage
    int security_critical
    int security_high
    int security_medium
    string data_migration_status
    string compliance_status
    int payroll_rule_changes
    timestamp updated_at
  }
  RISK_ASSESSMENTS {
    uuid id PK
    uuid release_id FK
    int overall_score
    string recommendation
    string quality_status
    string security_status
    string regression_status
    string defects_status
    string data_migration_status
    string compliance_status
    boolean is_stale
    timestamp created_at
  }
```

## Design decisions

- **`releases` ↔ `quality_metrics` is one-to-one.** Milestone 1 tracks only the current
  set of metrics per release; `quality_metrics.release_id` is unique.
- **`releases` ↔ `risk_assessments` is one-to-many**, even though only one row exists per
  release today. This is a deliberately reserved seam: a future score-history feature can
  simply stop overwriting and start inserting new rows, with no schema redesign required.
- **`is_stale` on `risk_assessments`** supports the reopen workflow (see US6 in
  `user-stories.md`): reopening a release marks its current assessment stale rather than
  deleting it, so the dashboard can show "this score is out of date" instead of losing
  the record.
- **`releases.status`** enforces the `DRAFT` / `ASSESSED` lifecycle at the database level
  via a check constraint, not just in application code.
- **`UNIQUE (product, version)`** on `releases` prevents two releases of the same product
  from sharing a version number.

## Migrations

Schema changes are applied via Flyway, in `src/main/resources/db/migration/`.
`V1__init_schema.sql` creates all three tables above.
