## Quick Start

### Prerequisites
- PostgreSQL 12+
- Flyway CLI or equivalent migration tool

### Apply Migrations

```bash
# Using Flyway
flyway -url=jdbc:postgresql://localhost:5432/iox_dev \
       -user=postgres \
       -password=yourpassword \
       -locations=filesystem:schema/migrations/iox-core \
       migrate

# Then apply ParametriX (optional)
flyway -url=jdbc:postgresql://localhost:5432/iox_dev \
       -user=postgres \
       -password=yourpassword \
       -locations=filesystem:schema/migrations/parametrix \
       migrate
```

### Using PostgreSQL psql directly

```bash
# Connect to database
psql -U postgres -d iox_dev

# Apply IOX Core migrations in order
\i schema/migrations/iox-core/V1.0__iox_core_project_contract.sql
\i schema/migrations/iox-core/V1.1__iox_core_identity_access.sql
\i schema/migrations/iox-core/V1.2__iox_core_organisation_project.sql
\i schema/migrations/iox-core/V1.3_to_V1.11__iox_core_remaining_segments.sql
\i schema/migrations/iox-core/V1.12__iox_core_extensions_and_foreign_keys.sql
\i schema/migrations/iox-core/V1.13__iox_core_schema_completion.sql

# Apply ParametriX (optional)
\i schema/migrations/parametrix/V0.1_to_V0.6__parametrix_parametric_estimation.sql
```

## Schema Overview

### IOX Core (70 base tables + 6 materialized views across 12 functional segments)

| Segment | Entities | Version |
|---------|----------|---------|
| Identity & Access | 7 | v1.1 |
| Organisation & Project | 5 | v1.2 |
| Meetings & Actions | 5 | v1.3 |
| Documents & Transmittals | 6 | v1.4 |
| Cost Plan (detail) | 4 | v1.5 |
| BOQ & Procurement | 7 | v1.6 |
| QA | 3 | v1.7 |
| Queries | 3 | v1.8 |
| Tender & Gates | 7 | v1.9 |
| Workflow & Templates | 4 | v1.10 |
| Support & Governance | 4 | v1.11 |
| Core Entities (Project & Contract) | 15 | v1.0 |

### ParametriX (14 tables)

- Parametric cost modeling
- Parameter management and calibration
- Estimate generation and sensitivity analysis
- Risk adjustment tracking

## Migration Order

**MUST be applied in version order due to foreign key dependencies:**

1. V1.0 — Contract baseline
2. V1.1 — Identity & Access (adds FKs back to v1.0)
3. V1.2 — Organisation & Project
4. V1.3–V1.11 — All remaining segments
5. V1.12 — Extensions & FK completion
6. V1.13 — Indexes, views, utility functions
7. V0.1–V0.6 — ParametriX (optional)

## Key Features

✅ **Immutable audit patterns** (AuditLog, DocumentVersion, BOQVersion, etc.)  
✅ **PII-flagged columns** (email, phone, ipAddress, etc.)  
✅ **150+ performance indexes** for query optimization  
✅ **6 materialized views** for reporting  
✅ **Polymorphic reference patterns** (entityType + entityId)  
✅ **Scope-qualified role assignment** (global/org/project)  
✅ **JSON columns** for flexible, schema-agnostic storage  

## Documentation

For complete details, see **MIGRATION_MANIFEST.md** which includes:
- Full entity descriptions and relationships
- Foreign key mapping
- Index strategy
- View definitions
- Utility functions
- Migration verification steps

## Troubleshooting

### Foreign Key Constraint Errors
Ensure migrations are applied in exact version order. Earlier versions must be fully applied before later ones.

### Missing Views or Functions
If views or functions fail to create, verify that V1.13 was applied successfully. It depends on all earlier migrations being complete.

### Duplicate Key Errors on Insert
Some tables have UNIQUE constraints (e.g., `(contractId, number)` on Contract). Verify input data doesn't violate these constraints before bulk insertion.

---

## Azure PostgreSQL Deployment

### Prerequisites
- Azure subscription with PostgreSQL permissions
- Azure Portal access
- `psql` client installed locally (or via Docker)
- Docker installed (for schema documentation generation)

### Step 1: Create Azure PostgreSQL Flexible Server

1. Go to [Azure Portal](https://portal.azure.com)
2. Create a new **Azure Database for PostgreSQL — Flexible Server**
3. Configure:
   - **Server name:** `iox-server` (or your choice)
   - **Admin username:** `dbadmin`
   - **Password:** Choose a strong password
   - **PostgreSQL version:** 14 or later
   - **Tier:** Burstable or General Purpose (depending on load)
   - **Storage:** 32+ GB
4. Go to **Networking** and add your IP to the firewall rules
5. Note your server details:
   - Server name (FQDN): `iox-server.postgres.database.azure.com`
   - Admin user: `dbadmin@iox-server`

### Step 2: Create the Database

```bash
# Connect to the master database
psql -h iox-server.postgres.database.azure.com \
     -U dbadmin@iox-server \
     -d postgres

# Inside psql:
CREATE DATABASE iox_dev;
\q
```

### Step 3: Apply Migrations

```bash
# Set environment variables with your Azure credentials
export PG_HOST="iox-server.postgres.database.azure.com"
export PG_DB="iox_dev"
export PG_USER="dbadmin@iox-server"
export PG_PASSWORD="YourSecurePassword!"

# Run the migration script
bash scripts/apply_migrations.sh
```

The script will:
- Verify the connection
- Apply all 7 migrations in strict dependency order (V1.0 → V1.13 + ParametriX)
- Display verification statistics

### Step 4: Load Seed Data (Optional)

```bash
# Apply realistic construction project sample data
psql -h $PG_HOST \
     -U $PG_USER \
     -d $PG_DB \
     -f schema/seed/seed_data.sql
```

This populates:
- 3 Organizations (developer, contractor, QS consultant)
- 6 Users with roles and permissions
- 1 Project: Southgate Business Park
- Contract, budgets, cost plans, BOQ structures
- Documents, meetings, action items
- Risk items and parametric cost estimates

### Step 5: Generate Schema Documentation

```bash
# Generate HTML documentation with ERD diagrams
bash scripts/generate_docs.sh
```

This creates `docs/schema-html/index.html` with:
- Entity-Relationship Diagrams per domain segment
- Complete table definitions, column types, and constraints
- Foreign key relationships and index details
- Searchable reference

**Note:** Requires Docker. Open the HTML file in a browser to view the documentation.

### Verification

After deployment, verify the schema:

```bash
# Check base tables (expected: 84)
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';"

# Check materialized views (expected: 6)
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'VIEW';"

# Check foreign keys (expected: ~95)
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c "SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY';"

# Verify views are accessible
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c "SELECT * FROM \"ProjectSummary\" LIMIT 1;"
```

---

## Support

- Refer to MIGRATION_MANIFEST.md for detailed documentation
- Check Notion Data Model Hub for entity specifications and decisions
- Review Changelog in Notion for breaking changes between versions
