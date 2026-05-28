<!-- AUTO-GENERATED — do not edit by hand. -->
<!-- Regenerate with: node tools/generate-modules-doc.mjs -->

# IOX module catalogue

Generated from `schema/clustering/module-mapping.json` and `COMMENT ON TABLE` text in the migration SQL. Updated whenever the schema or module mapping changes — see `GOVERNANCE.md`.

**Counts**: 84 base tables across 5 modules. 6 reporting views.

## Modules

### IOX Core


Shared data model — foundational objects referenced across all modules

**Tables (26)**

| Table | Description | Outbound FKs | PII |
|---|---|---|---|
| `AuditLog` | Immutable audit trail. | `userId → User.userId` | ⚠️ ipAddress, userAgent |
| `BenchmarkProject` | _no description_ | `createdById → User.userId` | — |
| `Budget` | _no description_ | `contractId → Contract.contractId` | — |
| `BudgetVersion` | _no description_ | `budgetId → Budget.budgetId`, `createdById → User.userId` | — |
| `CertifiedPayment` | _no description_ | `contractId → Contract.contractId`, `certifiedById → User.userId` | — |
| `CertifiedPaymentAllocation` | _no description_ | `certifiedPaymentId → CertifiedPayment.certifiedPaymentId`, `paymentScheduleItemId → PaymentScheduleItem.paymentScheduleItemId` | — |
| `Client` | _no description_ | `organizationId → Organization.organizationId` | — |
| `Contract` | Top-level contract entity with financial and temporal scope | `projectId → Project.projectId` | — |
| `ContractMatchKey` | _no description_ | `contractId → Contract.contractId` | — |
| `ContractStage` | _no description_ | `contractId → Contract.contractId` | — |
| `Contractor` | _no description_ | `contractId → Contract.contractId`, `organizationId → Organization.organizationId` | — |
| `CostPlan` | Estimate and cost tracking at contract level | `contractId → Contract.contractId`, `createdById → User.userId`, `benchmarkProjectId → BenchmarkProject.benchmarkProjectId` | — |
| `CostPlanVersion` | _no description_ | `costPlanId → CostPlan.costPlanId`, `createdById → User.userId` | — |
| `Department` | _no description_ | `headUserId → User.userId`, `parentDepartmentId → Department.departmentId`, `organizationId → Organization.organizationId` | — |
| `Notification` | System-generated alerts to users by event type | `userId → User.userId` | — |
| `Organization` | _no description_ | — | — |
| `PaymentSchedule` | _no description_ | `contractId → Contract.contractId` | — |
| `PaymentScheduleItem` | _no description_ | `paymentScheduleId → PaymentSchedule.paymentScheduleId` | — |
| `PerformanceRating` | _no description_ | `contractId → Contract.contractId`, `ratedById → User.userId` | — |
| `Permission` | _no description_ | — | — |
| `Project` | Primary scoping entity for all work deliverables | `clientId → Client.clientId` | — |
| `ProjectTeam` | _no description_ | `projectId → Project.projectId`, `userId → User.userId`, `userRoleId → UserRole.userRoleId` | — |
| `Role` | Named permission sets with hierarchical organization | `parentRoleId → Role.roleId` | — |
| `RolePermission` | _no description_ | `roleId → Role.roleId`, `permissionId → Permission.permissionId` | — |
| `User` | Core user identity and authentication. | — | ⚠️ email, firstName, lastName, phone, avatar |
| `UserRole` | Assignment of roles to users with global/org/project scoping | `userId → User.userId`, `roleId → Role.roleId`, `organizationId → Organization.organizationId`, `assignedById → User.userId` | — |

### ParametriX

*Lifecycle phase: Pre-Design*

Parametric cost modelling — build and calibrate cost models from parameters

**Capabilities**

- Build parametric cost models from configurable project parameters
- Run sensitivity analysis to stress-test cost assumptions
- Adjust estimates for risk and confidence levels
- Generate estimates to seed or validate a Cost Plan
- Calibrate models against historical benchmark data

**Tables (14)**

