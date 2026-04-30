-- IOX Core v1.3 through v1.11 - Combined segment release
-- Multiple segments: Meetings & Actions, Documents & Transmittals, Cost Plan, BOQ & Procurement,
-- QA, Queries, Tender & Gates, Workflow & Templates, Support & Governance
-- Approved: 2026-03-06 through 2026-04-29

-- =====================================================================
-- SEGMENT: Meetings & Actions (v1.3)
-- =====================================================================

CREATE TABLE "Meeting" (
  "meetingId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "type" TEXT,
  "scheduledAt" TIMESTAMP NOT NULL,
  "location" TEXT,
  "status" TEXT NOT NULL DEFAULT 'SCHEDULED',
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Meeting_projectId" ON "Meeting"("projectId");
CREATE INDEX "idx_Meeting_status" ON "Meeting"("status");

CREATE TABLE "MeetingAttendee" (
  "meetingAttendeeId" TEXT PRIMARY KEY,
  "meetingId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'INVITED',
  UNIQUE("meetingId", "userId")
);

CREATE INDEX "idx_MeetingAttendee_meetingId" ON "MeetingAttendee"("meetingId");
CREATE INDEX "idx_MeetingAttendee_userId" ON "MeetingAttendee"("userId");

CREATE TABLE "MeetingAgendaItem" (
  "meetingAgendaItemId" TEXT PRIMARY KEY,
  "meetingId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "sortOrder" INTEGER NOT NULL,
  "ownerId" TEXT,
  "durationMinutes" INTEGER
);

CREATE INDEX "idx_MeetingAgendaItem_meetingId" ON "MeetingAgendaItem"("meetingId");
CREATE INDEX "idx_MeetingAgendaItem_ownerId" ON "MeetingAgendaItem"("ownerId");

CREATE TABLE "MeetingMinutes" (
  "meetingMinutesId" TEXT PRIMARY KEY,
  "meetingId" TEXT NOT NULL,
  "content" TEXT NOT NULL,
  "approvedById" TEXT,
  "approvedAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("meetingId")
);

CREATE INDEX "idx_MeetingMinutes_meetingId" ON "MeetingMinutes"("meetingId");
CREATE INDEX "idx_MeetingMinutes_approvedById" ON "MeetingMinutes"("approvedById");

CREATE TABLE "ActionItem" (
  "actionItemId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "meetingId" TEXT,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "ownerId" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'OPEN',
  "priority" TEXT,
  "dueDate" DATE,
  "completedAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_ActionItem_projectId" ON "ActionItem"("projectId");
CREATE INDEX "idx_ActionItem_meetingId" ON "ActionItem"("meetingId");
CREATE INDEX "idx_ActionItem_ownerId" ON "ActionItem"("ownerId");
CREATE INDEX "idx_ActionItem_status" ON "ActionItem"("status");

-- =====================================================================
-- SEGMENT: Documents & Transmittals (v1.4)
-- =====================================================================

CREATE TABLE "Folder" (
  "folderId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "parentFolderId" TEXT,
  "name" TEXT NOT NULL,
  "sortOrder" INTEGER,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Folder_projectId" ON "Folder"("projectId");
CREATE INDEX "idx_Folder_parentFolderId" ON "Folder"("parentFolderId");

CREATE TABLE "Document" (
  "documentId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "folderId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "documentNumber" TEXT,
  "type" TEXT,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "uploadedById" TEXT NOT NULL,
  "currentVersionId" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Document_projectId" ON "Document"("projectId");
CREATE INDEX "idx_Document_folderId" ON "Document"("folderId");
CREATE INDEX "idx_Document_status" ON "Document"("status");

CREATE TABLE "DocumentVersion" (
  "documentVersionId" TEXT PRIMARY KEY,
  "documentId" TEXT NOT NULL,
  "versionLabel" TEXT NOT NULL,
  "fileUrl" TEXT NOT NULL,
  "fileSize" INTEGER,
  "mimeType" TEXT,
  "uploadedById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("documentId", "versionLabel")
);

CREATE INDEX "idx_DocumentVersion_documentId" ON "DocumentVersion"("documentId");

CREATE TABLE "Drawing" (
  "drawingId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "drawingNumber" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "discipline" TEXT,
  "revision" TEXT,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "fileUrl" TEXT,
  "uploadedById" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("projectId", "drawingNumber")
);

CREATE INDEX "idx_Drawing_projectId" ON "Drawing"("projectId");
CREATE INDEX "idx_Drawing_status" ON "Drawing"("status");

CREATE TABLE "Transmittal" (
  "transmittalId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "transmittalNumber" TEXT NOT NULL,
  "subject" TEXT NOT NULL,
  "sentById" TEXT NOT NULL,
  "recipientUserId" TEXT,
  "recipientName" TEXT,
  "recipientEmail" TEXT,
  "sentAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "responseRequiredBy" DATE,
  "status" TEXT NOT NULL DEFAULT 'SENT',
  "notes" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("projectId", "transmittalNumber")
);

CREATE INDEX "idx_Transmittal_projectId" ON "Transmittal"("projectId");
CREATE INDEX "idx_Transmittal_sentById" ON "Transmittal"("sentById");
CREATE INDEX "idx_Transmittal_status" ON "Transmittal"("status");

CREATE TABLE "TransmittalDocument" (
  "transmittalDocumentId" TEXT PRIMARY KEY,
  "transmittalId" TEXT NOT NULL,
  "documentId" TEXT NOT NULL,
  "documentVersionId" TEXT NOT NULL,
  UNIQUE("transmittalId", "documentId")
);

CREATE INDEX "idx_TransmittalDocument_transmittalId" ON "TransmittalDocument"("transmittalId");
CREATE INDEX "idx_TransmittalDocument_documentId" ON "TransmittalDocument"("documentId");

-- =====================================================================
-- SEGMENT: Cost Plan Detail (v1.5)
-- =====================================================================

CREATE TABLE "CostPlanElement" (
  "costPlanElementId" TEXT PRIMARY KEY,
  "costPlanId" TEXT NOT NULL,
  "costPlanAreaId" TEXT,
  "title" TEXT NOT NULL,
  "code" TEXT,
  "quantity" DECIMAL(19,2),
  "unit" TEXT,
  "unitRate" DECIMAL(19,2),
  "elementCost" DECIMAL(19,2),
  "currency" TEXT,
  "sortOrder" INTEGER,
  "notes" TEXT
);

CREATE INDEX "idx_CostPlanElement_costPlanId" ON "CostPlanElement"("costPlanId");
CREATE INDEX "idx_CostPlanElement_costPlanAreaId" ON "CostPlanElement"("costPlanAreaId");

CREATE TABLE "CostPlanArea" (
  "costPlanAreaId" TEXT PRIMARY KEY,
  "costPlanId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "grossInternalArea" DECIMAL(19,2),
  "sortOrder" INTEGER,
  "notes" TEXT
);

CREATE INDEX "idx_CostPlanArea_costPlanId" ON "CostPlanArea"("costPlanId");

CREATE TABLE "BenchmarkProject" (
  "benchmarkProjectId" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "grossInternalArea" DECIMAL(19,2),
  "totalCost" DECIMAL(19,2),
  "costPerM2" DECIMAL(19,2),
  "currency" TEXT,
  "location" TEXT,
  "costPerGFA" DECIMAL(19,2),
  "baseDate" DATE,
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_BenchmarkProject_createdById" ON "BenchmarkProject"("createdById");

CREATE TABLE "VEItem" (
  "veItemId" TEXT PRIMARY KEY,
  "costPlanId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "estimatedSaving" DECIMAL(19,2),
  "currency" TEXT,
  "status" TEXT NOT NULL DEFAULT 'PROPOSED',
  "raisedById" TEXT NOT NULL,
  "reviewedById" TEXT,
  "reviewedAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_VEItem_costPlanId" ON "VEItem"("costPlanId");
CREATE INDEX "idx_VEItem_status" ON "VEItem"("status");

-- =====================================================================
-- SEGMENT: BOQ & Procurement (v1.6)
-- =====================================================================

CREATE TABLE "BOQStrategy" (
  "boqStrategyId" TEXT PRIMARY KEY
);

CREATE TABLE "BOQ" (
  "boqId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId")
);

CREATE INDEX "idx_BOQ_contractId" ON "BOQ"("contractId");
CREATE INDEX "idx_BOQ_status" ON "BOQ"("status");

CREATE TABLE "BOQBill" (
  "boqBillId" TEXT PRIMARY KEY,
  "boqId" TEXT NOT NULL,
  "billNumber" INTEGER NOT NULL,
  "organizationId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "sortOrder" INTEGER,
  UNIQUE("boqId", "billNumber")
);

CREATE INDEX "idx_BOQBill_boqId" ON "BOQBill"("boqId");
CREATE INDEX "idx_BOQBill_organizationId" ON "BOQBill"("organizationId");

CREATE TABLE "BOQSection" (
  "boqSectionId" TEXT PRIMARY KEY,
  "boqBillId" TEXT NOT NULL,
  "sectionNumber" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "sortOrder" INTEGER,
  UNIQUE("boqBillId", "sectionNumber")
);

CREATE INDEX "idx_BOQSection_boqBillId" ON "BOQSection"("boqBillId");

CREATE TABLE "BOQItem" (
  "boqItemId" TEXT PRIMARY KEY,
  "boqSectionId" TEXT NOT NULL,
  "itemNumber" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "quantity" DECIMAL(19,2),
  "unit" TEXT,
  "unitRate" DECIMAL(19,2),
  "itemTotal" DECIMAL(19,2),
  "notes" TEXT,
  UNIQUE("boqSectionId", "itemNumber")
);

CREATE INDEX "idx_BOQItem_boqSectionId" ON "BOQItem"("boqSectionId");

CREATE TABLE "BOQVersion" (
  "boqVersionId" TEXT PRIMARY KEY,
  "boqId" TEXT NOT NULL,
  "versionLabel" TEXT NOT NULL,
  "snapshot" JSONB NOT NULL,
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("boqId", "versionLabel")
);

CREATE INDEX "idx_BOQVersion_boqId" ON "BOQVersion"("boqId");

CREATE TABLE "WorkOrder" (
  "workOrderId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "number" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "issuedDate" DATE,
  "targetCompletionDate" DATE,
  "status" TEXT NOT NULL DEFAULT 'ISSUED',
  "issuedById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId", "number")
);

CREATE INDEX "idx_WorkOrder_contractId" ON "WorkOrder"("contractId");
CREATE INDEX "idx_WorkOrder_status" ON "WorkOrder"("status");

-- =====================================================================
-- SEGMENT: QA (v1.7) - Stubs
-- =====================================================================

CREATE TABLE "Checklist" (
  "checklistId" TEXT PRIMARY KEY
);

CREATE TABLE "ChecklistItem" (
  "checklistItemId" TEXT PRIMARY KEY,
  "checklistId" TEXT NOT NULL
);

CREATE TABLE "QASheet" (
  "qaSheetId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'OPEN'
);

CREATE INDEX "idx_QASheet_projectId" ON "QASheet"("projectId");

-- =====================================================================
-- SEGMENT: Queries (v1.8)
-- =====================================================================

CREATE TABLE "Query" (
  "queryId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "reference" TEXT NOT NULL,
  "subject" TEXT NOT NULL,
  "body" TEXT NOT NULL,
  "raisedById" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'OPEN',
  "responseRequiredBy" DATE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId", "reference")
);

CREATE INDEX "idx_Query_contractId" ON "Query"("contractId");
CREATE INDEX "idx_Query_status" ON "Query"("status");

CREATE TABLE "QueryResponse" (
  "queryResponseId" TEXT PRIMARY KEY,
  "queryId" TEXT NOT NULL,
  "body" TEXT NOT NULL,
  "respondedById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_QueryResponse_queryId" ON "QueryResponse"("queryId");

CREATE TABLE "QueryAttachment" (
  "queryAttachmentId" TEXT PRIMARY KEY,
  "queryId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "fileUrl" TEXT,
  "externalUrl" TEXT,
  "mimeType" TEXT,
  "fileSize" INTEGER,
  "uploadedById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_QueryAttachment_queryId" ON "QueryAttachment"("queryId");

-- =====================================================================
-- SEGMENT: Tender & Gates (v1.9)
-- =====================================================================

CREATE TABLE "Gate" (
  "gateId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "sortOrder" INTEGER NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'PENDING',
  "targetDate" DATE,
  "passedAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Gate_contractId" ON "Gate"("contractId");
CREATE INDEX "idx_Gate_status" ON "Gate"("status");

CREATE TABLE "GateChecklistItem" (
  "gateChecklistItemId" TEXT PRIMARY KEY,
  "gateId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "isComplete" BOOLEAN NOT NULL DEFAULT FALSE,
  "completedById" TEXT,
  "completedAt" TIMESTAMP,
  "sortOrder" INTEGER NOT NULL
);

CREATE INDEX "idx_GateChecklistItem_gateId" ON "GateChecklistItem"("gateId");

CREATE TABLE "TenderQuery" (
  "tenderQueryId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "reference" TEXT NOT NULL,
  "subject" TEXT NOT NULL,
  "body" TEXT NOT NULL,
  "raisedByName" TEXT NOT NULL,
  "raisedByEmail" TEXT,
  "status" TEXT NOT NULL DEFAULT 'OPEN',
  "responseRequiredBy" DATE,
  "response" TEXT,
  "respondedById" TEXT,
  "respondedAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId", "reference")
);

CREATE INDEX "idx_TenderQuery_contractId" ON "TenderQuery"("contractId");
CREATE INDEX "idx_TenderQuery_status" ON "TenderQuery"("status");

CREATE TABLE "Addendum" (
  "addendumId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "number" INTEGER NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "issuedDate" DATE,
  "issuedById" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId", "number")
);

CREATE INDEX "idx_Addendum_contractId" ON "Addendum"("contractId");

CREATE TABLE "HandoverPackage" (
  "handoverPackageId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "submittedAt" TIMESTAMP,
  "acceptedAt" TIMESTAMP,
  "acceptedById" TEXT,
  "notes" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId")
);

CREATE INDEX "idx_HandoverPackage_contractId" ON "HandoverPackage"("contractId");

CREATE TABLE "NCR" (
  "ncrId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "reference" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "raisedByUserId" TEXT,
  "raisedByName" TEXT,
  "raisedByEmail" TEXT,
  "status" TEXT NOT NULL DEFAULT 'RAISED',
  "assignedToId" TEXT,
  "resolution" TEXT,
  "resolvedAt" TIMESTAMP,
  "closedAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId", "reference")
);

CREATE INDEX "idx_NCR_contractId" ON "NCR"("contractId");
CREATE INDEX "idx_NCR_status" ON "NCR"("status");

CREATE TABLE "PerformanceRating" (
  "performanceRatingId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "tenderReference" TEXT,
  "ratedById" TEXT NOT NULL,
  "overallScore" DECIMAL(5,2),
  "costScore" DECIMAL(5,2),
  "technicalScore" DECIMAL(5,2),
  "commercialScore" DECIMAL(5,2),
  "notes" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_PerformanceRating_contractId" ON "PerformanceRating"("contractId");

-- =====================================================================
-- SEGMENT: Workflow & Templates (v1.10) - Stubs
-- =====================================================================

CREATE TABLE "WorkflowDefinition" (
  "workflowDefinitionId" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL
);

CREATE TABLE "WorkflowInstance" (
  "workflowInstanceId" TEXT PRIMARY KEY,
  "workflowDefinitionId" TEXT NOT NULL,
  "entityType" TEXT NOT NULL,
  "entityId" TEXT NOT NULL,
  "currentState" TEXT NOT NULL
);

CREATE INDEX "idx_WorkflowInstance_workflowDefinitionId" ON "WorkflowInstance"("workflowDefinitionId");

CREATE TABLE "WorkflowTransition" (
  "workflowTransitionId" TEXT PRIMARY KEY,
  "workflowInstanceId" TEXT NOT NULL,
  "fromState" TEXT NOT NULL,
  "toState" TEXT NOT NULL,
  "transitionedById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_WorkflowTransition_workflowInstanceId" ON "WorkflowTransition"("workflowInstanceId");

CREATE TABLE "Template" (
  "templateId" TEXT PRIMARY KEY
);

-- =====================================================================
-- SEGMENT: Support & Governance (v1.11)
-- =====================================================================

CREATE TABLE "Risk" (
  "riskId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "category" TEXT,
  "probability" TEXT,
  "impact" TEXT,
  "status" TEXT NOT NULL DEFAULT 'OPEN',
  "mitigationPlan" TEXT,
  "ownerId" TEXT,
  "raisedById" TEXT NOT NULL,
  "reviewDate" DATE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Risk_contractId" ON "Risk"("contractId");
CREATE INDEX "idx_Risk_status" ON "Risk"("status");

CREATE TABLE "Assumption" (
  "assumptionId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "status" TEXT NOT NULL DEFAULT 'ACTIVE',
  "impact" TEXT,
  "ownerId" TEXT,
  "raisedById" TEXT NOT NULL,
  "reviewDate" DATE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Assumption_contractId" ON "Assumption"("contractId");
CREATE INDEX "idx_Assumption_status" ON "Assumption"("status");

CREATE TABLE "AuditLog" (
  "auditLogId" TEXT PRIMARY KEY,
  "userId" TEXT NOT NULL,
  "action" TEXT NOT NULL,
  "entityType" TEXT NOT NULL,
  "entityId" TEXT NOT NULL,
  "oldValue" JSONB,
  "newValue" JSONB,
  "ipAddress" TEXT,
  "userAgent" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_AuditLog_userId" ON "AuditLog"("userId");
CREATE INDEX "idx_AuditLog_entityType" ON "AuditLog"("entityType");
CREATE INDEX "idx_AuditLog_createdAt" ON "AuditLog"("createdAt");

CREATE TABLE "Notification" (
  "notificationId" TEXT PRIMARY KEY,
  "userId" TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "body" TEXT,
  "metadata" JSONB,
  "isRead" BOOLEAN NOT NULL DEFAULT FALSE,
  "readAt" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Notification_userId" ON "Notification"("userId");
CREATE INDEX "idx_Notification_isRead" ON "Notification"("isRead");
