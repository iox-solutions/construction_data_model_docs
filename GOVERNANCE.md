# IOX Governance

How the IOX shared data model is owned, changed, and versioned.

This document is **load-bearing**: it is the contract between the schema and the engineering teams that consume it. Changes to governance itself follow the [Breaking](#change-classes) flow.

---

## Roles

| Role | Count | Responsibilities |
|---|---|---|
| **Schema Steward** | 1 | Owns Core. Final approver on breaking changes. Runs the RFC process. Adjudicates ambiguous cross-module questions. |
| **Module Owner** | 1 per product module | Owns module-internal migrations and lint exceptions. Reviews PRs touching their module. Surfaces module-specific RFCs. |
| **Consumer** | Any product team | Files issues, proposes RFCs, requests new tables / columns, reports schema friction. |

Module ownership today:

| Module | Owner |
|---|---|
| Core | _TBD — assign before any breaking change_ |
| ParametriX | _TBD_ |
| PlanX | _TBD_ |
| ProcureX | _TBD_ |
| ReportX | _TBD_ |
| PlaceholderX | _TBD_ |

The Schema Steward role rotates only by explicit handover; until then the role is held by the project initiator.

---

## The One Rule

**Cross-module foreign keys must terminate at a Core anchor table.**

The Core anchors are: `CostPlan`, `Project`, `Contract`.

Module-to-module FKs are forbidden. If module A needs data from module B, it joins through a Core anchor that both modules already reference.

This rule is enforced by `tools/schema-lint.mjs` (rule `R1: no-cross-module-fk`) and is the single non-negotiable constraint of the IOX data model.

Why: it lets modules evolve independently. The day ProcureX wants to change its internal table shape, no other module's queries break, because no other module reads from a ProcureX table directly.

---

## Change classes

Every PR is one of these. The PR template asks you to pick.

### Additive — 1 reviewer

No existing consumer can break.

Includes:
- New table.
- New nullable column (without `NOT NULL`, no default required at write time).
- New index, view, function.
- New module mapping entry.
- Generated artefacts (`iox-types/src/generated.ts`), CHANGELOG, docs.

Process:
1. PR opened by author.
2. One reviewer (Schema Steward for Core changes, Module Owner for module-internal).
3. Merge. CHANGELOG `[Unreleased]` updated.

### Behavioral — 2 reviewers, 1 business day notice

Existing consumers continue to work, but their semantics shift.

Includes:
- Default value change on an existing column.
- New `NOT NULL` column (requires a documented default or backfill).
- New FK constraint on existing data (must pass on current production data).
- New lint rule.
- New view that shadows or replaces an existing query pattern.

Process:
1. PR opened, marked **Behavioral**.
2. Author posts a 1-business-day notice in `#iox-changes` linking the PR.
3. Two reviewers approve (Schema Steward + relevant Module Owner).
4. Merge. CHANGELOG `[Unreleased]` updated.

### Breaking — RFC required, 5 business days, deprecation window

A consumer that worked yesterday will fail today.

Includes:
- Column or table rename.
- Column type change (including widening that breaks parsing).
- Constraint tightening that rejects existing data.
- Drop of any public symbol (table, column, view, function).
- Removal of a previously deprecated symbol.
- Change to governance, the One Rule, or the version scheme.

Process:
1. Author opens an RFC (`docs/rfcs/NNNN-slug.md`, using `docs/rfcs/0000-template.md`).
2. RFC status set to **Open for comment**. Posted in `#iox-changes`.
3. Comment window: **5 business days minimum**.
4. Schema Steward marks **Accepted** or **Rejected** and links the decision.
5. Implementation PR references the RFC and follows the deprecation contract:
   - If renaming or dropping: ship the new symbol alongside the old in Core minor N.
   - Old symbol carries `COMMENT ON … IS 'DEPRECATED: removed in 1.(N+1)+. See RFC NNNN.'`.
   - `@iox/types` generates a `@deprecated` JSDoc tag.
   - Removal happens no earlier than Core minor N+1, calendar-month at minimum.

### Tooling / docs only — 1 reviewer

No schema change. PR template still required; CHANGELOG note optional.

---

## Versioning

IOX Core uses SemVer: **MAJOR.MINOR.PATCH**.

- **MAJOR** — a Breaking change has shipped.
- **MINOR** — Additive or Behavioral changes have shipped.
- **PATCH** — tooling, docs, generated-artefact regeneration only.

Module versions are pinned to a Core MAJOR.MINOR. Example: `ProcureX 1.13.x` is built against Core `1.13.x`.

Tags follow `v<major>.<minor>.<patch>` (e.g. `v1.13.0`). Module tags follow `<module>/v<major>.<minor>.<patch>` (e.g. `parametrix/v0.6.0`).

> **Note**: ParametriX is currently versioned `v0.x` predating this policy. The next Core minor will renumber it to align with Core. See RFC backlog.

---

## Deprecation policy

A symbol is **deprecated** when:

- Its `COMMENT ON …` text begins with `DEPRECATED:`.
- An RFC documents the removal plan and target version.
- `@iox/types` emits a `@deprecated` JSDoc tag on the corresponding TypeScript symbol.

A deprecated symbol must remain functional for **at least one Core minor version** before removal.

Consumers see the deprecation in three places:
1. The lint rule `R8: deprecated-symbol-in-use` (per-consumer opt-in via the lint config in their repo).
2. The TypeScript `@deprecated` annotation in their editor.
3. The CHANGELOG entry for the minor that introduced the deprecation.

---

## RFCs

When required: any **Breaking** change, or a change to governance itself.

Storage: `docs/rfcs/NNNN-slug.md`. Number sequentially. Use `docs/rfcs/0000-template.md`.

Status lifecycle: `Draft → Open for comment → Accepted | Rejected | Superseded`.

An RFC stays in the repo after a decision — including rejected ones. The record of *why* a thing was not done is as valuable as the record of why it was.

---

## Anti-fragmentation

The day a product team needs to ship and finds IOX inconvenient is the day IOX fragments. Mitigations:

1. **No new tables in product application databases without first checking IOX.** Enforced by review, not tooling.
2. **The one rule is CI-enforced** (`tools/schema-lint.mjs` rule R1). Exceptions require an RFC.
3. **`@iox/types` is the only schema contract a product team must keep in sync with** — they should not be reading SQL.
4. **The dev DB is one command away** (`docker compose up -d`). If it isn't, file an issue.

---

## Schema-health review

Quarterly, the Schema Steward and Module Owners review:

- Open RFCs.
- Deprecated symbols past their removal window.
- Lint exceptions that have accumulated.
- Orphan tables and unassigned columns.
- Drift between `module-mapping.json` and the migrations.

Output: a short markdown note appended to `docs/health-reviews/YYYY-QN.md`. No more than one page.

---

## Out of scope for this document

- Application-layer concerns (ORM choice, query patterns, caching, auth wiring beyond the schema).
- Deployment topology (single shared DB vs. per-product DBs) — covered separately in `docs/deployment-strategy.md` (to be written).
- Performance guarantees — Core indexes are best-effort; product teams own their workload-specific indexes.
