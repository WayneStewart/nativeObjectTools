# Review Session S6 — Release Checklist Gate

**Version:** 1.0
**Date:** 2026-04-11
**Author:** Wayne Stewart / Claude
**Dependencies:** S1, S2, S3, S4, S5 must be substantially complete before commencing this session
**Parallel with:** None — this is the integration and gate session

---

## Purpose

Work through the formal release checklist (`Documentation/Specifications/OTr-Phase-020-Spec.md`) systematically, using the findings from sessions S1–S5 as evidence. Resolve all outstanding TODOs, close all correctness check items, and produce a definitive go/no-go assessment for the v0.5 release.

This session does not perform new discovery — it consolidates the findings from the other sessions into a final release decision.

---

## Scope

### Primary document

`Documentation/Specifications/OTr-Phase-020-Spec.md` — the Release Checklist

### Supporting inputs (from prior sessions)

| Session | Contribution to S6 |
|---|---|
| S1 — Specification Completeness | Resolves spec gaps and contradictions; confirms the spec corpus is canonical |
| S2 — API Coverage Audit | Confirms all methods exist and are correctly registered |
| S3 — Native vs Plugin Behaviour | Resolves behavioural gaps, `OK` discipline, and provisional items |
| S4 — Test Coverage Audit | Confirms test coverage is sufficient for release |
| S5 — Coding Standard Compliance | Resolves `%attributes`, suffix, header, and semaphore issues |

---

## Review Checklist

### Section 1 — Phase implementation status

Confirm the status of each phase per Phase 20 §1:

- [ ] Phase 1 — Core Infrastructure: ✅ Implemented and tested (confirm with S4 findings)
- [ ] Phase 1.5 — Simple Export/Import: ✅ (confirm `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard` are implemented — flagged as uncertain in Phase 20 TODO)
- [ ] Phase 2 — Scalar Put/Get: ✅
- [ ] Phase 3 — Item Info and Utilities: ✅
- [ ] Phase 4 — Array Operations: ✅
- [ ] Phase 5 — Complex Types: ✅
- [ ] Phase 6 — Import/Export: ✅
- [ ] Phase 7 — API Naming Alignment: ✅ (confirm with S2 findings)
- [ ] Phase 8 — Unified Array Element Accessor: ✅
- [ ] Phase 9 — (confirm scope and status — Phase 9 spec exists but is not in Phase 20 table)
- [ ] Phase 10 — Logging Subsystem: confirm whether complete or still in progress
- [ ] Phase 15 — Side-by-Side Compatibility Testing: confirm whether complete
- [ ] Phase 100 — Dual Storage Architecture: confirmed post-release, not blocking

### Section 2 — TODOs (from Phase 20 §3)

Each item must be resolved before release. Status is recorded as: ✅ Resolved / ❌ Outstanding / ➡️ Deferred (with justification).

- [ ] Fix stray `_p` suffix in source files (5 files) — per S5 findings
- [ ] Fix stray `_p` / `_x` suffixes in `OTr-Phase-004-Spec.md` — per S1 findings
- [ ] Confirm all methods registered correctly in `folders.json` — per S2 findings
- [ ] Confirm `OK` set to 0 on every error path — per S3 findings
- [ ] Confirm `OTr_zSetOK` used consistently — per S5 findings
- [ ] Confirm documentation header in every `.4dm` — per S5 findings
- [ ] Confirm `%attributes` line correct on every method — per S5 findings
- [ ] Confirm all public API methods are `"shared":true`; all `OTr_z*`, `OTr_u*`, test methods are `"shared":false` — per S5 findings
- [ ] Confirm semaphore released on every exit path — per S3 and S5 findings
- [ ] Confirm `OTr_zInit` called at top of every public method — per S5 findings
- [ ] Confirm Phase 1.5 Load methods implemented — per S2 and S4 findings
- [ ] Confirm `____Test_Phase_5` covers all complex type round-trips — per S4 findings
- [ ] Confirm `____Test_Phase_6` covers BLOB serialisation round-trips — per S4 findings
- [ ] Confirm `____Test_OT_Compatibility` exists and registered in `Test Methods` group — per S2 and S4 findings
- [ ] Confirm side-by-side testing performed on a compatible platform — per Phase 15 and S3 findings
- [ ] Review whether `OTr_uDateToText`, `OTr_uTextToDate`, `OTr_uTimeToText`, `OTr_uTextToTime` are still required — per S2 and S3 findings; make a decision and document it

### Section 3 — Correctness checks (from Phase 20 §4)

