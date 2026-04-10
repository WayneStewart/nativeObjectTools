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
| ✅ | ✅ | Phase 15 — Side-by-Side Compatibility Testing | [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md) |
|    |    | Phase 100 — Dual Storage Mechanism and Three-Layer Architecture *(post-release)* | [OTr-Phase-100-Spec.md](OTr-Phase-100-Spec.md) |

---

## 2. Known Gaps (Unimplemented Methods)

*No outstanding unimplemented methods. `OTr_uExpandBinaries` and `OTr_uCollapseBinaries` were retired in Phase 6; binary data is stored natively in 4D Objects.*

---

## 3. TODOs

- [ ] Fix stray `_p` suffix (should be `_ptr` or `_pic` per `OTr-Types-Reference.md`) in source files:
  - `OTr_uPointerToText.4dm` — `$thePointer_p` → `$thePointer_ptr`
  - `OTr_uTextToPointer.4dm` — `$thePointer_p` in comment → `$thePointer_ptr`
  - `OTr_PutArrayPointer.4dm` — `$value_p` → `$value_ptr`
  - `OTr_GetArrayPointer.4dm` — `$value_p` → `$value_ptr`
  - `OTr_zSortSlotPointer.4dm` — `$ptr_p` → `$ptr_ptr` (or rename to `$result_ptr`)
- [ ] Fix stray `_p` / `_x` suffixes in spec documents:
  - `OTr-Phase-004-Spec.md` — `$thePointer_p`, `$value_p` for Pointer
  - ~~`OTr-Phase-005-Spec.md`~~ — ✅ fixed (`_p` → `_pic`, `_x` → `_blob`)
- [ ] Confirm all methods are registered in the correct group in `Project/Sources/folders.json`
- [ ] Confirm `OK` is set to 0 on every error path across all methods
- [ ] Confirm `OTr_zSetOK` is used consistently (not direct `OK:=0` assignments)
- [ ] Confirm documentation header in every `.4dm` follows the standard pattern
- [ ] Confirm `%attributes` line is correct on every method (`"invisible":true`, correct `"shared"` value)
- [ ] Confirm all public API methods are `"shared":true`; all `OTr_z*`, `OTr_u*`, and `Test_OTr_*` are `"shared":false`
- [ ] Confirm semaphore is released on every exit path (including error paths) in all public methods
- [ ] Confirm `OTr_zInit` is called (lazily) at the top of every public method
- [ ] Confirm Phase 1.5 Load methods (`OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard`) are implemented
- [ ] Write test method `____Test_Phase_5` covering all complex type round-trips
- [ ] Write test method `____Test_Phase_6` covering BLOB serialisation round-trips
- [ ] Write test method `____Test_OT_Compatibility` per [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md); register in `Test Methods` group in `folders.json`
- [ ] Confirm side-by-side testing performed on a compatible platform — see [OTr-Phase-015-Spec.md §2](OTr-Phase-015-Spec.md)
- [ ] Review whether `OTr_uDateToText`, `OTr_uTextToDate`, `OTr_uTimeToText`, and `OTr_uTextToTime` are still required. Scalar put/get methods (`OTr_PutDate`, `OTr_GetDate`, `OTr_PutTime`, `OTr_GetTime`) use native `OB SET`/`OB Get` and do not call these utilities. Current callers are the array path (`OTr_PutArrayDate`, `OTr_GetArrayDate`, `OTr_PutArrayTime`, `OTr_GetArrayTime`, `OTr_PutArray`, `OTr_zArrayFromObject`, `OTr_FindInArray`) and the record path (`OTr_PutRecord`, `OTr_GetRecord`). If the array and record storage strategies were unified with the scalar native approach, all four methods could be retired.

---

## 4. Correctness Checks

- [ ] Handle allocation: slot reuse confirmed (cleared slot reused by next `OTr_New`)
- [ ] Tail-trimming: trailing unused slots trimmed on `OTr_Clear` (§10.6)
- [ ] BLOB/Picture overwrite: existing values correctly replaced without leaking (native Object properties require no explicit release)
- [ ] Dot-path navigation: multi-level paths create intermediate objects when `AutoCreateObjects` is set
- [ ] 1-based ↔ 0-based index mapping: verified at first element, last element, and out-of-bounds for all array methods
- [ ] `OTr_ItemType` returns legacy OT type constants (not native 4D constants)
- [ ] `OTr_GetBoolean` returns Integer (0/1) for legacy compatibility, not Boolean
- [ ] `OTr_GetBLOB` fires deprecation warning via error handler before delegating to `OTr_GetNewBLOB`
- [ ] Date stored as `YYYY-MM-DD` text; Time stored as `HH:MM:SS` text; round-trip verified
- [ ] `OTr_SortArrays` multi-key sort verified with mixed ascending/descending keys
- [ ] `OTr_BLOBToObject` deserialisation: JSON payload correctly parsed and a new OTr handle returned with all properties (including native BLOBs and Pictures) correctly restored
- [ ] `OTr_BLOBToObject` magic-byte check: legacy OT BLOB produces a clear incompatibility error
- [ ] Compiler mode: all methods compile without error in 4D v19 LTS (no class syntax)

---

## 5. Migration Guide Checklist

*Items a caller must address when migrating from ObjectTools 5.0 to OTr. See [OTr-Phase-015-Spec.md §4](OTr-Phase-015-Spec.md) for the full incompatibility catalogue.*

- [ ] Find-and-replace `OT ` → `OTr_` across all calling methods (space to underscore)
- [ ] Remove or retain `OT Register` calls (`OTr_Register` is a no-op — safe to leave)
- [ ] Review `OT ObjectToBLOB` / `OT BLOBToObject` usage — OTr format is **not** compatible with legacy OT BLOBs; migration requires re-serialising via OTr
- [ ] Review `OT PutObject` / `OT GetObject` usage — OTr always deep-copies (no reference semantics)
- [ ] Audit all `OT Clear` call sites — same memory management discipline required; no garbage collection
- [ ] Confirm calling code uses `OTr_GetBoolean` return value as Integer (0/1), not Boolean
- [ ] Confirm calling code treats array indices as 1-based (OTr maps internally to 0-based Collections)
- [ ] Update all `OT GetPointer` call sites: OTr requires the output variable to be passed with the pointer-to-pointer syntax (`->myVar`), not as a plain variable. This is because 4D methods receive parameters by value and cannot write back through a plain Pointer; the `->` lets the method dereference one level to deposit the result. (`OT GetPointer` as a compiled plugin command had C-level write access and did not require this.)
- [ ] Update all `OT GetArrayPointer` call sites: `OTr_GetArrayPointer` returns the pointer as a function result rather than via an output parameter — change `OT GetArrayPointer(h; tag; idx; outVar)` to `outVar := OTr_GetArrayPointer(h; tag; idx)`

---

## 6. Publishing

- [ ] All phases implemented and tested
- [ ] All TODOs above resolved
- [ ] All correctness checks above passed
- [ ] Side-by-side compatibility testing passed per [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md)
- [ ] `OTr-Specification.md` version number updated
- [ ] `OTr_GetVersion` return value updated to match release version
- [ ] Git tag created for release commit
- [ ] Legacy ObjectTools plugin removed from project dependencies
