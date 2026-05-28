# IOX Construction Data Model — Project Guide

## Project Overview

Building the foundational data model for **IOX**, a platform for construction project cost management, procurement, and delivery. The data model spans 6 product modules (ParametriX, ProcureX, PlanX, ReportX, PlaceholderX) built on a shared IOX Core.

**Status**: Schema complete (v1.0–1.13 + ParametriX v0.1–v0.6). Focus is now on documentation, visualization, and seed data.

---

## Architecture

### Technology Stack
- **Database**: PostgreSQL 18.3 on Azure Database for Flexible Server (Entra ID auth)
- **Migrations**: Flyway convention (V1.0, V1.1, ..., V1.13, ParametriX V0.1–V0.6)
- **Documentation**: SchemaSpy 7.0.2 (via Docker) → HTML ERD diagrams
- **Visualization**: Custom Node.js generator → business architecture diagram (HTML/CSS, no JS)
- **Seed data**: Realistic construction project scenarios (Southgate Business Park)

### Data Model Structure

**IOX Core (16 base tables + 6 materialized views)**
- Shared foundation: Organization, Project, Contract, Budget, CostPlan, etc.
- Three primary anchor tables: **CostPlan**, **Project**, **Contract**
- All other modules reference these three anchors

**6 Product Modules** (lifecycle flow: Pre-Design → Design → Tender → Delivery)

| Module | Phase | Tables | Purpose |
|--------|-------|--------|---------|
| **ParametriX** | Pre-Design | 14 | Parametric cost modelling, sensitivity analysis, calibration |
| **PlanX** | Design Development | 1 | Cost plan elemental breakdown structure |
| **ProcureX** | Tender & Procurement | 37 | Tender gates, BOQs, queries, meetings, documents, NCRs, work orders |
| **ReportX** | Contract Delivery | 10 | Certified payments, variations, early warnings, financial dashboards |
| **PlaceholderX** | (Future) | 0 | Rate & benchmark data management — *coming soon* |

**Orphaned Tables** (not yet assigned): CommunicationProtocol, ProjectTeam, QASheet

---

## Schema Statistics

| Metric | Count |
|--------|-------|
| Base tables | 84 |
| Materialized views | 6 |
| Total FK constraints | ~95 |
| Total indexes | 150+ |
| Cross-module FK connections | 25 (all through Core anchors) |
| Intra-module FKs | 54 |

---

## Key Design Decisions

### 1. All Business Concepts in Config, Not Code
**Decision**: Module capabilities, lifecycle order, phase labels, connection descriptions, and core anchors all live in `schema/clustering/module-mapping.json`.

**Why**: Future data model changes are reflected in the diagram without touching the generator script. Config drift is prevented; the diagram is always in sync with the JSON.

**Implementation**:
```json
{
  "lifecycle": ["parametrix", "planx", "procurex", "reportx"],
  "coreAnchors": ["CostPlan", "Project", "Contract"],
  "modules": {
    "parametrix": {
      "label": "ParametriX",
      "phase": "Pre-Design",
      "capabilities": ["Build parametric...", ...],
      "tables": [...]
    }
  }
}
```

### 2. Immutable Audit Patterns
All versioning tables (`BudgetVersion`, `CostPlanVersion`, `BOQVersion`, `DocumentVersion`) and `AuditLog` are immutable — no updates or deletes after creation. Ensures a complete audit trail.

### 3. Polymorphic References (entityType + entityId)
WorkflowInstance/WorkflowTransition and AuditLog use `(entityType, entityId)` pairs instead of hard FK constraints. Avoids circular dependencies; handled at application layer.

### 4. PII Flagging
All PII fields are documented in schema comments:
- **High sensitivity**: User.email, firstName, lastName, phone, avatar
- **Medium**: AuditLog.ipAddress, userAgent
- **Contextual**: Transmittal.recipientEmail, TenderQuery.raisedByEmail, NCR.raisedByEmail

### 5. JSON Columns for Flexibility
`NoticeOfWin.projectBrief`, `AuditLog.oldValue/newValue`, `BudgetVersion.snapshot`, etc. use JSON for variable structures without schema migration overhead.

### 6. Scope-Qualified Roles (UserRole Pattern)
Three scoping modes:
- `organizationId = NULL, projectId = NULL` → Global scope
- `organizationId ≠ NULL, projectId = NULL` → Org scope
- `organizationId = NULL, projectId ≠ NULL` → Project scope

