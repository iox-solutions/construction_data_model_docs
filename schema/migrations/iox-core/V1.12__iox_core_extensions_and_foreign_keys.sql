-- IOX Core v1.3-v1.11 Foreign Key Constraints and Extensions
-- Completes all foreign key relationships for segments v1.3 through v1.11
-- Adds v1.12 and v1.13 extensions

-- =====================================================================
-- Foreign Keys - Meetings & Actions (v1.3)
-- =====================================================================

ALTER TABLE "Meeting" ADD CONSTRAINT "fk_Meeting_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");

ALTER TABLE "MeetingAttendee" ADD CONSTRAINT "fk_MeetingAttendee_meetingId" FOREIGN KEY ("meetingId") REFERENCES "Meeting"("meetingId");
ALTER TABLE "MeetingAttendee" ADD CONSTRAINT "fk_MeetingAttendee_userId" FOREIGN KEY ("userId") REFERENCES "User"("userId");

ALTER TABLE "MeetingAgendaItem" ADD CONSTRAINT "fk_MeetingAgendaItem_meetingId" FOREIGN KEY ("meetingId") REFERENCES "Meeting"("meetingId");
ALTER TABLE "MeetingAgendaItem" ADD CONSTRAINT "fk_MeetingAgendaItem_ownerId" FOREIGN KEY ("ownerId") REFERENCES "User"("userId");

ALTER TABLE "MeetingMinutes" ADD CONSTRAINT "fk_MeetingMinutes_meetingId" FOREIGN KEY ("meetingId") REFERENCES "Meeting"("meetingId");
ALTER TABLE "MeetingMinutes" ADD CONSTRAINT "fk_MeetingMinutes_approvedById" FOREIGN KEY ("approvedById") REFERENCES "User"("userId");

ALTER TABLE "ActionItem" ADD CONSTRAINT "fk_ActionItem_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");
ALTER TABLE "ActionItem" ADD CONSTRAINT "fk_ActionItem_meetingId" FOREIGN KEY ("meetingId") REFERENCES "Meeting"("meetingId");
ALTER TABLE "ActionItem" ADD CONSTRAINT "fk_ActionItem_ownerId" FOREIGN KEY ("ownerId") REFERENCES "User"("userId");

-- =====================================================================
-- Foreign Keys - Documents & Transmittals (v1.4)
-- =====================================================================

ALTER TABLE "Folder" ADD CONSTRAINT "fk_Folder_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");
ALTER TABLE "Folder" ADD CONSTRAINT "fk_Folder_parentFolderId" FOREIGN KEY ("parentFolderId") REFERENCES "Folder"("folderId");

ALTER TABLE "Document" ADD CONSTRAINT "fk_Document_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");
ALTER TABLE "Document" ADD CONSTRAINT "fk_Document_folderId" FOREIGN KEY ("folderId") REFERENCES "Folder"("folderId");
ALTER TABLE "Document" ADD CONSTRAINT "fk_Document_uploadedById" FOREIGN KEY ("uploadedById") REFERENCES "User"("userId");
ALTER TABLE "Document" ADD CONSTRAINT "fk_Document_currentVersionId" FOREIGN KEY ("currentVersionId") REFERENCES "DocumentVersion"("documentVersionId");

ALTER TABLE "DocumentVersion" ADD CONSTRAINT "fk_DocumentVersion_documentId" FOREIGN KEY ("documentId") REFERENCES "Document"("documentId");
ALTER TABLE "DocumentVersion" ADD CONSTRAINT "fk_DocumentVersion_uploadedById" FOREIGN KEY ("uploadedById") REFERENCES "User"("userId");

ALTER TABLE "Drawing" ADD CONSTRAINT "fk_Drawing_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");
ALTER TABLE "Drawing" ADD CONSTRAINT "fk_Drawing_uploadedById" FOREIGN KEY ("uploadedById") REFERENCES "User"("userId");

ALTER TABLE "Transmittal" ADD CONSTRAINT "fk_Transmittal_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");
ALTER TABLE "Transmittal" ADD CONSTRAINT "fk_Transmittal_sentById" FOREIGN KEY ("sentById") REFERENCES "User"("userId");
ALTER TABLE "Transmittal" ADD CONSTRAINT "fk_Transmittal_recipientUserId" FOREIGN KEY ("recipientUserId") REFERENCES "User"("userId");

ALTER TABLE "TransmittalDocument" ADD CONSTRAINT "fk_TransmittalDocument_transmittalId" FOREIGN KEY ("transmittalId") REFERENCES "Transmittal"("transmittalId");
ALTER TABLE "TransmittalDocument" ADD CONSTRAINT "fk_TransmittalDocument_documentId" FOREIGN KEY ("documentId") REFERENCES "Document"("documentId");
ALTER TABLE "TransmittalDocument" ADD CONSTRAINT "fk_TransmittalDocument_documentVersionId" FOREIGN KEY ("documentVersionId") REFERENCES "DocumentVersion"("documentVersionId");

