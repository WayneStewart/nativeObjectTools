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
| `Project/Sources/Methods/Compiler_Prototyping.4dm` | Dev-only compiler declarations (test arrays, Codex bridge variables). Handled by stageKoala directly per README convention; listed here for completeness. |
| `Project/Sources/Methods/OTr_w_Run.4dm` | Codex HTTP bridge dispatcher |
| `Project/Sources/Methods/OTr_w_RunCompileOnMain.4dm` | Codex bridge — compile-on-main helper |
| `Project/Sources/Methods/OTr_w_RunUnitTestWorker.4dm` | Codex bridge — unit test worker |
| `Project/Sources/Methods/OTr_w_RestartProjectWorker.4dm` | Codex bridge — restart worker |
| `Project/Sources/Methods/OTr_w_IsLocalRequest.4dm` | Codex bridge — loopback guard |
| `Project/Sources/Methods/OTr_w_CompileResultForJSON.4dm` | Codex bridge — compile result serialiser |
| `Project/Sources/Methods/OTr_w_GuyBlobExport.4dm` | Codex bridge — legacy blob export utility |
| `Project/Sources/Methods/OTr_w_Phase16Diag.4dm` | Codex bridge — Phase 16 diagnostics |
| `Project/Sources/Methods/TimetoDie.4dm` | Dev utility — graceful shutdown helper (Blade Runner easter egg) |
| `Project/Sources/Methods/___templateAutoStart.4dm` | AI scaffold template, not a shipping method |
| `Project/Sources/Methods/__BuildComponent.4dm` | Dev utility — component build launcher (superseded by `Fnd_FCS_BuildComponent`) |
| `Project/Sources/Methods/__WriteDocumentation.4dm` | Dev utility — documentation generator |
| `Project/Sources/Methods/util_compileProject.4dm` | Dev utility — headless compile helper |
| `Project/Sources/Methods/util_restartProject.4dm` | Dev utility — project restart helper |
| `Project/Sources/Methods/CLAUDE.md` | AI working memory file (Claude Code artefact) |
| `Project/Sources/Methods/_Testing.4dm` | Dev utility — gitignored in Echidna; excluded here as a belt-and-suspenders guard |
| `Project/Sources/Methods/OTr_z_Echidna.4dm` | Dev-only — returns image from `Resources/images/Echidna.jpg`; image files are stripped and method serves no purpose without them |
| `Project/Sources/Methods/OTr_z_Koala.4dm` | Dev-only — returns image from `Resources/images/koala.png`; same rationale |
| `Project/Sources/Methods/OTr_z_Wombat.4dm` | Dev-only — returns image from `Resources/images/Wombat.png`; same rationale |
| `WebFolder/` | Codex HTTP bridge web root — not part of the shipped component |
| `Resources/images/` | Dev-only — test images for picture round-trip testing; no production purpose |
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

---

## Retain only — inverted rules

For directories where most content ships but specific items must be excluded.

| Directory | Keep | Strip everything else |
|---|---|---|
| `Resources/` | `InfoPlist.json`, `InfoPlist.strings`, `OTr.xlf`, `templatebuildApp.xml`, `OTr_OTBlockMethods.json` | All other files and subdirectories (`images/` already listed above) |

---

## Items confirmed NOT stripped

These were considered and explicitly decided to ship on Koala/Platypus.

| Path | Reason retained |
|---|---|
| `Resources/templatebuildApp.xml` | Required by `Fnd_FCS_BuildComponent`, which ships (Decision #1, 2026-04-20) |
| `Resources/OTr_OTBlockMethods.json` | Required by `OTr_z_Comment_Uncomment_OT_Code` and `OTr_z_PluginShouldWork`, which ship as migration utilities |
| `Fnd_FCS_BuildComponent.4dm` | Ships so downstream users can rebuild the component against their own signing identity |
| `_____Import_OT_Blob.4dm` | Ships — useful end-developer utility for importing legacy OT blobs interactively |
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
