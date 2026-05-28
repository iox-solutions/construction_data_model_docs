# RFC NNNN — <Title>

- **Status**: Draft <!-- Draft | Open for comment | Accepted | Rejected | Superseded -->
- **Author**: <Your name>
- **Created**: YYYY-MM-DD
- **Decision deadline**: YYYY-MM-DD <!-- 5 business days after "Open for comment" -->
- **Related**: <!-- RFC numbers, GitHub issues, prior discussions -->

## Summary

One paragraph. What does this propose? What changes?

## Motivation

Why does this need to change? What's the user-visible problem if we don't do it? Cite concrete examples — bug reports, incidents, blocked product work, repeated questions in office hours.

## Detailed design

Specifically what the change is. For schema changes include:

- Tables / columns / constraints added, modified, removed.
- The migration SQL (or a sketch of it).
- The deprecation timeline if removing or renaming a public symbol.
- Backfill or data-migration steps required.

For tooling / governance changes: the behaviour change, where it lives, and how it's enforced.

## Consumers affected

Which products / modules / packages will need to change? Be specific:

- `@iox/types` — yes, regenerated.
- ProcureX UI — references `OldColumn` in `src/foo.ts:42`.
- Reporting jobs — query `SELECT … FROM "Old"`.

If you don't know, say so. The RFC process is partly to surface unknown consumers.

## Migration path

For breaking changes only. How does an existing consumer move from the old shape to the new shape? Include:

1. Pre-release: ship the new symbol alongside the old (deprecation comment).
2. Release: cut a Core minor that contains both.
3. Communication: announce in `#iox-changes`, update CHANGELOG.
4. Removal: cut a Core major that drops the old symbol — minimum one Core minor later.

## Alternatives considered

What else did you look at? Why is this proposal better than:

- Doing nothing.
- A non-breaking workaround.
- A different schema shape.

A weak alternatives section is the most common reason an RFC gets pushed back. Take it seriously.

## Risks and unresolved questions

- What could go wrong?
- What are you unsure about?
- What questions do you want the comment window to resolve?

## Approval

- [ ] Schema Steward
- [ ] Module owner(s) of affected module(s)
- [ ] At least one consumer signed off (or — explicitly — none yet exist)

---

<!--
After Decision deadline, summarise the outcome and link to the merged PR(s).
If rejected, capture *why* — that record is more valuable than the proposal itself.
-->
