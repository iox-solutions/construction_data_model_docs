-- =====================================================================
-- IOX Core v1.14 — password-hash rename + QA FK repair
--
-- Two distinct changes bundled here:
--
--   1. RFC 0002 — rename User.password to User.passwordHash and document
--      the hashing contract. Breaking change; deprecation window waived
--      because no production consumer exists (Schema Steward decision,
--      2026-05-28).
--
--   2. Follow-up from RFC 0001 — V1.12 declared three foreign keys against
--      columns that do not exist in their tables:
--        - fk_QASheet_contractId      (QASheet.contractId)
--        - fk_BOQ_createdById         (BOQ.createdById)
--        - fk_Query_assignedToId      (Query.assignedToId)
--      All three broken declarations were removed from V1.12; the columns
--      and constraints are added correctly here.
--
-- Greenfield-safe: no production deployment per Schema Steward (2026-05-28).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. RFC 0002 — User.password rename
-- ---------------------------------------------------------------------

ALTER TABLE "User" RENAME COLUMN "password" TO "passwordHash";

COMMENT ON COLUMN "User"."passwordHash" IS
  'Argon2id hash of the user password. NEVER store plaintext. NEVER include in AuditLog payloads.';

-- ---------------------------------------------------------------------
-- 2. RFC 0001 follow-up — repair three V1.12 FK declarations whose
--    source columns were never added to their CREATE TABLE statements.
-- ---------------------------------------------------------------------

-- QASheet.contractId
ALTER TABLE "QASheet" ADD COLUMN "contractId" TEXT;
ALTER TABLE "QASheet"
  ADD CONSTRAINT "fk_QASheet_contractId"
  FOREIGN KEY ("contractId") REFERENCES "Contract"("contractId");
CREATE INDEX "idx_QASheet_contractId" ON "QASheet"("contractId");

-- BOQ.createdById
ALTER TABLE "BOQ" ADD COLUMN "createdById" TEXT;
ALTER TABLE "BOQ"
  ADD CONSTRAINT "fk_BOQ_createdById"
  FOREIGN KEY ("createdById") REFERENCES "User"("userId");
CREATE INDEX "idx_BOQ_createdById" ON "BOQ"("createdById");

-- Query.assignedToId
ALTER TABLE "Query" ADD COLUMN "assignedToId" TEXT;
ALTER TABLE "Query"
  ADD CONSTRAINT "fk_Query_assignedToId"
  FOREIGN KEY ("assignedToId") REFERENCES "User"("userId");
CREATE INDEX "idx_Query_assignedToId" ON "Query"("assignedToId");
