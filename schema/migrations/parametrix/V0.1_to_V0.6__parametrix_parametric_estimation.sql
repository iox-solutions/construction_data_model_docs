-- ParametriX v0.1-v0.6 — Parametric Cost Estimation Module
-- Complete schema for parametric cost modeling and estimation
-- Extends IOX Core with parameter-driven cost relationships

-- =====================================================================
-- v0.1 — Parameter Foundation
-- =====================================================================

CREATE TABLE "ParameterCategory" (
  "parameterCategoryId" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Parameter" (
  "parameterId" TEXT PRIMARY KEY,
  "parameterCategoryId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "code" TEXT NOT NULL UNIQUE,
  "description" TEXT,
  "dataType" TEXT NOT NULL,
  "unit" TEXT,
  "minValue" DECIMAL(19,2),
  "maxValue" DECIMAL(19,2),
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Parameter_parameterCategoryId" ON "Parameter"("parameterCategoryId");
CREATE INDEX "idx_Parameter_code" ON "Parameter"("code");

-- =====================================================================
-- v0.2 — Parametric Models
-- =====================================================================

CREATE TABLE "ParametricModel" (
  "parametricModelId" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "projectType" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'ACTIVE',
  "version" TEXT,
  "baselineYear" INTEGER,
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_ParametricModel_projectType" ON "ParametricModel"("projectType");
CREATE INDEX "idx_ParametricModel_status" ON "ParametricModel"("status");

CREATE TABLE "ModelParameter" (
  "modelParameterId" TEXT PRIMARY KEY,
  "parametricModelId" TEXT NOT NULL,
  "parameterId" TEXT NOT NULL,
  "isRequired" BOOLEAN NOT NULL DEFAULT FALSE,
  "defaultValue" TEXT,
  "sortOrder" INTEGER,
  UNIQUE("parametricModelId", "parameterId")
);

CREATE INDEX "idx_ModelParameter_parametricModelId" ON "ModelParameter"("parametricModelId");
CREATE INDEX "idx_ModelParameter_parameterId" ON "ModelParameter"("parameterId");

-- =====================================================================
-- v0.3 — Cost Relationships and Rules
-- =====================================================================

CREATE TABLE "CostRelationship" (
  "costRelationshipId" TEXT PRIMARY KEY,
  "parametricModelId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "baselineValue" DECIMAL(19,2),
  "currency" TEXT,
  "formula" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_CostRelationship_parametricModelId" ON "CostRelationship"("parametricModelId");

CREATE TABLE "CostRelationshipParameter" (
  "relationshipParameterId" TEXT PRIMARY KEY,
  "costRelationshipId" TEXT NOT NULL,
  "parameterId" TEXT NOT NULL,
  "coefficient" DECIMAL(19,4),
  "sortOrder" INTEGER
);

CREATE INDEX "idx_CostRelationshipParameter_costRelationshipId" ON "CostRelationshipParameter"("costRelationshipId");
CREATE INDEX "idx_CostRelationshipParameter_parameterId" ON "CostRelationshipParameter"("parameterId");

-- =====================================================================
-- v0.4 — Estimate Generation
-- =====================================================================

CREATE TABLE "ParametricEstimate" (
  "parametricEstimateId" TEXT PRIMARY KEY,
  "costPlanId" TEXT NOT NULL,
  "parametricModelId" TEXT NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'DRAFT',
  "estimatedValue" DECIMAL(19,2),
  "currency" TEXT,
  "confidenceLevel" DECIMAL(5,2),
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_ParametricEstimate_costPlanId" ON "ParametricEstimate"("costPlanId");
CREATE INDEX "idx_ParametricEstimate_parametricModelId" ON "ParametricEstimate"("parametricModelId");
CREATE INDEX "idx_ParametricEstimate_status" ON "ParametricEstimate"("status");

CREATE TABLE "EstimateParameterValue" (
  "estimateParameterValueId" TEXT PRIMARY KEY,
  "parametricEstimateId" TEXT NOT NULL,
  "parameterId" TEXT NOT NULL,
  "value" TEXT NOT NULL,
  "unit" TEXT
);

CREATE INDEX "idx_EstimateParameterValue_parametricEstimateId" ON "EstimateParameterValue"("parametricEstimateId");
CREATE INDEX "idx_EstimateParameterValue_parameterId" ON "EstimateParameterValue"("parameterId");

CREATE TABLE "EstimateOutputValue" (
  "estimateOutputValueId" TEXT PRIMARY KEY,
  "parametricEstimateId" TEXT NOT NULL,
  "costRelationshipId" TEXT NOT NULL,
  "outputValue" DECIMAL(19,2),
  "unit" TEXT
);

CREATE INDEX "idx_EstimateOutputValue_parametricEstimateId" ON "EstimateOutputValue"("parametricEstimateId");
CREATE INDEX "idx_EstimateOutputValue_costRelationshipId" ON "EstimateOutputValue"("costRelationshipId");

-- =====================================================================
-- v0.5 — Historical Calibration Data
-- =====================================================================

CREATE TABLE "CalibrationDataSource" (
  "calibrationDataSourceId" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "sourceType" TEXT NOT NULL,
  "dataPoints" INTEGER,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "CalibrationDataPoint" (
  "calibrationDataPointId" TEXT PRIMARY KEY,
  "calibrationDataSourceId" TEXT NOT NULL,
  "projectReference" TEXT,
  "actualCost" DECIMAL(19,2),
  "currency" TEXT,
  "location" TEXT,
  "date" DATE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_CalibrationDataPoint_calibrationDataSourceId" ON "CalibrationDataPoint"("calibrationDataSourceId");

CREATE TABLE "CalibrationDataPointParameter" (
  "dataPointParameterId" TEXT PRIMARY KEY,
  "calibrationDataPointId" TEXT NOT NULL,
  "parameterId" TEXT NOT NULL,
  "value" TEXT NOT NULL,
  "unit" TEXT
);

CREATE INDEX "idx_CalibrationDataPointParameter_calibrationDataPointId" ON "CalibrationDataPointParameter"("calibrationDataPointId");
CREATE INDEX "idx_CalibrationDataPointParameter_parameterId" ON "CalibrationDataPointParameter"("parameterId");

-- =====================================================================
-- v0.6 — Estimate Sensitivity and Analysis
-- =====================================================================

CREATE TABLE "SensitivityAnalysis" (
  "sensitivityAnalysisId" TEXT PRIMARY KEY,
  "parametricEstimateId" TEXT NOT NULL,
  "parameterId" TEXT NOT NULL,
  "baselineValue" TEXT NOT NULL,
  "variationPercent" DECIMAL(5,2),
  "sensitivityFactor" DECIMAL(19,4),
  "impact" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_SensitivityAnalysis_parametricEstimateId" ON "SensitivityAnalysis"("parametricEstimateId");
CREATE INDEX "idx_SensitivityAnalysis_parameterId" ON "SensitivityAnalysis"("parameterId");

CREATE TABLE "RiskAdjustment" (
  "riskAdjustmentId" TEXT PRIMARY KEY,
  "parametricEstimateId" TEXT NOT NULL,
  "description" TEXT NOT NULL,
  "adjustmentPercent" DECIMAL(5,2),
  "adjustmentAmount" DECIMAL(19,2),
  "justification" TEXT,
  "createdById" TEXT NOT NULL,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_RiskAdjustment_parametricEstimateId" ON "RiskAdjustment"("parametricEstimateId");

-- =====================================================================
-- Foreign Keys - ParametriX
-- =====================================================================

ALTER TABLE "Parameter" ADD CONSTRAINT "fk_Parameter_parameterCategoryId" FOREIGN KEY ("parameterCategoryId") REFERENCES "ParameterCategory"("parameterCategoryId");

ALTER TABLE "ParametricModel" ADD CONSTRAINT "fk_ParametricModel_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");

ALTER TABLE "ModelParameter" ADD CONSTRAINT "fk_ModelParameter_parametricModelId" FOREIGN KEY ("parametricModelId") REFERENCES "ParametricModel"("parametricModelId");
ALTER TABLE "ModelParameter" ADD CONSTRAINT "fk_ModelParameter_parameterId" FOREIGN KEY ("parameterId") REFERENCES "Parameter"("parameterId");

ALTER TABLE "CostRelationship" ADD CONSTRAINT "fk_CostRelationship_parametricModelId" FOREIGN KEY ("parametricModelId") REFERENCES "ParametricModel"("parametricModelId");

ALTER TABLE "CostRelationshipParameter" ADD CONSTRAINT "fk_CostRelationshipParameter_costRelationshipId" FOREIGN KEY ("costRelationshipId") REFERENCES "CostRelationship"("costRelationshipId");
ALTER TABLE "CostRelationshipParameter" ADD CONSTRAINT "fk_CostRelationshipParameter_parameterId" FOREIGN KEY ("parameterId") REFERENCES "Parameter"("parameterId");

ALTER TABLE "ParametricEstimate" ADD CONSTRAINT "fk_ParametricEstimate_costPlanId" FOREIGN KEY ("costPlanId") REFERENCES "CostPlan"("costPlanId");
ALTER TABLE "ParametricEstimate" ADD CONSTRAINT "fk_ParametricEstimate_parametricModelId" FOREIGN KEY ("parametricModelId") REFERENCES "ParametricModel"("parametricModelId");
ALTER TABLE "ParametricEstimate" ADD CONSTRAINT "fk_ParametricEstimate_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");

ALTER TABLE "EstimateParameterValue" ADD CONSTRAINT "fk_EstimateParameterValue_parametricEstimateId" FOREIGN KEY ("parametricEstimateId") REFERENCES "ParametricEstimate"("parametricEstimateId");
ALTER TABLE "EstimateParameterValue" ADD CONSTRAINT "fk_EstimateParameterValue_parameterId" FOREIGN KEY ("parameterId") REFERENCES "Parameter"("parameterId");

ALTER TABLE "EstimateOutputValue" ADD CONSTRAINT "fk_EstimateOutputValue_parametricEstimateId" FOREIGN KEY ("parametricEstimateId") REFERENCES "ParametricEstimate"("parametricEstimateId");
ALTER TABLE "EstimateOutputValue" ADD CONSTRAINT "fk_EstimateOutputValue_costRelationshipId" FOREIGN KEY ("costRelationshipId") REFERENCES "CostRelationship"("costRelationshipId");

ALTER TABLE "CalibrationDataPoint" ADD CONSTRAINT "fk_CalibrationDataPoint_calibrationDataSourceId" FOREIGN KEY ("calibrationDataSourceId") REFERENCES "CalibrationDataSource"("calibrationDataSourceId");

ALTER TABLE "CalibrationDataPointParameter" ADD CONSTRAINT "fk_CalibrationDataPointParameter_calibrationDataPointId" FOREIGN KEY ("calibrationDataPointId") REFERENCES "CalibrationDataPoint"("calibrationDataPointId");
ALTER TABLE "CalibrationDataPointParameter" ADD CONSTRAINT "fk_CalibrationDataPointParameter_parameterId" FOREIGN KEY ("parameterId") REFERENCES "Parameter"("parameterId");

ALTER TABLE "SensitivityAnalysis" ADD CONSTRAINT "fk_SensitivityAnalysis_parametricEstimateId" FOREIGN KEY ("parametricEstimateId") REFERENCES "ParametricEstimate"("parametricEstimateId");
ALTER TABLE "SensitivityAnalysis" ADD CONSTRAINT "fk_SensitivityAnalysis_parameterId" FOREIGN KEY ("parameterId") REFERENCES "Parameter"("parameterId");

ALTER TABLE "RiskAdjustment" ADD CONSTRAINT "fk_RiskAdjustment_parametricEstimateId" FOREIGN KEY ("parametricEstimateId") REFERENCES "ParametricEstimate"("parametricEstimateId");
ALTER TABLE "RiskAdjustment" ADD CONSTRAINT "fk_RiskAdjustment_createdById" FOREIGN KEY ("createdById") REFERENCES "User"("userId");
