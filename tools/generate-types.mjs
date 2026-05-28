#!/usr/bin/env node
// Generate TypeScript types from IOX migration SQL.
//
// Usage:
//   node tools/generate-types.mjs
//
// Output: iox-types/src/generated.ts
//
// Re-run after any migration change. Output is checked in so consumers do not
// need a postinstall step.

import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';
import { parseSchema, loadModuleMapping, sqlTypeToTs } from './parse-schema.mjs';

const OUT = new URL('../iox-types/src/generated.ts', import.meta.url).pathname;

function buildTableToModule(mapping) {
  const map = new Map();
  for (const [moduleKey, mod] of Object.entries(mapping.modules)) {
    for (const t of mod.tables ?? []) map.set(t, moduleKey);
  }
  // Tables explicitly excluded from module visualisation are still real tables.
  // Treat them as 'core' if they are not already assigned.
  for (const t of mapping.exclude ?? []) {
    if (!map.has(t)) map.set(t, 'core');
  }
  return map;
}

function tsIdent(name) {
  // Table names are already valid TS identifiers (PascalCase). Reserved words
  // like `Notification` are fine — they are not TS reserved.
  return name;
}

function colTypeLine(col) {
  const ts = sqlTypeToTs(col.sqlType);
  const finalType = col.notNull ? ts : `${ts} | null`;
  const optMark = col.notNull && col.default == null ? '' : '?';
  return `  ${JSON.stringify(col.name)}${optMark}: ${finalType};`;
}

function emitInterface(table, comment) {
  const lines = [];
  if (comment) {
    const safe = comment.replace(/\*\//g, '*\\/');
    lines.push('/**');
    for (const ln of safe.split(/\r?\n/)) lines.push(` * ${ln}`);
    lines.push(' */');
  }
  lines.push(`export interface ${tsIdent(table.name)} {`);
  for (const col of table.columns) lines.push(colTypeLine(col));
  lines.push('}');
  return lines.join('\n');
}

function main() {
  const { tables, foreignKeys, comments } = parseSchema();
  const mapping = loadModuleMapping();
  const tableToModule = buildTableToModule(mapping);

  const allTableNames = [...tables.keys()].sort();
  const allModules = [
    ...new Set(['core', ...Object.keys(mapping.modules), 'unassigned']),
  ];

  const header = `// AUTO-GENERATED — do not edit by hand.
// Regenerate with: node tools/generate-types.mjs
// Source: schema/migrations/**
//
// Conventions:
//   - DECIMAL / NUMERIC columns are typed as \`string\` (default pg-node behaviour).
//     Cast to number / BigDecimal at the application boundary.
//   - TIMESTAMP / DATE columns are typed as \`Date\`. The pg driver returns
//     strings unless you install a type parser; configure your client accordingly.
//   - Columns without NOT NULL include \`| null\` in their type.
//   - Columns with a DEFAULT or that are nullable are marked optional (\`?\`)
//     for inserts; reads always return all keys.
`;

  const interfaces = allTableNames
    .map((name) => emitInterface(tables.get(name), comments.get(name)))
    .join('\n\n');

  const moduleUnion = `export type Module =\n  ${allModules
    .map((m) => `| ${JSON.stringify(m)}`)
    .join('\n  ')};`;

  const entityTypeUnion = `// Union of every persisted entity name. Use this for polymorphic refs
// (WorkflowInstance.entityType, AuditLog.entityType) and discriminated unions.
export type EntityType =\n  ${allTableNames
    .map((n) => `| ${JSON.stringify(n)}`)
    .join('\n  ')};`;

  const tableModulesMap = `export const TABLE_MODULES: Readonly<Record<EntityType, Module>> = {\n${allTableNames
    .map((n) => `  ${JSON.stringify(n)}: ${JSON.stringify(tableToModule.get(n) ?? 'unassigned')},`)
    .join('\n')}\n} as const;`;

  const fkArray = `export interface ForeignKey {
  readonly from: EntityType;
  readonly column: string;
  readonly to: EntityType;
  readonly references: string;
  readonly constraint: string;
}

export const FOREIGN_KEYS: ReadonlyArray<ForeignKey> = [
${foreignKeys
  .slice()
  .sort((a, b) =>
    a.table === b.table ? a.column.localeCompare(b.column) : a.table.localeCompare(b.table),
  )
  .map(
    (fk) =>
      `  { from: ${JSON.stringify(fk.table)}, column: ${JSON.stringify(fk.column)}, to: ${JSON.stringify(
        fk.refTable,
      )}, references: ${JSON.stringify(fk.refColumn)}, constraint: ${JSON.stringify(fk.constraint)} },`,
  )
  .join('\n')}
] as const;`;

  const anchors = `// Core anchor tables — every cross-module FK terminates at one of these.
export const CORE_ANCHORS = ${JSON.stringify(mapping.coreAnchors)} as const satisfies ReadonlyArray<EntityType>;`;

  const tableCount = allTableNames.length;
  const fkCount = foreignKeys.length;

  const stats = `// Schema statistics at generation time.
export const SCHEMA_STATS = {
  tables: ${tableCount},
  foreignKeys: ${fkCount},
  generatedAt: ${JSON.stringify(new Date().toISOString().slice(0, 10))},
} as const;`;

  const body = [
    header,
    moduleUnion,
    entityTypeUnion,
    anchors,
    interfaces,
    tableModulesMap,
    fkArray,
    stats,
  ].join('\n\n');

  mkdirSync(dirname(OUT), { recursive: true });
  writeFileSync(OUT, body + '\n', 'utf8');

  console.log(`Wrote ${OUT}`);
  console.log(`  ${tableCount} tables, ${fkCount} foreign keys`);
}

main();
