// Shared SQL parser used by generate-types and schema-lint.
// Zero deps. Handles the subset of PostgreSQL DDL used by the IOX migrations:
//   CREATE TABLE "X" ( ... );
//   CREATE [UNIQUE] INDEX [name] ON "X" [USING method] ("col"[, ...]);
//   CREATE VIEW "X" AS ... ;
//   ALTER TABLE "X" ADD CONSTRAINT "name" FOREIGN KEY ("col"[, ...]) REFERENCES "Y" ("col2"[, ...]);
//   ALTER TABLE "X" ADD COLUMN "col" TYPE [modifiers];
//   ALTER TABLE "X" RENAME COLUMN "old" TO "new";
//   COMMENT ON TABLE "X" IS '...';
//
// Not a general SQL parser. Assumes the dialect used by IOX migrations:
// double-quoted PascalCase identifiers, one column per line, balanced parens.

import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';

const SCHEMA_ROOT = new URL('../schema/migrations/', import.meta.url).pathname;

export const MIGRATION_FILES = [
  ['iox-core', 'V1.0__iox_core_project_contract.sql'],
  ['iox-core', 'V1.1__iox_core_identity_access.sql'],
  ['iox-core', 'V1.2__iox_core_organisation_project.sql'],
  ['iox-core', 'V1.3_to_V1.11__iox_core_remaining_segments.sql'],
  ['iox-core', 'V1.12__iox_core_extensions_and_foreign_keys.sql'],
  ['iox-core', 'V1.13__iox_core_schema_completion.sql'],
  ['iox-core', 'V1.14__iox_core_password_hash_and_qa_fk.sql'],
  ['parametrix', 'V0.1_to_V0.6__parametrix_parametric_estimation.sql'],
];

const MODULE_MAPPING_PATH = new URL(
  '../schema/clustering/module-mapping.json',
  import.meta.url,
).pathname;

export function loadModuleMapping() {
  return JSON.parse(readFileSync(MODULE_MAPPING_PATH, 'utf8'));
}

export function loadMigrations() {
  return MIGRATION_FILES.map(([dir, file]) => ({
    module: dir,
    file,
    path: join(SCHEMA_ROOT, dir, file),
    sql: readFileSync(join(SCHEMA_ROOT, dir, file), 'utf8'),
  }));
}

// --- Tokeniser helpers -----------------------------------------------------

// Strip line comments (-- ...) and collapse statements by ;. Keeps quoted
// identifiers/strings intact so colons/semicolons inside them are preserved.
function splitStatements(sql) {
  const out = [];
  let buf = '';
  let i = 0;
  let inSingle = false;
  let inDouble = false;
  let inLineComment = false;
  let inDollar = false;
  let dollarTag = '';

  while (i < sql.length) {
    const ch = sql[i];
    const next = sql[i + 1];

    if (inLineComment) {
      if (ch === '\n') {
        inLineComment = false;
        buf += '\n';
      }
      i++;
      continue;
    }

    if (inDollar) {
      buf += ch;
      if (ch === '$' && sql.slice(i, i + dollarTag.length) === dollarTag) {
        buf += sql.slice(i + 1, i + dollarTag.length);
        i += dollarTag.length;
        inDollar = false;
        dollarTag = '';
        continue;
      }
      i++;
      continue;
    }

    if (!inSingle && !inDouble && ch === '-' && next === '-') {
      inLineComment = true;
      i += 2;
      continue;
    }

    if (!inSingle && !inDouble && ch === '$') {
      const m = sql.slice(i).match(/^\$[a-zA-Z_]*\$/);
      if (m) {
        dollarTag = m[0];
        inDollar = true;
        buf += dollarTag;
        i += dollarTag.length;
        continue;
      }
    }

    if (!inDouble && ch === "'" && sql[i - 1] !== '\\') {
      inSingle = !inSingle;
    } else if (!inSingle && ch === '"') {
      inDouble = !inDouble;
    }

    if (!inSingle && !inDouble && ch === ';') {
      const trimmed = buf.trim();
      if (trimmed) out.push(trimmed);
      buf = '';
      i++;
      continue;
    }

    buf += ch;
    i++;
  }
  const tail = buf.trim();
  if (tail) out.push(tail);
  return out;
}

// --- Parsers ---------------------------------------------------------------

const TABLE_RE = /^CREATE\s+TABLE\s+"([^"]+)"\s*\(([\s\S]*)\)\s*$/i;
const VIEW_RE = /^CREATE\s+(?:OR\s+REPLACE\s+)?(?:MATERIALIZED\s+)?VIEW\s+"([^"]+)"\s+AS\b/i;
const INDEX_RE =
  /^CREATE\s+(UNIQUE\s+)?INDEX\s+(?:"([^"]+)"|(\w+))?\s*ON\s+"([^"]+)"\s*(?:USING\s+\w+\s*)?\(([^)]+)\)/i;
const ALTER_FK_RE =
  /^ALTER\s+TABLE\s+"([^"]+)"\s+ADD\s+CONSTRAINT\s+"([^"]+)"\s+FOREIGN\s+KEY\s*\(\s*"([^"]+)"\s*\)\s+REFERENCES\s+"([^"]+)"\s*\(\s*"([^"]+)"\s*\)/i;
const ALTER_ADD_COL_RE =
  /^ALTER\s+TABLE\s+"([^"]+)"\s+ADD\s+COLUMN\s+("[^"]+"\s+.+)$/i;
