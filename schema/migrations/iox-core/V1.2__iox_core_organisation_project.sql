-- IOX Core v1.2 — Organisation & Project Segment
-- Release: Client and Project hierarchy with team management
-- Approved: 2026-03-06

-- Client
CREATE TABLE "Client" (
  "clientId" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "organizationId" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Client_organizationId" ON "Client"("organizationId");

-- Project
CREATE TABLE "Project" (
  "projectId" TEXT PRIMARY KEY,
  "clientId" TEXT NOT NULL,
  "number" TEXT NOT NULL UNIQUE,
  "name" TEXT NOT NULL,
  "description" TEXT,
  "location" TEXT,
  "status" TEXT NOT NULL DEFAULT 'ACTIVE',
  "startDate" DATE,
  "endDate" DATE,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "idx_Project_clientId" ON "Project"("clientId");
CREATE INDEX "idx_Project_status" ON "Project"("status");

-- NoticeOfWin
CREATE TABLE "NoticeOfWin" (
  "noticeOfWinId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "awardDate" DATE,
  "awardValue" DECIMAL(19,2),
  "currency" TEXT,
  "projectBrief" JSONB,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("projectId")
);

CREATE INDEX "idx_NoticeOfWin_projectId" ON "NoticeOfWin"("projectId");

-- ProjectTeam
CREATE TABLE "ProjectTeam" (
  "projectTeamId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "userRoleId" TEXT NOT NULL,
  "joinedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "leftAt" TIMESTAMP
);

CREATE INDEX "idx_ProjectTeam_projectId" ON "ProjectTeam"("projectId");
CREATE INDEX "idx_ProjectTeam_userId" ON "ProjectTeam"("userId");
CREATE INDEX "idx_ProjectTeam_userRoleId" ON "ProjectTeam"("userRoleId");
CREATE UNIQUE INDEX "idx_ProjectTeam_active" ON "ProjectTeam"("projectId", "userId") WHERE "leftAt" IS NULL;

-- CommunicationProtocol
CREATE TABLE "CommunicationProtocol" (
  "communicationProtocolId" TEXT PRIMARY KEY,
  "projectId" TEXT NOT NULL,
  "responseTimeframeDays" INTEGER,
  "namingConvention" TEXT,
  "notes" TEXT,
  "createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE("projectId")
);

CREATE INDEX "idx_CommunicationProtocol_projectId" ON "CommunicationProtocol"("projectId");

-- Add foreign keys for Client
ALTER TABLE "Client" ADD CONSTRAINT "fk_Client_organizationId" FOREIGN KEY ("organizationId") REFERENCES "Organization"("organizationId");

-- Add foreign keys for Project
ALTER TABLE "Project" ADD CONSTRAINT "fk_Project_clientId" FOREIGN KEY ("clientId") REFERENCES "Client"("clientId");

-- Add foreign keys for NoticeOfWin
ALTER TABLE "NoticeOfWin" ADD CONSTRAINT "fk_NoticeOfWin_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");

-- Add foreign keys for ProjectTeam
ALTER TABLE "ProjectTeam" ADD CONSTRAINT "fk_ProjectTeam_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");
ALTER TABLE "ProjectTeam" ADD CONSTRAINT "fk_ProjectTeam_userId" FOREIGN KEY ("userId") REFERENCES "User"("userId");
ALTER TABLE "ProjectTeam" ADD CONSTRAINT "fk_ProjectTeam_userRoleId" FOREIGN KEY ("userRoleId") REFERENCES "UserRole"("userRoleId");

-- Add foreign keys for CommunicationProtocol
ALTER TABLE "CommunicationProtocol" ADD CONSTRAINT "fk_CommunicationProtocol_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");

-- Update Contract to reference Project (retroactively linking v1.0 Contract to v1.2 Project)
ALTER TABLE "Contract" ADD CONSTRAINT "fk_Contract_projectId" FOREIGN KEY ("projectId") REFERENCES "Project"("projectId");
