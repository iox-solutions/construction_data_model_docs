# Polymorphic references in IOX

The pattern, where it's used, and how to keep it honest.

---

## The pattern

A small number of IOX tables reference *other tables* by name rather than by hard foreign key. They do this with two columns:

```sql
"entityType" TEXT NOT NULL,
"entityId"   TEXT NOT NULL
```

`entityType` is the string name of a table (e.g. `"Contract"`, `"BOQ"`). `entityId` is the primary-key value of a row in that table.

There is no FK constraint on `entityId`. The database will accept any string. Validity is enforced at the application layer.

## Why we do this

The pattern exists to avoid a class of design that would otherwise be required: 30+ nullable FK columns on a single audit or workflow table, one for each entity type that might be referenced, with a complex CHECK constraint asserting exactly one is non-null. That is technically correct, expensive to maintain, and brittle when new tables are added.

The trade-off: hard FKs guarantee referential integrity at the database level; polymorphic refs guarantee it at the application boundary or not at all. We accept the trade-off in narrow, well-defined places:

- **Cross-cutting infrastructure** that must reference *anything* (audit logs).
- **Generic workflow engines** that drive state machines over many entity types (workflow instances and transitions).

Anywhere else, use a real FK.

## Where it's used

Three tables, all in IOX Core:

| Table | Polymorphic columns | Reason |
|---|---|---|
| `AuditLog` | `entityType`, `entityId` | Records who-changed-what across every table. Hard FK would mean a column per entity. |
| `WorkflowInstance` | `entityType`, `entityId` | One workflow state machine drives many entity types (queries, transmittals, gates, etc.). |
| `WorkflowTransition` | (inherits via `workflowInstanceId`) | Transitively polymorphic — references whatever its parent instance references. |

**That's it.** If you find yourself reaching for `entityType + entityId` in a new table, the bar to cross is high. Open an RFC.

## How to keep polymorphic refs honest

### At the application boundary

Use the generated `EntityType` union from `@iox/types`:

```ts
import type { EntityType } from '@iox/types';

interface AuditLogInsert {
  userId: string;
  action: string;
  entityType: EntityType;  // <- not `string`
  entityId: string;
  oldValue?: unknown;
  newValue?: unknown;
}

function recordAudit(input: AuditLogInsert) {
  // TypeScript rejects entityType: 'NotARealTable' at compile time.
}
```

The compiler now enforces what the database does not.

### At the data boundary

For audit logs in particular, the `entityId` value can become stale: the referenced row might be deleted later. Two acceptable strategies:

- **Treat audit logs as historical.** Accept that an `entityId` may refer to a row that no longer exists. Don't try to resolve every audit entry to a live entity. Most reporting use cases don't need to.
- **Snapshot the row.** When `AuditLog.oldValue` / `newValue` capture the row contents, the audit entry is self-describing even if the referenced row is later deleted. This is the pattern the IOX `AuditLog` uses (`oldValue JSONB`, `newValue JSONB`).

For workflow refs, the underlying entity should *not* be deleted while a workflow is active. Enforce in the workflow service, not in the schema.

### At the runtime boundary (optional)

If you want belt-and-braces validation against `FOREIGN_KEYS` data at runtime — e.g. asserting that a polymorphic ref points to a table that exists and that the row is present:

```ts
import { TABLE_MODULES } from '@iox/types';

function isKnownEntityType(s: string): s is EntityType {
  return s in TABLE_MODULES;
}

async function resolvePolymorphicRef<T extends EntityType>(
  entityType: T,
  entityId: string,
  db: DB,
): Promise<unknown | null> {
  if (!isKnownEntityType(entityType)) return null;
  // Build a parameterised query targeting the right table.
  // This is OK *because* entityType is constrained to EntityType — no SQL injection surface.
  const result = await db.query(
    `SELECT * FROM "${entityType}" WHERE "${primaryKeyFor(entityType)}" = $1`,
    [entityId],
  );
  return result[0] ?? null;
}
```

(Computing the primary key column from the table name is straightforward — by convention it's `<camelCaseTableName>Id`. Generate a helper.)

## What polymorphic refs are NOT for

- **General-purpose attachments.** If you need to attach documents to many entity types, use a real join table per entity type (e.g. `QueryAttachment`, `TransmittalDocument`). The schema does this already.
- **One-to-many ownership.** If you have a parent that owns many children of different shapes, model each child with its own table and FK.
- **Skipping the schema review process.** "Just add `(entityType, entityId)`" is the kind of shortcut that calcifies. The RFC bar applies.

## Lint

There is no `schema-lint` rule for polymorphic refs as of v1.13. The pattern is detected by name (`entityType + entityId`) and reviewed manually. A future rule could enforce:

- New tables introducing the pattern require an RFC link in the migration comment.
- `entityType` columns must be paired with `entityId` (no orphan `entityType` without a matching `entityId`).

If that becomes useful, contribute it.

## Related

- `iox-types/src/generated.ts` — the `EntityType` union and `FOREIGN_KEYS` catalogue.
- `GOVERNANCE.md` — RFC process for introducing new polymorphic refs.
- `CLAUDE.md` — original design-decision note (#3).