| Table | Description | Outbound FKs | PII |
|---|---|---|---|
| `CalibrationDataPoint` | _no description_ | `calibrationDataSourceId → CalibrationDataSource.calibrationDataSourceId` | — |
| `CalibrationDataPointParameter` | _no description_ | `calibrationDataPointId → CalibrationDataPoint.calibrationDataPointId`, `parameterId → Parameter.parameterId` | — |
| `CalibrationDataSource` | _no description_ | — | — |
| `CostRelationship` | _no description_ | `parametricModelId → ParametricModel.parametricModelId` | — |
| `CostRelationshipParameter` | _no description_ | `costRelationshipId → CostRelationship.costRelationshipId`, `parameterId → Parameter.parameterId` | — |
| `EstimateOutputValue` | _no description_ | `parametricEstimateId → ParametricEstimate.parametricEstimateId`, `costRelationshipId → CostRelationship.costRelationshipId` | — |
| `EstimateParameterValue` | _no description_ | `parametricEstimateId → ParametricEstimate.parametricEstimateId`, `parameterId → Parameter.parameterId` | — |
| `ModelParameter` | _no description_ | `parametricModelId → ParametricModel.parametricModelId`, `parameterId → Parameter.parameterId` | — |
| `Parameter` | _no description_ | `parameterCategoryId → ParameterCategory.parameterCategoryId` | — |
| `ParameterCategory` | _no description_ | — | — |
| `ParametricEstimate` | _no description_ | `costPlanId → CostPlan.costPlanId`, `parametricModelId → ParametricModel.parametricModelId`, `createdById → User.userId` | — |
| `ParametricModel` | _no description_ | `createdById → User.userId` | — |
| `RiskAdjustment` | _no description_ | `parametricEstimateId → ParametricEstimate.parametricEstimateId`, `createdById → User.userId` | — |
| `SensitivityAnalysis` | _no description_ | `parametricEstimateId → ParametricEstimate.parametricEstimateId`, `parameterId → Parameter.parameterId` | — |

### PlanX

*Lifecycle phase: Design Development*

Cost plan management — develop, issue and maintain cost plans through the project lifecycle

**Capabilities**

- Structure cost plans into elemental breakdown areas
- Issue and version cost plans as design develops
- Maintain alignment between plan structure and project budget
- Track cost plan evolution across multiple design iterations

**Tables (2)**

| Table | Description | Outbound FKs | PII |
|---|---|---|---|
| `CostPlanArea` | _no description_ | `costPlanId → CostPlan.costPlanId` | — |
| `CostPlanElement` | _no description_ | `costPlanId → CostPlan.costPlanId`, `costPlanAreaId → CostPlanArea.costPlanAreaId` | — |

### ProcureX

*Lifecycle phase: Tender & Procurement*

Tender analysis — manage the full procurement and tendering lifecycle

**Capabilities**

- Manage the tender lifecycle from gate review to contract award
- Issue and respond to tender queries, drawings and documents
- Record meetings, actions, risks, assumptions and NCRs
- Track BOQs, addenda and work orders
- Assess value engineering items against the cost plan

**Tables (39)**

