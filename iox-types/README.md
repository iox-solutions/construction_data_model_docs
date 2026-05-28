# @iox/types

Auto-generated TypeScript types for every IOX schema table, plus module ownership and foreign-key metadata.

The contents of `src/generated.ts` are produced from the migration SQL — **do not hand-edit**. Re-generate after any schema change:

```bash
node tools/generate-types.mjs
```

## What you get

- `interface <TableName>` for every table — column → TS type, with `| null` on nullable columns.
- `type EntityType` — union of every table name. Use this for polymorphic refs (`WorkflowInstance.entityType`, `AuditLog.entityType`).
- `type Module` — union of module keys (`core`, `parametrix`, `procurex`, ...).
- `TABLE_MODULES` — runtime map from table name to owning module.
- `FOREIGN_KEYS` — runtime FK catalogue. Useful for runtime validation of polymorphic refs.
- `CORE_ANCHORS` — `['CostPlan', 'Project', 'Contract']`.
- `SCHEMA_STATS` — table / FK counts and generation date.

## Type-mapping conventions

| Postgres | TypeScript | Notes |
|---|---|---|
| `TEXT`, `VARCHAR`, `UUID` | `string` | |
| `INTEGER`, `SMALLINT`, `BIGINT` | `number` | `BIGINT` is unsafe past 2^53 — consider a custom type parser. |
| `DECIMAL`, `NUMERIC` | `string` | `pg-node` returns these as strings. Parse at the boundary. |
| `BOOLEAN` | `boolean` | |
| `TIMESTAMP`, `DATE` | `Date` | The default `pg` driver returns strings — install a type parser or cast at the boundary. |
| `JSON`, `JSONB` | `unknown` | Narrow with a runtime schema validator (zod, valibot) at the boundary. |
| `TEXT[]` | `string[]` | |

## Example

```ts
import type { Project, Contract, EntityType } from '@iox/types';
import { CORE_ANCHORS, FOREIGN_KEYS } from '@iox/types';

function describeProject(p: Project): string {
  return `${p.number} ${p.name}`;
}

// Polymorphic ref: enforce that entityType is a real table name.
function logAudit(entityType: EntityType, entityId: string) { /* ... */ }
```

## Consumption

This package is currently consumed via the workspace path (`@iox/types`).
A future RFC will move it to a private npm registry — see `GOVERNANCE.md`.
