# IOX deployment guide

Production / staging deployment to Azure PostgreSQL Flexible Server.

For local development use `docker compose up -d` — see [`LOCAL_DEV.md`](./LOCAL_DEV.md).

---

## Prerequisites

- Azure subscription with PostgreSQL Flexible Server permissions
- `psql` client (host install or via Docker)
- Docker (only for `scripts/generate_docs.sh` SchemaSpy output)

---

## 1. Provision the server

Create an **Azure Database for PostgreSQL — Flexible Server**:

| Setting | Value |
|---|---|
| Server name | `iox-server` (or your choice) |
| PostgreSQL version | 14 or later (production schema is tested against 18) |
| Tier | Burstable or General Purpose, depending on load |
| Storage | 32+ GB |
| Admin username | `dbadmin` |
| Auth | Password or Entra ID (recommended) |

Add your deploying machine's IP to **Networking → Firewall rules**.

Server FQDN: `iox-server.postgres.database.azure.com`.

---

## 2. Create the database

```bash
psql -h iox-server.postgres.database.azure.com \
     -U dbadmin@iox-server \
     -d postgres \
     -c 'CREATE DATABASE iox_dev;'
```

---

## 3. Apply migrations

Set environment variables:

```bash
export PG_HOST="iox-server.postgres.database.azure.com"
export PG_DB="iox_dev"
export PG_USER="dbadmin@iox-server"
export PG_PASSWORD="<your-password>"
```

Then either run the helper script:

```bash
bash scripts/apply_migrations.sh
```

…or use Flyway:

```bash
flyway -url=jdbc:postgresql://${PG_HOST}:5432/${PG_DB} \
       -user=${PG_USER} -password=${PG_PASSWORD} \
       -locations=filesystem:schema/migrations/iox-core,filesystem:schema/migrations/parametrix \
       migrate
```

…or psql directly, in strict version order:

```bash
psql -h $PG_HOST -U $PG_USER -d $PG_DB \
  -f schema/migrations/iox-core/V1.0__iox_core_project_contract.sql \
  -f schema/migrations/iox-core/V1.1__iox_core_identity_access.sql \
  -f schema/migrations/iox-core/V1.2__iox_core_organisation_project.sql \
  -f schema/migrations/iox-core/V1.3_to_V1.11__iox_core_remaining_segments.sql \
  -f schema/migrations/iox-core/V1.12__iox_core_extensions_and_foreign_keys.sql \
  -f schema/migrations/iox-core/V1.13__iox_core_schema_completion.sql \
  -f schema/migrations/parametrix/V0.1_to_V0.6__parametrix_parametric_estimation.sql
```

**Order is mandatory.** Migrations include retroactive FKs (V1.1, V1.12) and will fail if applied out of sequence.

---

## 4. Load seed data (optional)

The Southgate Business Park scenario — 3 organisations, 6 users, 1 project, contract, budgets, cost plans, BOQ structures, documents, meetings, action items, parametric estimates.

```bash
psql -h $PG_HOST -U $PG_USER -d $PG_DB -f schema/seed/seed_data.sql
```

Skip in production.

---

## 5. Verify

```bash
psql -h $PG_HOST -U $PG_USER -d $PG_DB <<'SQL'
SELECT 'base tables' AS metric,
       COUNT(*)      AS actual,
       84            AS expected
  FROM information_schema.tables
 WHERE table_schema='public' AND table_type='BASE TABLE'
UNION ALL
SELECT 'views', COUNT(*), 6
  FROM information_schema.views WHERE table_schema='public'
UNION ALL
SELECT 'foreign keys (≥120 expected)', COUNT(*), 120
  FROM information_schema.table_constraints
 WHERE constraint_type='FOREIGN KEY' AND constraint_schema='public';
SQL
```

Also check a materialized-style view is queryable:

```bash
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c 'SELECT * FROM "ProjectSummary" LIMIT 1;'
```

---

## 6. Generate schema documentation

Requires Docker.

```bash
bash scripts/generate_docs.sh
```

Output: `docs/schema-html/` — SchemaSpy ERD diagrams, table pages, XML export.

The XML is the input to `scripts/generate_business_diagram.js`, which produces the management-friendly lifecycle diagram at `docs/schema-html/business-architecture.html`.

---

## Troubleshooting

### Connection refused / firewall
Add your IP to the Azure PostgreSQL **Networking → Firewall rules**. The error is reported by libpq as a timeout.

### Migration FK errors
Migrations were applied out of order. Drop the database and re-apply from `V1.0` — or run `bash tools/migration-test.sh` locally first to confirm the migration set is healthy.

### Missing views or functions
`V1.13` failed. Inspect the psql output of that migration — usually a CTE column name mismatch from a partial earlier migration.

### Seed data load fails
Almost always a FK reference to an entity that wasn't inserted earlier. The seed file is order-sensitive. Re-run with `psql -v ON_ERROR_STOP=1` to halt on the first failure and find the offending row.

---

## References

- [Flyway documentation](https://flywaydb.org/documentation) — migration naming convention.
- [SchemaSpy](https://schemaspy.org) — ERD generation.
- [`MIGRATION_MANIFEST.md`](../MIGRATION_MANIFEST.md) — per-migration entity catalogue.
