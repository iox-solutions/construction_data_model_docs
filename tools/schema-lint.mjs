#!/usr/bin/env node
// IOX schema lint — encodes the rules that make IOX a shared standard.
//
// Usage:
//   node tools/schema-lint.mjs                # exits 1 on any error
//   node tools/schema-lint.mjs --warn-only    # always exits 0; report only
//
// Rules:
//   R1  no-cross-module-fk        ERROR  — FKs between non-core modules are forbidden;
//                                          all cross-module joins must go through Core anchors.
//   R2  fk-target-must-exist      ERROR  — FK target table is unknown.
//   R3  pk-id-suffix              WARN   — primary key column should end in "Id"
//                                          (matches established pattern).
//   R4  audit-timestamps          WARN   — non-immutable tables should have createdAt+updatedAt.
//                                          Immutable tables (versions, log, transitions) are exempt.
//   R5  pii-comment               WARN   — tables holding email/phone/ipAddress should have a
//                                          COMMENT ON TABLE describing PII fields.
//   R6  password-plaintext        ERROR  — a column literally named "password" is a footgun.
//                                          If intentional, suppress with a comment.
//   R7  orphan-table              WARN   — table not assigned to any module in module-mapping.json.
//
// Add more rules below as patterns emerge. Each rule is a single function.

import { parseSchema, loadModuleMapping } from './parse-schema.mjs';

const args = new Set(process.argv.slice(2));
const WARN_ONLY = args.has('--warn-only');

const findings = []; // { level, rule, table?, message }
function add(level, rule, table, message) {
  findings.push({ level, rule, table, message });
}

const { tables, foreignKeys, comments } = parseSchema();
const mapping = loadModuleMapping();

// Build table → module index from module-mapping.json. Tables under exclude[]
// are still "core-managed" infrastructure (User, AuditLog, etc.) and not
// orphans; tables in placeholderx (empty by design) are excluded for now.
const tableToModule = new Map();
for (const [moduleKey, mod] of Object.entries(mapping.modules)) {
  for (const t of mod.tables ?? []) tableToModule.set(t, moduleKey);
}
for (const t of mapping.exclude ?? []) {
  if (!tableToModule.has(t)) tableToModule.set(t, 'core');
}

const CORE_ANCHORS = new Set(mapping.coreAnchors);
const NON_PRODUCT_MODULES = new Set(['core']);

// --- R1: no-cross-module-fk -----------------------------------------------
// Cross-module FKs are allowed only when the target is in core (Core anchor pattern).
// Same-module FKs are fine. Unknown ownership → flagged separately by R7.
for (const fk of foreignKeys) {
  const fromMod = tableToModule.get(fk.table);
  const toMod = tableToModule.get(fk.refTable);
  if (!fromMod || !toMod) continue; // R7 covers orphans
  if (fromMod === toMod) continue;
  if (NON_PRODUCT_MODULES.has(toMod)) continue; // Cross-module → core is the only allowed direction
  add(
    'error',
    'no-cross-module-fk',
    fk.table,
    `FK ${fk.constraint}: ${fk.table}(${fromMod}) → ${fk.refTable}(${toMod}). ` +
      `Cross-module references must terminate at a Core table. ` +
      `Route through a Core anchor (${[...CORE_ANCHORS].join(', ')}) instead.`,
  );
}

// --- R2: fk-target-must-exist ---------------------------------------------
for (const fk of foreignKeys) {
  if (!tables.has(fk.refTable)) {
    add(
      'error',
      'fk-target-must-exist',
      fk.table,
      `FK ${fk.constraint} references unknown table "${fk.refTable}".`,
    );
  }
}

// --- R3: pk-id-suffix -----------------------------------------------------
for (const [name, t] of tables) {
  const pk = t.columns.find((c) => c.isPrimaryKey);
  if (!pk) continue;
  if (!pk.name.endsWith('Id')) {
    add(
      'warn',
      'pk-id-suffix',
      name,
      `Primary key "${pk.name}" should end in "Id" (convention: ${name[0].toLowerCase()}${name.slice(1)}Id).`,
    );
  }
}