---

## File Structure

```
IOX/construction_data_model_docs/
├── CLAUDE.md                          ← This file
├── README.md                          ← Deployment guide (Azure, SchemaSpy, seed data)
├── MIGRATION_MANIFEST.md              ← Schema version history + entity catalogue
├── schema/
│   ├── migrations/
│   │   ├── iox-core/
│   │   │   ├── V1.0__iox_core_project_contract.sql
│   │   │   ├── V1.1__iox_core_identity_access.sql
│   │   │   ├── ... (V1.2 through V1.13)
│   │   └── parametrix/
│   │       └── V0.1_to_V0.6__parametrix_parametric_estimation.sql
│   ├── clustering/
│   │   └── module-mapping.json        ← Business config: lifecycle, capabilities, connections
│   └── seed/
│       └── seed_data.sql              ← Realistic construction project scenario
├── scripts/
│   ├── apply_migrations.sh            ← Deploy all migrations to Azure PostgreSQL
│   ├── generate_docs.sh               ← Run SchemaSpy → HTML ERD docs
│   └── generate_business_diagram.js   ← Generate business architecture visualization
└── docs/
    └── schema-html/
        ├── index.html                 ← SchemaSpy main index
        ├── tables/                    ← SchemaSpy table pages
        ├── business-architecture.html ← Management-friendly lifecycle diagram
        └── iox_datamodel.public.xml   ← SchemaSpy XML (source for diagram generator)
```

---

## Common Workflows

### 1. Deploy to Azure PostgreSQL

**Prerequisites**: Azure PostgreSQL Flexible Server provisioned with Entra ID auth.

```bash
export PG_HOST="iox-server.postgres.database.azure.com"
export PG_DB="iox_dev"
export PG_USER="dbadmin@iox-server"
export PG_PASSWORD="<your-password>"

bash scripts/apply_migrations.sh
```

**Verify**:
```bash
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';"
# Expected: 84
```

### 2. Load Seed Data

```bash
psql -h $PG_HOST -U $PG_USER -d $PG_DB -f schema/seed/seed_data.sql
```

**Verify**:
```bash
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c "SELECT COUNT(*) FROM \"User\";"
# Expected: 6
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c "SELECT COUNT(*) FROM \"Project\";"
# Expected: 1 (Southgate Business Park)
```

### 3. Generate Schema Documentation

```bash
bash scripts/generate_docs.sh
```

Opens a Docker SchemaSpy container, connects to Azure PostgreSQL, and outputs:
- `docs/schema-html/index.html` — main index with entity-relationship diagrams
- `docs/schema-html/iox_datamodel.public.xml` — structured metadata

### 4. Update Business Architecture Diagram

After changing `schema/clustering/module-mapping.json`:

```bash
node scripts/generate_business_diagram.js
```

Outputs: `docs/schema-html/business-architecture.html`

The diagram shows:
- 4 lifecycle modules with capabilities (no table names)
- Vertical connectors to Core anchor tables
- Full-width Core foundation band
- Collapsible technical reference with FK trees
- Management-friendly, printable format

### 5. Add a New Module or Table

1. **Update `module-mapping.json`**:
   - Add module entry (or add table to existing module)
   - If new module, add to `"lifecycle"` array in correct order
   - Add `"phase"`, `"capabilities"` if new module
   - Add connection descriptions in `"connectionDescriptions"`

2. **Create migration SQL**:
   - File: `schema/migrations/<module>/V<next>__<description>.sql`
   - Follow Flyway naming: `V1.14__iox_core_new_feature.sql`
   - No destructive operations (no DROP, no ALTER that breaks compatibility)

3. **Update MIGRATION_MANIFEST.md**:
   - Document new entity definitions
   - Update schema statistics table
   - Explain any new design decisions

4. **Test locally, then deploy**:
   ```bash
   bash scripts/apply_migrations.sh
   bash scripts/generate_docs.sh
   node scripts/generate_business_diagram.js
   ```

---

## Data Model Concepts

### Anchor Tables (3)

**CostPlan**: Budget breakdown for a project — evolves through design phases.
- Connected by: ParametriX (estimates), PlanX (structure), ProcureX (VE assessment)
- Supports: versioning (CostPlanVersion), elemental breakdown (CostPlanElement), detailed items

**Project**: The construction project itself — parent for all activities.
- Connected by: ProcureX (meetings, documents, actions, drawings, transmittals)
- Supports: team assignment, communication protocols, award capture (NoticeOfWin)