const ALTER_RENAME_COL_RE =
  /^ALTER\s+TABLE\s+"([^"]+)"\s+RENAME\s+COLUMN\s+"([^"]+)"\s+TO\s+"([^"]+)"\s*$/i;
const COMMENT_RE = /^COMMENT\s+ON\s+TABLE\s+"([^"]+)"\s+IS\s+'([\s\S]*)'$/i;
const FUNCTION_RE = /^CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\b/i;

// Parse the body of a CREATE TABLE — split by top-level commas.
function splitTableBody(body) {
  const out = [];
  let depth = 0;
  let buf = '';
  let inSingle = false;
  let inDouble = false;
  for (let i = 0; i < body.length; i++) {
    const ch = body[i];
    if (!inDouble && ch === "'") inSingle = !inSingle;
    else if (!inSingle && ch === '"') inDouble = !inDouble;
    if (!inSingle && !inDouble) {
      if (ch === '(') depth++;
      else if (ch === ')') depth--;
      else if (ch === ',' && depth === 0) {
        const t = buf.trim();
        if (t) out.push(t);
        buf = '';
        continue;
      }
    }
    buf += ch;
  }
  const tail = buf.trim();
  if (tail) out.push(tail);
  return out;
}

function parseColumnOrConstraint(line) {
  const norm = line.replace(/\s+/g, ' ').trim();
  // Constraints
  if (/^PRIMARY\s+KEY\b/i.test(norm)) return { kind: 'pk', raw: norm };
  if (/^UNIQUE\s*\(/i.test(norm)) {
    const cols = [...norm.matchAll(/"([^"]+)"/g)].map((m) => m[1]);
    return { kind: 'unique', columns: cols, raw: norm };
  }
  if (/^FOREIGN\s+KEY\b/i.test(norm)) {
    return { kind: 'fk-inline', raw: norm };
  }
  if (/^CONSTRAINT\b/i.test(norm)) return { kind: 'constraint', raw: norm };

  // Column: "name" TYPE [modifiers]
  const m = norm.match(/^"([^"]+)"\s+(.+)$/);
  if (!m) return { kind: 'unknown', raw: norm };

  const name = m[1];
  const rest = m[2];
  const upperRest = rest.toUpperCase();

  // Type extraction: take leading token plus optional (...) and optional []
  const typeMatch = rest.match(/^([A-Z][A-Z0-9_]*(?:\s*\([^)]+\))?(?:\s*\[\s*\])?)/i);
  const sqlType = typeMatch ? typeMatch[1].replace(/\s+/g, '') : rest.split(/\s/)[0];

  const isPrimaryKey = /\bPRIMARY\s+KEY\b/i.test(rest);
  const notNull = /\bNOT\s+NULL\b/i.test(rest) || isPrimaryKey;
  const unique = /\bUNIQUE\b/i.test(rest);
  const defaultMatch = rest.match(/\bDEFAULT\s+([^,]+?)(?:\s+(?:NOT\s+NULL|UNIQUE|PRIMARY\s+KEY|REFERENCES|CHECK)\b|$)/i);

  return {
    kind: 'column',
    name,
    sqlType,
    notNull,
    unique,
    isPrimaryKey,
    default: defaultMatch ? defaultMatch[1].trim() : null,
    raw: norm,
  };
}

function parseCreateTable(stmt) {
  const m = stmt.match(TABLE_RE);
  if (!m) return null;
  const name = m[1];
  const body = m[2];
  const items = splitTableBody(body).map(parseColumnOrConstraint);
  const columns = items.filter((i) => i.kind === 'column');
  const uniques = items.filter((i) => i.kind === 'unique').map((u) => u.columns);
  return { name, columns, uniques };
}

function parseCreateIndex(stmt) {
  const m = stmt.match(INDEX_RE);
  if (!m) return null;
  const cols = [...m[5].matchAll(/"([^"]+)"/g)].map((x) => x[1]);
  return {
    unique: !!m[1],
    name: m[2] || m[3] || null,
    table: m[4],
    columns: cols,
  };
}

function parseAlterFK(stmt) {
  const m = stmt.match(ALTER_FK_RE);
  if (!m) return null;
  return {
    table: m[1],
    constraint: m[2],
    column: m[3],
    refTable: m[4],
    refColumn: m[5],
  };
}

function parseAlterAddColumn(stmt) {
  const m = stmt.match(ALTER_ADD_COL_RE);
  if (!m) return null;
  const col = parseColumnOrConstraint(m[2]);
  if (col.kind !== 'column') return null;
  return { table: m[1], column: col };
}