// --- R4: audit-timestamps -------------------------------------------------
// Tables that are immutable by design should NOT get this warning.
// Heuristic: name ends in "Version", "Transition", "Log", "Allocation",
// "Attendee", "ChecklistItem", or is a join table (PK + two FK cols).
const IMMUTABLE_SUFFIXES = ['Version', 'Transition', 'Log', 'Allocation', 'Attendee'];
function isLikelyImmutable(name, t) {
  if (IMMUTABLE_SUFFIXES.some((s) => name.endsWith(s))) return true;
  // Pure stub tables with only an id column — incomplete, exempt from this rule.
  if (t.columns.length <= 2) return true;
  return false;
}
for (const [name, t] of tables) {
  if (isLikelyImmutable(name, t)) continue;
  const colNames = new Set(t.columns.map((c) => c.name));
  if (!colNames.has('createdAt')) {
    add('warn', 'audit-timestamps', name, `Missing "createdAt" column.`);
  } else if (!colNames.has('updatedAt')) {
    add(
      'warn',
      'audit-timestamps',
      name,
      `Has "createdAt" but no "updatedAt". Add updatedAt or document why this table is append-only.`,
    );
  }
}

// --- R5: pii-comment ------------------------------------------------------
const PII_COL_NAMES = new Set([
  'email',
  'phone',
  'firstName',
  'lastName',
  'fullName',
  'address',
  'ipAddress',
  'userAgent',
  'avatar',
  'dateOfBirth',
  'taxId',
]);
for (const [name, t] of tables) {
  const piiCols = t.columns.filter((c) => PII_COL_NAMES.has(c.name)).map((c) => c.name);
  if (piiCols.length === 0) continue;
  const comment = comments.get(name);
  const documented = comment && /pii/i.test(comment);
  if (!documented) {
    add(
      'warn',
      'pii-comment',
      name,
      `Has PII columns [${piiCols.join(', ')}] but no PII note in COMMENT ON TABLE. ` +
        `Add: COMMENT ON TABLE "${name}" IS '... PII-flagged: ${piiCols.join(', ')}'.`,
    );
  }
}

// --- R6: password-plaintext -----------------------------------------------
for (const [name, t] of tables) {
  const pw = t.columns.find((c) => c.name === 'password');
  if (pw) {
    add(
      'error',
      'password-plaintext',
      name,
      `Column "password" is a footgun. Rename to "passwordHash", document the hashing algorithm in COMMENT ON COLUMN, or move auth out of the schema entirely.`,
    );
  }
}

// --- R7: orphan-table -----------------------------------------------------
for (const name of tables.keys()) {
  if (!tableToModule.has(name)) {
    add('warn', 'orphan-table', name, `Not assigned to any module in module-mapping.json.`);
  }
}

// --- Report ---------------------------------------------------------------
const byLevel = findings.reduce(
  (acc, f) => ((acc[f.level] = (acc[f.level] || 0) + 1), acc),
  {},
);
const errors = byLevel.error || 0;
const warns = byLevel.warn || 0;

const RED = '\x1b[31m';
const YEL = '\x1b[33m';
const DIM = '\x1b[2m';
const RST = '\x1b[0m';

if (findings.length === 0) {
  console.log('schema-lint: clean.');
  process.exit(0);
}

const byRule = new Map();
for (const f of findings) {
  if (!byRule.has(f.rule)) byRule.set(f.rule, []);
  byRule.get(f.rule).push(f);
}

for (const [rule, items] of [...byRule.entries()].sort()) {
  const level = items[0].level;
  const colour = level === 'error' ? RED : YEL;
  console.log(`\n${colour}${level.toUpperCase()}${RST} ${rule} (${items.length})`);
  for (const f of items) {
    console.log(`  ${DIM}${f.table ?? '-'}${RST}  ${f.message}`);
  }
}

console.log(`\nSummary: ${errors} error(s), ${warns} warning(s).`);
if (errors > 0 && !WARN_ONLY) process.exit(1);
process.exit(0);
