<!-- IOX Data Model — PostgreSQL Migration Files Manifest -->

# IOX Core & ParametriX — PostgreSQL Schema Migrations

**Schema Version:** IOX Core v1.13 + ParametriX v0.6  
**Created:** 2026-04-30  
**Total Migrations:** 6 files (IOX Core) + 1 file (ParametriX) + 1 file (Finalization)

---

## Migration Files (Flyway Convention)

All files follow Flyway naming convention: `V[version]__[description].sql`

### IOX Core Migrations

#### **V1.0__iox_core_project_contract.sql**
**Segment:** Project & Contract  
**Release Date:** 2026-03-06  
**Status:** Approved  

**Entities:** 15  
- Contract, ContractMatchKey, Contractor
- Budget, BudgetVersion, CostPlan, CostPlanVersion, CostPlanArea
- ContractStage, EarlyWarning, VariationOrder, EarlyWarningVariationOrderLink
- PaymentSchedule, PaymentScheduleItem, CertifiedPayment, CertifiedPaymentAllocation

**Dependencies:** None (baseline)

---

#### **V1.1__iox_core_identity_access.sql**
**Segment:** Identity & Access  
**Release Date:** 2026-03-06  
**Status:** Approved  

**Entities:** 7  
- User, Role, Permission, RolePermission
- UserRole, Organization, Department

**Dependencies:** V1.0 (retroactively adds foreign keys to Contract, Budget, CostPlan, etc.)

**Key Features:**
- Full RBAC with hierarchical roles
- Scope-aware role assignment (global/org/project)
- PII flagging for User fields

---

#### **V1.2__iox_core_organisation_project.sql**
**Segment:** Organisation & Project  
**Release Date:** 2026-03-06  
**Status:** Approved  

**Entities:** 5  
- Client, Project, NoticeOfWin, ProjectTeam, CommunicationProtocol

**Dependencies:** V1.0, V1.1

**Key Features:**
- Client-to-Project hierarchy
- Project team role management
- Award capture with project brief (JSON)

---

#### **V1.3_to_V1.11__iox_core_remaining_segments.sql**
**Segments:** 
- v1.3: Meetings & Actions (5 entities)
- v1.4: Documents & Transmittals (6 entities)
- v1.5: Cost Plan Detail (4 entities)
- v1.6: BOQ & Procurement (7 entities)
- v1.7: QA (3 stub entities)
- v1.8: Queries (3 entities)
- v1.9: Tender & Gates (7 entities)
- v1.10: Workflow & Templates (4 stub entities)
- v1.11: Support & Governance (4 entities)

**Release Dates:** 2026-03-06 through 2026-04-29  
**Status:** Approved  

**Total Entities:** 43  

**Dependencies:** V1.0, V1.1, V1.2

**Key Highlights:**
- Document versioning with immutable audit trail
- Transmittal tracking with external recipient support
- Hierarchical folder structure
- Gate-based tender process management
- Three types of risk/assumption/query tracking
- Workflow state machines with immutable transitions
- Comprehensive audit logging with PII flagging

---

#### **V1.12__iox_core_extensions_and_foreign_keys.sql**
**Segment:** All (Foreign Key Completion + Extensions)  
**Release Date:** 2026-04-29  
**Status:** Approved  

**Changes:**
- Adds all foreign key constraints for v1.3–v1.11 entities
- Adds indexes for User extensions: allowedCountries, allowedDevelopers (from v1.12)
- Adds indexes for BenchmarkProject extensions: location, costPerGFA (from v1.13)
- Links CostPlan to BenchmarkProject

**Dependencies:** All previous IOX Core migrations

---

#### **V1.13__iox_core_schema_completion.sql**
**Segment:** All (Performance & Reporting)  
**Release Date:** 2026-04-29  
**Status:** Approved  

**Changes:**
- Additional performance indexes for common query patterns
- Five materialized views for reporting:
  - ProjectSummary
  - ContractStatusSummary
  - UserActivitySummary
  - OpenActionItemsByOwner
  - ContractCostSummary
  - DocumentTransmissionAudit
- Utility functions for common operations
- Schema documentation comments

**Dependencies:** All previous migrations

---

### ParametriX Migrations

#### **V0.1_to_V0.6__parametrix_parametric_estimation.sql**
**Module:** ParametriX (Parametric Cost Estimation)  
**Release Dates:** v0.1–v0.6 (2024–2025)  
**Status:** Approved  

**Entities:** 14  
- ParameterCategory, Parameter, ParametricModel, ModelParameter
- CostRelationship, CostRelationshipParameter
- ParametricEstimate, EstimateParameterValue, EstimateOutputValue
- CalibrationDataSource, CalibrationDataPoint, CalibrationDataPointParameter
- SensitivityAnalysis, RiskAdjustment

**Dependencies:** IOX Core v1.5+ (extends CostPlan, references User)

**Key Features:**
- Parameter-driven cost modeling
- Multiple-cost-relationship support per model
- Sensitivity analysis and risk adjustments
- Historical calibration data for model tuning
- Confidence level tracking on estimates

