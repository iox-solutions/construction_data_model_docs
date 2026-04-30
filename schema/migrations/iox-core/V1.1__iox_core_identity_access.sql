-- IOX Core v1.1 — Identity & Access Segment
-- Release: Complete identity, access control, and organisational hierarchy
-- Approved: 2026-03-06

-- User
CREATE TABLE "User" (
  "userId" TEXT PRIMARY KEY,
  "email" TEXT NOT NULL UNIQUE,
  "password" TEXT NOT NULL,
  "firstName" TEXT NOT NULL,
  "lastName" TEXT NOT NULL,
  "phone" TEXT,
  "avatar" TEXT,
  "status" TEXT NOT NULL DEFAULT 'ACTIVE',
  "emailVerified" TIMESTAMP,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "allowedCountries" TEXT[],
  "allowedDevelopers" TEXT[]
);

CREATE INDEX "idx_User_email" ON "User"("email");
CREATE INDEX "idx_User_status" ON "User"("status");

-- Role
CREATE TABLE "Role" (
  "roleId" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "code" TEXT NOT NULL UNIQUE,
  "level" INTEGER NOT NULL,
  "track" TEXT NOT NULL,
  "description" TEXT,
  "parentRoleId" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Role_code" ON "Role"("code");
CREATE INDEX "idx_Role_parentRoleId" ON "Role"("parentRoleId");

-- Permission
CREATE TABLE "Permission" (
  "permissionId" TEXT PRIMARY KEY,
  "code" TEXT NOT NULL UNIQUE,
  "name" TEXT NOT NULL,
  "module" TEXT NOT NULL,
  "action" TEXT NOT NULL,
  "description" TEXT
);

CREATE INDEX "idx_Permission_code" ON "Permission"("code");
CREATE INDEX "idx_Permission_module" ON "Permission"("module");

-- RolePermission
CREATE TABLE "RolePermission" (
  "rolePermissionId" TEXT PRIMARY KEY,
  "roleId" TEXT NOT NULL,
  "permissionId" TEXT NOT NULL,
  UNIQUE("roleId", "permissionId")
);

CREATE INDEX "idx_RolePermission_roleId" ON "RolePermission"("roleId");
CREATE INDEX "idx_RolePermission_permissionId" ON "RolePermission"("permissionId");

-- Organization
CREATE TABLE "Organization" (
  "organizationId" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "code" TEXT,
  "address" TEXT,
  "phone" TEXT,
  "email" TEXT,
  "website" TEXT,
  "logo" TEXT,
  "status" TEXT NOT NULL DEFAULT 'ACTIVE',
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Organization_type" ON "Organization"("type");
CREATE INDEX "idx_Organization_status" ON "Organization"("status");

-- Department
CREATE TABLE "Department" (
  "departmentId" TEXT PRIMARY KEY,
  "organizationId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "code" TEXT,
  "parentDepartmentId" TEXT,
  "headUserId" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Department_organizationId" ON "Department"("organizationId");
CREATE INDEX "idx_Department_parentDepartmentId" ON "Department"("parentDepartmentId");
CREATE INDEX "idx_Department_headUserId" ON "Department"("headUserId");

-- UserRole
CREATE TABLE "UserRole" (
  "userRoleId" TEXT PRIMARY KEY,
  "userId" TEXT NOT NULL,
  "roleId" TEXT NOT NULL,
  "organizationId" TEXT,
  "projectId" TEXT,
  "isPrimary" BOOLEAN NOT NULL DEFAULT FALSE,
  "assignedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "assignedById" TEXT
);

CREATE INDEX "idx_UserRole_userId" ON "UserRole"("userId");
CREATE INDEX "idx_UserRole_roleId" ON "UserRole"("roleId");
CREATE INDEX "idx_UserRole_organizationId" ON "UserRole"("organizationId");
CREATE INDEX "idx_UserRole_projectId" ON "UserRole"("projectId");
CREATE INDEX "idx_UserRole_assignedById" ON "UserRole"("assignedById");

-- Add foreign key constraint for parentRoleId (self-reference)
ALTER TABLE "Role" ADD CONSTRAINT "fk_Role_parentRoleId" FOREIGN KEY ("parentRoleId") REFERENCES "Role"("roleId");

-- Add foreign key constraint for headUserId in Department
ALTER TABLE "Department" ADD CONSTRAINT "fk_Department_headUserId" FOREIGN KEY ("headUserId") REFERENCES "User"("userId");

-- Add foreign key constraint for parentDepartmentId in Department
ALTER TABLE "Department" ADD CONSTRAINT "fk_Department_parentDepartmentId" FOREIGN KEY ("parentDepartmentId") REFERENCES "Department"("departmentId");

-- Add foreign key constraint for organizationId in Department
ALTER TABLE "Department" ADD CONSTRAINT "fk_Department_organizationId" FOREIGN KEY ("organizationId") REFERENCES "Organization"("organizationId");

-- Add foreign keys for UserRole
ALTER TABLE "UserRole" ADD CONSTRAINT "fk_UserRole_userId" FOREIGN KEY ("userId") REFERENCES "User"("userId");
ALTER TABLE "UserRole" ADD CONSTRAINT "fk_UserRole_roleId" FOREIGN KEY ("roleId") REFERENCES "Role"("roleId");
ALTER TABLE "UserRole" ADD CONSTRAINT "fk_UserRole_organizationId" FOREIGN KEY ("organizationId") REFERENCES "Organization"("organizationId");
ALTER TABLE "UserRole" ADD CONSTRAINT "fk_UserRole_assignedById" FOREIGN KEY ("assignedById") REFERENCES "User"("userId");

-- Add foreign keys for RolePermission
ALTER TABLE "RolePermission" ADD CONSTRAINT "fk_RolePermission_roleId" FOREIGN KEY ("roleId") REFERENCES "Role"("roleId");
ALTER TABLE "RolePermission" ADD CONSTRAINT "fk_RolePermission_permissionId" FOREIGN KEY ("permissionId") REFERENCES "Permission"("permissionId");

-- Add foreign keys for ContractMatchKey (from v1.0)
ALTER TABLE "ContractMatchKey" ADD CONSTRAINT "fk_ContractMatchKey_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");

-- Add foreign keys for Contractor (from v1.0)
ALTER TABLE "Contractor" ADD CONSTRAINT "fk_Contractor_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "Contractor" ADD CONSTRAINT "fk_Contractor_organizationId" FOREIGN KEY ("organizationId") REFERENCES "Organization"("organizationId");

-- Add foreign keys for Budget (from v1.0)
ALTER TABLE "Budget" ADD CONSTRAINT "fk_Budget_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");

-- Add foreign keys for BudgetVersion (from v1.0)
ALTER TABLE "BudgetVersion" ADD CONSTRAINT "fk_BudgetVersion_budgetId" FOREIGN KEY ("budgetId") REFERENCES "Budget"("budgetId");
ALTER TABLE "BudgetVersion" ADD CONSTRAINT "fk_BudgetVersion_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");

