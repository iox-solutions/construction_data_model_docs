-- IOX Core v1.0 — Project & Contract Segment
-- Initial release: Core entities for contract and cost management
-- Approved: 2026-03-06

-- Contract
CREATE TABLE "Contract" (
  "contractId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "number" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "contractType" TEXT,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "clientOrganizationId" TEXT,
  "contractorId" TEXT,
  "startDate" DATE,
  "endDate" DATE,
  "value" DECIMAL(19,2),
  "currency" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("projectId", "number")
);

CREATE INDEX "idx_Contract_projectId" ON "Contract"("projectId");
CREATE INDEX "idx_Contract_status" ON "Contract"("status");

-- ContractMatchKey
CREATE TABLE "ContractMatchKey" (
  "contractMatchKeyId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "keyName" TEXT NOT NULL,
  "keyValue" TEXT NOT NULL,
  UNIQUE("contractId", "keyName")
);

CREATE INDEX "idx_ContractMatchKey_contractId" ON "ContractMatchKey"("contractId");

-- Contractor
CREATE TABLE "Contractor" (
  "contractorId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "organizationId" TEXT NOT NULL,
  "role" TEXT,
  "appointmentDate" DATE,
  UNIQUE("contractId", "organizationId")
);

CREATE INDEX "idx_Contractor_contractId" ON "Contractor"("contractId");
CREATE INDEX "idx_Contractor_organizationId" ON "Contractor"("organizationId");

-- Budget
CREATE TABLE "Budget" (
  "budgetId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "totalValue" DECIMAL(19,2),
  "currency" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId")
);

CREATE INDEX "idx_Budget_contractId" ON "Budget"("contractId");

-- BudgetVersion
CREATE TABLE "BudgetVersion" (
  "budgetVersionId" TEXT PRIMARY KEY,
  "budgetId" TEXT NOT NULL,
  "versionLabel" TEXT NOT NULL,
  "snapshot" JSONB NOT NULL,
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("budgetId", "versionLabel")
);

CREATE INDEX "idx_BudgetVersion_budgetId" ON "BudgetVersion"("budgetId");

-- CostPlan
CREATE TABLE "CostPlan" (
  "costPlanId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "totalCost" DECIMAL(19,2),
  "currency" TEXT,
  "benchmarkProjectId" TEXT,
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_CostPlan_contractId" ON "CostPlan"("contractId");
CREATE INDEX "idx_CostPlan_status" ON "CostPlan"("status");

-- CostPlanVersion
CREATE TABLE "CostPlanVersion" (
  "costPlanVersionId" TEXT PRIMARY KEY,
  "costPlanId" TEXT NOT NULL,
  "versionLabel" TEXT NOT NULL,
  "snapshot" JSONB NOT NULL,
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("costPlanId", "versionLabel")
);

CREATE INDEX "idx_CostPlanVersion_costPlanId" ON "CostPlanVersion"("costPlanId");

-- ContractStage
CREATE TABLE "ContractStage" (
  "contractStageId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "stageName" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'PENDING',
  "targetDate" DATE,
  "completedDate" DATE,
  UNIQUE("contractId", "stageName")
);

CREATE INDEX "idx_ContractStage_contractId" ON "ContractStage"("contractId");

-- EarlyWarning
CREATE TABLE "EarlyWarning" (
  "earlyWarningId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "status" TEXT NOT NULL DEFAULT 'OPEN',
  "raisedById" TEXT NOT NULL,
  "assignedToId" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_EarlyWarning_contractId" ON "EarlyWarning"("contractId");
CREATE INDEX "idx_EarlyWarning_status" ON "EarlyWarning"("status");

-- VariationOrder
CREATE TABLE "VariationOrder" (
  "variationOrderId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "reference" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "description" TEXT,
  "valuationAmount" DECIMAL(19,2),
  "status" TEXT NOT NULL DEFAULT 'PROPOSED',
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId", "reference")
);

CREATE INDEX "idx_VariationOrder_contractId" ON "VariationOrder"("contractId");

-- EarlyWarningVariationOrderLink
CREATE TABLE "EarlyWarningVariationOrderLink" (
  "linkId" TEXT PRIMARY KEY,
  "earlyWarningId" TEXT NOT NULL,
  "variationOrderId" TEXT NOT NULL,
  UNIQUE("earlyWarningId", "variationOrderId")
);

CREATE INDEX "idx_EarlyWarningVariationOrderLink_earlyWarningId" ON "EarlyWarningVariationOrderLink"("earlyWarningId");
CREATE INDEX "idx_EarlyWarningVariationOrderLink_variationOrderId" ON "EarlyWarningVariationOrderLink"("variationOrderId");

-- PaymentSchedule
CREATE TABLE "PaymentSchedule" (
  "paymentScheduleId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "totalValue" DECIMAL(19,2),
  "currency" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId")
);

CREATE INDEX "idx_PaymentSchedule_contractId" ON "PaymentSchedule"("contractId");

-- PaymentScheduleItem
CREATE TABLE "PaymentScheduleItem" (
  "paymentScheduleItemId" TEXT PRIMARY KEY,
  "paymentScheduleId" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "dueDate" DATE,
  "paymentValue" DECIMAL(19,2),
  "sortOrder" INTEGER,
  UNIQUE("paymentScheduleId", "sortOrder")
);

CREATE INDEX "idx_PaymentScheduleItem_paymentScheduleId" ON "PaymentScheduleItem"("paymentScheduleId");

-- CertifiedPayment
CREATE TABLE "CertifiedPayment" (
  "certifiedPaymentId" TEXT PRIMARY KEY,
  "contractId" TEXT NOT NULL,
  "reference" TEXT NOT NULL,
  "certificationDate" DATE NOT NULL,
  "certifiedAmount" DECIMAL(19,2) NOT NULL,
  "currency" TEXT,
  "certifiedById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("contractId", "reference")
);

CREATE INDEX "idx_CertifiedPayment_contractId" ON "CertifiedPayment"("contractId");

-- CertifiedPaymentAllocation
CREATE TABLE "CertifiedPaymentAllocation" (
  "allocationId" TEXT PRIMARY KEY,
  "certifiedPaymentId" TEXT NOT NULL,
  "paymentScheduleItemId" TEXT NOT NULL,
  "allocatedAmount" DECIMAL(19,2),
  UNIQUE("certifiedPaymentId", "paymentScheduleItemId")
);

CREATE INDEX "idx_CertifiedPaymentAllocation_certifiedPaymentId" ON "CertifiedPaymentAllocation"("certifiedPaymentId");
CREATE INDEX "idx_CertifiedPaymentAllocation_paymentScheduleItemId" ON "CertifiedPaymentAllocation"("paymentScheduleItemId");
