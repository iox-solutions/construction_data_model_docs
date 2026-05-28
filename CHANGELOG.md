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

### Added
- `docker-compose.yml` for one-command local Postgres with full schema and seed data applied.
- `@iox/types` package — generated TypeScript interfaces, module map, FK catalogue, and `EntityType` union from the migration SQL.
- `tools/parse-schema.mjs` — shared SQL parser for migrations.
- `tools/generate-types.mjs` — regenerates `iox-types/src/generated.ts`.
- `tools/schema-lint.mjs` — enforces the one rule (no cross-module FKs except via Core anchors) and audits PII / audit-timestamp / PK / orphan patterns.
- `tools/migration-test.sh` — disposable Postgres run that applies every migration, loads seed, and verifies counts.
- `GOVERNANCE.md` — change classes, approval flow, versioning, deprecation policy.
- `ENGINEER_HANDBOOK.md` — consumer-facing intro.
- `.github/pull_request_template.md` and `docs/rfcs/0000-template.md`.

### Known issues surfaced by lint
- `User.password` is a plaintext-named column — should be `passwordHash` (see RFC backlog).
- Two cross-module FK violations:
  - `CertifiedPaymentAllocation` (core) → `CertifiedPayment` (reportx)
  - `CostPlanElement` (core) → `CostPlanArea` (planx)
- Three orphan tables (`ProjectTeam`, `CommunicationProtocol`, `QASheet`) — not assigned to any module.

These predate the v1.13 baseline and are tracked for resolution in the next minor.

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
