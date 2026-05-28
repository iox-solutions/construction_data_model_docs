#!/usr/bin/env node
// Generate docs/MODULES.md from module-mapping.json + COMMENT ON TABLE text.
//
// Usage:
//   node tools/generate-modules-doc.mjs
//
// Output: docs/MODULES.md (checked in; CI fails if out of sync).
//
// The aim is a single, accurate, browsable per-module index that engineers
// can read without trawling the migration SQL.

import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';
import { parseSchema, loadModuleMapping } from './parse-schema.mjs';

const OUT = new URL('../docs/MODULES.md', import.meta.url).pathname;

function buildTableToModule(mapping) {
  const map = new Map();
  for (const [moduleKey, mod] of Object.entries(mapping.modules)) {
    for (const t of mod.tables ?? []) map.set(t, moduleKey);
  }
  for (const t of mapping.exclude ?? []) {
    if (!map.has(t)) map.set(t, 'core');
  }
  return map;
}

function fmtComment(comment) {
  if (!comment) return '';
  // Strip the PII note from the front so the description reads cleanly.
  // PII info is shown separately.
  return comment.replace(/\.\s*PII-flagged:[^.]*\.?/i, '.').trim();
}

function fmtPiiNote(comment) {
  if (!comment) return null;
  const m = comment.match(/PII-flagged:\s*([^.]+)\.?/i);
  return m ? m[1].trim() : null;
}

function fkSummary(tableName, foreignKeys) {
  const outbound = foreignKeys
    .filter((fk) => fk.table === tableName)
    .map((fk) => `${fk.column} → ${fk.refTable}.${fk.refColumn}`);
  if (outbound.length === 0) return '';
  return outbound.map((s) => `\`${s}\``).join(', ');
}

function main() {
  const { tables, foreignKeys, comments, views } = parseSchema();
  const mapping = loadModuleMapping();
  const tableToModule = buildTableToModule(mapping);

  // Order modules: core first, then lifecycle order from module-mapping.json,
  // then any extras (excluded, unassigned).
  const orderedModuleKeys = ['core', ...mapping.lifecycle, 'placeholderx'].filter(
    (k, i, arr) => arr.indexOf(k) === i && mapping.modules[k],
  );

  // Group tables by module.
  const byModule = new Map();
  for (const key of [...orderedModuleKeys, 'unassigned']) byModule.set(key, []);
  for (const name of [...tables.keys()].sort()) {
    const mod = tableToModule.get(name);
    if (!mod) {
      byModule.get('unassigned').push(name);
    } else {
      if (!byModule.has(mod)) byModule.set(mod, []);
      byModule.get(mod).push(name);
    }
  }

  const lines = [];
  lines.push('<!-- AUTO-GENERATED — do not edit by hand. -->');
  lines.push('<!-- Regenerate with: node tools/generate-modules-doc.mjs -->');
  lines.push('');
  lines.push('# IOX module catalogue');
  lines.push('');
  lines.push(
    `Generated from \`schema/clustering/module-mapping.json\` and \`COMMENT ON TABLE\` text in the migration SQL. Updated whenever the schema or module mapping changes — see \`GOVERNANCE.md\`.`,
  );
  lines.push('');
  lines.push(
    `**Counts**: ${tables.size} base tables across ${[...byModule.entries()].filter(([_, t]) => t.length > 0).length} modules. ${views.size} reporting views.`,
  );
  lines.push('');
  lines.push('## Modules');
  lines.push('');
  for (const key of orderedModuleKeys) {
    const tableNames = byModule.get(key) ?? [];
    if (tableNames.length === 0 && key !== 'placeholderx') continue;
    const mod = mapping.modules[key];
    lines.push(`### ${mod.label}`);
    lines.push('');
    if (mod.phase) lines.push(`*Lifecycle phase: ${mod.phase}*`);
    lines.push('');
    lines.push(mod.description ?? '');
    lines.push('');
    if (mod.capabilities && mod.capabilities.length) {
      lines.push('**Capabilities**');
      lines.push('');
      for (const cap of mod.capabilities) lines.push(`- ${cap}`);
      lines.push('');
    }
    if (tableNames.length === 0) {
      lines.push('_No tables in this module yet._');
      lines.push('');
      continue;
    }
    lines.push(`**Tables (${tableNames.length})**`);
    lines.push('');
    lines.push('| Table | Description | Outbound FKs | PII |');
    lines.push('|---|---|---|---|');
    for (const name of tableNames) {
      const desc = fmtComment(comments.get(name));
      const pii = fmtPiiNote(comments.get(name));
      const fks = fkSummary(name, foreignKeys);
      lines.push(
        `| \`${name}\` | ${desc || '_no description_'} | ${fks || '—'} | ${pii ? '⚠️ ' + pii : '—'} |`,
      );
    }
    lines.push('');
  }

  // Unassigned section — only present if there are orphans.
  const orphans = byModule.get('unassigned') ?? [];
  if (orphans.length > 0) {
    lines.push('### Unassigned');
    lines.push('');
    lines.push(
      `Tables in the schema that are not listed under any module in \`module-mapping.json\`. These are flagged by \`schema-lint\` rule R7 and tracked in [RFC 0001](./rfcs/0001-resolve-orphan-tables.md).`,
    );
    lines.push('');
    lines.push('| Table | Outbound FKs |');
    lines.push('|---|---|');
    for (const name of orphans) {
      const fks = fkSummary(name, foreignKeys);
      lines.push(`| \`${name}\` | ${fks || '—'} |`);
    }
    lines.push('');
  }

  // Views.
  if (views.size > 0) {
    lines.push('## Views');
    lines.push('');
    lines.push('Reporting views defined in `V1.13`. Treat as read-only.');
    lines.push('');
    for (const name of [...views.keys()].sort()) {
      lines.push(`- \`${name}\``);
    }
    lines.push('');
  }

  mkdirSync(dirname(OUT), { recursive: true });
  writeFileSync(OUT, lines.join('\n'), 'utf8');
  console.log(`Wrote ${OUT}`);
  console.log(`  ${tables.size} tables in ${orderedModuleKeys.length} modules; ${orphans.length} orphan(s); ${views.size} view(s)`);
}

main();