---

## Schema Statistics

| Metric | Count |
|--------|-------|
| **Base Tables** | 84 |
| **Materialized Views** | 6 |
| **Total Objects** | 90 |
| **IOX Core Tables** | 70 |
| **ParametriX Tables** | 14 |
| **Total Indexes** | 150+ |
| **Foreign Key Constraints** | 95+ |
| **Functions** | 4 |

---

## Execution Order

**IMPORTANT:** Migrations **must be applied in version order** due to foreign key dependencies.

```sql
-- Phase 1: IOX Core Foundation
V1.0__iox_core_project_contract.sql
V1.1__iox_core_identity_access.sql
V1.2__iox_core_organisation_project.sql
V1.3_to_V1.11__iox_core_remaining_segments.sql
V1.12__iox_core_extensions_and_foreign_keys.sql
V1.13__iox_core_schema_completion.sql

-- Phase 2: ParametriX (Optional — can be deferred)
V0.1_to_V0.6__parametrix_parametric_estimation.sql
```

---

## Migration Verification

After applying all migrations, verify:

1. **Table count:** 84 base tables should exist
```sql
   SELECT COUNT(*) FROM information_schema.tables 
   WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
   -- Expected: 84
```

2. **View count:** 6 materialized views should exist
```sql
   SELECT COUNT(*) FROM information_schema.tables 
   WHERE table_schema = 'public' AND table_type = 'VIEW';
   -- Expected: 6
```

3. **Foreign key constraints:** All relationships should be defined
```sql
   SELECT COUNT(*) FROM information_schema.table_constraints 
   WHERE constraint_type = 'FOREIGN KEY';
```

4. **Views are accessible:**
```sql
   SELECT * FROM "ProjectSummary" LIMIT 1;
```

5. **Functions are callable:**
```sql
   SELECT get_user_full_name('any_user_id');
```

---

## Key Design Decisions

### Stability & Immutability
- **AuditLog:** Immutable (no updates/deletes) — tracks all system changes
- **DocumentVersion:** Immutable — preserves file history
- **BOQVersion, BudgetVersion, CostPlanVersion:** Immutable snapshots
- **WorkflowTransition:** Immutable state change record

### PII Classification
All PII fields are flagged in comments:
- **User.email, firstName, lastName, phone, avatar** — High sensitivity
- **AuditLog.ipAddress, userAgent** — Medium sensitivity
- **Transmittal.recipientEmail, TenderQuery.raisedByEmail, NCR.raisedByEmail** — Contextual PII
- **Organization.phone, email** — Lower sensitivity (org-level)

### Polymorphic References
- **WorkflowInstance/Transition:** entityType + entityId pattern (Decision 4)
- **AuditLog:** entityType + entityId for generic action tracking
- Avoids circular FK dependencies; handled at application layer

### JSON Columns (Decision 3)
All remain JSON for flexibility:
- **NoticeOfWin.projectBrief** — Variable structure by project type
- **AuditLog.oldValue, newValue** — Arbitrary entity states
- **Notification.metadata** — Event-type-specific payloads
- **BudgetVersion, CostPlanVersion, BOQVersion.snapshot** — Point-in-time snapshots

---

## Scope Qualifiers (UserRole Pattern)

UserRole supports three scoping modes:
- **organizationId = NULL, projectId = NULL** → Global scope
- **organizationId = populated, projectId = NULL** → Org scope
- **organizationId = NULL, projectId = populated** → Project scope
- **Both populated → Invalid** (enforced by business rules, not DB constraint)

---

## Indexes Strategy

**By Category:**
- **PKs & FKs:** All primary & foreign key columns indexed automatically
- **Status/Lifecycle:** Index on status fields for filtering (e.g., "OPEN" queries)
- **Time Ranges:** Indexes on createdAt, updatedAt for time-based reporting
- **Hierarchies:** Indexes on self-referencing FKs (parentDepartmentId, parentFolderId, parentRoleId)
- **Multi-column:** Composite indexes on frequently combined filters (project + status, contract + date range)
- **Array Columns:** GIN indexes on User.allowedCountries and allowedDevelopers

---

## Future Extensibility

The schema is designed for safe growth:

1. **Stub entities** (Checklist, ChecklistItem, Template, BOQStrategy) are placeholders for future definition
2. **Open items** documented in Notion (e.g., rating scale for PerformanceRating)
3. **JSON columns** allow schema evolution without migrations
4. **Views** can be updated as reporting needs change
5. **No destructive operations** in any migration — safe to layer additional changes

---

## Support & Maintenance

**For questions or updates:**
- Refer to Logical Data Dictionary in Notion for entity definitions
- Check Relationship Catalog for FK details
- Review Changelog for version history and breaking changes

**To add a new entity:**
1. Document in Logical Data Dictionary (Notion)
2. Propose as Proposed Update with decision tracking
3. Create migration file: `V[next-version]__[segment]_[description].sql`
4. Update DataModel Studio workflow to require migration SQL alongside Notion updates
