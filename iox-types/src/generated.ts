// AUTO-GENERATED — do not edit by hand.
// Regenerate with: node tools/generate-types.mjs
// Source: schema/migrations/**
//
// Conventions:
//   - DECIMAL / NUMERIC columns are typed as `string` (default pg-node behaviour).
//     Cast to number / BigDecimal at the application boundary.
//   - TIMESTAMP / DATE columns are typed as `Date`. The pg driver returns
//     strings unless you install a type parser; configure your client accordingly.
//   - Columns without NOT NULL include `| null` in their type.
//   - Columns with a DEFAULT or that are nullable are marked optional (`?`)
//     for inserts; reads always return all keys.


export type Module =
  | "core"
  | "parametrix"
  | "procurex"
  | "planx"
  | "reportx"
  | "placeholderx"
  | "unassigned";

// Union of every persisted entity name. Use this for polymorphic refs
// (WorkflowInstance.entityType, AuditLog.entityType) and discriminated unions.
export type EntityType =
  | "ActionItem"
  | "Addendum"
  | "Assumption"
  | "AuditLog"
  | "BOQ"
  | "BOQBill"
  | "BOQItem"
  | "BOQSection"
  | "BOQStrategy"
  | "BOQVersion"
  | "BenchmarkProject"
  | "Budget"
  | "BudgetVersion"
  | "CalibrationDataPoint"
  | "CalibrationDataPointParameter"
  | "CalibrationDataSource"
  | "CertifiedPayment"
  | "CertifiedPaymentAllocation"
  | "Checklist"
  | "ChecklistItem"
  | "Client"
  | "CommunicationProtocol"
  | "Contract"
  | "ContractMatchKey"
  | "ContractStage"
  | "Contractor"
  | "CostPlan"
  | "CostPlanArea"
  | "CostPlanElement"
  | "CostPlanVersion"
  | "CostRelationship"
  | "CostRelationshipParameter"
  | "Department"
  | "Document"
  | "DocumentVersion"
  | "Drawing"
  | "EarlyWarning"
  | "EarlyWarningVariationOrderLink"
  | "EstimateOutputValue"
  | "EstimateParameterValue"
  | "Folder"
  | "Gate"
  | "GateChecklistItem"
  | "HandoverPackage"
  | "Meeting"
  | "MeetingAgendaItem"
  | "MeetingAttendee"
  | "MeetingMinutes"
  | "ModelParameter"
  | "NCR"
  | "NoticeOfWin"
  | "Notification"
  | "Organization"
  | "Parameter"
  | "ParameterCategory"
  | "ParametricEstimate"
  | "ParametricModel"
  | "PaymentSchedule"
  | "PaymentScheduleItem"
  | "PerformanceRating"
  | "Permission"
  | "Project"
  | "ProjectTeam"
  | "QASheet"
  | "Query"
  | "QueryAttachment"
  | "QueryResponse"
  | "Risk"
  | "RiskAdjustment"
  | "Role"
  | "RolePermission"
  | "SensitivityAnalysis"
  | "Template"
  | "TenderQuery"
  | "Transmittal"
  | "TransmittalDocument"
  | "User"
  | "UserRole"
  | "VEItem"
  | "VariationOrder"
  | "WorkOrder"
  | "WorkflowDefinition"
  | "WorkflowInstance"
  | "WorkflowTransition";

// Core anchor tables — every cross-module FK terminates at one of these.
export const CORE_ANCHORS = ["CostPlan","Project","Contract"] as const satisfies ReadonlyArray<EntityType>;

