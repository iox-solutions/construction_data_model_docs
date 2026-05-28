-- IOX Core & ParametriX Seed Data
-- Generated from analysis of migrations v1.0-v1.13 and v0.1-v0.6
-- Comprehensive test data with 3 organizations, 3 users, 3 roles, 1 project, 1 contract, 1 budget, 1 cost plan
-- All data respects NOT NULL constraints and uses exact column names from migrations

BEGIN TRANSACTION;

-- =====================================================================
-- ORGANIZATIONS (3)
-- =====================================================================

INSERT INTO "Organization" (
  "organizationId",
  "name",
  "type",
  "code",
  "address",
  "phone",
  "email",
  "website",
  "logo",
  "status",
  "createdAt"
) VALUES
  ('org-001', 'Acme Construction Ltd', 'CONTRACTOR', 'ACME001', '123 Main Street, London, UK', '+44 20 7946 0958', 'info@acme.com', 'https://acme.com', NULL, 'ACTIVE', CURRENT_TIMESTAMP),
  ('org-002', 'BuildCorp International', 'CONTRACTOR', 'BUILDCORP001', '456 Industrial Ave, Manchester, UK', '+44 161 123 4567', 'contact@buildcorp.com', 'https://buildcorp.com', NULL, 'ACTIVE', CURRENT_TIMESTAMP),
  ('org-003', 'PrimeDev Solutions', 'CLIENT', 'PRIMEDEV001', '789 Business Park, Birmingham, UK', '+44 121 555 8888', 'hello@primedev.com', 'https://primedev.com', NULL, 'ACTIVE', CURRENT_TIMESTAMP);

-- =====================================================================
-- USERS (3)
-- =====================================================================

INSERT INTO "User" (
  "userId",
  "email",
  "passwordHash",
  "firstName",
  "lastName",
  "phone",
  "avatar",
  "status",
  "emailVerified",
  "createdAt",
  "updatedAt",
  "allowedCountries",
  "allowedDevelopers"
) VALUES
  ('user-001', 'james.smith@acme.com', '$2b$10$hash1', 'James', 'Smith', '+44 7700 900001', NULL, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, ARRAY['GB', 'US'], ARRAY['dev-team-1']),
  ('user-002', 'sarah.johnson@buildcorp.com', '$2b$10$hash2', 'Sarah', 'Johnson', '+44 7700 900002', NULL, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, ARRAY['GB', 'EU'], ARRAY['dev-team-2']),
  ('user-003', 'michael.brown@primedev.com', '$2b$10$hash3', 'Michael', 'Brown', '+44 7700 900003', NULL, 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, ARRAY['GB'], ARRAY['dev-team-1', 'dev-team-3']);

-- =====================================================================
-- ROLES (3)
-- =====================================================================

INSERT INTO "Role" (
  "roleId",
  "name",
  "code",
  "level",
  "track",
  "description",
  "parentRoleId",
  "createdAt"
) VALUES
  ('role-001', 'Project Manager', 'PM', 1, 'MANAGEMENT', 'Manages project scope, timeline, and stakeholders', NULL, CURRENT_TIMESTAMP),
  ('role-002', 'Cost Engineer', 'COST_ENG', 2, 'TECHNICAL', 'Develops and manages cost plans and budgets', NULL, CURRENT_TIMESTAMP),
  ('role-003', 'Contract Administrator', 'CONTRACT_ADMIN', 2, 'COMPLIANCE', 'Administers contracts and procurement', NULL, CURRENT_TIMESTAMP);

-- =====================================================================
-- PERMISSIONS (for roles)
-- =====================================================================

INSERT INTO "Permission" (
  "permissionId",
  "code",
  "name",
  "module",
  "action",
  "description"
) VALUES
  ('perm-001', 'PROJECT_VIEW', 'View Project', 'PROJECT', 'VIEW', 'View project details'),
  ('perm-002', 'PROJECT_EDIT', 'Edit Project', 'PROJECT', 'EDIT', 'Edit project details'),
  ('perm-003', 'CONTRACT_VIEW', 'View Contract', 'CONTRACT', 'VIEW', 'View contract information'),
  ('perm-004', 'CONTRACT_EDIT', 'Edit Contract', 'CONTRACT', 'EDIT', 'Edit contract information'),
  ('perm-005', 'COST_VIEW', 'View Cost Plan', 'COST', 'VIEW', 'View cost plans'),
  ('perm-006', 'COST_EDIT', 'Edit Cost Plan', 'COST', 'EDIT', 'Edit cost plans');

-- =====================================================================
-- ROLE-PERMISSION LINKS
-- =====================================================================

INSERT INTO "RolePermission" (
  "rolePermissionId",
  "roleId",
  "permissionId"
) VALUES
  ('role-perm-001', 'role-001', 'perm-001'),
  ('role-perm-002', 'role-001', 'perm-002'),
  ('role-perm-003', 'role-001', 'perm-003'),
  ('role-perm-004', 'role-001', 'perm-004'),
  ('role-perm-005', 'role-002', 'perm-005'),
  ('role-perm-006', 'role-002', 'perm-006'),
  ('role-perm-007', 'role-003', 'perm-003'),
  ('role-perm-008', 'role-003', 'perm-004');

