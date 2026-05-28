#!/usr/bin/env node
/**
 * IOX Business Architecture Diagram Generator
 *
 * Layout: Option B — Lifecycle flow
 *   Top row : 4 lifecycle module cards (ParametriX → PlanX → ProcureX → ReportX)
 *   Connectors: vertical arrows from each module down into the Core band
 *   Core band : full-width foundation showing 3 anchor tables + supporting objects
 *   Below     : PlaceholderX (coming soon) + orphaned tables
 *   Collapsible: technical reference with FK trees per module
 *
 * Pure HTML/CSS — no JS-drawn connections, no external dependencies.
 */

const fs   = require('fs');
const path = require('path');

const PROJECT_DIR  = path.resolve(__dirname, '..');
const XML_PATH     = path.join(PROJECT_DIR, 'docs/schema-html/iox_datamodel.public.xml');
const MAPPING_PATH = path.join(PROJECT_DIR, 'schema/clustering/module-mapping.json');
const OUTPUT_PATH  = path.join(PROJECT_DIR, 'docs/schema-html/business-architecture.html');

if (!fs.existsSync(XML_PATH)) {
  console.error('Error: SchemaSpy XML not found. Run generate_docs.sh first.');
  process.exit(1);
}

const xml     = fs.readFileSync(XML_PATH, 'utf8');
const mapping = JSON.parse(fs.readFileSync(MAPPING_PATH, 'utf8'));

// ─── Parse schema ─────────────────────────────────────────────────────────────

const allTables = [...xml.matchAll(/<table name="([^"]+)"/g)].map(m => m[1]);

const tableToModule = {};
for (const [key, mod] of Object.entries(mapping.modules)) {
  for (const t of mod.tables) tableToModule[t] = key;
}

const excluded   = new Set(mapping.exclude);
const unassigned = allTables.filter(t => !tableToModule[t] && !excluded.has(t));

const moduleTables = {};
for (const [key, mod] of Object.entries(mapping.modules)) {
  moduleTables[key] = mod.tables.filter(t => allTables.includes(t));
}

// ─── Single-pass FK parse: builds intra-module trees + cross-module groups ──────

const intraFksByModule = {};
const allFkLinks       = [];

for (const block of [...xml.matchAll(/<table name="([^"]+)"[\s\S]*?<\/table>/g)]) {
  const child    = block[1];
  const childMod = tableToModule[child];
  for (const p of [...block[0].matchAll(/<parent column="[^"]*" foreignKey="[^"]*" implied="false"[^>]*table="([^"]+)"/g)]) {
    const parent    = p[1];
    const parentMod = tableToModule[parent];
    allFkLinks.push({ from: child, to: parent });

    if (childMod && !excluded.has(child) && childMod === parentMod && parent !== child) {
      if (!intraFksByModule[childMod]) intraFksByModule[childMod] = [];
      intraFksByModule[childMod].push({ child, parent });
    }
  }
}

function buildTree(moduleKey) {
  const tables   = new Set(moduleTables[moduleKey]);
  const links    = intraFksByModule[moduleKey] || [];
  const parentOf = {};
  const children = {};
  for (const { child, parent } of links) {
    if (!tables.has(child) || !tables.has(parent)) continue;
    if (parentOf[child]) continue;
    parentOf[child] = parent;
    if (!children[parent]) children[parent] = [];
    children[parent].push(child);
  }
  const roots = [...tables].filter(t => !parentOf[t]);
  return { roots, children };
}

function renderTreeNode(table, children, depth, seen) {
  if (seen.has(table)) return '';
  seen.add(table);
  const kids      = children[table] || [];
  const indent    = depth * 18;
  const childHTML = kids.map(k => renderTreeNode(k, children, depth + 1, seen)).join('');
  return `<div class="tree-item" style="padding-left:${indent}px">
    <div class="tree-row">
      ${depth > 0 ? '<span class="tree-elbow"></span>' : ''}
      <a class="chip" href="tables/${table}.html" target="_blank">${table}</a>
    </div>${childHTML}
  </div>`;
}

