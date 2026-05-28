-- IOX Seed Data (CORRECTED for actual schema)
-- Minimal seed data that matches the actual migration schema
--
-- This version is conservative - only includes columns that definitely exist

BEGIN;

-- Organizations
INSERT INTO "Organization" ("organizationId", "name", "type", "code", "address", "phone", "email", "website", "status", "createdAt")
VALUES
  ('org-client-001', 'Southgate Property Developers', 'CLIENT', 'SGD', '50 Development Lane, London', '+44 20 7946 0958', 'info@southgatedev.co.uk', 'www.southgatedev.co.uk', 'ACTIVE', NOW()),
  ('org-contractor-001', 'BuildCorp Construction', 'CONTRACTOR', 'BDC', '100 Build Street, Manchester', '+44 161 496 0000', 'contracts@buildcorp.co.uk', 'www.buildcorp.co.uk', 'ACTIVE', NOW()),
  ('org-consultant-001', 'Quantrust QS', 'CONSULTANT', 'QTR', '20 Quantity Court, Birmingham', '+44 121 236 3232', 'enquiry@quantrust.co.uk', 'www.quantrust.co.uk', 'ACTIVE', NOW());

-- Users
INSERT INTO "User" ("userId", "email", "firstName", "lastName", "phone", "password", "status", "createdAt")
VALUES
  ('user-001', 'sarah.johnson@southgate.co.uk', 'Sarah', 'Johnson', '+44 20 7946 0958', 'hashed_pwd', 'ACTIVE', NOW()),
  ('user-002', 'james.wilson@buildcorp.co.uk', 'James', 'Wilson', '+44 161 496 0001', 'hashed_pwd', 'ACTIVE', NOW()),
  ('user-003', 'rachel.smith@quantrust.co.uk', 'Rachel', 'Smith', '+44 121 236 3233', 'hashed_pwd', 'ACTIVE', NOW());

-- Roles
INSERT INTO "Role" ("roleId", "code", "name", "level", "track", "createdAt")
VALUES
  ('role-director', 'PROJECT_DIRECTOR', 'Project Director', 10, 'MANAGEMENT', NOW()),
  ('role-pm', 'PROJECT_MANAGER', 'Project Manager', 8, 'MANAGEMENT', NOW()),
  ('role-qs', 'QUANTITY_SURVEYOR', 'Quantity Surveyor', 7, 'TECHNICAL', NOW());

-- Permissions
INSERT INTO "Permission" ("permissionId", "code", "module", "action", "createdAt")
VALUES
  ('perm-contract-create', 'CONTRACT_CREATE', 'CONTRACT', 'CREATE', NOW()),
  ('perm-budget-view', 'BUDGET_VIEW', 'BUDGET', 'VIEW', NOW());

-- Role-Permission mapping
INSERT INTO "RolePermission" ("rolePermissionId", "roleId", "permissionId", "createdAt")
VALUES
  ('rp-001', 'role-director', 'perm-contract-create', NOW()),
  ('rp-002', 'role-qs', 'perm-budget-view', NOW());

-- Department
INSERT INTO "Department" ("departmentId", "organizationId", "code", "name", "headUserId", "createdAt")
VALUES
  ('dept-001', 'org-client-001', 'DEV-PM', 'Project Management', 'user-001', NOW()),
  ('dept-002', 'org-contractor-001', 'BDC-EXEC', 'Execution', 'user-002', NOW());

-- Client
INSERT INTO "Client" ("clientId", "organizationId", "name", "createdAt")
VALUES
  ('client-001', 'org-client-001', 'Southgate Property Developers', NOW());

-- Project
INSERT INTO "Project" ("projectId", "clientId", "number", "name", "status", "location", "startDate", "endDate", "createdAt")
VALUES
  ('proj-001', 'client-001', 'SBP-2026-001', 'Southgate Business Park', 'ACTIVE', 'London, SE15', NOW() - INTERVAL '12 months', NOW() + INTERVAL '18 months', NOW());

-- BenchmarkProject
INSERT INTO "BenchmarkProject" ("benchmarkProjectId", "name", "grossInternalArea", "totalCost", "costPerM2", "costPerGFA", "location", "baseDate", "createdAt", "createdById")
VALUES
  ('bench-001', 'Similar Business Park - Oxford', 28500.00, 57000000.00, 2000.00, 2000.00, 'Oxford, UK', '2025-06-01', NOW(), 'user-001');