-- =====================================================================
-- USER-ROLE ASSIGNMENTS
-- =====================================================================

INSERT INTO "UserRole" (
  "userRoleId",
  "userId",
  "roleId",
  "organizationId",
  "projectId",
  "isPrimary",
  "assignedAt",
  "assignedById"
) VALUES
  ('user-role-001', 'user-001', 'role-001', 'org-001', NULL, TRUE, CURRENT_TIMESTAMP, NULL),
  ('user-role-002', 'user-002', 'role-002', 'org-002', NULL, TRUE, CURRENT_TIMESTAMP, NULL),
  ('user-role-003', 'user-003', 'role-003', 'org-003', NULL, TRUE, CURRENT_TIMESTAMP, NULL);

-- =====================================================================
-- DEPARTMENTS (supporting organizational structure)
-- =====================================================================

INSERT INTO "Department" (
  "departmentId",
  "organizationId",
  "name",
  "code",
  "parentDepartmentId",
  "headUserId",
  "createdAt"
) VALUES
  ('dept-001', 'org-001', 'Project Delivery', 'PD', NULL, 'user-001', CURRENT_TIMESTAMP),
  ('dept-002', 'org-002', 'Cost Management', 'CM', NULL, 'user-002', CURRENT_TIMESTAMP),
  ('dept-003', 'org-003', 'Contract Management', 'CONTRACTING', NULL, 'user-003', CURRENT_TIMESTAMP);

-- =====================================================================
-- CLIENT
-- =====================================================================

INSERT INTO "Client" (
  "clientId",
  "name",
  "organizationId",
  "createdAt"
) VALUES
  ('client-001', 'PrimeDev Solutions Client', 'org-003', CURRENT_TIMESTAMP);

-- =====================================================================
-- PROJECT (1)
-- =====================================================================

