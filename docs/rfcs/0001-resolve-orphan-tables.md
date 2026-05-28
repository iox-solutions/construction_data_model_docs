# RFC 0001 — Resolve orphan tables

- **Status**: Accepted
- **Author**: Schema Steward
- **Created**: 2026-05-28
- **Decided**: 2026-05-28
- **Related**: schema-lint rule `R7: orphan-table`; CLAUDE.md Next Steps

## Summary

Three tables (`ProjectTeam`, `CommunicationProtocol`, `QASheet`) exist in the schema but are not assigned to any module in `schema/clustering/module-mapping.json`. This RFC proposes a resolution for each — assign to an existing module, move to Core, or remove — and the migration needed.

## Motivation

Orphan tables are a load-bearing source of confusion:

1. They don't appear in the business architecture diagram, so a product engineer reading the diagram believes the schema lacks them.
2. They're not covered by module ownership in `GOVERNANCE.md` — no one is on the hook for evolving them.
3. They generate persistent `schema-lint R7` warnings, eroding signal-to-noise in CI.
4. Two of them (`ProjectTeam`, `CommunicationProtocol`) are clearly load-bearing — they already have FKs from Core. `QASheet` is a stub.

Letting orphans persist past v1.13 sends the message that the schema is *almost* finished, which weakens the case to teams considering whether to adopt it.

## Detailed design

Each orphan is considered independently. Decision per table is requested separately — they don't need to resolve together.

### 1. `ProjectTeam`

**Current shape** (V1.2): `(projectTeamId, projectId, userId, userRoleId, joinedAt, leftAt)`. Has FKs to `Project`, `User`, `UserRole`. Has a partial unique index for active members.

**Analysis**: This is a project-scoped membership table. It is *infrastructure* (Identity & Access territory) — it represents who has access to a Project, not domain data owned by a product module.

**Options**:

- **Option A — Assign to Core.** Treat alongside `User`, `Role`, `UserRole`. Pro: matches its role. Con: Core grows by one table.
- **Option B — Move to a new "Identity" module separation.** Currently `exclude[]` in `module-mapping.json` lists `User/Role/Permission/...` outside the visible modules. Extend that pattern.
- **Option C — Add to ProcureX.** Pro: ProcureX has the most project-level activity. Con: Conflates infrastructure with domain — same problem as today.

**Recommendation**: **Option A**. `ProjectTeam` is identity infrastructure; surface it alongside `Organization`, `Client`, etc. in Core. Add `'ProjectTeam'` to `modules.core.tables` in `module-mapping.json`. No SQL migration required.

### 2. `CommunicationProtocol`

**Current shape** (V1.2): `(communicationProtocolId, projectId, responseTimeframeDays, namingConvention, notes, createdAt, updatedAt)`. UNIQUE per project — at most one protocol per project.

**Analysis**: This is project-level configuration governing how transmittals/queries are exchanged. Used by ProcureX workflows (transmittals, document exchange).

**Options**:

- **Option A — Assign to ProcureX.** Pro: that's where it's consumed. Con: FK is from CommunicationProtocol → Project (Core anchor), which is fine; the table itself sits in ProcureX.
- **Option B — Assign to Core.** Pro: it's project-level metadata, like `NoticeOfWin`. Con: Core gets a procurement-flavoured table.
- **Option C — Delete and replace with JSONB column on `Project`.** Pro: removes a 1-row-per-project table. Con: loses queryability; one-off schema, no audit trail.

**Recommendation**: **Option A**. Add `'CommunicationProtocol'` to `modules.procurex.tables`. Same SQL, just diagram + lint awareness.

### 3. `QASheet`

**Current shape** (V1.3–V1.11): `(qaSheetId, projectId, title, status)`. A stub — no createdAt, no version tracking, no relationship to QA workflow tables. Has FK from QASheet → Contract added in V1.12 (note: schema-lint will flag `QASheet.projectId` is unreferenced if the FK target is Contract not Project — verify).

**Analysis**: This was scaffolding for the v1.7 QA segment, which never landed properly (`Checklist`, `ChecklistItem` are also stubs). The QA module was deferred.

**Options**:

