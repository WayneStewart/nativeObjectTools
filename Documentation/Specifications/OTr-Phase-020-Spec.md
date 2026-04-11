# OTr — Release Checklist

**Version:** 0.3
**Date:** 2026-04-04
**Status:** Active (v0.5 Release Checklist)
**Author:** Wayne Stewart / Claude

---

## 1. Phase Implementation

| Spec | Impl | Phase | Spec Document |
|:---:|:---:|---|---|
| ✅ | ✅ | Phase 1 — Core Infrastructure | *(no separate spec)* |
| ✅ | ✅ | Phase 1.5 — Simple Export/Import | *(no separate spec)* |
| ✅ | ✅ | Phase 2 — Scalar Put/Get | *(no separate spec)* |
| ✅ | ✅ | Phase 3 — Item Info and Utilities | [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md) |
| ✅ | ✅ | Phase 4 — Array Operations | [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md) |
| ✅ | ✅ | Phase 5 — Complex Types | [OTr-Phase-005-Spec.md](OTr-Phase-005-Spec.md) |
| ✅ | ✅ | Phase 6 — Import/Export | [OTr-Phase-006-Spec.md](OTr-Phase-006-Spec.md) |
| ✅ | ✅ | Phase 7 — API Naming Alignment | [OTr-Phase-007-Spec.md](OTr-Phase-007-Spec.md) |
| ✅ | ✅ | Phase 8 — Unified Array Element Accessor | [OTr-Phase-008-Spec.md](OTr-Phase-008-Spec.md) |
| ✅ | ✅ | Phase 9 — Pre-Release Audit and Corrections — no new public API methods; documents undocumented methods, establishes canonical `OK` behaviour table, and resolves reentrant-lock design. **Note:** Phase 20 §1 previously (incorrectly) stated Phase 9 was "reserved/intentionally omitted". This was an error; `OTr-Phase-009-Spec.md` exists and is substantially complete. Corrected 2026-04-12 (S6). | [OTr-Phase-009-Spec.md](OTr-Phase-009-Spec.md) |
| ✅ | ✅ | Phase 10 — Logging Subsystem | [OTr-Phase-010-Spec.md](OTr-Phase-010-Spec.md) |
| ✅ | ✅ | Phase 15 — Side-by-Side Compatibility Testing | [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md) |
|    |    | Phase 100 — Dual Storage Mechanism and Three-Layer Architecture *(post-release)* | [OTr-Phase-100-Spec.md](OTr-Phase-100-Spec.md) |

---

## 2. Known Gaps (Unimplemented Methods)

*No outstanding unimplemented methods. `OTr_uExpandBinaries` and `OTr_uCollapseBinaries` were retired in Phase 6; binary data is stored natively in 4D Objects.*

---

## 3. TODOs

- [x] Fix stray `_p` suffix (should be `_ptr` or `_pic` per `OTr-Types-Reference.md`) in source files — **Resolved prior to S5 audit.** S5 §3.1 confirms all five files clean.
  - ~~`OTr_uPointerToText.4dm` — `$thePointer_p` → `$thePointer_ptr`~~
  - ~~`OTr_uTextToPointer.4dm` — `$thePointer_p` in comment → `$thePointer_ptr`~~
  - ~~`OTr_PutArrayPointer.4dm` — `$value_p` → `$value_ptr`~~
  - ~~`OTr_GetArrayPointer.4dm` — `$value_p` → `$value_ptr`~~
  - ~~`OTr_zSortSlotPointer.4dm` — `$ptr_p` → `$ptr_ptr` (or rename to `$result_ptr`)~~
- [ ] Fix stray `_p` / `_x` suffixes in spec documents (S1 §2.4):
  - `OTr-Phase-004-Spec.md` — `$thePointer_p`, `$value_p` for Pointer → `_ptr` (outstanding)
  - ~~`OTr-Phase-005-Spec.md`~~ — ✅ fixed (`_p` → `_pic`, `_x` → `_blob`)
  - Also: `OTr_uBlobToText.4dm` source uses `$theBlob_x` → should be `$theBlob_blob` (S2 §3.7)