-- User Roles
INSERT INTO "UserRole" ("userRoleId", "userId", "roleId", "organizationId", "projectId", "isPrimary", "assignedById", "assignedAt", "createdAt")
VALUES
  ('ur-001', 'user-001', 'role-director', 'org-client-001', 'proj-001', TRUE, 'user-001', NOW(), NOW()),
  ('ur-002', 'user-002', 'role-pm', 'org-contractor-001', 'proj-001', TRUE, 'user-001', NOW(), NOW()),
  ('ur-003', 'user-003', 'role-qs', 'org-consultant-001', 'proj-001', TRUE, 'user-001', NOW(), NOW());

-- CommunicationProtocol
INSERT INTO "CommunicationProtocol" ("communicationProtocolId", "projectId", "responseTimeframeDays", "namingConvention", "createdAt")
VALUES
  ('proto-001', 'proj-001', 5, 'SBP-[YYYY]-[MM]-[DD]-[SEQ]', NOW());

-- NoticeOfWin
INSERT INTO "NoticeOfWin" ("noticeOfWinId", "projectId", "awardDate", "awardValue", "projectBrief", "createdAt")
VALUES
  ('now-001', 'proj-001', NOW() - INTERVAL '12 months', 45000000.00, '{"projectType": "MIXED_USE", "units": 150, "gfa": 28500}'::JSONB, NOW());

-- Contract
INSERT INTO "Contract" ("contractId", "projectId", "clientOrganizationId", "contractorId", "number", "title", "contractType", "status", "value", "currency", "startDate", "endDate", "createdAt", "updatedAt")
VALUES
  ('contract-001', 'proj-001', 'org-client-001', 'org-contractor-001', 'SBP-C-001', 'Main Contract', 'MAIN_CONTRACT', 'ACTIVE', 45000000.00, 'GBP', NOW() - INTERVAL '12 months', NOW() + INTERVAL '18 months', NOW(), NOW());

-- Contractor
INSERT INTO "Contractor" ("contractorId", "contractId", "organizationId", "role", "appointmentDate")
VALUES
  ('con-001', 'contract-001', 'org-contractor-001', 'MAIN_CONTRACTOR', NOW() - INTERVAL '12 months');

-- Budget
INSERT INTO "Budget" ("budgetId", "contractId", "title", "status", "totalValue", "currency", "createdAt")
VALUES
  ('budget-001', 'contract-001', 'Project Budget', 'APPROVED', 45000000.00, 'GBP', NOW());

-- CostPlan
INSERT INTO "CostPlan" ("costPlanId", "contractId", "title", "createdById", "benchmarkProjectId", "status", "totalCost", "currency", "createdAt", "updatedAt")
VALUES
  ('cp-001', 'contract-001', 'Baseline Cost Plan', 'user-003', 'bench-001', 'APPROVED', 45000000.00, 'GBP', NOW(), NOW());

-- PaymentSchedule
INSERT INTO "PaymentSchedule" ("paymentScheduleId", "contractId", "title", "totalValue", "currency", "createdAt")
VALUES
  ('ps-001', 'contract-001', 'Payment Schedule', 45000000.00, 'GBP', NOW());

-- PaymentScheduleItem
INSERT INTO "PaymentScheduleItem" ("paymentScheduleItemId", "paymentScheduleId", "description", "paymentValue", "dueDate", "sortOrder")
VALUES
  ('psi-001', 'ps-001', 'Mobilization', 2250000.00, NOW() - INTERVAL '9 months', 1),
  ('psi-002', 'ps-001', 'Structural Works', 13500000.00, NOW() + INTERVAL '6 months', 2),
  ('psi-003', 'ps-001', 'Finishes', 22500000.00, NOW() + INTERVAL '12 months', 3),
  ('psi-004', 'ps-001', 'Handover', 6750000.00, NOW() + INTERVAL '18 months', 4);

-- CertifiedPayment
INSERT INTO "CertifiedPayment" ("certifiedPaymentId", "contractId", "reference", "certificationDate", "certifiedAmount", "currency", "certifiedById", "createdAt")
VALUES
  ('cpa-001', 'contract-001', 'CERT-001', NOW() - INTERVAL '6 months', 2250000.00, 'GBP', 'user-003', NOW());

-- Folder
INSERT INTO "Folder" ("folderId", "projectId", "parentFolderId", "folderPath", "sortOrder", "createdAt")
VALUES
  ('fold-root', 'proj-001', NULL, 'SBP', 0, NOW()),
  ('fold-contracts', 'proj-001', 'fold-root', 'SBP/Contracts', 1, NOW());