-- =====================================================================
-- Foreign Keys - Cost Plan Detail (v1.5)
-- =====================================================================

ALTER TABLE "CostPlanElement" ADD CONSTRAINT "fk_CostPlanElement_costPlanId" FOREIGN KEY ("costPlanId") REFERENCES "CostPlan"("costPlanId");
ALTER TABLE "CostPlanElement" ADD CONSTRAINT "fk_CostPlanElement_costPlanAreaId" FOREIGN KEY ("costPlanAreaId") REFERENCES "CostPlanArea"("costPlanAreaId");

ALTER TABLE "CostPlanArea" ADD CONSTRAINT "fk_CostPlanArea_costPlanId" FOREIGN KEY ("costPlanId") REFERENCES "CostPlan"("costPlanId");

ALTER TABLE "BenchmarkProject" ADD CONSTRAINT "fk_BenchmarkProject_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");

ALTER TABLE "VEItem" ADD CONSTRAINT "fk_VEItem_costPlanId" FOREIGN KEY ("costPlanId") REFERENCES "CostPlan"("costPlanId");
ALTER TABLE "VEItem" ADD CONSTRAINT "fk_VEItem_raisedById" FOREIGN KEY ("raisedById") REFERENCES "User"("userId");
ALTER TABLE "VEItem" ADD CONSTRAINT "fk_VEItem_reviewedById" FOREIGN KEY ("reviewedById") REFERENCES "User"("userId");

-- =====================================================================
-- Foreign Keys - BOQ & Procurement (v1.6)
-- =====================================================================

ALTER TABLE "BOQ" ADD CONSTRAINT "fk_BOQ_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
-- fk_BOQ_createdById moved to V1.14 (column was missing in CREATE TABLE).

ALTER TABLE "BOQBill" ADD CONSTRAINT "fk_BOQBill_boqId" FOREIGN KEY ("boqId") REFERENCES "BOQ"("boqId");

ALTER TABLE "BOQSection" ADD CONSTRAINT "fk_BOQSection_boqBillId" FOREIGN KEY ("boqBillId") REFERENCES "BOQBill"("boqBillId");

ALTER TABLE "BOQItem" ADD CONSTRAINT "fk_BOQItem_boqSectionId" FOREIGN KEY ("boqSectionId") REFERENCES "BOQSection"("boqSectionId");

ALTER TABLE "BOQVersion" ADD CONSTRAINT "fk_BOQVersion_boqId" FOREIGN KEY ("boqId") REFERENCES "BOQ"("boqId");
ALTER TABLE "BOQVersion" ADD CONSTRAINT "fk_BOQVersion_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");

ALTER TABLE "WorkOrder" ADD CONSTRAINT "fk_WorkOrder_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "WorkOrder" ADD CONSTRAINT "fk_WorkOrder_issuedById" FOREIGN KEY ("issuedById") REFERENCES "User"("userId");

-- =====================================================================
-- Foreign Keys - QA (v1.7)
-- =====================================================================

-- Removed in v1.14: the original declaration referenced a "contractId" column
-- that does not exist in QASheet (CREATE TABLE in V1.3_to_V1.11 only defined
-- qaSheetId, projectId, title, status). The column and FK are added correctly
-- in V1.14. See RFC 0001's "Follow-up surfaced during landing".

-- =====================================================================
-- Foreign Keys - Queries (v1.8)
-- =====================================================================

ALTER TABLE "Query" ADD CONSTRAINT "fk_Query_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "Query" ADD CONSTRAINT "fk_Query_raisedById" FOREIGN KEY ("raisedById") REFERENCES "User"("userId");
-- fk_Query_assignedToId moved to V1.14 (column was missing in CREATE TABLE).

ALTER TABLE "QueryResponse" ADD CONSTRAINT "fk_QueryResponse_queryId" FOREIGN KEY ("queryId") REFERENCES "Query"("queryId");
ALTER TABLE "QueryResponse" ADD CONSTRAINT "fk_QueryResponse_respondedById" FOREIGN KEY ("respondedById") REFERENCES "User"("userId");

ALTER TABLE "QueryAttachment" ADD CONSTRAINT "fk_QueryAttachment_queryId" FOREIGN KEY ("queryId") REFERENCES "Query"("queryId");
ALTER TABLE "QueryAttachment" ADD CONSTRAINT "fk_QueryAttachment_uploadedById" FOREIGN KEY ("uploadedById") REFERENCES "User"("userId");

-- =====================================================================
-- Foreign Keys - Tender & Gates (v1.9)
-- =====================================================================

ALTER TABLE "Gate" ADD CONSTRAINT "fk_Gate_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");

