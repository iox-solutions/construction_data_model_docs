-- Final Schema Setup - Indexes, Views, and Utility Functions
-- Completes schema optimization and provides useful views for reporting

-- =====================================================================
-- Additional Performance Indexes
-- =====================================================================

-- Frequently queried combinations
CREATE INDEX "idx_Contract_project_status" ON "Contract"("projectId", "status");
CREATE INDEX "idx_CostPlan_contract_status" ON "CostPlan"("contractId", "status");
CREATE INDEX "idx_Document_project_folder_status" ON "Document"("projectId", "folderId", "status");
CREATE INDEX "idx_Meeting_project_scheduled" ON "Meeting"("projectId", "scheduledAt");
CREATE INDEX "idx_ActionItem_project_owner_status" ON "ActionItem"("projectId", "ownerId", "status");
CREATE INDEX "idx_UserRole_user_isPrimary" ON "UserRole"("userId", "isPrimary");
CREATE INDEX "idx_AuditLog_entity_timestamp" ON "AuditLog"("entityType", "entityId", "createdAt");

-- Time-range queries
CREATE INDEX "idx_Contract_dateRange" ON "Contract"("startDate", "endDate");
CREATE INDEX "idx_Meeting_timeRange" ON "Meeting"("scheduledAt");
CREATE INDEX "idx_AuditLog_dateRange" ON "AuditLog"("createdAt");

-- Status and lifecycle queries
CREATE INDEX "idx_Transmittal_status_date" ON "Transmittal"("status", "sentAt");
CREATE INDEX "idx_Query_status_date" ON "Query"("status", "createdAt");
CREATE INDEX "idx_Risk_status_contract" ON "Risk"("status", "contractId");

-- =====================================================================
-- Materialized Views for Reporting
-- =====================================================================

-- Project Summary View
CREATE VIEW "ProjectSummary" AS
SELECT
  p."projectId",
  p."number",
  p."name",
  c."name" AS "clientName",
  COUNT(DISTINCT cont."contractId") AS "contractCount",
  COUNT(DISTINCT f."folderId") AS "documentFolderCount",
  COUNT(DISTINCT m."meetingId") AS "meetingCount",
  COUNT(DISTINCT a."actionItemId") AS "actionItemCount",
  p."status",
  p."startDate",
  p."endDate",
  p."createdAt"
FROM "Project" p
LEFT JOIN "Client" c ON p."clientId" = c."clientId"
LEFT JOIN "Contract" cont ON p."projectId" = cont."projectId"
LEFT JOIN "Folder" f ON p."projectId" = f."projectId"
LEFT JOIN "Meeting" m ON p."projectId" = m."projectId"
LEFT JOIN "ActionItem" a ON p."projectId" = a."projectId"
GROUP BY p."projectId", p."number", p."name", c."name", p."status", p."startDate", p."endDate", p."createdAt";

-- Contract Status Summary
CREATE VIEW "ContractStatusSummary" AS
SELECT
  c."contractId",
  c."number",
  c."title",
  c."status",
  c."value",
  c."currency",
  COUNT(DISTINCT cp."costPlanId") AS "costPlanCount",
  COUNT(DISTINCT bo."boqId") AS "boqCount",
  COUNT(DISTINCT q."queryId") AS "queryCount",
  COUNT(DISTINCT r."riskId") AS "riskCount",
  c."startDate",
  c."endDate",
  c."createdAt"
FROM "Contract" c
LEFT JOIN "CostPlan" cp ON c."contractId" = cp."contractId"
LEFT JOIN "BOQ" bo ON c."contractId" = bo."contractId"
LEFT JOIN "Query" q ON c."contractId" = q."contractId"
LEFT JOIN "Risk" r ON c."contractId" = r."contractId"
GROUP BY c."contractId", c."number", c."title", c."status", c."value", c."currency", c."startDate", c."endDate", c."createdAt";

-- User Activity Summary
CREATE VIEW "UserActivitySummary" AS
SELECT
  u."userId",
  u."email",
  u."firstName",
  u."lastName",
  COUNT(DISTINCT al."auditLogId") AS "actionCount",
  COUNT(DISTINCT ai."actionItemId") AS "ownedActionItems",
  COUNT(DISTINCT pt."projectTeamId") AS "projectsActive",
  MAX(al."createdAt") AS "lastActivity",
  u."createdAt"
FROM "User" u
LEFT JOIN "AuditLog" al ON u."userId" = al."userId"
LEFT JOIN "ActionItem" ai ON u."userId" = ai."ownerId"
LEFT JOIN "ProjectTeam" pt ON u."userId" = pt."userId" AND pt."leftAt" IS NULL
GROUP BY u."userId", u."email", u."firstName", u."lastName", u."createdAt";

-- Open Action Items by Owner
CREATE VIEW "OpenActionItemsByOwner" AS
SELECT
  a."ownerId",
  u."firstName" || ' ' || u."lastName" AS "ownerName",
  COUNT(*) AS "openCount",
  MIN(a."dueDate") AS "nextDueDate",
  COUNT(CASE WHEN a."dueDate" < CURRENT_DATE THEN 1 END) AS "overdueCount"
FROM "ActionItem" a
JOIN "User" u ON a."ownerId" = u."userId"
WHERE a."status" IN ('OPEN', 'IN_PROGRESS')
GROUP BY a."ownerId", u."firstName", u."lastName";