INSERT INTO "Project" (
  "projectId",
  "clientId",
  "number",
  "name",
  "description",
  "location",
  "status",
  "startDate",
  "endDate",
  "createdAt",
  "updatedAt"
) VALUES
  ('proj-001', 'client-001', 'PRJ-2026-001', 'London Office Renovation', 'Complete renovation of 50,000 m2 office complex in Central London', 'London, UK', 'ACTIVE', '2026-04-01', '2028-03-31', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- NOTICE OF WIN
-- =====================================================================

INSERT INTO "NoticeOfWin" (
  "noticeOfWinId",
  "projectId",
  "awardDate",
  "awardValue",
  "currency",
  "projectBrief",
  "createdAt"
) VALUES
  ('now-001', 'proj-001', '2026-03-15', 5000000.00, 'GBP', '{"scope": "Full renovation", "timeline": "24 months"}', CURRENT_TIMESTAMP);

-- =====================================================================
-- PROJECT TEAM MEMBER
-- =====================================================================

INSERT INTO "ProjectTeam" (
  "projectTeamId",
  "projectId",
  "userId",
  "userRoleId",
  "joinedAt",
  "leftAt"
) VALUES
  ('pt-001', 'proj-001', 'user-001', 'user-role-001', CURRENT_TIMESTAMP, NULL);

-- =====================================================================
-- COMMUNICATION PROTOCOL
-- =====================================================================

INSERT INTO "CommunicationProtocol" (
  "communicationProtocolId",
  "projectId",
  "responseTimeframeDays",
  "namingConvention",
  "notes",
  "createdAt",
  "updatedAt"
) VALUES
  ('comm-proto-001', 'proj-001', 5, 'PROJECT-{DATE}-{SEQUENCE}', 'Standard communication procedures for project team', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- CONTRACT (1)
-- =====================================================================

INSERT INTO "Contract" (
  "contractId",
  "projectId",
  "number",
  "title",
  "description",
  "contractType",
  "status",
  "clientOrganizationId",
  "contractorId",
  "startDate",
  "endDate",
  "value",
  "currency",
  "createdAt",
  "updatedAt"
) VALUES
  ('cont-001', 'proj-001', 'CNT-2026-001', 'Main Contractor - Renovation Works', 'Principal contract for all renovation works at London Office', 'WORKS', 'ACTIVE', 'org-003', 'org-001', '2026-05-01', '2028-04-30', 4500000.00, 'GBP', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- CONTRACT MATCH KEY
-- =====================================================================

INSERT INTO "ContractMatchKey" (
  "contractMatchKeyId",
  "contractId",
  "keyName",
  "keyValue"
) VALUES
  ('cmk-001', 'cont-001', 'TENDER_REFERENCE', 'TEND-2026-LND-OFF'),
  ('cmk-002', 'cont-001', 'PROJECT_CODE', 'LON-OFF-REN-2026');

-- =====================================================================
-- CONTRACTOR (linking organization to contract)
-- =====================================================================

INSERT INTO "Contractor" (
  "contractorId",
  "contractId",
  "organizationId",
  "role",
  "appointmentDate"
) VALUES
  ('contr-001', 'cont-001', 'org-001', 'Main Contractor', '2026-03-20');

-- =====================================================================
-- BUDGET (1)
-- =====================================================================

INSERT INTO "Budget" (
  "budgetId",
  "contractId",
  "title",
  "status",
  "totalValue",
  "currency",
  "createdAt"
) VALUES
  ('budget-001', 'cont-001', 'Project Budget - Main Contract', 'ACTIVE', 4500000.00, 'GBP', CURRENT_TIMESTAMP);

-- =====================================================================
-- BUDGET VERSION
-- =====================================================================

INSERT INTO "BudgetVersion" (
  "budgetVersionId",
  "budgetId",
  "versionLabel",
  "snapshot",
  "createdById",
  "createdAt"
) VALUES
  ('budget-ver-001', 'budget-001', 'v1.0', '{"status": "ACTIVE", "totalValue": 4500000.00, "currency": "GBP"}', 'user-001', CURRENT_TIMESTAMP);

-- =====================================================================
-- COST PLAN (1)
-- =====================================================================

INSERT INTO "CostPlan" (
  "costPlanId",
  "contractId",
  "title",
  "status",
  "totalCost",
  "currency",
  "benchmarkProjectId",
  "createdById",
  "createdAt",
  "updatedAt"
) VALUES
  ('cp-001', 'cont-001', 'Cost Plan - Renovation Works', 'DRAFT', 4500000.00, 'GBP', NULL, 'user-002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- COST PLAN VERSION
-- =====================================================================

INSERT INTO "CostPlanVersion" (
  "costPlanVersionId",
  "costPlanId",
  "versionLabel",
  "snapshot",
  "createdById",
  "createdAt"
) VALUES
  ('cp-ver-001', 'cp-001', 'v1.0-DRAFT', '{"title": "Cost Plan - Renovation Works", "status": "DRAFT", "totalCost": 4500000.00}', 'user-002', CURRENT_TIMESTAMP);

-- =====================================================================
-- COST PLAN AREA
-- =====================================================================

INSERT INTO "CostPlanArea" (
  "costPlanAreaId",
  "costPlanId",
  "name",
  "grossInternalArea",
  "sortOrder",
  "notes"
) VALUES
  ('cpa-001', 'cp-001', 'Ground Floor', 12500.00, 1, 'Ground floor area of office complex'),
  ('cpa-002', 'cp-001', 'Upper Floors', 37500.00, 2, 'Combined area of upper floors');

-- =====================================================================
-- COST PLAN ELEMENT
-- =====================================================================

INSERT INTO "CostPlanElement" (
  "costPlanElementId",
  "costPlanId",
  "costPlanAreaId",
  "title",
  "code",
  "quantity",
  "unit",
  "unitRate",
  "elementCost",
  "currency",
  "sortOrder",
  "notes"
) VALUES
  ('cpe-001', 'cp-001', 'cpa-001', 'Structural Works', 'STR-001', 12500.00, 'm2', 150.00, 1875000.00, 'GBP', 1, 'Structural repairs and reinforcement'),
  ('cpe-002', 'cp-001', 'cpa-002', 'MEP Installation', 'MEP-001', 37500.00, 'm2', 75.00, 2812500.00, 'GBP', 2, 'Mechanical, Electrical, Plumbing systems');

-- =====================================================================
-- BENCHMARK PROJECT (supporting cost estimation)
-- =====================================================================

INSERT INTO "BenchmarkProject" (
  "benchmarkProjectId",
  "name",
  "description",
  "grossInternalArea",
  "totalCost",
  "costPerM2",
  "currency",
  "location",
  "costPerGFA",
  "baseDate",
  "createdById",
  "createdAt",
  "updatedAt"
) VALUES
  ('bench-001', 'Reference Office Renovation 2024', 'Similar office complex renovation completed in 2024', 45000.00, 4050000.00, 90.00, 'GBP', 'Manchester, UK', 90.00, '2024-06-30', 'user-002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- PAYMENT SCHEDULE
-- =====================================================================

INSERT INTO "PaymentSchedule" (
  "paymentScheduleId",
  "contractId",
  "title",
  "totalValue",
  "currency",
  "createdAt"
) VALUES
  ('ps-001', 'cont-001', 'Payment Schedule - Main Works', 4500000.00, 'GBP', CURRENT_TIMESTAMP);

-- =====================================================================
-- PAYMENT SCHEDULE ITEM
-- =====================================================================

INSERT INTO "PaymentScheduleItem" (
  "paymentScheduleItemId",
  "paymentScheduleId",
  "description",
  "dueDate",
  "paymentValue",
  "sortOrder"
) VALUES
  ('psi-001', 'ps-001', 'Mobilization & Site Setup', '2026-06-30', 450000.00, 1),
  ('psi-002', 'ps-001', 'Structural Works - Phase 1', '2026-12-31', 1125000.00, 2),
  ('psi-003', 'ps-001', 'MEP Installation - Phase 1', '2027-06-30', 1406250.00, 3),
  ('psi-004', 'ps-001', 'Final Completion', '2028-04-30', 1518750.00, 4);

-- =====================================================================
-- VARIATION ORDER (supporting contract management)
-- =====================================================================

INSERT INTO "VariationOrder" (
  "variationOrderId",
  "contractId",
  "reference",
  "title",
  "description",
  "valuationAmount",
  "status",
  "createdById",
  "createdAt",
  "updatedAt"
) VALUES
  ('vo-001', 'cont-001', 'VO-2026-001', 'Additional Structural Investigation', 'Additional structural investigation works identified during project start', 125000.00, 'PROPOSED', 'user-001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- CONTRACT STAGE
-- =====================================================================

INSERT INTO "ContractStage" (
  "contractStageId",
  "contractId",
  "stageName",
  "status",
  "targetDate",
  "completedDate"
) VALUES
  ('stage-001', 'cont-001', 'Mobilization', 'IN_PROGRESS', '2026-06-30', NULL),
  ('stage-002', 'cont-001', 'Structural Works', 'PENDING', '2027-03-31', NULL),
  ('stage-003', 'cont-001', 'MEP Installation', 'PENDING', '2028-02-28', NULL);

-- =====================================================================
-- EARLY WARNING
-- =====================================================================

INSERT INTO "EarlyWarning" (
  "earlyWarningId",
  "contractId",
  "title",
  "description",
  "status",
  "raisedById",
  "assignedToId",
  "createdAt",
  "updatedAt"
) VALUES
  ('ew-001', 'cont-001', 'Potential Supply Chain Delay', 'Delay in procurement of specialized MEP equipment may impact timeline', 'OPEN', 'user-001', 'user-002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- EARLY WARNING - VARIATION ORDER LINK
-- =====================================================================

INSERT INTO "EarlyWarningVariationOrderLink" (
  "linkId",
  "earlyWarningId",
  "variationOrderId"
) VALUES
  ('ewvol-001', 'ew-001', 'vo-001');

-- =====================================================================
-- CERTIFIED PAYMENT
-- =====================================================================

INSERT INTO "CertifiedPayment" (
  "certifiedPaymentId",
  "contractId",
  "reference",
  "certificationDate",
  "certifiedAmount",
  "currency",
  "certifiedById",
  "createdAt"
) VALUES
  ('cp-cert-001', 'cont-001', 'CERT-2026-001', '2026-07-15', 450000.00, 'GBP', 'user-001', CURRENT_TIMESTAMP);

-- =====================================================================
-- CERTIFIED PAYMENT ALLOCATION
-- =====================================================================

INSERT INTO "CertifiedPaymentAllocation" (
  "allocationId",
  "certifiedPaymentId",
  "paymentScheduleItemId",
  "allocatedAmount"
) VALUES
  ('alloc-001', 'cp-cert-001', 'psi-001', 450000.00);

-- =====================================================================
-- FOLDER (for document management)
-- =====================================================================

INSERT INTO "Folder" (
  "folderId",
  "projectId",
  "parentFolderId",
  "name",
  "sortOrder",
  "createdAt",
  "updatedAt"
) VALUES
  ('folder-001', 'proj-001', NULL, 'Contract Documents', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('folder-002', 'proj-001', NULL, 'Designs & Drawings', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- DOCUMENT
-- =====================================================================

INSERT INTO "Document" (
  "documentId",
  "projectId",
  "folderId",
  "title",
  "documentNumber",
  "type",
  "status",
  "uploadedById",
  "currentVersionId",
  "createdAt",
  "updatedAt"
) VALUES
  ('doc-001', 'proj-001', 'folder-001', 'Main Contract Agreement', 'CONT-2026-001', 'CONTRACT', 'ACTIVE', 'user-001', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- DOCUMENT VERSION
-- =====================================================================

INSERT INTO "DocumentVersion" (
  "documentVersionId",
  "documentId",
  "versionLabel",
  "fileUrl",
  "fileSize",
  "mimeType",
  "uploadedById",
  "createdAt"
) VALUES
  ('docver-001', 'doc-001', 'v1.0', 'https://storage.example.com/documents/CONT-2026-001-v1.0.pdf', 2048576, 'application/pdf', 'user-001', CURRENT_TIMESTAMP);

-- Update currentVersionId now that we have the version
UPDATE "Document" SET "currentVersionId" = 'docver-001' WHERE "documentId" = 'doc-001';

-- =====================================================================
-- DRAWING
-- =====================================================================

INSERT INTO "Drawing" (
  "drawingId",
  "projectId",
  "drawingNumber",
  "title",
  "discipline",
  "revision",
  "status",
  "fileUrl",
  "uploadedById",
  "createdAt",
  "updatedAt"
) VALUES
  ('draw-001', 'proj-001', 'A-101', 'Ground Floor Plan', 'ARCHITECTURE', 'A1', 'CURRENT', 'https://storage.example.com/drawings/A-101-A1.pdf', 'user-001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- TRANSMITTAL
-- =====================================================================

INSERT INTO "Transmittal" (
  "transmittalId",
  "projectId",
  "transmittalNumber",
  "subject",
  "sentById",
  "recipientUserId",
  "recipientName",
  "recipientEmail",
  "sentAt",
  "responseRequiredBy",
  "status",
  "notes",
  "createdAt"
) VALUES
  ('trans-001', 'proj-001', 'TRANS-2026-001', 'Issue for Review: Ground Floor Plans', 'user-001', 'user-002', 'Sarah Johnson', 'sarah.johnson@buildcorp.com', CURRENT_TIMESTAMP, '2026-05-15', 'SENT', 'Please review and provide feedback on ground floor layout', CURRENT_TIMESTAMP);

-- =====================================================================
-- TRANSMITTAL DOCUMENT
-- =====================================================================

INSERT INTO "TransmittalDocument" (
  "transmittalDocumentId",
  "transmittalId",
  "documentId",
  "documentVersionId"
) VALUES
  ('td-001', 'trans-001', 'doc-001', 'docver-001');

-- =====================================================================
-- MEETING (for project coordination)
-- =====================================================================

INSERT INTO "Meeting" (
  "meetingId",
  "projectId",
  "title",
  "type",
  "scheduledAt",
  "location",
  "status",
  "createdAt",
  "updatedAt"
) VALUES
  ('meet-001', 'proj-001', 'Project Kickoff Meeting', 'KICKOFF', '2026-05-10 10:00:00', 'London Office, Meeting Room 1', 'SCHEDULED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- MEETING ATTENDEE
-- =====================================================================

INSERT INTO "MeetingAttendee" (
  "meetingAttendeeId",
  "meetingId",
  "userId",
  "status"
) VALUES
  ('ma-001', 'meet-001', 'user-001', 'ACCEPTED'),
  ('ma-002', 'meet-001', 'user-002', 'INVITED'),
  ('ma-003', 'meet-001', 'user-003', 'ACCEPTED');

-- =====================================================================
-- MEETING AGENDA ITEM
-- =====================================================================

INSERT INTO "MeetingAgendaItem" (
  "meetingAgendaItemId",
  "meetingId",
  "title",
  "description",
  "sortOrder",
  "ownerId",
  "durationMinutes"
) VALUES
  ('agenda-001', 'meet-001', 'Project Overview & Scope', 'Review project scope and objectives', 1, 'user-001', 30),
  ('agenda-002', 'meet-001', 'Schedule & Milestones', 'Discuss project timeline and key milestones', 2, 'user-001', 30),
  ('agenda-003', 'meet-001', 'Cost & Budget', 'Review budget allocation and cost plan', 3, 'user-002', 20);

-- =====================================================================
-- MEETING MINUTES
-- =====================================================================

INSERT INTO "MeetingMinutes" (
  "meetingMinutesId",
  "meetingId",
  "content",
  "approvedById",
  "approvedAt",
  "createdAt",
  "updatedAt"
) VALUES
  ('minutes-001', 'meet-001', 'Confirmed project scope and timeline. Baseline budget of GBP 4.5M approved. Next phase: detailed design review scheduled for 20-May.', 'user-001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- ACTION ITEM
-- =====================================================================

INSERT INTO "ActionItem" (
  "actionItemId",
  "projectId",
  "meetingId",
  "title",
  "description",
  "ownerId",
  "status",
  "priority",
  "dueDate",
  "completedAt",
  "createdAt",
  "updatedAt"
) VALUES
  ('action-001', 'proj-001', 'meet-001', 'Prepare Detailed Design Schedule', 'Create detailed design schedule for structural works', 'user-001', 'OPEN', 'HIGH', '2026-05-20', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('action-002', 'proj-001', 'meet-001', 'Finalize Cost Plan Details', 'Detail cost plan by phase and cost centers', 'user-002', 'OPEN', 'HIGH', '2026-05-25', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- BOQ (Bill of Quantities)
-- =====================================================================

INSERT INTO "BOQ" (
  "boqId",
  "contractId",
  "title",
  "status",
  "createdAt",
  "updatedAt"
) VALUES
  ('boq-001', 'cont-001', 'Bill of Quantities - Main Works', 'DRAFT', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- BOQ BILL (first bill in BOQ)
-- =====================================================================

INSERT INTO "BOQBill" (
  "boqBillId",
  "boqId",
  "billNumber",
  "organizationId",
  "title",
  "sortOrder"
) VALUES
  ('boq-bill-001', 'boq-001', 1, 'org-001', 'Bill 1: Structural Works', 1);

-- =====================================================================
-- BOQ SECTION
-- =====================================================================

INSERT INTO "BOQSection" (
  "boqSectionId",
  "boqBillId",
  "sectionNumber",
  "title",
  "sortOrder"
) VALUES
  ('boq-sec-001', 'boq-bill-001', '1.1', 'Demolition & Site Preparation', 1),
  ('boq-sec-002', 'boq-bill-001', '1.2', 'Structural Repairs', 2);

-- =====================================================================
-- BOQ ITEM
-- =====================================================================

INSERT INTO "BOQItem" (
  "boqItemId",
  "boqSectionId",
  "itemNumber",
  "description",
  "quantity",
  "unit",
  "unitRate",
  "itemTotal",
  "notes"
) VALUES
  ('boq-item-001', 'boq-sec-001', '1.1.1', 'Remove existing partitions and fixtures', 1250.00, 'm2', 25.00, 31250.00, 'Interior demolition work'),
  ('boq-item-002', 'boq-sec-002', '1.2.1', 'Structural column repair and reinforcement', 45.00, 'NO', 5000.00, 225000.00, 'Structural repairs');

-- =====================================================================
-- BOQ VERSION
-- =====================================================================

INSERT INTO "BOQVersion" (
  "boqVersionId",
  "boqId",
  "versionLabel",
  "snapshot",
  "createdById",
  "createdAt"
) VALUES
  ('boq-ver-001', 'boq-001', 'v1.0-DRAFT', '{"status": "DRAFT", "billCount": 1, "itemCount": 2}', 'user-001', CURRENT_TIMESTAMP);

-- =====================================================================
-- WORK ORDER
-- =====================================================================

INSERT INTO "WorkOrder" (
  "workOrderId",
  "contractId",
  "number",
  "title",
  "description",
  "issuedDate",
  "targetCompletionDate",
  "status",
  "issuedById",
  "createdAt",
  "updatedAt"
) VALUES
  ('wo-001', 'cont-001', 'WO-2026-001', 'Mobilization & Site Setup', 'Initial mobilization and site setup activities', '2026-05-01', '2026-06-30', 'ISSUED', 'user-001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- QUERY (clarification queries)
-- =====================================================================

INSERT INTO "Query" (
  "queryId",
  "contractId",
  "reference",
  "subject",
  "body",
  "raisedById",
  "status",
  "responseRequiredBy",
  "createdAt",
  "updatedAt"
) VALUES
  ('query-001', 'cont-001', 'Q-2026-001', 'Clarification on Structural Specification', 'Can you clarify the specification for column reinforcement in section 3.2?', 'user-002', 'OPEN', '2026-05-20', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- QUERY RESPONSE
-- =====================================================================

INSERT INTO "QueryResponse" (
  "queryResponseId",
  "queryId",
  "body",
  "respondedById",
  "createdAt",
  "updatedAt"
) VALUES
  ('qr-001', 'query-001', 'Column reinforcement shall use Grade 460 steel with epoxy coating per BS 4449:2005', 'user-001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- GATE (project gates/milestone controls)
-- =====================================================================

INSERT INTO "Gate" (
  "gateId",
  "contractId",
  "title",
  "sortOrder",
  "status",
  "targetDate",
  "passedAt",
  "createdAt",
  "updatedAt"
) VALUES
  ('gate-001', 'cont-001', 'Design Approval', 1, 'PENDING', '2026-06-15', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('gate-002', 'cont-001', 'Value Engineering Review', 2, 'PENDING', '2026-07-15', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- GATE CHECKLIST ITEM
-- =====================================================================

INSERT INTO "GateChecklistItem" (
  "gateChecklistItemId",
  "gateId",
  "title",
  "isComplete",
  "completedById",
  "completedAt",
  "sortOrder"
) VALUES
  ('gate-check-001', 'gate-001', 'Architectural drawings reviewed', FALSE, NULL, NULL, 1),
  ('gate-check-002', 'gate-001', 'Structural engineer approval obtained', FALSE, NULL, NULL, 2),
  ('gate-check-003', 'gate-001', 'Regulatory compliance confirmed', FALSE, NULL, NULL, 3);

-- =====================================================================
-- RISK
-- =====================================================================

INSERT INTO "Risk" (
  "riskId",
  "contractId",
  "title",
  "description",
  "category",
  "probability",
  "impact",
  "status",
  "mitigationPlan",
  "ownerId",
  "raisedById",
  "reviewDate",
  "createdAt",
  "updatedAt"
) VALUES
  ('risk-001', 'cont-001', 'Supply Chain Delay', 'Delay in procurement of specialized MEP equipment', 'SUPPLY', 'MEDIUM', 'HIGH', 'OPEN', 'Identify alternative suppliers and place early orders', 'user-002', 'user-001', '2026-05-20', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- ASSUMPTION
-- =====================================================================

INSERT INTO "Assumption" (
  "assumptionId",
  "contractId",
  "title",
  "description",
  "status",
  "impact",
  "ownerId",
  "raisedById",
  "reviewDate",
  "createdAt",
  "updatedAt"
) VALUES
  ('assume-001', 'cont-001', 'Client Funding Availability', 'Assumed client will provide funding as per agreed schedule', 'ACTIVE', 'CRITICAL', 'user-003', 'user-001', '2026-06-30', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- AUDIT LOG
-- =====================================================================

INSERT INTO "AuditLog" (
  "auditLogId",
  "userId",
  "action",
  "entityType",
  "entityId",
  "oldValue",
  "newValue",
  "ipAddress",
  "userAgent",
  "createdAt"
) VALUES
  ('audit-001', 'user-001', 'CREATE', 'Contract', 'cont-001', NULL, '{"contractId": "cont-001", "status": "ACTIVE", "value": 4500000.00}', '192.168.1.100', 'Mozilla/5.0', CURRENT_TIMESTAMP),
  ('audit-002', 'user-001', 'CREATE', 'Project', 'proj-001', NULL, '{"projectId": "proj-001", "status": "ACTIVE", "name": "London Office Renovation"}', '192.168.1.100', 'Mozilla/5.0', CURRENT_TIMESTAMP);

-- =====================================================================
-- NOTIFICATION
-- =====================================================================

INSERT INTO "Notification" (
  "notificationId",
  "userId",
  "type",
  "title",
  "body",
  "metadata",
  "isRead",
  "readAt",
  "createdAt"
) VALUES
  ('notif-001', 'user-001', 'PROJECT_CREATED', 'Project Created', 'London Office Renovation project has been created', '{"projectId": "proj-001"}', FALSE, NULL, CURRENT_TIMESTAMP),
  ('notif-002', 'user-002', 'ACTION_ASSIGNED', 'Action Item Assigned', 'You have been assigned: Finalize Cost Plan Details', '{"actionItemId": "action-002"}', FALSE, NULL, CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: PARAMETER CATEGORY
-- =====================================================================

INSERT INTO "ParameterCategory" (
  "parameterCategoryId",
  "name",
  "description",
  "createdAt"
) VALUES
  ('param-cat-001', 'Building Characteristics', 'Core building parameters that drive cost estimation', CURRENT_TIMESTAMP),
  ('param-cat-002', 'Location Factors', 'Geographic and logistical parameters', CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: PARAMETER
-- =====================================================================

INSERT INTO "Parameter" (
  "parameterId",
  "parameterCategoryId",
  "name",
  "code",
  "description",
  "dataType",
  "unit",
  "minValue",
  "maxValue",
  "createdAt"
) VALUES
  ('param-001', 'param-cat-001', 'Gross Internal Area', 'GIA', 'Total gross internal area of building', 'DECIMAL', 'm2', 1000.00, 1000000.00, CURRENT_TIMESTAMP),
  ('param-002', 'param-cat-001', 'Number of Storeys', 'STOREYS', 'Total number of building storeys', 'INTEGER', 'NO', 1.00, 50.00, CURRENT_TIMESTAMP),
  ('param-003', 'param-cat-002', 'Location Factor', 'LOC_FACTOR', 'Regional cost adjustment factor', 'DECIMAL', 'RATIO', 0.50, 2.00, CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: PARAMETRIC MODEL
-- =====================================================================

INSERT INTO "ParametricModel" (
  "parametricModelId",
  "name",
  "description",
  "projectType",
  "status",
  "version",
  "baselineYear",
  "createdById",
  "createdAt",
  "updatedAt"
) VALUES
  ('param-model-001', 'Office Renovation Model v1', 'Parametric model for office renovation projects', 'OFFICE_RENOVATION', 'ACTIVE', '1.0', 2026, 'user-002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: MODEL PARAMETER
-- =====================================================================

INSERT INTO "ModelParameter" (
  "modelParameterId",
  "parametricModelId",
  "parameterId",
  "isRequired",
  "defaultValue",
  "sortOrder"
) VALUES
  ('model-param-001', 'param-model-001', 'param-001', TRUE, '45000', 1),
  ('model-param-002', 'param-model-001', 'param-002', TRUE, '5', 2),
  ('model-param-003', 'param-model-001', 'param-003', FALSE, '1.0', 3);

-- =====================================================================
-- ParametriX: COST RELATIONSHIP
-- =====================================================================

INSERT INTO "CostRelationship" (
  "costRelationshipId",
  "parametricModelId",
  "name",
  "description",
  "baselineValue",
  "currency",
  "formula",
  "createdAt"
) VALUES
  ('cost-rel-001', 'param-model-001', 'Structural Cost', 'Cost for structural renovation works', 1875000.00, 'GBP', 'GIA * StoreyFactor * StructuralRate * LocationFactor', CURRENT_TIMESTAMP),
  ('cost-rel-002', 'param-model-001', 'MEP Cost', 'Cost for mechanical, electrical, plumbing works', 2812500.00, 'GBP', 'GIA * MEPRate * LocationFactor', CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: COST RELATIONSHIP PARAMETER
-- =====================================================================

INSERT INTO "CostRelationshipParameter" (
  "relationshipParameterId",
  "costRelationshipId",
  "parameterId",
  "coefficient",
  "sortOrder"
) VALUES
  ('cost-rel-param-001', 'cost-rel-001', 'param-001', 150.0000, 1),
  ('cost-rel-param-002', 'cost-rel-001', 'param-002', 0.5000, 2),
  ('cost-rel-param-003', 'cost-rel-002', 'param-001', 75.0000, 1);

-- =====================================================================
-- ParametriX: PARAMETRIC ESTIMATE
-- =====================================================================

INSERT INTO "ParametricEstimate" (
  "parametricEstimateId",
  "costPlanId",
  "parametricModelId",
  "status",
  "estimatedValue",
  "currency",
  "confidenceLevel",
  "createdById",
  "createdAt",
  "updatedAt"
) VALUES
  ('param-est-001', 'cp-001', 'param-model-001', 'DRAFT', 4500000.00, 'GBP', 75.00, 'user-002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: ESTIMATE PARAMETER VALUE
-- =====================================================================

INSERT INTO "EstimateParameterValue" (
  "estimateParameterValueId",
  "parametricEstimateId",
  "parameterId",
  "value",
  "unit"
) VALUES
  ('est-param-val-001', 'param-est-001', 'param-001', '45000', 'm2'),
  ('est-param-val-002', 'param-est-001', 'param-002', '5', 'NO'),
  ('est-param-val-003', 'param-est-001', 'param-003', '1.0', 'RATIO');

-- =====================================================================
-- ParametriX: ESTIMATE OUTPUT VALUE
-- =====================================================================

INSERT INTO "EstimateOutputValue" (
  "estimateOutputValueId",
  "parametricEstimateId",
  "costRelationshipId",
  "outputValue",
  "unit"
) VALUES
  ('est-output-val-001', 'param-est-001', 'cost-rel-001', 1875000.00, 'GBP'),
  ('est-output-val-002', 'param-est-001', 'cost-rel-002', 2812500.00, 'GBP');

-- =====================================================================
-- ParametriX: CALIBRATION DATA SOURCE
-- =====================================================================

INSERT INTO "CalibrationDataSource" (
  "calibrationDataSourceId",
  "name",
  "description",
  "sourceType",
  "dataPoints",
  "createdAt"
) VALUES
  ('calib-source-001', 'Historical Office Renovations 2022-2026', 'Dataset of completed office renovation projects', 'HISTORICAL', 12, CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: CALIBRATION DATA POINT
-- =====================================================================

INSERT INTO "CalibrationDataPoint" (
  "calibrationDataPointId",
  "calibrationDataSourceId",
  "projectReference",
  "actualCost",
  "currency",
  "location",
  "date",
  "createdAt"
) VALUES
  ('calib-point-001', 'calib-source-001', 'REF-2024-001', 4050000.00, 'GBP', 'Manchester, UK', '2024-06-30', CURRENT_TIMESTAMP),
  ('calib-point-002', 'calib-source-001', 'REF-2023-001', 3800000.00, 'GBP', 'Birmingham, UK', '2023-09-15', CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: CALIBRATION DATA POINT PARAMETER
-- =====================================================================

INSERT INTO "CalibrationDataPointParameter" (
  "dataPointParameterId",
  "calibrationDataPointId",
  "parameterId",
  "value",
  "unit"
) VALUES
  ('calib-param-001', 'calib-point-001', 'param-001', '45000', 'm2'),
  ('calib-param-002', 'calib-point-001', 'param-002', '5', 'NO'),
  ('calib-param-003', 'calib-point-002', 'param-001', '42000', 'm2'),
  ('calib-param-004', 'calib-point-002', 'param-002', '5', 'NO');

-- =====================================================================
-- ParametriX: SENSITIVITY ANALYSIS
-- =====================================================================

INSERT INTO "SensitivityAnalysis" (
  "sensitivityAnalysisId",
  "parametricEstimateId",
  "parameterId",
  "baselineValue",
  "variationPercent",
  "sensitivityFactor",
  "impact",
  "createdAt"
) VALUES
  ('sens-001', 'param-est-001', 'param-001', '45000', 10.00, 0.9500, 'HIGH', CURRENT_TIMESTAMP),
  ('sens-002', 'param-est-001', 'param-003', '1.0', 15.00, 0.7200, 'MEDIUM', CURRENT_TIMESTAMP);

-- =====================================================================
-- ParametriX: RISK ADJUSTMENT
-- =====================================================================

INSERT INTO "RiskAdjustment" (
  "riskAdjustmentId",
  "parametricEstimateId",
  "description",
  "adjustmentPercent",
  "adjustmentAmount",
  "justification",
  "createdById",
  "createdAt"
) VALUES
  ('risk-adj-001', 'param-est-001', 'Supply chain contingency', 5.00, 225000.00, 'Added for potential supply chain delays and material price inflation', 'user-002', CURRENT_TIMESTAMP);

-- =====================================================================
-- End of Seed Data
-- =====================================================================

COMMIT;
