-- V1__init_schema.sql

CREATE TABLE releases (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name          VARCHAR(255) NOT NULL,
    product       VARCHAR(255) NOT NULL,
    version       VARCHAR(50)  NOT NULL,
    release_date  DATE         NOT NULL,
    status        VARCHAR(20)  NOT NULL DEFAULT 'DRAFT'
                  CHECK (status IN ('DRAFT', 'ASSESSED')),
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    CONSTRAINT uq_product_version UNIQUE (product, version)
);

CREATE TABLE quality_metrics (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    release_id                  UUID NOT NULL UNIQUE
                                REFERENCES releases(id) ON DELETE CASCADE,
    automated_test_pct          INT CHECK (automated_test_pct BETWEEN 0 AND 100),
    regression_pass_pct         INT CHECK (regression_pass_pct BETWEEN 0 AND 100),
    critical_defects            INT NOT NULL DEFAULT 0 CHECK (critical_defects >= 0),
    high_defects                INT NOT NULL DEFAULT 0 CHECK (high_defects >= 0),
    production_defect_leakage   INT NOT NULL DEFAULT 0 CHECK (production_defect_leakage >= 0),
    security_critical           INT NOT NULL DEFAULT 0 CHECK (security_critical >= 0),
    security_high               INT NOT NULL DEFAULT 0 CHECK (security_high >= 0),
    security_medium             INT NOT NULL DEFAULT 0 CHECK (security_medium >= 0),
    data_migration_status       VARCHAR(20) CHECK (data_migration_status IN ('PASSED','FAILED','NOT_RUN')),
    compliance_status           VARCHAR(20) CHECK (compliance_status IN ('PASSED','FAILED','NOT_RUN')),
    payroll_rule_changes        INT NOT NULL DEFAULT 0 CHECK (payroll_rule_changes >= 0),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE risk_assessments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    release_id          UUID NOT NULL REFERENCES releases(id) ON DELETE CASCADE,
    overall_score       INT NOT NULL CHECK (overall_score BETWEEN 0 AND 100),
    recommendation      VARCHAR(30) NOT NULL
                        CHECK (recommendation IN ('APPROVE','APPROVE_WITH_CONDITIONS','BLOCK')),
    quality_status        VARCHAR(10) NOT NULL CHECK (quality_status IN ('PASS','WARNING','FAIL')),
    security_status       VARCHAR(10) NOT NULL CHECK (security_status IN ('PASS','WARNING','FAIL')),
    regression_status     VARCHAR(10) NOT NULL CHECK (regression_status IN ('PASS','WARNING','FAIL')),
    defects_status        VARCHAR(10) NOT NULL CHECK (defects_status IN ('PASS','WARNING','FAIL')),
    data_migration_status VARCHAR(10) NOT NULL CHECK (data_migration_status IN ('PASS','WARNING','FAIL')),
    compliance_status     VARCHAR(10) NOT NULL CHECK (compliance_status IN ('PASS','WARNING','FAIL')),
    is_stale            BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_risk_assessments_release_id ON risk_assessments(release_id);
