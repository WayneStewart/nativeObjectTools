# Release exclusions manifest

This file is the single source of truth for what is stripped from the Echidna tree
when staging Koala. The `Release_stageKoala` method reads this file; it does not
carry a hard-coded list. If the question arises — *"why was this removed from the
release?"* — the answer is a row in one of the tables below.

All paths are relative to the repository root. Glob patterns follow standard shell
glob syntax (`*` matches within a single path component; `**` matches across
components). Paths ending in `/` denote directories (removed recursively).

---

## Always strip

These are removed unconditionally on every release.

| Path / pattern | Reason |
|---|---|
| `Project/Sources/Methods/____Test_*.4dm` | Test harness — all phase test runners |
| `Project/Sources/Methods/____Make_*.4dm` | Test fixture builders |
| `Project/Sources/Methods/________DemoForAi.4dm` | AI demo scaffold, not part of component API |
| `Project/Sources/Methods/Compiler_OTr_v_Methods.4dm` | Compiler declarations for ____Test_ and ____Make_ methods — stripped with those methods |
| `Project/Sources/Methods/Compiler_OTr_w_Methods.4dm` | Compiler declarations for OTr_w_ Codex bridge methods — stripped with those methods |
| `Project/Sources/Methods/OTr_w_*.4dm` | All Codex HTTP bridge methods — none ship |
| `Project/Sources/Methods/TimetoDie.4dm` | Dev utility — graceful shutdown helper (Blade Runner easter egg) |
| `Project/Sources/Methods/___templateAutoStart.4dm` | AI scaffold template, not a shipping method |
| `Project/Sources/Methods/__BuildComponent.4dm` | Dev utility — component build launcher (superseded by `Fnd_FCS_BuildComponent`) |
| `Project/Sources/Methods/__WriteDocumentation.4dm` | Dev utility — documentation generator |
| `Project/Sources/Methods/CLAUDE.md` | AI working memory file (Claude Code artefact) |
| `Project/Sources/Methods/_Testing.4dm` | Dev utility — gitignored in Echidna; excluded here as a belt-and-suspenders guard |
| `Project/Sources/Methods/OTr_z_Echidna.4dm` | Dev-only — returns image from `Resources/images/Echidna.jpg`; image files are stripped and method serves no purpose without them |
| `Project/Sources/Methods/OTr_z_Koala.4dm` | Dev-only — returns image from `Resources/images/koala.png`; same rationale |
| `Project/Sources/Methods/OTr_z_Wombat.4dm` | Dev-only — returns image from `Resources/images/Wombat.png`; same rationale |
| `WebFolder/` | Codex HTTP bridge web root — not part of the shipped component |
| `Resources/images/koala.png` | Dev-only — stripped; `OTr_z_Koala` ships but returns empty picture without its image |
| `Resources/images/Echidna.jpg` | Dev-only — stripped; `OTr_z_Echidna` ships but returns empty picture without its image |
| `DevNotes/` | Maintainer notes, example logs, session transcripts |
| `Specifications/` | Phase specifications — maintainer-only |
| `.claude/` | Claude Code settings |
| `.github/workflows/smoke-test.yml` | Smoke-test workflow — not part of the release workflow set |
| `Release/handover-*.md` | Session handover documents |
| `4D-Method-Writing-Guide.md` | Maintainer reference |
| `OTr-API-Differences.md` | Maintainer reference |
| `OTr-Specification.md` | Maintainer reference |
| `OTr-Types-Reference.md` | Maintainer reference |
| `plan-*.prompt.md` | AI planning prompts |
| `userPreferences.*` | Per-user 4D preferences (gitignored in Echidna; guard against accidental tracking) |
| `Resources/1 Corinthians 1.docx` | Test fixture for text-blob round-trip; not part of the shipped component |

---

## Retain only — inverted rules

For directories where most content ships but specific items must be excluded.

| Directory | Keep | Strip everything else |
|---|---|---|
| `Resources/` | `InfoPlist.json`, `InfoPlist.strings`, `OTr.xlf`, `templatebuildApp.xml`, `OTr_OTBlockMethods.json`, `images/Wombat.png` | All other files and subdirectories |

---

## Items confirmed NOT stripped

These were considered and explicitly decided to ship on Koala/Platypus.

| Path | Reason retained |
|---|---|
| `Resources/templatebuildApp.xml` | Required by `Fnd_FCS_BuildComponent`, which ships (Decision #1, 2026-04-20) |
| `Resources/OTr_OTBlockMethods.json` | Required by `OTr_z_Comment_Uncomment_OT_Code` and `OTr_z_PluginShouldWork`, which ship as migration utilities |
| `Fnd_FCS_BuildComponent.4dm` | Ships so downstream users can rebuild the component against their own signing identity |
| `OTr_LoadAndViewOTBlob.4dm` | Ships — useful end-developer utility for loading and viewing legacy OT blobs interactively |
| `OTr_z_Comment_Uncomment_OT_Code.4dm` | Ships — migration utility for users transitioning from the legacy plugin |
| `OTr_z_PluginShouldWork.4dm` | Ships — companion to `OTr_z_Comment_Uncomment_OT_Code` |
| `Examples/` | Ships — provides usage examples to end users |
| `Documentation/Methods/` | Ships — component method documentation |

---

## Open questions

None at this time.

---

## Changelog

- 2026-04-20 — Initial draft. All entries derived from Echidna tree survey conducted at
  commit `2a8db87`. Decisions #1–#4 from the 2026-04-19/20 sessions applied.
- 2026-04-20 — Revised after review: `_____Import_OT_Blob.4dm` retained (ships as
  end-developer utility); `OTr_z_Comment_Uncomment_OT_Code.4dm`, `OTr_z_PluginShouldWork.4dm`,
  and `Resources/OTr_OTBlockMethods.json` retained (migration utilities for users
  transitioning from the legacy plugin); `OTr_z_Echidna.4dm`, `OTr_z_Koala.4dm`,
  `OTr_z_Wombat.4dm`, and `Resources/images/` stripped (test-only picture round-trip
  infrastructure, round-trip comparison never implemented).
- 2026-04-21 — Added `Resources/1 Corinthians 1.docx` to always-strip (test fixture only);
  `Compiler_OTr_w_Methods` and `Compiler_OTr_v_Methods` entries confirmed correct following
  reorganisation into per-prefix compiler methods; `OTr_LoadAndViewOTBlob.4dm` confirmed as
  renamed from `_____Import_OT_Blob.4dm`.
