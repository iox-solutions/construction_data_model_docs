# RFC 0003 — Resolve cross-module FK violations

- **Status**: Draft
- **Author**: Schema Steward
- **Created**: 2026-05-28
- **Decision deadline**: TBD
- **Related**: schema-lint rule `R1: no-cross-module-fk`; [`GOVERNANCE.md`](../../GOVERNANCE.md) — The One Rule

## Summary

Two foreign keys in the schema violate The One Rule (no cross-module FKs except to a Core anchor). This RFC analyses each and proposes a resolution.

The violations:

1. **`CertifiedPaymentAllocation` (core) → `CertifiedPayment` (reportx)** via `fk_CertifiedPaymentAllocation_certifiedPaymentId`.
2. **`CostPlanElement` (core) → `CostPlanArea` (planx)** via `fk_CostPlanElement_costPlanAreaId`.

Both predate the standards layer. Each is independently resolvable.

## Motivation

The One Rule is the single architectural invariant of IOX. Letting two violations stand at v1.13 has three costs:

1. The lint rule emits errors that have to be either fixed or explicitly suppressed — a per-violation `// lint-ignore` comment is fine for one-off cases but undermines the rule if accumulated.
2. Modules can no longer evolve independently. If `reportx` wants to restructure `CertifiedPayment`, it must coordinate with Core. The whole point of the anchor pattern is to avoid this coupling.
3. Engineers building the first product consumer will (correctly) infer that the rule is negotiable, and the rule will not hold.

Fix both before v1.14.

## Detailed design

Both violations are fundamentally **module assignment errors**, not architectural ones. The tables involved are mis-labelled in `module-mapping.json`. Two options per violation; the recommendation is the same shape for both.

### Violation 1 — `CertifiedPaymentAllocation` → `CertifiedPayment`

Current ownership (per `module-mapping.json`):

- `CertifiedPaymentAllocation` → `core`
- `CertifiedPayment` → `reportx`

The Core-anchor pattern says cross-module FKs should terminate in Core. Here, the *Core* table is FKing to a *reportx* table — the wrong direction.

**Options**:

- **Option A — Move `CertifiedPayment` to Core.** Pro: aligns with `PaymentSchedule` / `PaymentScheduleItem` which are already in Core. Con: ReportX loses a "headline" table from its diagram.
- **Option B — Move `CertifiedPaymentAllocation` to ReportX.** Pro: keeps Core small, moves the join table next to its anchor. Con: requires that no existing Core consumer reads CertifiedPaymentAllocation without going through ReportX — likely fine, since reporting is the only consumer of payment allocations.

**Recommendation**: **Option A**. `CertifiedPayment` is payment-lifecycle data, conceptually peer to `PaymentSchedule`. ReportX is a reporting view *over* payments, not the owner of them. The mapping should reflect that.

Migration: pure config change in `module-mapping.json`. No SQL. Move `'CertifiedPayment'` from `modules.reportx.tables` to `modules.core.tables`. Update `connectionDescriptions` if any reference it directly.

### Violation 2 — `CostPlanElement` → `CostPlanArea`

Current ownership:

- `CostPlanElement` → `core`
- `CostPlanArea` → `planx`

**Options**:

- **Option A — Move `CostPlanArea` to Core.** Pro: `CostPlanElement` is firmly in Core (it's the detail under `CostPlan`). Pulling `CostPlanArea` into Core aligns the two. Con: PlanX (which currently only contains `CostPlanArea`) becomes empty — and was already nearly empty.
- **Option B — Move `CostPlanElement` to PlanX.** Pro: PlanX gains substance, becomes the home of cost-plan structure. Con: existing Core consumers (parametrix references CostPlan, which has CostPlanElements) now reach into PlanX — but they go through `CostPlan` (the Core anchor), so this is technically fine.

**Recommendation**: **Option B**. PlanX's whole purpose is to own cost-plan structure (per `module-mapping.json`: "Cost plan elemental breakdown structure"). Putting *all* cost-plan-structure tables there (both `CostPlanArea` and `CostPlanElement`) is the conceptually clean answer. Core retains the `CostPlan` anchor; PlanX owns the breakdown.

Migration: pure config change. Move `'CostPlanElement'` from `modules.core.tables` to `modules.planx.tables`. Update `connectionDescriptions["core.CostPlanElement:planx"]` — that entry already exists, recognising the relationship; it should change direction.

### Lint consequence

Once `module-mapping.json` is updated:

```bash
node tools/schema-lint.mjs
# Expected: rule R1 ERROR count drops from 2 to 0.
```

If it doesn't, the wrong direction was applied; re-check.

## Consumers affected

- `module-mapping.json`.
- The business architecture diagram (regenerate via `node scripts/generate_business_diagram.js`).
- `@iox/types` `TABLE_MODULES` map (regenerate via `node tools/generate-types.mjs`).
- `docs/MODULES.md` (regenerate via `node tools/generate-modules-doc.mjs`).
- No SQL change; no production consumer.

## Migration path

No deprecation window required — this is reclassification, not a schema change. The migration is:

1. Edit `schema/clustering/module-mapping.json`:
   - Move `CertifiedPayment` from `reportx.tables` to `core.tables`.
   - Move `CostPlanElement` from `core.tables` to `planx.tables`.
2. Update `connectionDescriptions` if labels reference the moved tables.
3. Run all regenerators (`npm run generate`).
4. Verify `npm run lint` reports 0 errors for rule R1.
5. CHANGELOG: Behavioral — module reassignment, no SQL change.

## Alternatives considered

- **Suppress the lint rule for these two FKs with explicit annotations.** Rejected — encodes the violation as canonical rather than fixing it. The whole point of the rule is to make exceptions visible; making them invisible defeats the purpose.
- **Rewrite the FKs to route through a Core anchor.** E.g., add `costPlanId` to `CostPlanElement` and remove `costPlanAreaId`. This is more invasive and changes the data model semantics — `CostPlanElement` *does* belong to a `CostPlanArea` conceptually. Better to acknowledge the relationship and move the tables.
- **Accept the violations as documented exceptions.** Rejected — the schema-lint rule is the One Rule, and exceptions break the contract with consumers.

## Risks and unresolved questions

- Reassigning `CertifiedPayment` removes a "headline" table from ReportX. Confirm ReportX is still meaningful with `EarlyWarning`, `VariationOrder`, and the reporting views. Likely yes — those are what ReportX actually *adds* over Core. CertifiedPayment is base data.
- The recommended Option B for violation 2 moves `CostPlanElement` to PlanX. Verify no cross-module FK to `CostPlanElement` from another non-core module — schema-lint will catch this. Spot-check `ParametricEstimate` references CostPlan (the anchor), not CostPlanElement.
- After Option B, PlanX has two tables (`CostPlanArea`, `CostPlanElement`). That's still small, and is honest about PlanX's scope. Adding more before a consumer exists is premature.

## Approval

- [ ] Schema Steward
- [ ] (Future: ReportX owner and PlanX owner once named)