- **Option A — Delete `QASheet`, `Checklist`, `ChecklistItem`.** Pro: removes scaffolding that hasn't earned its place. Con: a future QA module starts from zero.
- **Option B — Move all three to a new `qax` module entry marked "experimental".** Pro: signals intent without pretending they're production-ready. Con: experimental tables that linger become permanent.
- **Option C — Flesh them out now.** Out of scope for this RFC.

**Recommendation**: **Option A — delete.** They are non-functional stubs from v1.7. A new RFC can introduce QA when a consumer needs it. Migration:

```sql
-- V1.14__remove_qa_stubs.sql
DROP TABLE "QASheet";
DROP TABLE "ChecklistItem";
DROP TABLE "Checklist";
```

(All three have no inbound FKs, confirm with `schema-lint`.)

## Consumers affected

- `@iox/types` — regenerates with no `QASheet`/`Checklist`/`ChecklistItem` types if Option A on #3 is taken.
- `schema/clustering/module-mapping.json` — updated.
- Business architecture diagram — regenerates automatically.
- No production consumers (no products built yet).

## Migration path

- **Option A on #1 and #2**: pure config change. No SQL. CHANGELOG note under Additive.
- **Option A on #3**: SQL migration. Breaking change — but no production consumer exists, so the deprecation window can be waived.

## Alternatives considered

- **Do nothing.** Orphans persist, lint warnings grow with every new orphan. Rejected — the standards layer is undermined.
- **Bulk-assign all three to Core.** Quick. Rejected — `QASheet` doesn't deserve preservation, and `CommunicationProtocol` belongs with the workflow that consumes it.
- **Defer to the first product consumer.** Rejected — they'd inherit unclear ownership and the orphans would calcify.

## Risks and unresolved questions

- Confirm `QASheet.projectId` FK target — schema-lint suggests it FKs to `Contract` per V1.12. If so, the column name is misleading and would need correction before delete-or-keep is decided. Action: verify via inspection before acceptance.
- Is there a fourth orphan-adjacent case in `Notification`, `AuditLog`, `PerformanceRating` that the `exclude[]` array is hiding? Those are listed under `exclude[]` in `module-mapping.json` — meaning "deliberately not shown in the module diagram." This RFC does not propose changing that.

## Decision (2026-05-28)

Schema Steward accepted all three resolutions; only one deviates from the original recommendation.

| # | Table | Decision | Rationale |
|---|---|---|---|
| 1 | `ProjectTeam` | **Assign to Core** (Option A — recommended) | Identity/access infrastructure; surfaces alongside `User`/`Role`/`UserRole`. Pure config change. |
| 2 | `CommunicationProtocol` | **Assign to ProcureX** (Option A — recommended) | Lives where transmittal/query workflows consume it. Pure config change. |
| 3 | `QASheet` (+ `Checklist`, `ChecklistItem`) | **Assign to ProcureX** (no DROP) | Steward declined the recommended Option A (delete). QA workflow is procurement/delivery-adjacent (sibling to NCR which is already in ProcureX). Stubs retained for a future QA RFC to flesh out rather than rebuild from zero. |

Net effect of the config change:

- `ProjectTeam` added to `modules.core.tables`.
- `CommunicationProtocol` and `QASheet` added to `modules.procurex.tables`.
- `Checklist`/`ChecklistItem` were already in `modules.procurex.tables` — no edit needed.
- `schema-lint` R7 (orphan-table) goes from 3 warnings to 0.

### Follow-up surfaced during landing

While inspecting `QASheet` to verify the column-name flag from the RFC's "Risks", I found that V1.12 line 88 declares a foreign key on `QASheet.contractId` — a column that does not exist in the `QASheet` CREATE TABLE (V1.3–V1.11 only defines `qaSheetId, projectId, title, status`). The static schema parser silently accepts this, but `migration-test.sh` would fail at this statement under `ON_ERROR_STOP=1`. The handover's verification list did **not** include `migration-test.sh`, so this has been latent.

**Disposition**: this is independent of RFC 0001's module reassignment. It will be addressed as part of RFC 0002's V1.14 migration (adding `contractId` to `QASheet` and re-adding the FK there), keeping V1.12 immutable per Flyway convention.

## Approval

- [x] Schema Steward (2026-05-28)
- [ ] (No module owners assigned yet — Schema Steward signs off solo until owners are named.)