export interface ActionItem {
  "actionItemId": string;
  "projectId": string;
  "meetingId"?: string | null;
  "title": string;
  "description"?: string | null;
  "ownerId": string;
  "status"?: string;
  "priority"?: string | null;
  "dueDate"?: Date | null;
  "completedAt"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface Addendum {
  "addendumId": string;
  "contractId": string;
  "number": number;
  "title": string;
  "description"?: string | null;
  "issuedDate"?: Date | null;
  "issuedById"?: string | null;
  "createdAt"?: Date;
}

export interface Assumption {
  "assumptionId": string;
  "contractId": string;
  "title": string;
  "description"?: string | null;
  "status"?: string;
  "impact"?: string | null;
  "ownerId"?: string | null;
  "raisedById": string;
  "reviewDate"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

/**
 * Immutable audit trail. PII-flagged: ipAddress, userAgent
 */
export interface AuditLog {
  "auditLogId": string;
  "userId": string;
  "action": string;
  "entityType": string;
  "entityId": string;
  "oldValue"?: unknown | null;
  "newValue"?: unknown | null;
  "ipAddress"?: string | null;
  "userAgent"?: string | null;
  "createdAt"?: Date;
}

/**
 * Bill of Quantities hierarchically organized by Bill > Section > Item
 */
export interface BOQ {
  "boqId": string;
  "contractId": string;
  "title": string;
  "status"?: string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface BOQBill {
  "boqBillId": string;
  "boqId": string;
  "billNumber": number;
  "organizationId": string;
  "title": string;
  "sortOrder"?: number | null;
}

export interface BOQItem {
  "boqItemId": string;
  "boqSectionId": string;
  "itemNumber": string;
  "description": string;
  "quantity"?: string | null;
  "unit"?: string | null;
  "unitRate"?: string | null;
  "itemTotal"?: string | null;
  "notes"?: string | null;
}

export interface BOQSection {
  "boqSectionId": string;
  "boqBillId": string;
  "sectionNumber": string;
  "title": string;
  "sortOrder"?: number | null;
}

export interface BOQStrategy {
  "boqStrategyId": string;
}

export interface BOQVersion {
  "boqVersionId": string;
  "boqId": string;
  "versionLabel": string;
  "snapshot": unknown;
  "createdById": string;
  "createdAt"?: Date;
}

export interface BenchmarkProject {
  "benchmarkProjectId": string;
  "name": string;
  "description"?: string | null;
  "grossInternalArea"?: string | null;
  "totalCost"?: string | null;
  "costPerM2"?: string | null;
  "currency"?: string | null;
  "location"?: string | null;
  "costPerGFA"?: string | null;
  "baseDate"?: Date | null;
  "createdById": string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface Budget {
  "budgetId": string;
  "contractId": string;
  "title": string;
  "status"?: string;
  "totalValue"?: string | null;
  "currency"?: string | null;
  "createdAt"?: Date;
}

export interface BudgetVersion {
  "budgetVersionId": string;
  "budgetId": string;
  "versionLabel": string;
  "snapshot": unknown;
  "createdById": string;
  "createdAt"?: Date;
}

export interface CalibrationDataPoint {
  "calibrationDataPointId": string;
  "calibrationDataSourceId": string;
  "projectReference"?: string | null;
  "actualCost"?: string | null;
  "currency"?: string | null;
  "location"?: string | null;
  "date"?: Date | null;
  "createdAt"?: Date;
}

export interface CalibrationDataPointParameter {
  "dataPointParameterId": string;
  "calibrationDataPointId": string;
  "parameterId": string;
  "value": string;
  "unit"?: string | null;
}

export interface CalibrationDataSource {
  "calibrationDataSourceId": string;
  "name": string;
  "description"?: string | null;
  "sourceType": string;
  "dataPoints"?: number | null;
  "createdAt"?: Date;
}

export interface CertifiedPayment {
  "certifiedPaymentId": string;
  "contractId": string;
  "reference": string;
  "certificationDate": Date;
  "certifiedAmount": string;
  "currency"?: string | null;
  "certifiedById": string;
  "createdAt"?: Date;
}

export interface CertifiedPaymentAllocation {
  "allocationId": string;
  "certifiedPaymentId": string;
  "paymentScheduleItemId": string;
  "allocatedAmount"?: string | null;
}

export interface Checklist {
  "checklistId": string;
}

export interface ChecklistItem {
  "checklistItemId": string;
  "checklistId": string;
}

export interface Client {
  "clientId": string;
  "name": string;
  "organizationId"?: string | null;
  "createdAt"?: Date;
}

export interface CommunicationProtocol {
  "communicationProtocolId": string;
  "projectId": string;
  "responseTimeframeDays"?: number | null;
  "namingConvention"?: string | null;
  "notes"?: string | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

/**
 * Top-level contract entity with financial and temporal scope
 */
export interface Contract {
  "contractId": string;
  "projectId": string;
  "number": string;
  "title": string;
  "description"?: string | null;
  "contractType"?: string | null;
  "status"?: string;
  "clientOrganizationId"?: string | null;
  "contractorId"?: string | null;
  "startDate"?: Date | null;
  "endDate"?: Date | null;
  "value"?: string | null;
  "currency"?: string | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface ContractMatchKey {
  "contractMatchKeyId": string;
  "contractId": string;
  "keyName": string;
  "keyValue": string;
}

export interface ContractStage {
  "contractStageId": string;
  "contractId": string;
  "stageName": string;
  "status"?: string;
  "targetDate"?: Date | null;
  "completedDate"?: Date | null;
}

export interface Contractor {
  "contractorId": string;
  "contractId": string;
  "organizationId": string;
  "role"?: string | null;
  "appointmentDate"?: Date | null;
}

/**
 * Estimate and cost tracking at contract level
 */
export interface CostPlan {
  "costPlanId": string;
  "contractId": string;
  "title": string;
  "status"?: string;
  "totalCost"?: string | null;
  "currency"?: string | null;
  "benchmarkProjectId"?: string | null;
  "createdById": string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface CostPlanArea {
  "costPlanAreaId": string;
  "costPlanId": string;
  "name": string;
  "grossInternalArea"?: string | null;
  "sortOrder"?: number | null;
  "notes"?: string | null;
}

export interface CostPlanElement {
  "costPlanElementId": string;
  "costPlanId": string;
  "costPlanAreaId"?: string | null;
  "title": string;
  "code"?: string | null;
  "quantity"?: string | null;
  "unit"?: string | null;
  "unitRate"?: string | null;
  "elementCost"?: string | null;
  "currency"?: string | null;
  "sortOrder"?: number | null;
  "notes"?: string | null;
}

export interface CostPlanVersion {
  "costPlanVersionId": string;
  "costPlanId": string;
  "versionLabel": string;
  "snapshot": unknown;
  "createdById": string;
  "createdAt"?: Date;
}

export interface CostRelationship {
  "costRelationshipId": string;
  "parametricModelId": string;
  "name": string;
  "description"?: string | null;
  "baselineValue"?: string | null;
  "currency"?: string | null;
  "formula"?: string | null;
  "createdAt"?: Date;
}

export interface CostRelationshipParameter {
  "relationshipParameterId": string;
  "costRelationshipId": string;
  "parameterId": string;
  "coefficient"?: string | null;
  "sortOrder"?: number | null;
}

export interface Department {
  "departmentId": string;
  "organizationId": string;
  "name": string;
  "code"?: string | null;
  "parentDepartmentId"?: string | null;
  "headUserId"?: string | null;
  "createdAt"?: Date;
}

/**
 * Logical document record with versioning via DocumentVersion
 */
export interface Document {
  "documentId": string;
  "projectId": string;
  "folderId": string;
  "title": string;
  "documentNumber"?: string | null;
  "type"?: string | null;
  "status"?: string;
  "uploadedById": string;
  "currentVersionId"?: string | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface DocumentVersion {
  "documentVersionId": string;
  "documentId": string;
  "versionLabel": string;
  "fileUrl": string;
  "fileSize"?: number | null;
  "mimeType"?: string | null;
  "uploadedById": string;
  "createdAt"?: Date;
}

export interface Drawing {
  "drawingId": string;
  "projectId": string;
  "drawingNumber": string;
  "title": string;
  "discipline"?: string | null;
  "revision"?: string | null;
  "status"?: string;
  "fileUrl"?: string | null;
  "uploadedById"?: string | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface EarlyWarning {
  "earlyWarningId": string;
  "contractId": string;
  "title": string;
  "description"?: string | null;
  "status"?: string;
  "raisedById": string;
  "assignedToId"?: string | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface EarlyWarningVariationOrderLink {
  "linkId": string;
  "earlyWarningId": string;
  "variationOrderId": string;
}

export interface EstimateOutputValue {
  "estimateOutputValueId": string;
  "parametricEstimateId": string;
  "costRelationshipId": string;
  "outputValue"?: string | null;
  "unit"?: string | null;
}

export interface EstimateParameterValue {
  "estimateParameterValueId": string;
  "parametricEstimateId": string;
  "parameterId": string;
  "value": string;
  "unit"?: string | null;
}

export interface Folder {
  "folderId": string;
  "projectId": string;
  "parentFolderId"?: string | null;
  "name": string;
  "sortOrder"?: number | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface Gate {
  "gateId": string;
  "contractId": string;
  "title": string;
  "sortOrder": number;
  "status"?: string;
  "targetDate"?: Date | null;
  "passedAt"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface GateChecklistItem {
  "gateChecklistItemId": string;
  "gateId": string;
  "title": string;
  "isComplete"?: boolean;
  "completedById"?: string | null;
  "completedAt"?: Date | null;
  "sortOrder": number;
}

export interface HandoverPackage {
  "handoverPackageId": string;
  "contractId": string;
  "title": string;
  "status"?: string;
  "submittedAt"?: Date | null;
  "acceptedAt"?: Date | null;
  "acceptedById"?: string | null;
  "notes"?: string | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

/**
 * Project meetings with attendees, agenda, and action items
 */
export interface Meeting {
  "meetingId": string;
  "projectId": string;
  "title": string;
  "type"?: string | null;
  "scheduledAt": Date;
  "location"?: string | null;
  "status"?: string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface MeetingAgendaItem {
  "meetingAgendaItemId": string;
  "meetingId": string;
  "title": string;
  "description"?: string | null;
  "sortOrder": number;
  "ownerId"?: string | null;
  "durationMinutes"?: number | null;
}

export interface MeetingAttendee {
  "meetingAttendeeId": string;
  "meetingId": string;
  "userId": string;
  "status"?: string;
}

export interface MeetingMinutes {
  "meetingMinutesId": string;
  "meetingId": string;
  "content": string;
  "approvedById"?: string | null;
  "approvedAt"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface ModelParameter {
  "modelParameterId": string;
  "parametricModelId": string;
  "parameterId": string;
  "isRequired"?: boolean;
  "defaultValue"?: string | null;
  "sortOrder"?: number | null;
}

export interface NCR {
  "ncrId": string;
  "contractId": string;
  "reference": string;
  "title": string;
  "description"?: string | null;
  "raisedByUserId"?: string | null;
  "raisedByName"?: string | null;
  "raisedByEmail"?: string | null;
  "status"?: string;
  "assignedToId"?: string | null;
  "resolution"?: string | null;
  "resolvedAt"?: Date | null;
  "closedAt"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface NoticeOfWin {
  "noticeOfWinId": string;
  "projectId": string;
  "awardDate"?: Date | null;
  "awardValue"?: string | null;
  "currency"?: string | null;
  "projectBrief"?: unknown | null;
  "createdAt"?: Date;
}

/**
 * System-generated alerts to users by event type
 */
export interface Notification {
  "notificationId": string;
  "userId": string;
  "type": string;
  "title": string;
  "body"?: string | null;
  "metadata"?: unknown | null;
  "isRead"?: boolean;
  "readAt"?: Date | null;
  "createdAt"?: Date;
}

export interface Organization {
  "organizationId": string;
  "name": string;
  "type": string;
  "code"?: string | null;
  "address"?: string | null;
  "phone"?: string | null;
  "email"?: string | null;
  "website"?: string | null;
  "logo"?: string | null;
  "status"?: string;
  "createdAt"?: Date;
}

export interface Parameter {
  "parameterId": string;
  "parameterCategoryId": string;
  "name": string;
  "code": string;
  "description"?: string | null;
  "dataType": string;
  "unit"?: string | null;
  "minValue"?: string | null;
  "maxValue"?: string | null;
  "createdAt"?: Date;
}

export interface ParameterCategory {
  "parameterCategoryId": string;
  "name": string;
  "description"?: string | null;
  "createdAt"?: Date;
}

export interface ParametricEstimate {
  "parametricEstimateId": string;
  "costPlanId": string;
  "parametricModelId": string;
  "status"?: string;
  "estimatedValue"?: string | null;
  "currency"?: string | null;
  "confidenceLevel"?: string | null;
  "createdById": string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface ParametricModel {
  "parametricModelId": string;
  "name": string;
  "description"?: string | null;
  "projectType": string;
  "status"?: string;
  "version"?: string | null;
  "baselineYear"?: number | null;
  "createdById": string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface PaymentSchedule {
  "paymentScheduleId": string;
  "contractId": string;
  "title": string;
  "totalValue"?: string | null;
  "currency"?: string | null;
  "createdAt"?: Date;
}

export interface PaymentScheduleItem {
  "paymentScheduleItemId": string;
  "paymentScheduleId": string;
  "description": string;
  "dueDate"?: Date | null;
  "paymentValue"?: string | null;
  "sortOrder"?: number | null;
}

export interface PerformanceRating {
  "performanceRatingId": string;
  "contractId": string;
  "tenderReference"?: string | null;
  "ratedById": string;
  "overallScore"?: string | null;
  "costScore"?: string | null;
  "technicalScore"?: string | null;
  "commercialScore"?: string | null;
  "notes"?: string | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface Permission {
  "permissionId": string;
  "code": string;
  "name": string;
  "module": string;
  "action": string;
  "description"?: string | null;
}

/**
 * Primary scoping entity for all work deliverables
 */
export interface Project {
  "projectId": string;
  "clientId": string;
  "number": string;
  "name": string;
  "description"?: string | null;
  "location"?: string | null;
  "status"?: string;
  "startDate"?: Date | null;
  "endDate"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface ProjectTeam {
  "projectTeamId": string;
  "projectId": string;
  "userId": string;
  "userRoleId": string;
  "joinedAt"?: Date;
  "leftAt"?: Date | null;
}

export interface QASheet {
  "qaSheetId": string;
  "projectId": string;
  "title": string;
  "status"?: string;
}

/**
 * Planning-phase clarification requests scoped to Contract
 */
export interface Query {
  "queryId": string;
  "contractId": string;
  "reference": string;
  "subject": string;
  "body": string;
  "raisedById": string;
  "status"?: string;
  "responseRequiredBy"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface QueryAttachment {
  "queryAttachmentId": string;
  "queryId": string;
  "name": string;
  "fileUrl"?: string | null;
  "externalUrl"?: string | null;
  "mimeType"?: string | null;
  "fileSize"?: number | null;
  "uploadedById": string;
  "createdAt"?: Date;
}

export interface QueryResponse {
  "queryResponseId": string;
  "queryId": string;
  "body": string;
  "respondedById": string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

/**
 * Formally tracked risks with probability/impact and mitigation
 */
export interface Risk {
  "riskId": string;
  "contractId": string;
  "title": string;
  "description"?: string | null;
  "category"?: string | null;
  "probability"?: string | null;
  "impact"?: string | null;
  "status"?: string;
  "mitigationPlan"?: string | null;
  "ownerId"?: string | null;
  "raisedById": string;
  "reviewDate"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface RiskAdjustment {
  "riskAdjustmentId": string;
  "parametricEstimateId": string;
  "description": string;
  "adjustmentPercent"?: string | null;
  "adjustmentAmount"?: string | null;
  "justification"?: string | null;
  "createdById": string;
  "createdAt"?: Date;
}

/**
 * Named permission sets with hierarchical organization
 */
export interface Role {
  "roleId": string;
  "name": string;
  "code": string;
  "level": number;
  "track": string;
  "description"?: string | null;
  "parentRoleId"?: string | null;
  "createdAt"?: Date;
}

export interface RolePermission {
  "rolePermissionId": string;
  "roleId": string;
  "permissionId": string;
}

export interface SensitivityAnalysis {
  "sensitivityAnalysisId": string;
  "parametricEstimateId": string;
  "parameterId": string;
  "baselineValue": string;
  "variationPercent"?: string | null;
  "sensitivityFactor"?: string | null;
  "impact"?: string | null;
  "createdAt"?: Date;
}

export interface Template {
  "templateId": string;
}

/**
 * Tender-phase clarification requests from bidders
 */
export interface TenderQuery {
  "tenderQueryId": string;
  "contractId": string;
  "reference": string;
  "subject": string;
  "body": string;
  "raisedByName": string;
  "raisedByEmail"?: string | null;
  "status"?: string;
  "responseRequiredBy"?: Date | null;
  "response"?: string | null;
  "respondedById"?: string | null;
  "respondedAt"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

/**
 * Formal dispatch record with recipient tracking
 */
export interface Transmittal {
  "transmittalId": string;
  "projectId": string;
  "transmittalNumber": string;
  "subject": string;
  "sentById": string;
  "recipientUserId"?: string | null;
  "recipientName"?: string | null;
  "recipientEmail"?: string | null;
  "sentAt"?: Date;
  "responseRequiredBy"?: Date | null;
  "status"?: string;
  "notes"?: string | null;
  "createdAt"?: Date;
}

export interface TransmittalDocument {
  "transmittalDocumentId": string;
  "transmittalId": string;
  "documentId": string;
  "documentVersionId": string;
}

/**
 * Core user identity and authentication. PII-flagged: email, firstName, lastName, phone, avatar
 */
export interface User {
  "userId": string;
  "email": string;
  "password": string;
  "firstName": string;
  "lastName": string;
  "phone"?: string | null;
  "avatar"?: string | null;
  "status"?: string;
  "emailVerified"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
  "allowedCountries"?: string[] | null;
  "allowedDevelopers"?: string[] | null;
}

/**
 * Assignment of roles to users with global/org/project scoping
 */
export interface UserRole {
  "userRoleId": string;
  "userId": string;
  "roleId": string;
  "organizationId"?: string | null;
  "projectId"?: string | null;
  "isPrimary"?: boolean;
  "assignedAt"?: Date;
  "assignedById"?: string | null;
}

export interface VEItem {
  "veItemId": string;
  "costPlanId": string;
  "title": string;
  "description"?: string | null;
  "estimatedSaving"?: string | null;
  "currency"?: string | null;
  "status"?: string;
  "raisedById": string;
  "reviewedById"?: string | null;
  "reviewedAt"?: Date | null;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface VariationOrder {
  "variationOrderId": string;
  "contractId": string;
  "reference": string;
  "title": string;
  "description"?: string | null;
  "valuationAmount"?: string | null;
  "status"?: string;
  "createdById": string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface WorkOrder {
  "workOrderId": string;
  "contractId": string;
  "number": string;
  "title": string;
  "description"?: string | null;
  "issuedDate"?: Date | null;
  "targetCompletionDate"?: Date | null;
  "status"?: string;
  "issuedById": string;
  "createdAt"?: Date;
  "updatedAt"?: Date;
}

export interface WorkflowDefinition {
  "workflowDefinitionId": string;
  "name": string;
}

export interface WorkflowInstance {
  "workflowInstanceId": string;
  "workflowDefinitionId": string;
  "entityType": string;
  "entityId": string;
  "currentState": string;
}

export interface WorkflowTransition {
  "workflowTransitionId": string;
  "workflowInstanceId": string;
  "fromState": string;
  "toState": string;
  "transitionedById": string;
  "createdAt"?: Date;
}

export const TABLE_MODULES: Readonly<Record<EntityType, Module>> = {
  "ActionItem": "procurex",
  "Addendum": "procurex",
  "Assumption": "procurex",
  "AuditLog": "core",
  "BOQ": "procurex",
  "BOQBill": "procurex",
  "BOQItem": "procurex",
  "BOQSection": "procurex",
  "BOQStrategy": "procurex",
  "BOQVersion": "procurex",
  "BenchmarkProject": "core",
  "Budget": "core",
  "BudgetVersion": "core",
  "CalibrationDataPoint": "parametrix",
  "CalibrationDataPointParameter": "parametrix",
  "CalibrationDataSource": "parametrix",
  "CertifiedPayment": "reportx",
  "CertifiedPaymentAllocation": "core",
  "Checklist": "procurex",
  "ChecklistItem": "procurex",
  "Client": "core",
  "CommunicationProtocol": "unassigned",
  "Contract": "core",
  "ContractMatchKey": "core",
  "ContractStage": "core",
  "Contractor": "core",
  "CostPlan": "core",
  "CostPlanArea": "planx",
  "CostPlanElement": "core",
  "CostPlanVersion": "core",
  "CostRelationship": "parametrix",
  "CostRelationshipParameter": "parametrix",
  "Department": "core",
  "Document": "procurex",
  "DocumentVersion": "procurex",
  "Drawing": "procurex",
  "EarlyWarning": "reportx",
  "EarlyWarningVariationOrderLink": "reportx",
  "EstimateOutputValue": "parametrix",
  "EstimateParameterValue": "parametrix",
  "Folder": "procurex",
  "Gate": "procurex",
  "GateChecklistItem": "procurex",
  "HandoverPackage": "procurex",
  "Meeting": "procurex",
  "MeetingAgendaItem": "procurex",
  "MeetingAttendee": "procurex",
  "MeetingMinutes": "procurex",
  "ModelParameter": "parametrix",
  "NCR": "procurex",
  "NoticeOfWin": "procurex",
  "Notification": "core",
  "Organization": "core",
  "Parameter": "parametrix",
  "ParameterCategory": "parametrix",
  "ParametricEstimate": "parametrix",
  "ParametricModel": "parametrix",
  "PaymentSchedule": "core",
  "PaymentScheduleItem": "core",
  "PerformanceRating": "core",
  "Permission": "core",
  "Project": "core",
  "ProjectTeam": "unassigned",
  "QASheet": "unassigned",
  "Query": "procurex",
  "QueryAttachment": "procurex",
  "QueryResponse": "procurex",
  "Risk": "procurex",
  "RiskAdjustment": "parametrix",
  "Role": "core",
  "RolePermission": "core",
  "SensitivityAnalysis": "parametrix",
  "Template": "procurex",
  "TenderQuery": "procurex",
  "Transmittal": "procurex",
  "TransmittalDocument": "procurex",
  "User": "core",
  "UserRole": "core",
  "VEItem": "procurex",
  "VariationOrder": "reportx",
  "WorkOrder": "procurex",
  "WorkflowDefinition": "procurex",
  "WorkflowInstance": "procurex",
  "WorkflowTransition": "procurex",
} as const;

export interface ForeignKey {
  readonly from: EntityType;
  readonly column: string;
  readonly to: EntityType;
  readonly references: string;
  readonly constraint: string;
}

export const FOREIGN_KEYS: ReadonlyArray<ForeignKey> = [
  { from: "ActionItem", column: "meetingId", to: "Meeting", references: "meetingId", constraint: "fk_ActionItem_meetingId" },
  { from: "ActionItem", column: "ownerId", to: "User", references: "userId", constraint: "fk_ActionItem_ownerId" },
  { from: "ActionItem", column: "projectId", to: "Project", references: "projectId", constraint: "fk_ActionItem_projectId" },
  { from: "Addendum", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_Addendum_contractId" },
  { from: "Addendum", column: "issuedById", to: "User", references: "userId", constraint: "fk_Addendum_issuedById" },
  { from: "Assumption", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_Assumption_contractId" },
  { from: "Assumption", column: "ownerId", to: "User", references: "userId", constraint: "fk_Assumption_ownerId" },
  { from: "Assumption", column: "raisedById", to: "User", references: "userId", constraint: "fk_Assumption_raisedById" },
  { from: "AuditLog", column: "userId", to: "User", references: "userId", constraint: "fk_AuditLog_userId" },
  { from: "BenchmarkProject", column: "createdById", to: "User", references: "userId", constraint: "fk_BenchmarkProject_createdById" },
  { from: "BOQ", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_BOQ_contractId" },
  { from: "BOQ", column: "createdById", to: "User", references: "userId", constraint: "fk_BOQ_createdById" },
  { from: "BOQBill", column: "boqId", to: "BOQ", references: "boqId", constraint: "fk_BOQBill_boqId" },
  { from: "BOQItem", column: "boqSectionId", to: "BOQSection", references: "boqSectionId", constraint: "fk_BOQItem_boqSectionId" },
  { from: "BOQSection", column: "boqBillId", to: "BOQBill", references: "boqBillId", constraint: "fk_BOQSection_boqBillId" },
  { from: "BOQVersion", column: "boqId", to: "BOQ", references: "boqId", constraint: "fk_BOQVersion_boqId" },
  { from: "BOQVersion", column: "createdById", to: "User", references: "userId", constraint: "fk_BOQVersion_createdById" },
  { from: "Budget", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_Budget_contractId" },
  { from: "BudgetVersion", column: "budgetId", to: "Budget", references: "budgetId", constraint: "fk_BudgetVersion_budgetId" },
  { from: "BudgetVersion", column: "createdById", to: "User", references: "userId", constraint: "fk_BudgetVersion_createdById" },
  { from: "CalibrationDataPoint", column: "calibrationDataSourceId", to: "CalibrationDataSource", references: "calibrationDataSourceId", constraint: "fk_CalibrationDataPoint_calibrationDataSourceId" },
  { from: "CalibrationDataPointParameter", column: "calibrationDataPointId", to: "CalibrationDataPoint", references: "calibrationDataPointId", constraint: "fk_CalibrationDataPointParameter_calibrationDataPointId" },
  { from: "CalibrationDataPointParameter", column: "parameterId", to: "Parameter", references: "parameterId", constraint: "fk_CalibrationDataPointParameter_parameterId" },
  { from: "CertifiedPayment", column: "certifiedById", to: "User", references: "userId", constraint: "fk_CertifiedPayment_certifiedById" },
  { from: "CertifiedPayment", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_CertifiedPayment_contractId" },
  { from: "CertifiedPaymentAllocation", column: "certifiedPaymentId", to: "CertifiedPayment", references: "certifiedPaymentId", constraint: "fk_CertifiedPaymentAllocation_certifiedPaymentId" },
  { from: "CertifiedPaymentAllocation", column: "paymentScheduleItemId", to: "PaymentScheduleItem", references: "paymentScheduleItemId", constraint: "fk_CertifiedPaymentAllocation_paymentScheduleItemId" },
  { from: "Client", column: "organizationId", to: "Organization", references: "organizationId", constraint: "fk_Client_organizationId" },
  { from: "CommunicationProtocol", column: "projectId", to: "Project", references: "projectId", constraint: "fk_CommunicationProtocol_projectId" },
  { from: "Contract", column: "projectId", to: "Project", references: "projectId", constraint: "fk_Contract_projectId" },
  { from: "ContractMatchKey", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_ContractMatchKey_contractId" },
  { from: "Contractor", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_Contractor_contractId" },
  { from: "Contractor", column: "organizationId", to: "Organization", references: "organizationId", constraint: "fk_Contractor_organizationId" },
  { from: "ContractStage", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_ContractStage_contractId" },
  { from: "CostPlan", column: "benchmarkProjectId", to: "BenchmarkProject", references: "benchmarkProjectId", constraint: "fk_CostPlan_benchmarkProjectId" },
  { from: "CostPlan", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_CostPlan_contractId" },
  { from: "CostPlan", column: "createdById", to: "User", references: "userId", constraint: "fk_CostPlan_createdById" },
  { from: "CostPlanArea", column: "costPlanId", to: "CostPlan", references: "costPlanId", constraint: "fk_CostPlanArea_costPlanId" },
  { from: "CostPlanElement", column: "costPlanAreaId", to: "CostPlanArea", references: "costPlanAreaId", constraint: "fk_CostPlanElement_costPlanAreaId" },
  { from: "CostPlanElement", column: "costPlanId", to: "CostPlan", references: "costPlanId", constraint: "fk_CostPlanElement_costPlanId" },
  { from: "CostPlanVersion", column: "costPlanId", to: "CostPlan", references: "costPlanId", constraint: "fk_CostPlanVersion_costPlanId" },
  { from: "CostPlanVersion", column: "createdById", to: "User", references: "userId", constraint: "fk_CostPlanVersion_createdById" },
  { from: "CostRelationship", column: "parametricModelId", to: "ParametricModel", references: "parametricModelId", constraint: "fk_CostRelationship_parametricModelId" },
  { from: "CostRelationshipParameter", column: "costRelationshipId", to: "CostRelationship", references: "costRelationshipId", constraint: "fk_CostRelationshipParameter_costRelationshipId" },
  { from: "CostRelationshipParameter", column: "parameterId", to: "Parameter", references: "parameterId", constraint: "fk_CostRelationshipParameter_parameterId" },
  { from: "Department", column: "headUserId", to: "User", references: "userId", constraint: "fk_Department_headUserId" },
  { from: "Department", column: "organizationId", to: "Organization", references: "organizationId", constraint: "fk_Department_organizationId" },
  { from: "Department", column: "parentDepartmentId", to: "Department", references: "departmentId", constraint: "fk_Department_parentDepartmentId" },
  { from: "Document", column: "currentVersionId", to: "DocumentVersion", references: "documentVersionId", constraint: "fk_Document_currentVersionId" },
  { from: "Document", column: "folderId", to: "Folder", references: "folderId", constraint: "fk_Document_folderId" },
  { from: "Document", column: "projectId", to: "Project", references: "projectId", constraint: "fk_Document_projectId" },
  { from: "Document", column: "uploadedById", to: "User", references: "userId", constraint: "fk_Document_uploadedById" },
  { from: "DocumentVersion", column: "documentId", to: "Document", references: "documentId", constraint: "fk_DocumentVersion_documentId" },
  { from: "DocumentVersion", column: "uploadedById", to: "User", references: "userId", constraint: "fk_DocumentVersion_uploadedById" },
  { from: "Drawing", column: "projectId", to: "Project", references: "projectId", constraint: "fk_Drawing_projectId" },
  { from: "Drawing", column: "uploadedById", to: "User", references: "userId", constraint: "fk_Drawing_uploadedById" },
  { from: "EarlyWarning", column: "assignedToId", to: "User", references: "userId", constraint: "fk_EarlyWarning_assignedToId" },
  { from: "EarlyWarning", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_EarlyWarning_contractId" },
  { from: "EarlyWarning", column: "raisedById", to: "User", references: "userId", constraint: "fk_EarlyWarning_raisedById" },
  { from: "EarlyWarningVariationOrderLink", column: "earlyWarningId", to: "EarlyWarning", references: "earlyWarningId", constraint: "fk_EarlyWarningVariationOrderLink_earlyWarningId" },
  { from: "EarlyWarningVariationOrderLink", column: "variationOrderId", to: "VariationOrder", references: "variationOrderId", constraint: "fk_EarlyWarningVariationOrderLink_variationOrderId" },
  { from: "EstimateOutputValue", column: "costRelationshipId", to: "CostRelationship", references: "costRelationshipId", constraint: "fk_EstimateOutputValue_costRelationshipId" },
  { from: "EstimateOutputValue", column: "parametricEstimateId", to: "ParametricEstimate", references: "parametricEstimateId", constraint: "fk_EstimateOutputValue_parametricEstimateId" },
  { from: "EstimateParameterValue", column: "parameterId", to: "Parameter", references: "parameterId", constraint: "fk_EstimateParameterValue_parameterId" },
  { from: "EstimateParameterValue", column: "parametricEstimateId", to: "ParametricEstimate", references: "parametricEstimateId", constraint: "fk_EstimateParameterValue_parametricEstimateId" },
  { from: "Folder", column: "parentFolderId", to: "Folder", references: "folderId", constraint: "fk_Folder_parentFolderId" },
  { from: "Folder", column: "projectId", to: "Project", references: "projectId", constraint: "fk_Folder_projectId" },
  { from: "Gate", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_Gate_contractId" },
  { from: "GateChecklistItem", column: "completedById", to: "User", references: "userId", constraint: "fk_GateChecklistItem_completedById" },
  { from: "GateChecklistItem", column: "gateId", to: "Gate", references: "gateId", constraint: "fk_GateChecklistItem_gateId" },
  { from: "HandoverPackage", column: "acceptedById", to: "User", references: "userId", constraint: "fk_HandoverPackage_acceptedById" },
  { from: "HandoverPackage", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_HandoverPackage_contractId" },
  { from: "Meeting", column: "projectId", to: "Project", references: "projectId", constraint: "fk_Meeting_projectId" },
  { from: "MeetingAgendaItem", column: "meetingId", to: "Meeting", references: "meetingId", constraint: "fk_MeetingAgendaItem_meetingId" },
  { from: "MeetingAgendaItem", column: "ownerId", to: "User", references: "userId", constraint: "fk_MeetingAgendaItem_ownerId" },
  { from: "MeetingAttendee", column: "meetingId", to: "Meeting", references: "meetingId", constraint: "fk_MeetingAttendee_meetingId" },
  { from: "MeetingAttendee", column: "userId", to: "User", references: "userId", constraint: "fk_MeetingAttendee_userId" },
  { from: "MeetingMinutes", column: "approvedById", to: "User", references: "userId", constraint: "fk_MeetingMinutes_approvedById" },
  { from: "MeetingMinutes", column: "meetingId", to: "Meeting", references: "meetingId", constraint: "fk_MeetingMinutes_meetingId" },
  { from: "ModelParameter", column: "parameterId", to: "Parameter", references: "parameterId", constraint: "fk_ModelParameter_parameterId" },
  { from: "ModelParameter", column: "parametricModelId", to: "ParametricModel", references: "parametricModelId", constraint: "fk_ModelParameter_parametricModelId" },
  { from: "NCR", column: "assignedToId", to: "User", references: "userId", constraint: "fk_NCR_assignedToId" },
  { from: "NCR", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_NCR_contractId" },
  { from: "NCR", column: "raisedByUserId", to: "User", references: "userId", constraint: "fk_NCR_raisedByUserId" },
  { from: "NoticeOfWin", column: "projectId", to: "Project", references: "projectId", constraint: "fk_NoticeOfWin_projectId" },
  { from: "Notification", column: "userId", to: "User", references: "userId", constraint: "fk_Notification_userId" },
  { from: "Parameter", column: "parameterCategoryId", to: "ParameterCategory", references: "parameterCategoryId", constraint: "fk_Parameter_parameterCategoryId" },
  { from: "ParametricEstimate", column: "costPlanId", to: "CostPlan", references: "costPlanId", constraint: "fk_ParametricEstimate_costPlanId" },
  { from: "ParametricEstimate", column: "createdById", to: "User", references: "userId", constraint: "fk_ParametricEstimate_createdById" },
  { from: "ParametricEstimate", column: "parametricModelId", to: "ParametricModel", references: "parametricModelId", constraint: "fk_ParametricEstimate_parametricModelId" },
  { from: "ParametricModel", column: "createdById", to: "User", references: "userId", constraint: "fk_ParametricModel_createdById" },
  { from: "PaymentSchedule", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_PaymentSchedule_contractId" },
  { from: "PaymentScheduleItem", column: "paymentScheduleId", to: "PaymentSchedule", references: "paymentScheduleId", constraint: "fk_PaymentScheduleItem_paymentScheduleId" },
  { from: "PerformanceRating", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_PerformanceRating_contractId" },
  { from: "PerformanceRating", column: "ratedById", to: "User", references: "userId", constraint: "fk_PerformanceRating_ratedById" },
  { from: "Project", column: "clientId", to: "Client", references: "clientId", constraint: "fk_Project_clientId" },
  { from: "ProjectTeam", column: "projectId", to: "Project", references: "projectId", constraint: "fk_ProjectTeam_projectId" },
  { from: "ProjectTeam", column: "userId", to: "User", references: "userId", constraint: "fk_ProjectTeam_userId" },
  { from: "ProjectTeam", column: "userRoleId", to: "UserRole", references: "userRoleId", constraint: "fk_ProjectTeam_userRoleId" },
  { from: "QASheet", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_QASheet_contractId" },
  { from: "Query", column: "assignedToId", to: "User", references: "userId", constraint: "fk_Query_assignedToId" },
  { from: "Query", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_Query_contractId" },
  { from: "Query", column: "raisedById", to: "User", references: "userId", constraint: "fk_Query_raisedById" },
  { from: "QueryAttachment", column: "queryId", to: "Query", references: "queryId", constraint: "fk_QueryAttachment_queryId" },
  { from: "QueryAttachment", column: "uploadedById", to: "User", references: "userId", constraint: "fk_QueryAttachment_uploadedById" },
  { from: "QueryResponse", column: "queryId", to: "Query", references: "queryId", constraint: "fk_QueryResponse_queryId" },
  { from: "QueryResponse", column: "respondedById", to: "User", references: "userId", constraint: "fk_QueryResponse_respondedById" },
  { from: "Risk", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_Risk_contractId" },
  { from: "Risk", column: "ownerId", to: "User", references: "userId", constraint: "fk_Risk_ownerId" },
  { from: "Risk", column: "raisedById", to: "User", references: "userId", constraint: "fk_Risk_raisedById" },
  { from: "RiskAdjustment", column: "createdById", to: "User", references: "userId", constraint: "fk_RiskAdjustment_createdById" },
  { from: "RiskAdjustment", column: "parametricEstimateId", to: "ParametricEstimate", references: "parametricEstimateId", constraint: "fk_RiskAdjustment_parametricEstimateId" },
  { from: "Role", column: "parentRoleId", to: "Role", references: "roleId", constraint: "fk_Role_parentRoleId" },
  { from: "RolePermission", column: "permissionId", to: "Permission", references: "permissionId", constraint: "fk_RolePermission_permissionId" },
  { from: "RolePermission", column: "roleId", to: "Role", references: "roleId", constraint: "fk_RolePermission_roleId" },
  { from: "SensitivityAnalysis", column: "parameterId", to: "Parameter", references: "parameterId", constraint: "fk_SensitivityAnalysis_parameterId" },
  { from: "SensitivityAnalysis", column: "parametricEstimateId", to: "ParametricEstimate", references: "parametricEstimateId", constraint: "fk_SensitivityAnalysis_parametricEstimateId" },
  { from: "TenderQuery", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_TenderQuery_contractId" },
  { from: "TenderQuery", column: "respondedById", to: "User", references: "userId", constraint: "fk_TenderQuery_respondedById" },
  { from: "Transmittal", column: "projectId", to: "Project", references: "projectId", constraint: "fk_Transmittal_projectId" },
  { from: "Transmittal", column: "recipientUserId", to: "User", references: "userId", constraint: "fk_Transmittal_recipientUserId" },
  { from: "Transmittal", column: "sentById", to: "User", references: "userId", constraint: "fk_Transmittal_sentById" },
  { from: "TransmittalDocument", column: "documentId", to: "Document", references: "documentId", constraint: "fk_TransmittalDocument_documentId" },
  { from: "TransmittalDocument", column: "documentVersionId", to: "DocumentVersion", references: "documentVersionId", constraint: "fk_TransmittalDocument_documentVersionId" },
  { from: "TransmittalDocument", column: "transmittalId", to: "Transmittal", references: "transmittalId", constraint: "fk_TransmittalDocument_transmittalId" },
  { from: "UserRole", column: "assignedById", to: "User", references: "userId", constraint: "fk_UserRole_assignedById" },
  { from: "UserRole", column: "organizationId", to: "Organization", references: "organizationId", constraint: "fk_UserRole_organizationId" },
  { from: "UserRole", column: "roleId", to: "Role", references: "roleId", constraint: "fk_UserRole_roleId" },
  { from: "UserRole", column: "userId", to: "User", references: "userId", constraint: "fk_UserRole_userId" },
  { from: "VariationOrder", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_VariationOrder_contractId" },
  { from: "VariationOrder", column: "createdById", to: "User", references: "userId", constraint: "fk_VariationOrder_createdById" },
  { from: "VEItem", column: "costPlanId", to: "CostPlan", references: "costPlanId", constraint: "fk_VEItem_costPlanId" },
  { from: "VEItem", column: "raisedById", to: "User", references: "userId", constraint: "fk_VEItem_raisedById" },
  { from: "VEItem", column: "reviewedById", to: "User", references: "userId", constraint: "fk_VEItem_reviewedById" },
  { from: "WorkflowInstance", column: "workflowDefinitionId", to: "WorkflowDefinition", references: "workflowDefinitionId", constraint: "fk_WorkflowInstance_workflowDefinitionId" },
  { from: "WorkflowTransition", column: "transitionedById", to: "User", references: "userId", constraint: "fk_WorkflowTransition_transitionedById" },
  { from: "WorkflowTransition", column: "workflowInstanceId", to: "WorkflowInstance", references: "workflowInstanceId", constraint: "fk_WorkflowTransition_workflowInstanceId" },
  { from: "WorkOrder", column: "contractId", to: "Contract", references: "contractId", constraint: "fk_WorkOrder_contractId" },
  { from: "WorkOrder", column: "issuedById", to: "User", references: "userId", constraint: "fk_WorkOrder_issuedById" },
] as const;

// Schema statistics at generation time.
export const SCHEMA_STATS = {
  tables: 84,
  foreignKeys: 139,
  generatedAt: "2026-05-28",
} as const;