-- Add foreign keys for CostPlan (from v1.0)
ALTER TABLE "CostPlan" ADD CONSTRAINT "fk_CostPlan_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "CostPlan" ADD CONSTRAINT "fk_CostPlan_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");

-- Add foreign keys for CostPlanVersion (from v1.0)
ALTER TABLE "CostPlanVersion" ADD CONSTRAINT "fk_CostPlanVersion_costPlanId" FOREIGN KEY ("costPlanId") REFERENCES "CostPlan"("costPlanId");
ALTER TABLE "CostPlanVersion" ADD CONSTRAINT "fk_CostPlanVersion_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");

-- Add foreign keys for ContractStage (from v1.0)
ALTER TABLE "ContractStage" ADD CONSTRAINT "fk_ContractStage_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");

-- Add foreign keys for EarlyWarning (from v1.0)
ALTER TABLE "EarlyWarning" ADD CONSTRAINT "fk_EarlyWarning_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "EarlyWarning" ADD CONSTRAINT "fk_EarlyWarning_raisedById" FOREIGN KEY ("raisedById") REFERENCES "User"("userId");
ALTER TABLE "EarlyWarning" ADD CONSTRAINT "fk_EarlyWarning_assignedToId" FOREIGN KEY ("assignedToId") REFERENCES "User"("userId");

-- Add foreign keys for VariationOrder (from v1.0)
ALTER TABLE "VariationOrder" ADD CONSTRAINT "fk_VariationOrder_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "VariationOrder" ADD CONSTRAINT "fk_VariationOrder_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");

-- Add foreign keys for EarlyWarningVariationOrderLink (from v1.0)
ALTER TABLE "EarlyWarningVariationOrderLink" ADD CONSTRAINT "fk_EarlyWarningVariationOrderLink_earlyWarningId" FOREIGN KEY ("earlyWarningId") REFERENCES "EarlyWarning"("earlyWarningId");
ALTER TABLE "EarlyWarningVariationOrderLink" ADD CONSTRAINT "fk_EarlyWarningVariationOrderLink_variationOrderId" FOREIGN KEY ("variationOrderId") REFERENCES "VariationOrder"("variationOrderId");

-- Add foreign keys for PaymentSchedule (from v1.0)
ALTER TABLE "PaymentSchedule" ADD CONSTRAINT "fk_PaymentSchedule_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");

-- Add foreign keys for PaymentScheduleItem (from v1.0)
ALTER TABLE "PaymentScheduleItem" ADD CONSTRAINT "fk_PaymentScheduleItem_paymentScheduleId" FOREIGN KEY ("paymentScheduleId") REFERENCES "PaymentSchedule"("paymentScheduleId");

-- Add foreign keys for CertifiedPayment (from v1.0)
ALTER TABLE "CertifiedPayment" ADD CONSTRAINT "fk_CertifiedPayment_contractId" FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
ALTER TABLE "CertifiedPayment" ADD CONSTRAINT "fk_CertifiedPayment_certifiedById" FOREIGN KEY ("certifiedById") REFERENCES "User"("userId");

-- Add foreign keys for CertifiedPaymentAllocation (from v1.0)
ALTER TABLE "CertifiedPaymentAllocation" ADD CONSTRAINT "fk_CertifiedPaymentAllocation_certifiedPaymentId" FOREIGN KEY ("certifiedPaymentId") REFERENCES "CertifiedPayment"("certifiedPaymentId");
ALTER TABLE "CertifiedPaymentAllocation" ADD CONSTRAINT "fk_CertifiedPaymentAllocation_paymentScheduleItemId" FOREIGN KEY ("paymentScheduleItemId") REFERENCES "PaymentScheduleItem"("paymentScheduleItemId");