function parseAlterRenameColumn(stmt) {
  const m = stmt.match(ALTER_RENAME_COL_RE);
  if (!m) return null;
  return { table: m[1], from: m[2], to: m[3] };
}

function parseComment(stmt) {
  const m = stmt.match(COMMENT_RE);
  if (!m) return null;
  return { table: m[1], comment: m[2].replace(/''/g, "'") };
}

function parseCreateView(stmt) {
  const m = stmt.match(VIEW_RE);
  if (!m) return null;
  return { name: m[1] };
}

// --- Public API ------------------------------------------------------------

/**
 * Parse all migrations into a flat catalogue.
 *
 * Returns:
 *   tables: Map<name, { name, columns, uniques, source }>
 *   views:  Map<name, { name, source }>
 *   indexes: Array
 *   foreignKeys: Array
 *   comments: Map<table, comment>
 *   statementsByFile: Array<{ file, statements }>
 */
export function parseSchema() {
  const tables = new Map();
  const views = new Map();
  const indexes = [];
  const foreignKeys = [];
  const comments = new Map();
  const statementsByFile = [];

  for (const mig of loadMigrations()) {
    const statements = splitStatements(mig.sql);
    statementsByFile.push({ file: mig.file, module: mig.module, statements });
    for (const stmt of statements) {
      const tbl = parseCreateTable(stmt);
      if (tbl) {
        tables.set(tbl.name, { ...tbl, source: mig.file });
        continue;
      }
      const vw = parseCreateView(stmt);
      if (vw) {
        views.set(vw.name, { ...vw, source: mig.file });
        continue;
      }
      const idx = parseCreateIndex(stmt);
      if (idx) {
        indexes.push({ ...idx, source: mig.file });
        continue;
      }
      const fk = parseAlterFK(stmt);
      if (fk) {
        foreignKeys.push({ ...fk, source: mig.file });
        continue;
      }
      const addCol = parseAlterAddColumn(stmt);
      if (addCol) {
        const tbl = tables.get(addCol.table);
        if (tbl && !tbl.columns.some((c) => c.name === addCol.column.name)) {
          tbl.columns.push(addCol.column);
        }
        continue;
      }
      const rename = parseAlterRenameColumn(stmt);
      if (rename) {
        const tbl = tables.get(rename.table);
        if (tbl) {
          const col = tbl.columns.find((c) => c.name === rename.from);
          if (col) col.name = rename.to;
        }
        continue;
      }
      const cm = parseComment(stmt);
      if (cm) {
        comments.set(cm.table, cm.comment);
        continue;
      }
      // CREATE FUNCTION / ALTER / others — ignored for now.
      if (FUNCTION_RE.test(stmt)) continue;
    }
  }

  return { tables, views, indexes, foreignKeys, comments, statementsByFile };
}

// --- Type mapping ----------------------------------------------------------

/**
 * Map a Postgres type string to a TypeScript type.
 * Conservative defaults: DECIMAL/NUMERIC → string (default pg-node behaviour),
 * JSON/JSONB → unknown, arrays → element[].
 */
export function sqlTypeToTs(sqlType) {
  const t = sqlType.toUpperCase().replace(/\s+/g, '');
  const isArray = /\[\]$/.test(t);
  const base = isArray ? t.replace(/\[\]$/, '') : t;
  const root = base.replace(/\([^)]*\)/, '');

  let mapped;
  switch (root) {
    case 'TEXT':
    case 'VARCHAR':
    case 'CHAR':
    case 'CHARACTER':
    case 'CHARACTERVARYING':
    case 'UUID':
      mapped = 'string';
      break;
    case 'INTEGER':
    case 'INT':
    case 'INT4':
    case 'SMALLINT':
    case 'INT2':
    case 'BIGINT':
    case 'INT8':
    case 'SERIAL':
    case 'BIGSERIAL':
      mapped = 'number';
      break;
    case 'DECIMAL':
    case 'NUMERIC':
    case 'REAL':
    case 'DOUBLE':
    case 'DOUBLEPRECISION':
    case 'FLOAT':
    case 'FLOAT4':
    case 'FLOAT8':
      mapped = 'string'; // pg-node returns NUMERIC as string by default
      break;
    case 'BOOLEAN':
    case 'BOOL':
      mapped = 'boolean';
      break;
    case 'TIMESTAMP':
    case 'TIMESTAMPTZ':
    case 'TIMESTAMPWITHTIMEZONE':
    case 'TIMESTAMPWITHOUTTIMEZONE':
    case 'DATE':
    case 'TIME':
    case 'TIMETZ':
      mapped = 'Date';
      break;
    case 'JSON':
    case 'JSONB':
      mapped = 'unknown';
      break;
    case 'BYTEA':
      mapped = 'Buffer';
      break;
    default:
      mapped = 'unknown';
  }
  return isArray ? `${mapped}[]` : mapped;
}