function renderTree(moduleKey) {
  const { roots, children } = buildTree(moduleKey);
  const tables = moduleTables[moduleKey];
  if (tables.length === 0) return '<em class="muted-text">Data model in development</em>';
  const seen = new Set();
  const treeHTML = roots.map(r => renderTreeNode(r, children, 0, seen)).join('');
  const orphans  = tables.filter(t => !seen.has(t));
  const orphanHTML = orphans.length > 0
    ? `<div class="tree-orphans">${orphans.map(t =>
        `<a class="chip" href="tables/${t}.html" target="_blank">${t}</a>`
      ).join('')}</div>`
    : '';
  return `<div class="tree-view">${treeHTML}${orphanHTML}</div>`;
}

// ─── Derive lifecycle config from module-mapping.json ─────────────────────────
//
// All business-level concepts (lifecycle order, phase labels, module capabilities,
// cross-module connections, core anchors) live in module-mapping.json.
// Nothing below is hard-coded — if the data model or module definitions change,
// update module-mapping.json and regenerate.

const lifecycleModules = mapping.lifecycle || [];

const descriptions = mapping.connectionDescriptions || {};

// Derive cross-module connections from FK analysis, enriched with config labels.
// For each (module → Core table) pair found in the schema, look up the
// connectionDescriptions entry to get the human-readable short + tooltip.
// If no entry exists, fall back to a generic label so new connections are
// still visible in the diagram without requiring a config update.
const seenFk = new Set();
const crossModuleGroups = {};  // key: "fromMod:coreTable"

for (const { from, to } of allFkLinks) {
  const fromMod = tableToModule[from];
  const toMod   = tableToModule[to];
  if (!fromMod || !toMod || fromMod === toMod) continue;
  if (excluded.has(from) || excluded.has(to))  continue;
  const fkKey = `${from}→${to}`;
  if (seenFk.has(fkKey)) continue;
  seenFk.add(fkKey);

  if (toMod === 'core') {
    const k = `${fromMod}:${to}`;
    if (!crossModuleGroups[k]) crossModuleGroups[k] = { fromMod, coreTable: to, tables: [] };
    crossModuleGroups[k].tables.push(from);
  }
}

// Build moduleConnections: { [modKey]: [{ anchor, short, tooltip }] }
// Only includes connections to coreAnchors — other Core table connections are
// noted in the technical reference but not drawn on the diagram.
const coreAnchorSet  = new Set(mapping.coreAnchors || []);
const moduleConnections = {};

for (const [groupKey, group] of Object.entries(crossModuleGroups)) {
  if (!coreAnchorSet.has(group.coreTable)) continue;
  const { fromMod, coreTable } = group;
  const desc = descriptions[groupKey] || {};
  if (!moduleConnections[fromMod]) moduleConnections[fromMod] = [];
  moduleConnections[fromMod].push({
    anchor:  coreTable,
    short:   desc.short   || `references ${coreTable}`,
    tooltip: desc.label   || `${fromMod} tables reference ${coreTable} in Core`
  });
}

// Build anchor → connected modules map (for the Core band sub-labels)
const anchorConnectedModules = {};
for (const [modKey, conns] of Object.entries(moduleConnections)) {
  for (const conn of conns) {
    if (!anchorConnectedModules[conn.anchor]) anchorConnectedModules[conn.anchor] = [];
    anchorConnectedModules[conn.anchor].push(mapping.modules[modKey]?.label || modKey);
  }
}

// Core band config — driven by module-mapping.json coreAnchors list
const coreAnchors = mapping.coreAnchors || [];
const coreOthers  = moduleTables['core'].filter(t => !coreAnchorSet.has(t));

// ─── Render a single module column (card + connector) ─────────────────────────