-- Contract Cost Summary
CREATE VIEW "ContractCostSummary" AS
SELECT
  c."contractId",
  c."number",
  c."title",
  c."value" AS "contractValue",
  SUM(CASE WHEN cp."status" = 'APPROVED' THEN cp."totalCost" ELSE 0 END) AS "approvedCostPlan",
  SUM(CASE WHEN bo."status" IN ('ISSUED', 'AGREED') THEN (
    SELECT COALESCE(SUM("itemTotal"), 0) FROM "BOQItem" bi
    WHERE bi."boqSectionId" IN (SELECT "boqSectionId" FROM "BOQSection" WHERE "boqBillId" IN (SELECT "boqBillId" FROM "BOQBill" WHERE "boqId" = bo."boqId"))
  ) ELSE 0 END) AS "boqTotal",
  COUNT(DISTINCT v."variationOrderId") AS "variationCount",
  c."currency",
  c."status"
FROM "Contract" c
LEFT JOIN "CostPlan" cp ON c."contractId" = cp."contractId"
LEFT JOIN "BOQ" bo ON c."contractId" = bo."contractId"
LEFT JOIN "VariationOrder" v ON c."contractId" = v."contractId"
GROUP BY c."contractId", c."number", c."title", c."value", c."currency", c."status";

-- Document Transmission Audit
CREATE VIEW "DocumentTransmissionAudit" AS
SELECT
  d."documentId",
  d."title",
  d."documentNumber",
  COUNT(DISTINCT t."transmittalId") AS "transmissionCount",
  MAX(t."sentAt") AS "lastTransmitted",
  COUNT(DISTINCT dv."documentVersionId") AS "versionCount",
  d."status",
  d."createdAt"
FROM "Document" d
LEFT JOIN "TransmittalDocument" td ON d."documentId" = td."documentId"
LEFT JOIN "Transmittal" t ON td."transmittalId" = t."transmittalId"
LEFT JOIN "DocumentVersion" dv ON d."documentId" = dv."documentId"
GROUP BY d."documentId", d."title", d."documentNumber", d."status", d."createdAt";

-- =====================================================================
-- Useful Utility Functions
-- =====================================================================

-- Function to get user's full name
CREATE OR REPLACE FUNCTION get_user_full_name(user_id TEXT)
RETURNS TEXT AS $$
SELECT "firstName" || ' ' || "lastName" FROM "User" WHERE "userId" = user_id;
$$ LANGUAGE SQL STABLE;

-- Function to get overdue action items count for a user
CREATE OR REPLACE FUNCTION get_overdue_actions(user_id TEXT)
RETURNS INTEGER AS $$
SELECT COUNT(*) FROM "ActionItem"
WHERE "ownerId" = user_id
  AND "status" IN ('OPEN', 'IN_PROGRESS')
  AND "dueDate" < CURRENT_DATE;
$$ LANGUAGE SQL STABLE;

-- Function to get project total contract value
CREATE OR REPLACE FUNCTION get_project_total_value(project_id TEXT)
RETURNS DECIMAL AS $$
SELECT COALESCE(SUM("value"), 0) FROM "Contract" WHERE "projectId" = project_id;
$$ LANGUAGE SQL STABLE;

-- Function to get user access level for an organization
CREATE OR REPLACE FUNCTION get_user_org_access_level(user_id TEXT, org_id TEXT)
RETURNS INTEGER AS $$
SELECT COALESCE(MAX(r."level"), 0)
FROM "UserRole" ur
JOIN "Role" r ON ur."roleId" = r."roleId"
WHERE ur."userId" = user_id AND ur."organizationId" = org_id;
$$ LANGUAGE SQL STABLE;

-- =====================================================================
-- Schema Documentation Comments
-- =====================================================================

COMMENT ON TABLE "User" IS 'Core user identity and authentication. PII-flagged: email, firstName, lastName, phone, avatar';
COMMENT ON TABLE "Role" IS 'Named permission sets with hierarchical organization';
COMMENT ON TABLE "UserRole" IS 'Assignment of roles to users with global/org/project scoping';
COMMENT ON TABLE "Contract" IS 'Top-level contract entity with financial and temporal scope';
COMMENT ON TABLE "CostPlan" IS 'Estimate and cost tracking at contract level';
COMMENT ON TABLE "Project" IS 'Primary scoping entity for all work deliverables';
COMMENT ON TABLE "Document" IS 'Logical document record with versioning via DocumentVersion';
COMMENT ON TABLE "Transmittal" IS 'Formal dispatch record with recipient tracking';
COMMENT ON TABLE "Meeting" IS 'Project meetings with attendees, agenda, and action items';
COMMENT ON TABLE "AuditLog" IS 'Immutable audit trail. PII-flagged: ipAddress, userAgent';
COMMENT ON TABLE "Query" IS 'Planning-phase clarification requests scoped to Contract';
COMMENT ON TABLE "TenderQuery" IS 'Tender-phase clarification requests from bidders';
COMMENT ON TABLE "BOQ" IS 'Bill of Quantities hierarchically organized by Bill > Section > Item';
COMMENT ON TABLE "Risk" IS 'Formally tracked risks with probability/impact and mitigation';
COMMENT ON TABLE "Notification" IS 'System-generated alerts to users by event type';

-- =====================================================================
-- End Schema Setup
-- =====================================================================