ALTER TABLE "GateChecklistItem" ADD CONSTRAINT "fk_GateChecklistItem_gateId" FOREIGN KEY ("gateId") REFERENCES "Gate"("gateId");
ALTER TABLE "GateChecklistItem" ADD CONSTRAINT "fk_GateChecklistItem_completedById" FOREIGN KEY ("completedById") REFERENCES "User"("userId");

ALTER TABLE "TenderQuery" ADD CONSTRAINT "fk_TenderQuery_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "TenderQuery" ADD CONSTRAINT "fk_TenderQuery_respondedById" FOREIGN KEY ("respondedById") REFERENCES "User"("userId");

ALTER TABLE "Addendum" ADD CONSTRAINT "fk_Addendum_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "Addendum" ADD CONSTRAINT "fk_Addendum_issuedById" FOREIGN KEY ("issuedById") REFERENCES "User"("userId");

ALTER TABLE "HandoverPackage" ADD CONSTRAINT "fk_HandoverPackage_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "HandoverPackage" ADD CONSTRAINT "fk_HandoverPackage_acceptedById" FOREIGN KEY ("acceptedById") REFERENCES "User"("userId");

ALTER TABLE "NCR" ADD CONSTRAINT "fk_NCR_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "NCR" ADD CONSTRAINT "fk_NCR_raisedByUserId" FOREIGN KEY ("raisedByUserId") REFERENCES "User"("userId");
ALTER TABLE "NCR" ADD CONSTRAINT "fk_NCR_assignedToId" FOREIGN KEY ("assignedToId") REFERENCES "User"("userId");

ALTER TABLE "PerformanceRating" ADD CONSTRAINT "fk_PerformanceRating_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "PerformanceRating" ADD CONSTRAINT "fk_PerformanceRating_ratedById" FOREIGN KEY ("ratedById") REFERENCES "User"("userId");

-- =====================================================================
-- Foreign Keys - Workflow & Templates (v1.10)
-- =====================================================================

ALTER TABLE "WorkflowInstance" ADD CONSTRAINT "fk_WorkflowInstance_workflowDefinitionId" FOREIGN KEY ("workflowDefinitionId") REFERENCES "WorkflowDefinition"("workflowDefinitionId");

ALTER TABLE "WorkflowTransition" ADD CONSTRAINT "fk_WorkflowTransition_workflowInstanceId" FOREIGN KEY ("workflowInstanceId") REFERENCES "WorkflowInstance"("workflowInstanceId");
ALTER TABLE "WorkflowTransition" ADD CONSTRAINT "fk_WorkflowTransition_transitionedById" FOREIGN KEY ("transitionedById") REFERENCES "User"("userId");

-- =====================================================================
-- Foreign Keys - Support & Governance (v1.11)
-- =====================================================================

ALTER TABLE "Risk" ADD CONSTRAINT "fk_Risk_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "Risk" ADD CONSTRAINT "fk_Risk_ownerId" FOREIGN KEY ("ownerId") REFERENCES "User"("userId");
ALTER TABLE "Risk" ADD CONSTRAINT "fk_Risk_raisedById" FOREIGN KEY ("raisedById") REFERENCES "User"("userId");

ALTER TABLE "Assumption" ADD CONSTRAINT "fk_Assumption_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "Assumption" ADD CONSTRAINT "fk_Assumption_ownerId" FOREIGN KEY ("ownerId") REFERENCES "User"("userId");
ALTER TABLE "Assumption" ADD CONSTRAINT "fk_Assumption_raisedById" FOREIGN KEY ("raisedById") REFERENCES "User"("userId");

ALTER TABLE "AuditLog" ADD CONSTRAINT "fk_AuditLog_userId" FOREIGN KEY ("userId") REFERENCES "User"("userId");

ALTER TABLE "Notification" ADD CONSTRAINT "fk_Notification_userId" FOREIGN KEY ("userId") REFERENCES "User"("userId");

-- =====================================================================
-- v1.12 — User Extensions
-- =====================================================================
-- Added: allowedCountries, allowedDevelopers (already in User table from v1.1)
-- These columns are now functional and indexed for filtering

CREATE INDEX "idx_User_allowedCountries" ON "User" USING GIN("allowedCountries");
CREATE INDEX "idx_User_allowedDevelopers" ON "User" USING GIN("allowedDevelopers");

-- =====================================================================
-- v1.13 — BenchmarkProject Extensions
-- =====================================================================
-- Added: location, costPerGFA (already in BenchmarkProject table from v1.5)
-- These fields are now canonical and indexed

CREATE INDEX "idx_BenchmarkProject_location" ON "BenchmarkProject"("location");

-- Add foreign key linking CostPlan to BenchmarkProject (retroactive from v1.5)
ALTER TABLE "CostPlan" ADD CONSTRAINT "fk_CostPlan_benchmarkProjectId" FOREIGN KEY ("benchmarkProjectId") REFERENCES "BenchmarkProject"("benchmarkProjectId");
