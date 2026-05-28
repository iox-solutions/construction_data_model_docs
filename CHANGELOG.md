# Changelog

All notable changes to the IOX shared data model are recorded here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and IOX Core follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **MAJOR** — backward-incompatible schema change (table drop, column rename, type narrowing, constraint tightening that invalidates existing rows).
- **MINOR** — backward-compatible addition (new table, new nullable column, new index, new view).
- **PATCH** — non-schema change (lint rules, docs, tooling, regenerated artefacts).

Module versions (ParametriX, ProcureX, etc.) are pinned to a Core MAJOR.MINOR — see `GOVERNANCE.md`.

---

## [Unreleased]

### Breaking
- **RFC 0002**: `User.password` renamed to `User.passwordHash` in V1.14. Deprecation window waived (no production consumer). `COMMENT ON COLUMN` documents the Argon2id contract and the audit-log prohibition. `schema-lint` R6 (password-plaintext) drops from 1 error to 0.

### Changed
- **RFC 0001** (additive — module-mapping.json only, no SQL): three orphan tables assigned to modules.
  - `ProjectTeam` → **Core** (identity infrastructure).
  - `CommunicationProtocol` → **ProcureX** (consumed by transmittal/query workflows).
  - `QASheet` → **ProcureX** (sibling to NCR; stubs retained for a future QA RFC rather than dropped).
  - `schema-lint` R7 (orphan-table) drops from 3 warnings to 0.
- **RFC 0003** (additive — module-mapping.json only, no SQL): two cross-module FK violations resolved by reclassification.
  - `CertifiedPayment` moved from **ReportX** to **Core** (peer to `PaymentSchedule`).
  - `CostPlanElement` moved from **Core** to **PlanX** (PlanX now owns the full cost-plan elemental structure).
  - `schema-lint` R1 (no-cross-module-fk) drops from 2 errors to 0.

### Added
- V1.14 migration repairs three pre-existing broken FK declarations from V1.12 (columns that were never added to the corresponding CREATE TABLE statements):
  - `QASheet.contractId` + `fk_QASheet_contractId`
  - `BOQ.createdById` + `fk_BOQ_createdById`
  - `Query.assignedToId` + `fk_Query_assignedToId`

  Each adds the column, the FK to its target, and a supporting index. The broken declarations were removed from V1.12 (greenfield-safe, no environments had successfully applied V1.12). `migration-test.sh` now passes end-to-end (84 tables, 139 FKs, seed loads).
- `tools/parse-schema.mjs` now handles `ALTER TABLE … ADD COLUMN` and `ALTER TABLE … RENAME COLUMN`, so `generate-types` and `schema-lint` see post-CREATE-TABLE column changes.
- `docker-compose.yml` for one-command local Postgres with full schema and seed data applied.
- `@iox/types` package — generated TypeScript interfaces, module map, FK catalogue, and `EntityType` union from the migration SQL.
- `tools/parse-schema.mjs` — shared SQL parser for migrations.
- `tools/generate-types.mjs` — regenerates `iox-types/src/generated.ts`.
- `tools/schema-lint.mjs` — enforces the one rule (no cross-module FKs except via Core anchors) and audits PII / audit-timestamp / PK / orphan patterns.
- `tools/migration-test.sh` — disposable Postgres run that applies every migration, loads seed, and verifies counts.
- `GOVERNANCE.md` — change classes, approval flow, versioning, deprecation policy.
- `ENGINEER_HANDBOOK.md` — consumer-facing intro.
- `.github/pull_request_template.md` and `docs/rfcs/0000-template.md`.

### Resolved this cycle
- ~~Three orphan tables (`ProjectTeam`, `CommunicationProtocol`, `QASheet`)~~ — resolved by RFC 0001.
- ~~`User.password` plaintext-named column~~ — resolved by RFC 0002 (V1.14).
- ~~Two cross-module FK violations (`CertifiedPaymentAllocation` → `CertifiedPayment`; `CostPlanElement` → `CostPlanArea`)~~ — resolved by RFC 0003.
- ~~V1.12 broken FK declarations (QASheet/BOQ/Query)~~ — resolved by V1.14 (see Added above).

`schema-lint` now reports **0 errors** (down from 3 at v1.13). Remaining warnings are advisory: PII-flagging on `Organization`, missing `updatedAt` columns on ParametriX append-only tables.

---

## [1.13.0] — 2026-04-29

Baseline tagged release. State of the schema prior to introducing changelog discipline.

### Schema
- 84 base tables across IOX Core and ParametriX.
- 6 reporting views.
- 139 foreign-key constraints (~95 documented historically; actual count higher after V1.12 retroactive FKs).
- 150+ performance indexes.
- 4 utility functions.

### Modules
- **Core** (v1.13): 16 tables — Project, Contract, CostPlan + supporting entities.
- **ParametriX** (v0.6): 14 tables — parametric cost modelling.
- **ProcureX**: 37 tables mapped — tender, BOQ, queries, meetings, documents.
- **PlanX**: 1 table mapped (CostPlanArea).
- **ReportX**: 10 entities mapped (4 tables + 6 views).
- **PlaceholderX**: 0 tables (reserved).

See `MIGRATION_MANIFEST.md` for the full per-migration breakdown.

[Unreleased]: ./
[1.13.0]: ./
