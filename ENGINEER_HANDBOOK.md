# IOX Engineer Handbook

A 5-minute read for anyone building a product against the IOX data model.

---

## Why IOX exists

IOX is the shared data foundation for construction project cost management at this company. Six product modules — ParametriX, PlanX, ProcureX, ReportX, PlaceholderX, plus a Core that ties them together — all read from and write to the same Postgres schema.

This means:

- You don't redefine `Project`, `Contract`, or `User`. They already exist.
- You don't roll your own audit trail, RBAC, or document versioning. The pattern is set.
- You don't negotiate a schema with the next team over. They're reading the same tables.

The cost: you agree to one rule and one process. Both are below.

---

## What you get on day one

```bash
# 1. Start a local IOX Postgres with the full schema + seed data.
docker compose up -d

# 2. Connect.
psql postgresql://iox:iox@localhost:5432/iox_dev

# 3. In your app:
import type { Project, Contract, EntityType } from '@iox/types';
import { CORE_ANCHORS, FOREIGN_KEYS } from '@iox/types';
```

That's the whole onboarding path. You have a working database and accurate types in under five minutes.

### Things that are done for you

- **84 tables** covering project, contract, cost plan, BOQ, tender, documents, RBAC, audit.
- **6 reporting views** for common dashboards (`ProjectSummary`, `ContractStatusSummary`, `OpenActionItemsByOwner`, …).
- **Generated TypeScript types** for every table and every cross-table reference (`@iox/types`).
- **Immutable audit patterns** — `AuditLog`, `DocumentVersion`, `BudgetVersion`, `CostPlanVersion`, `BOQVersion`.
- **Scope-qualified RBAC** — global, organisation, or project scope on a single `UserRole` table.
- **PII flagging** in `COMMENT ON TABLE` text for compliance review.
- **Seeded "Southgate Business Park" scenario** — realistic data to develop against.

---

## What's asked of you

### The One Rule

> **Cross-module foreign keys must terminate at a Core anchor table.**

The Core anchors are `CostPlan`, `Project`, `Contract`.

If ProcureX needs ReportX data, you do not add a FK from ProcureX → ReportX. You join through the shared anchor (almost always `Contract`).

Enforced by `node tools/schema-lint.mjs` — runs in CI.

That's it. Everything else is convention you can push back on; this is the line.

### The process

| You want to | You do |
|---|---|
| Add a column to an existing module-internal table | Open an Additive PR. One reviewer. |
| Add a new table to your module | Open an Additive PR. Update `module-mapping.json`. One reviewer. |
| Change a default, add a constraint, add a FK | Open a Behavioral PR. Two reviewers, 1 day notice in `#iox-changes`. |
| Rename / drop a column, change a type, drop a table | Write an RFC. 5 business days. See `GOVERNANCE.md`. |
| Add a Core table | Open an RFC first. Core is small on purpose. |

Full detail in `GOVERNANCE.md`.

---

## How to consume the schema

### Types

```ts
import type { Project, Contract, ActionItem, EntityType } from '@iox/types';

async function listOpenActions(projectId: string): Promise<ActionItem[]> {
  const rows = await db.query<ActionItem>(
    `SELECT * FROM "ActionItem" WHERE "projectId" = $1 AND "status" IN ('OPEN','IN_PROGRESS')`,
    [projectId],
  );
  return rows;
}
```

### Polymorphic references

Several tables use `(entityType, entityId)` instead of a hard FK — `AuditLog`, `WorkflowInstance`. Use the generated `EntityType` union to keep them honest:

```ts
import type { EntityType } from '@iox/types';

function logAction(entityType: EntityType, entityId: string, action: string) {
  // TypeScript will reject `'NotARealTable'` at compile time.
}
```

### Module ownership

```ts
import { TABLE_MODULES, CORE_ANCHORS } from '@iox/types';

TABLE_MODULES['Contract'];     // 'core'
TABLE_MODULES['BOQ'];          // 'procurex'
CORE_ANCHORS;                  // readonly ['CostPlan','Project','Contract']
```

Use these at the boundary of your code if you want to detect cross-module joins at runtime.

---

## How to add a table

1. Decide which module it belongs to. If unclear, ask in `#iox-design`.
2. Add a new migration: `schema/migrations/<module>/V<next>__<description>.sql`.
3. Follow the established patterns:
   - PK column named `<entityName>Id`, type `TEXT PRIMARY KEY`.
   - `createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP`, plus `updatedAt` if the table is mutable.
   - All FKs declared at the bottom of the file via `ALTER TABLE … ADD CONSTRAINT … FOREIGN KEY …`.
   - PII fields documented in `COMMENT ON TABLE` text.
4. Add the table name to its module's `tables` array in `schema/clustering/module-mapping.json`.
5. Run locally:
   ```bash
   bash tools/migration-test.sh        # full apply + verify
   node tools/schema-lint.mjs          # rules check
   node tools/generate-types.mjs       # regenerate @iox/types
   ```
6. Update `CHANGELOG.md` under `[Unreleased]`.
7. Open the PR. The template walks you through the rest.

---

## How to ask for help

| Need | Channel |
|---|---|
| "Does IOX have a table for X?" | `#iox-design` |
| "Why doesn't my migration apply?" | `#iox-design` |
| "I want to propose a Breaking change" | Open an RFC. Cross-post in `#iox-changes`. |
| "I think the schema has a bug" | File an issue. Tag the relevant Module Owner. |
| Office hours | Weekly, link in `#iox-design` topic. First 2 months of any product onboarding, attend at least one. |

---

## What's coming

The schema is at **v1.13** — complete in shape, not yet pressure-tested by a real consumer. Near-term priorities:

1. First production consumer (ProcureX is the planned candidate). Findings from that build will drive v1.14.
2. Resolution of three known orphan tables (`ProjectTeam`, `CommunicationProtocol`, `QASheet`).
3. Resolution of two known cross-module FK violations (`CertifiedPaymentAllocation`, `CostPlanElement`) — see `CHANGELOG.md`.
4. `User.password` → `User.passwordHash` rename — first Breaking RFC.

See `docs/rfcs/` for active proposals.

---

## TL;DR

- `docker compose up -d` gives you a working IOX database.
- `import type { ... } from '@iox/types'` gives you accurate types.
- One rule: no cross-module FKs except via Core anchors.
- One process: PR template tells you what to do.

Welcome.
