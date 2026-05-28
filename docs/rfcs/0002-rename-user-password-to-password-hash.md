# RFC 0002 — Rename `User.password` → `User.passwordHash`

- **Status**: Accepted (with waiver)
- **Author**: Schema Steward
- **Created**: 2026-05-28
- **Decided**: 2026-05-28
- **Related**: schema-lint rule `R6: password-plaintext`

## Summary

Rename the `password` column on the `User` table to `passwordHash`, and document the hashing contract in a `COMMENT ON COLUMN`. This is a Breaking change under [`GOVERNANCE.md`](../../GOVERNANCE.md) and follows the standard deprecation flow.

## Motivation

A column literally named `password` is a footgun for three reasons:

1. **Implementation drift.** A column named `password` makes it ambiguous whether the value is a plaintext password, a hash, or a token. A future engineer reading the schema cannot tell. The current seed data writes hash-like strings, but nothing in the schema enforces or documents that.
2. **Audit trail leakage.** `AuditLog` records `oldValue` and `newValue` as JSONB. If an auth handler ever writes a `User` update where `password` is captured by the audit trigger, the audit log contains the secret in a queryable column. Renaming to `passwordHash` makes the convention enforceable at the application layer; documenting it as "never include in audit payloads" is then a single rule with a memorable column name.
3. **Reviewer signal.** A column named `password` shows up in `git grep password` searches — most of those hits will be application code, but the schema reference becomes noise. `passwordHash` is greppable and specific.

The cost is low: `User` is referenced widely by FKs but only one column is being renamed, and no production consumer exists today.

## Detailed design

### Schema changes

```sql
-- V1.14__rename_user_password_to_password_hash.sql

ALTER TABLE "User" RENAME COLUMN "password" TO "passwordHash";

COMMENT ON COLUMN "User"."passwordHash" IS
  'Argon2id hash of the user password. NEVER store plaintext. NEVER include in AuditLog payloads.';
```

### Deprecation window — N/A

`GOVERNANCE.md` requires Breaking changes to ship the new symbol alongside the old for at least one Core minor before removal. **This RFC requests a waiver of the deprecation window** because:

- No production consumer exists.
- The seed data is the only writer; a single seed update covers it.
- Maintaining a generated column `password AS passwordHash` for one minor adds noise without protecting anyone.

Waiver requires explicit Schema Steward sign-off in this RFC. If declined, the alternative is:

```sql
-- V1.14a (with deprecation): add passwordHash as a generated column for one minor.
ALTER TABLE "User" ADD COLUMN "passwordHash" TEXT GENERATED ALWAYS AS ("password") STORED;
COMMENT ON COLUMN "User"."password" IS
  'DEPRECATED: use passwordHash. Removed in Core v1.15. See RFC 0002.';
-- V1.15: drop "password".
```

### Tooling impact

- `tools/schema-lint.mjs` rule `R6` is satisfied by the rename. Keep the rule active — it protects against regressions.
- `iox-types/src/generated.ts` regenerates with `passwordHash: string`. `User.password` disappears from the generated type.
- `schema/seed/seed_data.sql` — update the `INSERT INTO "User"` block; column rename only.
- `iox-types/src/smoke-test.ts` — currently references `user.password`. Update.

## Consumers affected

- `@iox/types` — type changes (see above).
- Seed data — one INSERT statement updated.
- Any application code (none yet) writing to `User.password` directly — must switch to `passwordHash`.

## Migration path (if waiver is granted)

1. Land V1.14 SQL.
2. Update `seed_data.sql`.
3. Regenerate `@iox/types`.
4. Update `iox-types/src/smoke-test.ts`.
5. CHANGELOG: Breaking — `User.password` renamed to `User.passwordHash`. Reason: documented hashing contract, audit-log safety.

## Alternatives considered

- **Keep `password`, add a `COMMENT ON COLUMN` explaining it's a hash.** Rejected — comments do not survive code review of application code; the column name does.
- **Move auth out of the schema entirely (delegate to Entra ID).** Plausible long-term direction (CLAUDE.md flags Entra ID as a near-term step). This RFC does not preclude it; it just stops storing the value under a misleading name in the interim.
- **Rename to `secret` or `credential`.** Less specific. Rejected.

## Risks and unresolved questions

- Confirm there is no production database to migrate. If there is, the `ALTER TABLE RENAME COLUMN` is fast but invalidates any prepared statements referencing `password`.
- Confirm seed data does not have orchestration scripts that reference the old column name. Audit `scripts/apply_seed_data.sh` before merge.
- Decide whether the column should be `NOT NULL` once a real auth flow exists. Out of scope here.

## Decision (2026-05-28)

Schema Steward **accepted** the RFC and **granted** the deprecation-window waiver. Greenfield deployment confirmed (no production database). V1.14 ships the single ALTER TABLE RENAME COLUMN + COMMENT ON COLUMN, no generated-column shim.

### Scope expansion during landing

While running `migration-test.sh` (which was **not** part of the original v1.13 verification list — only the static parsers were), three pre-existing broken FK declarations in V1.12 surfaced. All three follow the same pattern: V1.12 declares an FK against a column the original CREATE TABLE did not include. Each fails `psql -v ON_ERROR_STOP=1` and prevents migration-test from running to completion. The static parser silently accepted them.

| Constraint | Missing source column |
|---|---|
| `fk_QASheet_contractId` | `QASheet.contractId` |
| `fk_BOQ_createdById` | `BOQ.createdById` |
| `fk_Query_assignedToId` | `Query.assignedToId` |

Bundled into V1.14 alongside the password rename: the broken declarations removed from V1.12, the three columns + FKs + indexes added in V1.14. End-to-end `migration-test.sh` now passes (84 tables, 139 FKs, seed loads).

### Tooling change

The shared SQL parser (`tools/parse-schema.mjs`) was extended to handle `ALTER TABLE … ADD COLUMN` and `ALTER TABLE … RENAME COLUMN`. The original parser only handled CREATE TABLE / CREATE INDEX / CREATE VIEW / ALTER TABLE ADD CONSTRAINT FK / COMMENT ON TABLE, so V1.14's ALTERs would otherwise have been invisible to `generate-types` and `schema-lint`.

## Approval

- [x] Schema Steward — waiver granted (2026-05-28)
- [ ] (No module owners assigned)
