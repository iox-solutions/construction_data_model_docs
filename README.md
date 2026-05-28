# IOX

> Shared data model for construction project cost management, procurement, and delivery.

IOX is the PostgreSQL schema and consumer contracts that every product in the IOX ecosystem builds against. Six product modules — **ParametriX, PlanX, ProcureX, ReportX, PlaceholderX** — share one Core (`CostPlan`, `Project`, `Contract`) and one set of patterns.

**Current state**: schema v1.13 — 84 tables, 6 views, 139 foreign keys, complete migration set. Standards layer added; first production consumer TBD.

---

## Start here

| You are | Read |
|---|---|
| A product engineer about to build against IOX | [`ENGINEER_HANDBOOK.md`](./ENGINEER_HANDBOOK.md) |
| Proposing a schema change | [`GOVERNANCE.md`](./GOVERNANCE.md) |
| Setting up local development | [`docs/LOCAL_DEV.md`](./docs/LOCAL_DEV.md) |
| Deploying to Azure | [`docs/DEPLOY.md`](./docs/DEPLOY.md) |
| Looking up what's in the schema | [`docs/MODULES.md`](./docs/MODULES.md) · [`MIGRATION_MANIFEST.md`](./MIGRATION_MANIFEST.md) |
| Tracking what's changed | [`CHANGELOG.md`](./CHANGELOG.md) |
| Tracking polymorphic refs | [`docs/POLYMORPHIC_REFS.md`](./docs/POLYMORPHIC_REFS.md) |

---

## 30-second tour

```bash
# Local Postgres with the full schema + seed data:
docker compose up -d                 # or: npm run db:up

# In application code:
import type { Project, Contract, EntityType } from '@iox/types';
import { CORE_ANCHORS, FOREIGN_KEYS } from '@iox/types';
```

Repeat after me: **no cross-module foreign keys except via Core anchors** (`CostPlan`, `Project`, `Contract`). That's the one rule. Everything else in `GOVERNANCE.md` is process.

---

## Repository layout

```
construction_data_model_docs/
├── README.md                  ← you are here
├── ENGINEER_HANDBOOK.md       ← consumer pitch + getting started
├── GOVERNANCE.md              ← roles, change classes, RFC flow, versioning
├── CHANGELOG.md               ← Keep-a-Changelog format
├── MIGRATION_MANIFEST.md      ← per-migration entity catalogue
├── CLAUDE.md                  ← project guide for Claude Code sessions
├── docker-compose.yml         ← local dev Postgres
├── package.json               ← npm scripts surface
├── schema/
│   ├── migrations/            ← Flyway-style V*.sql files
│   ├── clustering/            ← module-mapping.json (drives diagrams + lint)
│   └── seed/                  ← Southgate Business Park scenario
├── iox-types/                 ← @iox/types — generated TypeScript contract
│   ├── src/generated.ts       ← AUTO — do not edit
│   └── src/index.ts
├── tools/
│   ├── parse-schema.mjs       ← shared SQL parser
│   ├── generate-types.mjs     ← regenerates @iox/types
│   ├── generate-modules-doc.mjs
│   ├── schema-lint.mjs        ← enforces the one rule + audit/PII checks
│   └── migration-test.sh      ← ephemeral apply + verify
├── docs/
│   ├── LOCAL_DEV.md
│   ├── DEPLOY.md              ← Azure
│   ├── MODULES.md             ← AUTO — generated
│   ├── POLYMORPHIC_REFS.md
│   └── rfcs/                  ← RFCs follow 0000-template.md
└── scripts/                   ← SchemaSpy + business architecture diagram
```

---

## Daily commands

All run from the repo root.

```bash
npm run db:up           # start local Postgres with schema + seed
npm run db:reset        # nuke + recreate (after editing a migration)
npm run db:psql         # psql shell into the running container

npm run lint            # schema-lint — fails on errors, warns on rest
npm run types           # regenerate @iox/types
npm run modules         # regenerate docs/MODULES.md
npm run generate        # types + modules together

npm run typecheck       # tsc --noEmit on iox-types
npm run migration:test  # disposable Postgres, full apply + verify
npm test                # generate:check + lint + typecheck
```

`npm test` is what CI runs. Run it locally before opening a PR.

---

## How this repo is governed

- **One rule** — no cross-module FKs except via Core anchors. CI-enforced.
- **Three change classes** — additive (1 reviewer), behavioral (2 reviewers, 1-day notice), breaking (RFC, 5-day window). Full details: [`GOVERNANCE.md`](./GOVERNANCE.md).
- **SemVer** on Core; module versions pinned to a Core minor.
- **Generated artefacts checked in** (`iox-types/src/generated.ts`, `docs/MODULES.md`) — CI fails if you forget to regenerate.

---

## Known issues at v1.13

Picked up by `npm run lint`, documented in [`CHANGELOG.md`](./CHANGELOG.md), and proposed for resolution in the active RFCs:

- `User.password` plaintext name → [RFC 0002](./docs/rfcs/0002-rename-user-password-to-password-hash.md)
- Three orphan tables → [RFC 0001](./docs/rfcs/0001-resolve-orphan-tables.md)
- Two cross-module FK violations → [RFC 0003](./docs/rfcs/0003-cross-module-fk-violations.md)

---

## Status

Schema **stable** at v1.13. Standards layer **introduced** this commit. First production consumer **not yet built** — see the strategic notes in [`CHANGELOG.md`](./CHANGELOG.md#unreleased).
