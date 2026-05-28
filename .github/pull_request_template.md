<!--
Thanks for contributing to the IOX shared data model. Please complete the
relevant sections below. Sections marked OPTIONAL can be deleted if they
don't apply.
-->

## Summary

<!-- One or two sentences. What does this PR change, and why? -->

## Change class

Pick one — drives reviewer count and notice window (see `GOVERNANCE.md`):

- [ ] **Additive** — new table, new nullable column, new index, new view, generated artefact, docs. One reviewer.
- [ ] **Behavioral** — default change, new FK, constraint tightening that still admits existing data, new lint rule. Two reviewers, 1 business day notice.
- [ ] **Breaking** — rename, drop, type change, constraint that rejects existing data, removal of a deprecated symbol. Requires an RFC and a 5-business-day comment window.
- [ ] **Tooling / docs only** — no schema impact.

## Module(s) affected

<!-- core / parametrix / procurex / planx / reportx / placeholderx / tooling -->

## Migration files added or changed

<!-- e.g. `schema/migrations/iox-core/V1.14__add_passwordHash.sql` -->

## Checklist

- [ ] `node tools/schema-lint.mjs` passes (or new findings are explicitly justified below).
- [ ] `bash tools/migration-test.sh` passes locally.
- [ ] `node tools/generate-types.mjs` re-run and the diff to `iox-types/src/generated.ts` is included in this PR.
- [ ] `CHANGELOG.md` updated under `[Unreleased]`.
- [ ] `module-mapping.json` updated if a table was added, moved, or removed.
- [ ] `MIGRATION_MANIFEST.md` updated if a new migration file was added.
- [ ] No backwards-incompatible change without a linked RFC.

## Lint findings introduced or resolved

<!-- Paste the relevant lines from `schema-lint.mjs` output, or "none". -->

## RFC link (breaking changes only)

<!-- e.g. `docs/rfcs/0003-rename-password-to-password-hash.md` -->

## Reviewer notes

<!-- OPTIONAL: anything reviewers should pay particular attention to. -->