function moduleColHTML(key) {
  const mod        = mapping.modules[key];
  const bullets    = mod.capabilities || [];
  const conns      = moduleConnections[key] || [];
  const tableCount = moduleTables[key].length;

  const bulletsHTML = bullets
    .map(b => `<li>${b}</li>`)
    .join('\n            ');

  function singleConnector(conn) {
    return `<div class="conn-single">
          <div class="conn-line"></div>
          <div class="conn-pill" title="${conn.tooltip}">${conn.short}</div>
          <div class="conn-anchor-tag">→ ${conn.anchor}</div>
          <div class="conn-arrowhead"></div>
        </div>`;
  }

  function multiConnector(conns) {
    return `<div class="conn-multi">
          ${conns.map(c => `<div class="conn-branch">
            <div class="conn-line"></div>
            <div class="conn-pill conn-pill-sm" title="${c.tooltip}">
              <span class="conn-pill-anchor">${c.anchor}</span>
              <span class="conn-pill-desc">${c.short}</span>
            </div>
            <div class="conn-arrowhead"></div>
          </div>`).join('')}
        </div>`;
  }

  const connectorHTML = conns.length === 1
    ? singleConnector(conns[0])
    : multiConnector(conns);

  return `<div class="module-col" style="--mod-color:${mod.color}">
      <div class="phase-label">${mod.phase || ''}</div>
      <div class="module-card">
        <div class="module-header">
          <div class="module-name">${mod.label}</div>
          <div class="module-count">${tableCount} objects</div>
        </div>
        <div class="module-tagline">${mod.description.split('—').slice(1).join('—').trim()}</div>
        <ul class="module-bullets">
          ${bulletsHTML}
        </ul>
      </div>
      <div class="connector-zone">
        ${connectorHTML}
      </div>
    </div>`;
}

// ─── Render a technical reference section per module ──────────────────────────

function techModuleHTML(key) {
  const mod = mapping.modules[key];
  return `<div class="tech-module">
    <h3 class="tech-module-title" style="color:${mod.color}">${mod.label}</h3>
    <p class="tech-module-desc">${mod.description}</p>
    ${renderTree(key)}
  </div>`;
}

// ─── Build complete HTML ───────────────────────────────────────────────────────