-- Document
INSERT INTO "Document" ("documentId", "projectId", "folderId", "uploadedById", "documentNumber", "title", "type", "status", "createdAt")
VALUES
  ('doc-001', 'proj-001', 'fold-contracts', 'user-001', 'DOC-001', 'Main Contract', 'CONTRACT', 'APPROVED', NOW());

-- DocumentVersion
INSERT INTO "DocumentVersion" ("documentVersionId", "documentId", "uploadedById", "versionLabel", "fileUrl", "fileSize", "mimeType", "createdAt")
VALUES
  ('dv-001', 'doc-001', 'user-001', 'v1-signed', 'https://storage.example.com/contract-v1.pdf', 2500000, 'application/pdf', NOW());

-- Update Document currentVersionId
UPDATE "Document" SET "currentVersionId" = 'dv-001' WHERE "documentId" = 'doc-001';

-- Risk
INSERT INTO "Risk" ("riskId", "contractId", "title", "description", "category", "probability", "impact", "mitigationPlan", "ownerId", "raisedById", "status", "createdAt")
VALUES
  ('risk-001', 'contract-001', 'Material Cost Inflation', 'Steel and concrete prices may increase', 'COMMERCIAL', 'MEDIUM', 'HIGH', 'Lock in supplier rates', 'user-002', 'user-002', 'OPEN', NOW());

-- EarlyWarning
INSERT INTO "EarlyWarning" ("earlyWarningId", "contractId", "title", "description", "status", "raisedById", "assignedToId", "createdAt", "updatedAt")
VALUES
  ('ew-001', 'contract-001', 'Steel Delivery Delay', 'Fabricator reports 2-week delay', 'OPEN', 'user-002', 'user-001', NOW(), NOW());

-- Meeting
INSERT INTO "Meeting" ("meetingId", "projectId", "type", "status", "scheduledAt", "location", "createdAt")
VALUES
  ('mtg-001', 'proj-001', 'PROJECT_BOARD', 'SCHEDULED', NOW() - INTERVAL '2 months', 'London Office', NOW());

-- MeetingAttendee
INSERT INTO "MeetingAttendee" ("meetingAttendeeId", "meetingId", "userId", "status", "createdAt")
VALUES
  ('ma-001', 'mtg-001', 'user-001', 'ATTENDED', NOW()),
  ('ma-002', 'mtg-001', 'user-002', 'ATTENDED', NOW());

-- ActionItem
INSERT INTO "ActionItem" ("actionItemId", "projectId", "meetingId", "ownerId", "title", "description", "status", "priority", "dueDate", "createdAt")
VALUES
  ('ai-001', 'proj-001', 'mtg-001', 'user-002', 'Confirm structural sequence', 'Finalize construction sequence', 'OPEN', 'HIGH', NOW() + INTERVAL '2 weeks', NOW());

-- Gate
INSERT INTO "Gate" ("gateId", "contractId", "sortOrder", "gateName", "description", "status", "targetDate", "createdAt")
VALUES
  ('gate-001', 'contract-001', 1, 'Design Approval', 'Final design approval', 'PASSED', NOW() - INTERVAL '6 months', NOW()),
  ('gate-002', 'contract-001', 2, 'Works Start', 'Mobilization complete', 'IN_PROGRESS', NOW() + INTERVAL '3 months', NOW());

-- AuditLog
INSERT INTO "AuditLog" ("auditLogId", "userId", "action", "entityType", "entityId", "oldValue", "newValue", "ipAddress", "userAgent", "createdAt")
VALUES
  ('audit-001', 'user-001', 'CREATE', 'Project', 'proj-001', NULL, '{"projectId": "proj-001", "name": "Southgate"}'::JSONB, '192.168.1.100', 'Mozilla', NOW());

-- Notification
INSERT INTO "Notification" ("notificationId", "userId", "type", "title", "message", "metadata", "isRead", "createdAt")
VALUES
  ('notif-001', 'user-001', 'EARLY_WARNING', 'EW: Steel Delivery', 'Delivery delayed 2 weeks', '{"entityId": "ew-001"}'::JSONB, FALSE, NOW());

COMMIT;

-- Verification
SELECT
  (SELECT COUNT(*) FROM "Project") as projects,
  (SELECT COUNT(*) FROM "Contract") as contracts,
  (SELECT COUNT(*) FROM "User") as users,
  (SELECT COUNT(*) FROM "Risk") as risks,
  (SELECT COUNT(*) FROM "ActionItem") as actions;