Each item must be verified. Record: ✅ Verified / ❌ Failed / ➡️ Deferred.

- [ ] Handle allocation: slot reuse confirmed
- [ ] Tail-trimming: trailing unused slots trimmed on `OTr_Clear`
- [ ] BLOB/Picture overwrite: existing values correctly replaced
- [ ] Dot-path navigation: multi-level paths create intermediate objects with `AutoCreateObjects` set
- [ ] 1-based ↔ 0-based index mapping: verified at first element, last element, and out-of-bounds
- [ ] `OTr_ItemType` returns legacy OT type constants
- [ ] `OTr_GetBoolean` returns Integer (0/1), not Boolean
- [ ] `OTr_GetBLOB` fires deprecation warning
- [ ] Date stored as `YYYY-MM-DD` text; Time stored as `HH:MM:SS` text; round-trip verified — **OR** resolve the Date/Time native vs text storage question (S3 §3 finding) and update this check accordingly
- [ ] `OTr_SortArrays` multi-key sort verified
- [ ] `OTr_BLOBToObject` deserialisation: all properties correctly restored
- [ ] `OTr_BLOBToObject` magic-byte check: legacy OT BLOB produces clear incompatibility error
- [ ] Compiler mode: all methods compile without error in 4D v19 LTS

### Section 4 — Migration guide (from Phase 20 §5)

Review the migration guide checklist items for completeness and accuracy:

- [ ] Find-and-replace instruction (`OT ` → `OTr_`) is correct and complete
- [ ] `OTr_Register` no-op note is accurate
- [ ] `OTr_ObjectToBLOB` / `OTr_BLOBToObject` incompatibility note is accurate
- [ ] `OTr_PutObject` / `OTr_GetObject` deep-copy note is accurate
- [ ] `OTr_Clear` discipline note is accurate
- [ ] `OTr_GetBoolean` Integer return note is accurate
- [ ] Array index 1-based note is accurate
- [ ] `OTr_GetPointer` `->` syntax change is clearly documented
- [ ] `OTr_GetArrayPointer` function-result change is clearly documented

### Section 5 — Publishing gate (from Phase 20 §6)

All items must be ✅ before release is approved:

- [ ] All phases implemented and tested
- [ ] All TODOs above resolved
- [ ] All correctness checks above passed
- [ ] Side-by-side compatibility testing passed
- [ ] `OTr-Specification.md` version number updated
- [ ] `OTr_GetVersion` return value updated to match release version
- [ ] Git tag created for release commit
- [ ] Legacy ObjectTools plugin removed from project dependencies

---

## Additional Gate Items (not in Phase 20 but recommended)

The following items are not in the existing Phase 20 checklist but should be verified before release:

- [ ] **Phase 9 status** — Phase 9 exists as a spec but does not appear in Phase 20's implementation table and has no test method. Determine scope, implementation status, and whether it blocks release.
- [ ] **Date/Time storage strategy** — Resolve the discrepancy between master spec §3.6 (formatted text) and the apparent implementation (native `OB SET`) — update the spec, the Phase 20 correctness check, and `OTr-OK0-Conditions.txt` accordingly.
- [ ] **`OTr_BLOBToObject` offset parameter** — Resolve the "provisional" status noted in Phase 15 §4.2; confirm final implementation.
- [ ] **`____Test_Phase_7.4dm` decision** — Document whether a Phase 7 test method is required or whether the S2 API naming audit constitutes sufficient verification.
- [ ] **README.md status section** — Update the README status section to reflect the final release state before tagging.

---

## Go / No-Go Decision

At the conclusion of this session, record a formal go/no-go decision:

**GO** conditions (all must be met):
1. All Phase 20 §6 publishing gate items are ✅
2. All Phase 20 §3 TODOs are ✅ Resolved (or ➡️ Deferred with documented justification)
3. All Phase 20 §4 correctness checks are ✅ Verified
4. No outstanding S1–S5 findings of severity "blocker" remain unresolved

**NO-GO** — if any blocker-severity finding from S1–S5 is unresolved, record the finding, its owning session, and the action required to resolve it.

---

## Notes for the Reviewer

This session is most productive when all findings from S1–S5 have been compiled into a single consolidated findings document before beginning. Work through the Phase 20 checklist linearly, marking each item with a reference to the supporting session finding.

The Date/Time storage strategy discrepancy (flagged in S1 and S3) is likely to be the most consequential unresolved question. It affects the correctness check in §4, the spec in §1, and potentially the test coverage in S4. Resolve it first.