function buildHTML() {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>IOX Platform — Business Architecture</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background: #f0f2f5;
    color: #1a1a2e;
    line-height: 1.4;
  }

  /* ── Header ─────────────────────────────────────────────────────────────── */
  header {
    background: #1a1a2e;
    color: #fff;
    padding: 20px 40px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  header h1   { font-size: 1.25rem; font-weight: 700; }
  header p    { font-size: 0.78rem; opacity: 0.55; margin-top: 3px; }
  .back-link  { color: #888; text-decoration: none; font-size: 0.78rem; white-space: nowrap; }
  .back-link:hover { color: #fff; }

  /* ── Page ────────────────────────────────────────────────────────────────── */
  .page {
    padding: 28px 32px 48px;
    max-width: 1300px;
    margin: 0 auto;
  }

  .section-heading {
    font-size: 1.05rem;
    font-weight: 700;
    color: #1a1a2e;
    margin-bottom: 4px;
  }
  .section-subheading {
    font-size: 0.8rem;
    color: #777;
    margin-bottom: 20px;
  }

  /* ── Lifecycle wrapper card ──────────────────────────────────────────────── */
  .lifecycle-wrapper {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 1px 6px rgba(0,0,0,0.1);
    padding: 28px 28px 0;
    margin-bottom: 12px;
    overflow: hidden;
  }

  /* ── Module row (4 equal columns) ────────────────────────────────────────── */
  .module-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
  }

  .module-col {
    display: flex;
    flex-direction: column;
  }

  .phase-label {
    font-size: 0.62rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: var(--mod-color, #aaa);
    text-align: center;
    margin-bottom: 8px;
    opacity: 0.8;
  }

  /* ── Module card ─────────────────────────────────────────────────────────── */
  .module-card {
    border-radius: 8px;
    border: 1px solid #e4e4e4;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    flex: 1;
  }

  .module-header {
    background: var(--mod-color, #888);
    color: white;
    padding: 10px 14px;
    display: flex;
    justify-content: space-between;
    align-items: baseline;
  }
  .module-name  { font-size: 0.95rem; font-weight: 700; }
  .module-count { font-size: 0.68rem; opacity: 0.7; }

  .module-tagline {
    padding: 8px 14px;
    font-size: 0.73rem;
    color: #555;
    font-style: italic;
    background: #fafafa;
    border-bottom: 1px solid #f0f0f0;
  }

  .module-bullets {
    list-style: none;
    padding: 10px 14px 14px;
    display: flex;
    flex-direction: column;
    gap: 7px;
    flex: 1;
  }
  .module-bullets li {
    font-size: 0.78rem;
    color: #333;
    padding-left: 14px;
    position: relative;
    line-height: 1.35;
  }
  .module-bullets li::before {
    content: '→';
    position: absolute;
    left: 0;
    color: var(--mod-color, #888);
    font-size: 0.68rem;
    top: 2px;
  }

  /* ── Connector zone (between module card and Core band) ──────────────────── */
  .connector-zone {
    display: flex;
    justify-content: center;
    height: 110px;
    padding-top: 2px;
  }

  /* Single connection (ParametriX, PlanX, ReportX) */
  .conn-single {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
  }

  .conn-line {
    width: 2px;
    flex: 1;
    background: var(--mod-color, #888);
  }

  .conn-pill {
    background: white;
    border: 1.5px solid var(--mod-color, #888);
    color: var(--mod-color, #888);
    font-size: 0.65rem;
    font-weight: 500;
    padding: 3px 9px;
    border-radius: 10px;
    text-align: center;
    cursor: default;
    max-width: 88%;
    line-height: 1.3;
  }

  .conn-anchor-tag {
    font-size: 0.6rem;
    color: #aaa;
    margin: 2px 0 1px;
    font-style: italic;
  }

  .conn-arrowhead {
    width: 0;
    height: 0;
    border-left: 6px solid transparent;
    border-right: 6px solid transparent;
    border-top: 8px solid var(--mod-color, #888);
  }

  /* Multi-connection (ProcureX with 3 anchors) */
  .conn-multi {
    display: flex;
    justify-content: space-around;
    width: 100%;
    gap: 4px;
  }

  .conn-branch {
    display: flex;
    flex-direction: column;
    align-items: center;
    flex: 1;
  }

  .conn-pill-sm {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1px;
    padding: 3px 5px;
    max-width: 100%;
    border-radius: 6px;
  }

  .conn-pill-anchor {
    font-size: 0.66rem;
    font-weight: 700;
    display: block;
    line-height: 1.2;
  }

  .conn-pill-desc {
    font-size: 0.57rem;
    font-weight: 400;
    opacity: 0.85;
    display: block;
    line-height: 1.2;
    text-align: center;
  }

  /* ── Core band (full-width foundation) ───────────────────────────────────── */
  .core-band {
    background: #1a1a2e;
    color: white;
    padding: 22px 28px 26px;
    margin: 0 -28px;
  }

  .core-band-header {
    text-align: center;
    margin-bottom: 18px;
  }
  .core-band-title {
    font-size: 1rem;
    font-weight: 700;
    letter-spacing: -0.01em;
  }
  .core-band-subtitle {
    font-size: 0.72rem;
    color: rgba(255,255,255,0.45);
    margin-top: 4px;
  }

  /* Three anchor nodes */
  .core-anchors-row {
    display: grid;
    grid-template-columns: 2fr 1.2fr 1.8fr;
    gap: 14px;
    margin-bottom: 20px;
    max-width: 700px;
    margin-left: auto;
    margin-right: auto;
  }

  .core-anchor {
    background: rgba(255,255,255,0.1);
    border: 1.5px solid rgba(255,255,255,0.35);
    border-radius: 8px;
    padding: 10px 14px;
    text-align: center;
  }
  .core-anchor-name {
    font-size: 0.9rem;
    font-weight: 700;
    color: white;
    margin-bottom: 4px;
  }
  .core-anchor-modules {
    font-size: 0.6rem;
    color: rgba(255,255,255,0.45);
    line-height: 1.4;
  }

  /* Supporting objects */
  .core-supporting-label {
    font-size: 0.6rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.09em;
    color: rgba(255,255,255,0.3);
    text-align: center;
    margin-bottom: 10px;
  }
  .core-supporting {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    justify-content: center;
  }
  .core-chip {
    background: rgba(255,255,255,0.06);
    color: rgba(255,255,255,0.5);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 4px;
    padding: 3px 8px;
    font-size: 0.68rem;
    text-decoration: none;
    transition: background 0.15s;
  }
  .core-chip:hover { background: rgba(255,255,255,0.15); color: rgba(255,255,255,0.9); }

  /* ── Supporting row (PlaceholderX + Orphaned) ────────────────────────────── */
  .supporting-row {
    display: flex;
    gap: 12px;
    margin-bottom: 28px;
    align-items: stretch;
  }

  .placeholder-strip {
    flex: 1;
    background: #f8f8f8;
    border: 2px dashed #ccc;
    border-radius: 8px;
    padding: 14px 20px;
    display: flex;
    align-items: center;
    gap: 14px;
  }
  .placeholder-label {
    font-size: 0.88rem;
    font-weight: 700;
    color: #999;
    white-space: nowrap;
  }
  .placeholder-desc {
    font-size: 0.73rem;
    color: #bbb;
    flex: 1;
  }
  .coming-soon-badge {
    background: #e8e8e8;
    color: #aaa;
    font-size: 0.62rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.07em;
    padding: 3px 9px;
    border-radius: 10px;
    white-space: nowrap;
  }

  .orphaned-strip {
    background: #fff8e1;
    border: 1.5px solid #ffca28;
    border-radius: 8px;
    padding: 14px 16px;
    flex: 0 0 auto;
  }
  .orphaned-header {
    font-size: 0.72rem;
    font-weight: 700;
    color: #e65100;
    margin-bottom: 8px;
  }
  .orphaned-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
  }
  .orphaned-chip {
    background: white;
    border: 1px solid #ffca28;
    border-radius: 4px;
    padding: 3px 8px;
    font-size: 0.72rem;
    color: #888;
    text-decoration: none;
  }
  .orphaned-chip:hover { background: #fff3cd; color: #555; }

  /* ── Technical reference (collapsible) ───────────────────────────────────── */
  .tech-section {
    background: #fff;
    border-radius: 10px;
    box-shadow: 0 1px 4px rgba(0,0,0,0.08);
    overflow: hidden;
  }

  .tech-section > summary {
    padding: 15px 22px;
    font-size: 0.85rem;
    font-weight: 600;
    color: #555;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    list-style: none;
    user-select: none;
    border-bottom: 1px solid transparent;
  }
  .tech-section > summary::-webkit-details-marker { display: none; }
  .tech-section > summary::before {
    content: '▶';
    font-size: 0.62rem;
    color: #bbb;
    transition: transform 0.2s;
  }
  .tech-section[open] > summary::before { transform: rotate(90deg); }
  .tech-section[open] > summary { border-bottom-color: #e8e8e8; }
  .tech-section > summary:hover { background: #f8f8f8; }
  .tech-section > summary .summary-note {
    font-size: 0.72rem;
    font-weight: 400;
    color: #aaa;
    margin-left: 4px;
  }

  .tech-body {
    padding: 24px 28px;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 28px;
  }

  .tech-module-title {
    font-size: 0.85rem;
    font-weight: 700;
    margin-bottom: 3px;
  }
  .tech-module-desc {
    font-size: 0.7rem;
    color: #999;
    margin-bottom: 10px;
    padding-bottom: 10px;
    border-bottom: 1px solid #f0f0f0;
    line-height: 1.4;
  }

  /* FK tree */
  .tree-view   { font-size: 0.75rem; }
  .tree-item   { position: relative; }
  .tree-row    { display: flex; align-items: center; gap: 5px; margin: 2px 0; }
  .tree-elbow  {
    flex-shrink: 0;
    width: 14px; height: 14px;
    border-left: 1px solid #ccc;
    border-bottom: 1px solid #ccc;
    border-radius: 0 0 0 3px;
    margin-top: -6px;
    align-self: flex-start;
  }
  .tree-orphans {
    display: flex; flex-wrap: wrap; gap: 4px;
    padding: 6px 0 0;
    border-top: 1px dashed #e8e8e8;
    margin-top: 6px;
  }
  .chip {
    display: inline-block;
    background: #f3f4f6;
    color: #444;
    border-radius: 4px;
    padding: 3px 7px;
    font-size: 0.72rem;
    text-decoration: none;
    border: 1px solid #e4e4e4;
    white-space: nowrap;
    transition: background 0.15s;
  }
  .chip:hover { background: #e8eaf0; }
  .muted-text { color: #bbb; font-style: italic; font-size: 0.75rem; }

  /* ── Footer ──────────────────────────────────────────────────────────────── */
  footer {
    text-align: center;
    padding: 20px;
    font-size: 0.73rem;
    color: #bbb;
    border-top: 1px solid #e8e8e8;
  }
  footer a { color: #0d47a1; text-decoration: none; }
</style>
</head>
<body>

<header>
  <div>
    <h1>IOX Platform — Business Architecture</h1>
    <p>How the product modules relate to the shared data foundation</p>
  </div>
  <a href="index.html" class="back-link">← Full Technical Schema</a>
</header>

<div class="page">

  <h2 class="section-heading">Project Lifecycle</h2>
  <p class="section-subheading">Four product modules, each covering a distinct phase of the construction project lifecycle — all built on a shared IOX Core data layer</p>

  <div class="lifecycle-wrapper">

    <!-- Module cards row -->
    <div class="module-row">
      ${lifecycleModules.map(k => moduleColHTML(k)).join('\n      ')}
    </div>

    <!-- Core band -->
    <div class="core-band">
      <div class="core-band-header">
        <div class="core-band-title">IOX Core — Shared Data Foundation</div>
        <div class="core-band-subtitle">These objects are shared across all modules · no single module owns them</div>
      </div>

      <div class="core-anchors-row">
        ${coreAnchors.map(anchor => {
          const connectedMods = anchorConnectedModules[anchor] || [];
          return `<div class="core-anchor">
          <div class="core-anchor-name">${anchor}</div>
          <div class="core-anchor-modules">${connectedMods.join(' · ')}</div>
        </div>`;
        }).join('')}
      </div>

      <div class="core-supporting-label">Supporting shared objects</div>
      <div class="core-supporting">
        ${coreOthers.map(t =>
          `<a class="core-chip" href="tables/${t}.html" target="_blank">${t}</a>`
        ).join('\n        ')}
      </div>
    </div>

  </div><!-- /lifecycle-wrapper -->

  <!-- Supporting modules and orphans -->
  <div class="supporting-row">
    <div class="placeholder-strip">
      <div class="placeholder-label">PlaceholderX</div>
      <div class="placeholder-desc">${mapping.modules.placeholderx?.description?.split('—').slice(1).join('—').trim() || 'Rate &amp; benchmark data management'}</div>
      <span class="coming-soon-badge">Coming Soon</span>
    </div>
    ${unassigned.length > 0 ? `
    <div class="orphaned-strip">
      <div class="orphaned-header">⚠ Not yet assigned to a module</div>
      <div class="orphaned-chips">
        ${unassigned.map(t =>
          `<a class="orphaned-chip" href="tables/${t}.html" target="_blank">${t}</a>`
        ).join('')}
      </div>
    </div>` : ''}
  </div>

  <!-- Technical reference -->
  <details class="tech-section">
    <summary>
      Technical Reference — Table Details &amp; FK Relationships
      <span class="summary-note">table lists and intra-module dependency trees</span>
    </summary>
    <div class="tech-body">
      ${lifecycleModules.map(k => techModuleHTML(k)).join('\n      ')}
      ${techModuleHTML('core')}
      ${unassigned.length > 0 ? `
      <div class="tech-module">
        <h3 class="tech-module-title" style="color:#e65100">Unassigned</h3>
        <p class="tech-module-desc">Not yet assigned to a product module</p>
        <div style="display:flex;flex-wrap:wrap;gap:4px">
          ${unassigned.map(t =>
            `<a class="chip" href="tables/${t}.html" target="_blank">${t}</a>`
          ).join('')}
        </div>
      </div>` : ''}
    </div>
  </details>

</div><!-- /page -->

<footer>
  Generated from live schema &middot; <a href="index.html">Full SchemaSpy documentation</a>
</footer>

</body>
</html>`;
}

// ─── Run ──────────────────────────────────────────────────────────────────────

const html = buildHTML();
fs.writeFileSync(OUTPUT_PATH, html, 'utf8');

console.log('\n✓ Business architecture diagram generated');
console.log(`  ${OUTPUT_PATH}\n`);
console.log('Modules:');
for (const key of [...lifecycleModules, 'placeholderx']) {
  const mod = mapping.modules[key];
  console.log(`  ${mod.label.padEnd(20)} ${(moduleTables[key] || []).length} objects`);
}
console.log(`  ${'IOX Core'.padEnd(20)} ${moduleTables['core'].length} objects`);
console.log(`  ${'Orphaned'.padEnd(20)} ${unassigned.length} (${unassigned.join(', ')})`);
