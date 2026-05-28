// Compile-time smoke test for @iox/types.
//
// This file is not a runtime test — it exists to fail `tsc --noEmit` if the
// generator produces malformed types. Every assertion below uses purely the
// type system; no runtime checks.
//
// What we exercise:
//   - Key tables exist and have their canonical columns at the expected types.
//   - The EntityType union contains the anchor tables.
//   - TABLE_MODULES is keyed by EntityType and returns Module values.
//   - FOREIGN_KEYS items have the documented shape.
//   - CORE_ANCHORS contains exactly the three anchors.

import type {
  ActionItem,
  Contract,
  CostPlan,
  EntityType,
  ForeignKey,
  Module,
  Project,
  User,
} from './index';

import { CORE_ANCHORS, FOREIGN_KEYS, SCHEMA_STATS, TABLE_MODULES } from './index';

// --- Anchor table shape ----------------------------------------------------

const project: Project = {
  projectId: 'p-1',
  clientId: 'c-1',
  number: 'P-001',
  name: 'Southgate Business Park',
  // Optional / defaulted / nullable fields elided — the type system must allow that.
};

const contract: Contract = {
  contractId: 'k-1',
  projectId: project.projectId,
  number: 'C-001',
  title: 'Main Works',
};

const costPlan: CostPlan = {
  costPlanId: 'cp-1',
  contractId: contract.contractId,
  title: 'Initial Cost Plan',
  createdById: 'u-1',
};

// --- Nullable handling -----------------------------------------------------

// ActionItem.completedAt is nullable — `null` must be assignable.
const action: ActionItem = {
  actionItemId: 'a-1',
  projectId: project.projectId,
  title: 'Confirm scope',
  ownerId: 'u-1',
  completedAt: null,
};

// --- Array column ---------------------------------------------------------

const user: User = {
  userId: 'u-1',
  email: 'user@example.com',
  password: 'redacted', // tracked as a rename target — see RFC 0002
  firstName: 'A',
  lastName: 'B',
  allowedCountries: ['GB', 'IE'],
};

// --- EntityType union -----------------------------------------------------

const anchorAsEntity: EntityType = 'Project';
// @ts-expect-error — non-existent table must be rejected by the union.
const bogus: EntityType = 'NotARealTable';

// --- TABLE_MODULES typing -------------------------------------------------

const projectModule: Module = TABLE_MODULES['Project'];
const contractModule: Module = TABLE_MODULES['Contract'];

// --- FOREIGN_KEYS structural check ----------------------------------------

const firstFk: ForeignKey | undefined = FOREIGN_KEYS[0];
if (firstFk) {
  const _from: EntityType = firstFk.from;
  const _to: EntityType = firstFk.to;
  const _col: string = firstFk.column;
  const _ref: string = firstFk.references;
  const _name: string = firstFk.constraint;
}

// --- CORE_ANCHORS ---------------------------------------------------------

const _anchorCount: 3 = CORE_ANCHORS.length;
const _anchor: 'CostPlan' | 'Project' | 'Contract' = CORE_ANCHORS[0];

// --- Schema stats ---------------------------------------------------------

const _tables: number = SCHEMA_STATS.tables;
const _fks: number = SCHEMA_STATS.foreignKeys;

// Mark uses to silence "declared but never read".
export const _smoke = [project, contract, costPlan, action, user, anchorAsEntity, projectModule, contractModule];
void bogus;