- [ ] Confirm all methods are registered in the correct group in `Project/Sources/folders.json` — S2/S5 audit: all 107 public methods and all 15 utility methods correctly registered. Several private methods absent from `folders.json` (advisory — no functional impact; see S6-Findings §2.3). `OTr_zLogGetCallStack.4dm` file confirmed present on disk (S5/S6 cross-check). Remaining advisory items to be addressed before tagging.
- [ ] Confirm `OK` is set to 0 on every error path across all methods — **BLOCKERS IDENTIFIED (S3).** Four defects require code fixes before release. See S6-Findings §2.4 and Blockers B-01 through B-04.
- [x] Confirm `OTr_zSetOK` is used consistently (not direct `OK:=0` assignments) — **Resolved.** S5 §6 PASS. No direct `OK:=0` assignments found across all 158 files.
- [x] Confirm documentation header in every `.4dm` follows the standard pattern — **Resolved.** S5 §4.1 PASS. All 158 files have boxed-header separators and `// Project Method:` signature lines. `OTr_uEqualObjects` header corrected 2026-04-11.
- [x] Confirm `%attributes` line is correct on every method (`"invisible":true`, correct `"shared"` value) — **Resolved.** S5 §1.1 PASS. All 158 files have `%attributes` line. Advisory: 27 private/utility files carry `{"invisible":true}` without explicit `"shared":false`; 4D defaults correctly to `false`. No functional impact.
- [x] Confirm all public API methods are `"shared":true`; all `OTr_z*`, `OTr_u*`, and `Test_OTr_*` are `"shared":false` — **Resolved.** S5 §1.1 PASS.
- [x] Confirm semaphore is released on every exit path (including error paths) in all public methods — **Resolved.** S5 §8.1 — `OTr_InsertElement` defect (lock acquired but never released) corrected 2026-04-11. S3 §8.1 PASS on all other reviewed paths.
- [x] Confirm `OTr_zInit` is called (lazily) at the top of every public method — **Resolved.** S5 §7.1 — `OTr_zLock` calls `OTr_zInit` on every invocation; virtually every public method calls `OTr_zLock`, satisfying the requirement through this proxy pattern.
- [x] Confirm Phase 1.5 Load methods (`OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard`) are implemented — all three `.4dm` files confirmed present; `#DECLARE` signatures verified; all three registered in `folders.json` "OT API Methods" group (S2 audit, 2026-04-11)
- [x] Write test method `____Test_Phase_5` covering all complex type round-trips — **Resolved.** S4 §1.5 confirms `____Test_Phase_5` exists; covers BLOB, Picture, Pointer, Variable. `OTr_PutRecord`/`OTr_GetRecord` skipped with documented reason.
- [x] Write test method `____Test_Phase_6` covering BLOB serialisation round-trips — **Resolved.** S4 §1.6 confirms `____Test_Phase_6` exists; covers `OTr_ObjectToBLOB`/`OTr_BLOBToObject` including BLOB and Picture items.
- [x] Write test method `____Test_OT_Compatibility` per [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md); register in `Test Methods` group in `folders.json` — **Resolved (naming note).** `____Test_Phase_15` serves this purpose (30/30 Pass, registered in `folders.json`). TODO text updated to reflect actual method name.
- [x] Confirm side-by-side testing performed on a compatible platform — **Resolved.** Phase 15 §7: 30/30 Pass. Platform constraint documented in test source.
- [x] Review whether `OTr_uDateToText`, `OTr_uTextToDate`, `OTr_uTimeToText`, and `OTr_uTextToTime` are still required — **Resolved: retain all four.** Caller audit (S2, 2026-04-11) confirmed each has 6–7 active callers across the array path (`OTr_PutArrayDate`, `OTr_GetArrayDate`, `OTr_PutArrayTime`, `OTr_GetArrayTime`, `OTr_PutArray`, `OTr_zArrayFromObject`, `OTr_FindInArray`) and the record path (`OTr_PutRecord`, `OTr_GetRecord`). These utilities are the canonical implementation of the `YYYY-MM-DD` / `HH:MM:SS` text storage strategy for Date and Time in array and record contexts. They must not be retired unless that storage strategy is changed (see Cross-Cutting Issue #1 in `00-Review-Index.md`).

---

## 4. Correctness Checks

- [x] Handle allocation: slot reuse confirmed (cleared slot reused by next `OTr_New`) — **Verified.** S3 §2.1 PASS.
- [x] Tail-trimming: trailing unused slots trimmed on `OTr_Clear` (§10.6) — **Verified.** S3 §2.2 PASS — backward walk from end of `<>OTR_InUse_ab` implemented correctly.
- [x] BLOB/Picture overwrite: existing values correctly replaced without leaking (native Object properties require no explicit release) — **Verified.** S3 §6.3 PASS by Phase 15 result.
- [x] Dot-path navigation: multi-level paths create intermediate objects when `AutoCreateObjects` is set — **Verified with note.** S3 §3.5 PASS — all Put methods pass `autoCreate=True` to `OTr_zResolvePath`. Note: the global `SetOptions` `AutoCreateObjects` bit may not be consulted; the parameter is hard-coded `True` from each Put method. Behavioural gap relative to OT 5.0 for callers who disable `AutoCreateObjects` via `OTr_SetOptions`.
- [x] 1-based ↔ 0-based index mapping: verified at first element, last element, and out-of-bounds for all array methods — **Verified.** S3 §5.1 PASS; S4 §3.4 — index 1 and last element exercised in tests.
- [x] `OTr_ItemType` returns legacy OT type constants (not native 4D constants) — **Verified.** S3 §4.1 PASS — `OTr_zMapType` confirmed for all major types. **Note:** `OTr_ItemType` also has a pending BLOCKER fix (S6 B-03: missing `OTr_zSetOK(1)` on success path).
- [x] `OTr_GetBoolean` returns Integer (0/1) for legacy compatibility, not Boolean — **Verified.** S3 §3.2 PASS — explicit branch; declared as returning Integer.
- [x] `OTr_GetBLOB` fires deprecation warning via error handler before delegating to `OTr_GetNewBLOB` — **Verified.** S4 §1.5 PASS — deprecation path exercised; note: `OTr_GetBLOB` is a full implementation (pointer-form), not a stub. Phase 15 §4.1 table requires update to remove "cannot be implemented" note.
- [x] Date stored as `YYYY-MM-DD` text; Time stored as `HH:MM:SS` text; round-trip verified — **Verified (dual-path).** S1 §1.3 RESOLVED — dual-path storage strategy implemented. Default (ISO text) aligns with this check. `OTr_GetRecord` dual-path retrieval applied 2026-04-11; confirmed by S6 code review 2026-04-12.
- [x] `OTr_SortArrays` multi-key sort verified with mixed ascending/descending keys — **Verified.** S3 §5.3 PASS; S4 §3.4 — multi-key test present.
- [x] `OTr_BLOBToObject` deserialisation: JSON payload correctly parsed and a new OTr handle returned with all properties (including native BLOBs and Pictures) correctly restored — **Verified.** S3 §7.1 PASS; Phase 15 §7 Pass.
- [x] `OTr_BLOBToObject` magic-byte check: legacy OT BLOB produces a clear incompatibility error — **Partially verified.** S3 §7.1 — legacy OT BLOB will fail `BLOB TO VARIABLE`, triggering `OTr_zError`. Mechanism correct. S4 §3.6 — no test exercises this path with a well-formed legacy OT BLOB. Coverage gap only; runtime path is correct.
- [ ] Compiler mode: all methods compile without error in 4D v19 LTS (no class syntax) — **Not audited.** No explicit compilation test run in S1–S5. Must be performed before release. One `C_LONGINT` in `OTr_uEqualObjects.4dm` (deferred per S5 §2.3) is valid 4D v19 syntax.

---

## 5. Migration Guide Checklist

*Items a caller must address when migrating from ObjectTools 5.0 to OTr. See [OTr-Phase-015-Spec.md §4](OTr-Phase-015-Spec.md) for the full incompatibility catalogue.*

- [x] Find-and-replace `OT ` → `OTr_` across all calling methods (space to underscore) — **Accurate.** Phase 15 §4.1 verified.
- [x] Remove or retain `OT Register` calls (`OTr_Register` is a no-op — safe to leave) — **Accurate.** S3 §2.4 PASS.
- [x] Review `OT ObjectToBLOB` / `OT BLOBToObject` usage — OTr format is **not** compatible with legacy OT BLOBs; migration requires re-serialising via OTr — **Accurate.** S3 §7.1 confirmed.
- [x] Review `OT PutObject` / `OT GetObject` usage — OTr always deep-copies (no reference semantics) — **Accurate.** S3 §6.1 PASS.
- [x] Audit all `OT Clear` call sites — same memory management discipline required; no garbage collection — **Accurate.** S3 §2.2/§2.3 PASS.
- [x] Confirm calling code uses `OTr_GetBoolean` return value as Integer (0/1), not Boolean — **Accurate.** S3 §3.2 PASS.
- [x] Confirm calling code treats array indices as 1-based (OTr maps internally to 0-based Collections) — **Accurate.** S3 §5.1 PASS.
- [x] Update all `OT GetPointer` call sites: OTr requires the output variable to be passed with the pointer-to-pointer syntax (`->myVar`), not as a plain variable. This is because 4D methods receive parameters by value and cannot write back through a plain Pointer; the `->` lets the method dereference one level to deposit the result. (`OT GetPointer` as a compiled plugin command had C-level write access and did not require this.) — **Accurate.** S3 §6.5 PASS; Phase 15 §4.2.
- [x] Update all `OT GetArrayPointer` call sites: `OTr_GetArrayPointer` returns the pointer as a function result rather than via an output parameter — change `OT GetArrayPointer(h; tag; idx; outVar)` to `outVar := OTr_GetArrayPointer(h; tag; idx)` — **Accurate.** S2 §3.4; Phase 15 §4.2.

---

## 6. Publishing

- [ ] All phases implemented and tested — phases 1–8 and 15 confirmed; Phase 10 logging has no unit tests (side-by-side behavioural tests only); Phase 9 n/a. **Conditional — dependent on blocker fixes.**
- [ ] All TODOs above resolved — Phase 4 spec suffix corrections outstanding; `folders.json` advisory items outstanding; **four blocker-severity OK discipline defects unresolved** (see §3, S6-Findings §Blockers).
- [ ] All correctness checks above passed — 12 of 13 checks verified; compiler mode test not yet run. B-01 (`OTr_GetRecord` dual-path) confirmed resolved by S6 code review 2026-04-12.
- [x] Side-by-side compatibility testing passed per [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md) — 30/30 Pass (2026-04-11); platform constraint documented.
- [ ] `OTr-Specification.md` version number updated — currently v0.5 / 2026-03-31; must be incremented before release.
- [ ] `OTr_GetVersion` return value updated to match release version — not audited; must be verified.
- [ ] Git tag created for release commit — pre-release; tag does not exist yet.
- [ ] Legacy ObjectTools plugin removed from project dependencies — not audited; must be verified.

---

## 7. S6 Gate Decision

**Date:** 2026-04-12
**Result:** **GO** (subject to remaining non-blocker items listed in §6 above)

All four initially-identified blockers resolved. See `Review/S6-Findings.md` for full findings.

| Blocker | File | Outcome |
|---|---|---|
| ~~B-01~~ | `OTr_GetRecord.4dm` | **Resolved 2026-04-11** — dual-path confirmed in code |
| ~~B-02~~ | `OTr_FindInArray.4dm` | **Not a bug** — code already correct; S3 finding was stale |
| ~~B-03~~ | `OTr_ItemType.4dm` | **Not a bug** — `OTr_zSetOK(1)` removal correct per OT 5.0 Reference |
| ~~B-04~~ | `OTr_LoadFromText.4dm` | **Fixed 2026-04-12** — `OTr_zError` added on parse failure |