| Table | Description | Outbound FKs | PII |
|---|---|---|---|
| `ActionItem` | _no description_ | `projectId → Project.projectId`, `meetingId → Meeting.meetingId`, `ownerId → User.userId` | — |
| `Addendum` | _no description_ | `contractId → Contract.contractId`, `issuedById → User.userId` | — |
| `Assumption` | _no description_ | `contractId → Contract.contractId`, `ownerId → User.userId`, `raisedById → User.userId` | — |
| `BOQ` | Bill of Quantities hierarchically organized by Bill > Section > Item | `contractId → Contract.contractId`, `createdById → User.userId` | — |
| `BOQBill` | _no description_ | `boqId → BOQ.boqId` | — |
| `BOQItem` | _no description_ | `boqSectionId → BOQSection.boqSectionId` | — |
| `BOQSection` | _no description_ | `boqBillId → BOQBill.boqBillId` | — |
| `BOQStrategy` | _no description_ | — | — |
| `BOQVersion` | _no description_ | `boqId → BOQ.boqId`, `createdById → User.userId` | — |
| `Checklist` | _no description_ | — | — |
| `ChecklistItem` | _no description_ | — | — |
| `CommunicationProtocol` | _no description_ | `projectId → Project.projectId` | — |
| `Document` | Logical document record with versioning via DocumentVersion | `projectId → Project.projectId`, `folderId → Folder.folderId`, `uploadedById → User.userId`, `currentVersionId → DocumentVersion.documentVersionId` | — |
| `DocumentVersion` | _no description_ | `documentId → Document.documentId`, `uploadedById → User.userId` | — |
| `Drawing` | _no description_ | `projectId → Project.projectId`, `uploadedById → User.userId` | — |
| `Folder` | _no description_ | `projectId → Project.projectId`, `parentFolderId → Folder.folderId` | — |
| `Gate` | _no description_ | `contractId → Contract.contractId` | — |
| `GateChecklistItem` | _no description_ | `gateId → Gate.gateId`, `completedById → User.userId` | — |
| `HandoverPackage` | _no description_ | `contractId → Contract.contractId`, `acceptedById → User.userId` | — |
| `Meeting` | Project meetings with attendees, agenda, and action items | `projectId → Project.projectId` | — |
| `MeetingAgendaItem` | _no description_ | `meetingId → Meeting.meetingId`, `ownerId → User.userId` | — |
| `MeetingAttendee` | _no description_ | `meetingId → Meeting.meetingId`, `userId → User.userId` | — |
| `MeetingMinutes` | _no description_ | `meetingId → Meeting.meetingId`, `approvedById → User.userId` | — |
| `NCR` | _no description_ | `contractId → Contract.contractId`, `raisedByUserId → User.userId`, `assignedToId → User.userId` | — |
| `NoticeOfWin` | _no description_ | `projectId → Project.projectId` | — |
| `QASheet` | _no description_ | `contractId → Contract.contractId` | — |
| `Query` | Planning-phase clarification requests scoped to Contract | `contractId → Contract.contractId`, `raisedById → User.userId`, `assignedToId → User.userId` | — |
| `QueryAttachment` | _no description_ | `queryId → Query.queryId`, `uploadedById → User.userId` | — |
| `QueryResponse` | _no description_ | `queryId → Query.queryId`, `respondedById → User.userId` | — |
| `Risk` | Formally tracked risks with probability/impact and mitigation | `contractId → Contract.contractId`, `ownerId → User.userId`, `raisedById → User.userId` | — |
| `Template` | _no description_ | — | — |
| `TenderQuery` | Tender-phase clarification requests from bidders | `contractId → Contract.contractId`, `respondedById → User.userId` | — |
| `Transmittal` | Formal dispatch record with recipient tracking | `projectId → Project.projectId`, `sentById → User.userId`, `recipientUserId → User.userId` | — |
| `TransmittalDocument` | _no description_ | `transmittalId → Transmittal.transmittalId`, `documentId → Document.documentId`, `documentVersionId → DocumentVersion.documentVersionId` | — |
| `VEItem` | _no description_ | `costPlanId → CostPlan.costPlanId`, `raisedById → User.userId`, `reviewedById → User.userId` | — |
| `WorkOrder` | _no description_ | `contractId → Contract.contractId`, `issuedById → User.userId` | — |
| `WorkflowDefinition` | _no description_ | — | — |
| `WorkflowInstance` | _no description_ | `workflowDefinitionId → WorkflowDefinition.workflowDefinitionId` | — |
| `WorkflowTransition` | _no description_ | `workflowInstanceId → WorkflowInstance.workflowInstanceId`, `transitionedById → User.userId` | — |

### ReportX

*Lifecycle phase: Contract Delivery*

Cost report management — track and report contract financials, variations and certified payments

**Capabilities**

- Track certified payments against the payment schedule
- Record and assess variation orders and early warnings
- Report live contract financial position
- Provide project and programme-level financial dashboards

**Tables (3)**

| Table | Description | Outbound FKs | PII |
|---|---|---|---|
| `EarlyWarning` | _no description_ | `contractId → Contract.contractId`, `raisedById → User.userId`, `assignedToId → User.userId` | — |
| `EarlyWarningVariationOrderLink` | _no description_ | `earlyWarningId → EarlyWarning.earlyWarningId`, `variationOrderId → VariationOrder.variationOrderId` | — |
| `VariationOrder` | _no description_ | `contractId → Contract.contractId`, `createdById → User.userId` | — |

### PlaceholderX


Rate and benchmark data management — maintain reference cost data and market rates

_No tables in this module yet._

## Views

Reporting views defined in `V1.13`. Treat as read-only.

- `ContractCostSummary`
- `ContractStatusSummary`
- `DocumentTransmissionAudit`
- `OpenActionItemsByOwner`
- `ProjectSummary`
- `UserActivitySummary`