**Contract**: Legal agreement with a contractor — scope of work and payment terms.
- Connected by: ProcureX (gates, BOQs, queries, risks, assumptions, NCRs, addenda, work orders), ReportX (certified payments, variations, early warnings)
- Supports: stages, budget, payment schedule, variation tracking

### Supporting Objects (13 others in Core)

Budget, BudgetVersion, PaymentSchedule, PaymentScheduleItem, CertifiedPaymentAllocation, CostPlanVersion, CostPlanElement, Organization, Department, Client, Contractor, ContractStage, BenchmarkProject

### Connection Patterns

All cross-module connections flow **through Core anchors**. No module-to-module direct FKs — maintains decoupling and allows modules to evolve independently.

Example: ProcureX → ProcureX → Project (Core anchor) ← ParametriX doesn't happen. Instead:
- ProcureX tables FK to Project (in Core)
- Project is shared across all modules
- Modules see Project as the common reference

---

## How to Interpret Schema Changes

### When SchemaSpy XML Changes
The `iox_datamodel.public.xml` is regenerated by `generate_docs.sh` and reflects the live database. If FK relationships or tables change in the schema:

1. FK tree structure changes → collapsible technical reference auto-updates
2. New cross-module connections detected → diagram auto-updates (if the module is in `module-mapping.json`)
3. Unassigned tables → appear in the "Not yet assigned" section

### When module-mapping.json Changes
All derived concepts update:
- Lifecycle order → module card order changes
- Capabilities → bullets in module card update
- Phase label → lifecycle stage label updates
- Connection descriptions → connector labels and tooltips update
- Core anchors → which tables are featured in Core band
- Table assignments → which module a table belongs to

### Adding vs. Updating
- **New table in schema**: Add to `module-mapping.json` and regenerate diagram
- **Change capability bullet**: Update JSON and regenerate
- **Rename phase**: Update JSON and regenerate
- **Rename module**: Update JSON, update migration files if needed, regenerate
- **Change connection description**: Update `connectionDescriptions` in JSON and regenerate

---

## Troubleshooting

### SchemaSpy fails to connect
- Verify Azure PostgreSQL firewall allows your IP
- Check `$PG_HOST`, `$PG_USER`, `$PG_PASSWORD` are set correctly
- Ensure database `$PG_DB` exists: `psql -h $PG_HOST -U $PG_USER -d postgres -c "CREATE DATABASE iox_dev;"`

### Migrations fail with FK constraint errors
- Ensure migrations are applied in exact version order (V1.0 → V1.13 → ParametriX)
- Check that tables referenced in new FKs already exist from earlier migrations
- Don't skip migrations

### Diagram shows incomplete module tree
- Verify FK relationships in XML are detected (check `iox_datamodel.public.xml`)
- Confirm table is in `module-mapping.json` under correct module
- Regenerate diagram: `node scripts/generate_business_diagram.js`

### Seed data load fails
- Check column names and types against actual schema
- Ensure all FK references exist (dependencies must be inserted in order)
- View error message for exact column mismatch
- Fix `schema/seed/seed_data.sql` and retry

---

## External Resources

- **Notion Data Dictionary**: [Add link if you have one]
- **Azure Portal**: https://portal.azure.com → Azure Database for PostgreSQL
- **SchemaSpy**: www.schemaspy.org (documentation)
- **Flyway**: https://flywaydb.org/documentation (migration naming convention)

---

## Next Steps / Current Blockers

- [ ] Review business architecture diagram with stakeholders
- [ ] Finalize module capabilities wording (currently placeholder-driven)
- [ ] Resolve orphaned tables (CommunicationProtocol, ProjectTeam, QASheet) — assign to modules or mark as system
- [ ] Build application layer ORM/query layer (models, validators, relationships)
- [ ] Implement Entra ID integration for user authentication
- [ ] Set up CI/CD pipeline for migration testing and deployment

---

## Session Initialization

Each CLI session will load:
1. This file (`CLAUDE.md`) for project context
2. Memory files from `.claude/projects/.../memory/` for:
   - User role and preferences
   - Project status and blockers
   - Feedback patterns and lessons learned
   - External system references
3. Current git state (branch, recent commits, uncommitted changes)
4. Task list (if any in-progress work)

Ask me at the start of any session: *"What's the status of the IOX project?"* and I'll recap what I know and what blockers exist.
