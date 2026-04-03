# OTr — Release Checklist

**Version:** 0.1
**Date:** 2026-04-03
**Author:** Wayne Stewart / Claude

---

## 1. Phase Implementation

| Done | Phase | Spec Document |
|:---:|---|---|
| ✅ | Phase 1 — Core Infrastructure | *(no separate spec)* |
| ✅ | Phase 1.5 — Simple Export/Import | *(no separate spec)* |
| ✅ | Phase 2 — Scalar Put/Get | *(no separate spec)* |
| ✅ | Phase 3 — Item Info and Utilities | [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md) |
| ✅ | Phase 4 — Array Operations | [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md) |
|   | Phase 5 — Complex Types | [OTr-Phase-005-Spec.md](OTr-Phase-005-Spec.md) |
|   | Phase 6 — Import/Export | [OTr-Phase-006-Spec.md](OTr-Phase-006-Spec.md) |
|   | Phase 7 — API Naming Alignment | [OTr-Phase-007-Spec.md](OTr-Phase-007-Spec.md) |

---

## 2. Known Gaps (Unimplemented Methods)

### Phase 5 — Complex Types

| Method | Category |
|---|---|
| `OTr_PutPointer` | Scalar Put |
| `OTr_GetPointer` | Scalar Get |
| `OTr_PutBLOB` | Scalar Put |
| `OTr_GetBLOB` | Scalar Get (deprecated stub) |
| `OTr_GetNewBLOB` | Scalar Get |
| `OTr_PutPicture` | Scalar Put |
| `OTr_GetPicture` | Scalar Get |
| `OTr_PutRecord` | Scalar Put |
| `OTr_GetRecord` | Scalar Get |
| `OTr_GetRecordTable` | Scalar Get |
| `OTr_PutVariable` | Scalar Put |
| `OTr_GetVariable` | Scalar Get |
| `OTr_uExpandBinaries` | Utility |
| `OTr_uCollapseBinaries` | Utility |

### Phase 6 — Import/Export

| Method | Category |
|---|---|
| `OTr_ObjectToBLOB` | Import/Export |
| `OTr_ObjectToNewBLOB` | Import/Export |
| `OTr_BLOBToObject` | Import/Export |
| `OTr_uMapType` | Utility (finalise) |

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
- [ ] Update Phase 1.5 Save methods to call `OTr_uExpandBinaries` (depends on Phase 5 completion)
- [ ] Implement Phase 1.5 Load methods (`OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard`) — blocked until Phase 5
- [ ] Write test method `____Test_Phase_5` covering all complex type round-trips
- [ ] Write test method `____Test_Phase_6` covering BLOB serialisation round-trips

---

## 4. Correctness Checks

- [ ] Handle allocation: slot reuse confirmed (cleared slot reused by next `OTr_New`)
- [ ] Tail-trimming: trailing unused slots trimmed on `OTr_Clear` (§10.6)
- [ ] Binary reference cleanup: `OTr_zReleaseBinaryRef` called before overwriting any `blob:N` / `pic:N` property
- [ ] Dot-path navigation: multi-level paths create intermediate objects when `AutoCreateObjects` is set
- [ ] 1-based ↔ 0-based index mapping: verified at first element, last element, and out-of-bounds for all array methods
- [ ] `OTr_ItemType` returns legacy OT type constants (not native 4D constants)
- [ ] `OTr_GetBoolean` returns Integer (0/1) for legacy compatibility, not Boolean
- [ ] `OTr_GetBLOB` fires deprecation warning via error handler before delegating to `OTr_GetNewBLOB`
- [ ] Date stored as `YYYY-MM-DD` text; Time stored as `HH:MM:SS` text; round-trip verified
- [ ] `OTr_SortArrays` multi-key sort verified with mixed ascending/descending keys
- [ ] `OTr_BLOBToObject` slot-index remapping: `blob:N` / `pic:N` indices from source session correctly remapped to new session slots
- [ ] `OTr_BLOBToObject` magic-byte check: legacy OT BLOB produces a clear incompatibility error
- [ ] Compiler mode: all methods compile without error in 4D v19 LTS (no class syntax)

---

## 5. Migration Guide Checklist

*Items a caller must address when migrating from ObjectTools 5.0 to OTr.*

- [ ] Find-and-replace `OT ` → `OTr_` across all calling methods (space to underscore)
- [ ] Remove or retain `OT Register` calls (`OTr_Register` is a no-op — safe to leave)
- [ ] Review `OT ObjectToBLOB` / `OT BLOBToObject` usage — OTr format is **not** compatible with legacy OT BLOBs; migration requires re-serialising via OTr
- [ ] Review `OT PutObject` / `OT GetObject` usage — OTr always deep-copies (no reference semantics)
- [ ] Audit all `OT Clear` call sites — same memory management discipline required; no garbage collection
- [ ] Confirm calling code uses `OTr_GetBoolean` return value as Integer (0/1), not Boolean
- [ ] Confirm calling code treats array indices as 1-based (OTr maps internally to 0-based Collections)

---

## 6. Incompatibilities with ObjectTools 5.0

This section catalogues all known API differences between OTr and ObjectTools 5.0. Callers migrating from the legacy plugin must audit each item below.

### 6.1 Methods That Cannot Be Implemented

These methods exist in ObjectTools 5.0 but have no equivalent implementation in OTr. The fundamental constraint is that a native 4D component method operates within a separate compiler namespace from the host database. Unlike a plugin, a component method **cannot write back to the caller's BLOB or Picture variable** passed as an output parameter.

| OT Method | OTr Equivalent | Reason |
|---|---|---|
| `OT GetBLOB(inObject; inTag; outBLOB)` | *(none)* | `outBLOB` is a BLOB output parameter; a component cannot materialise data into the caller's variable |
| `OT GetArrayBLOB(inObject; inTag; inIndex; outValue)` | *(none)* | Same BLOB output-parameter constraint |
| `OT GetArrayPicture(inObject; inTag; inIndex; outValue)` | *(none)* | Same Picture output-parameter constraint |

**Recommended migration path:** Replace calls to these methods with `OTr_GetNewBLOB` (Phase 5) and `OTr_GetPicture` (Phase 5), which return their values as function results rather than output parameters.

### 6.2 Methods Implemented with a Changed API

These methods are implemented in OTr, but their calling signature differs from the ObjectTools 5.0 counterpart. Callers must be updated.

| OT Method | OTr Method | Change | Notes |
|---|---|---|---|
| `OT ObjectToBLOB(inObject; ioBLOB)` | `OTr_ObjectToBLOB` | `ioBLOB` cannot be an in/out BLOB parameter in a component; the OTr method uses a function result instead | See Phase 6 spec for the revised signature |
| `OT BLOBToObject(inBLOB; ioOffset)` | `OTr_BLOBToObject` | `ioOffset` in/out semantics may require a pointer (`->`) workaround; the approach is to be finalised in Phase 6 | Provisional |
| `OT GetBLOB(inObject; inTag; outBLOB)` | `OTr_GetNewBLOB(inObject; inTag)` | Returns BLOB as function result rather than writing to an output parameter | Replaces `OT GetBLOB` entirely; see §6.1 |

### 6.3 Methods Implemented with Different Behaviour

These methods are implemented in OTr with the same or similar API, but their runtime behaviour or output differs from the ObjectTools 5.0 equivalent. Callers should review each case.

| OTr Method | OT Counterpart | Difference |
|---|---|---|
| `OTr_PutRecord` / `OTr_GetRecord` | `OT PutRecord` / `OT GetRecord` | OTr stores a **snapshot** of the record fields at the time `OTr_PutRecord` is called, serialised as a sub-object (`{ "__tableNum": N, "FieldName": value, ... }`). Pictures and BLOBs are stored as inline Base64 strings. `OTr_GetRecord` restores the snapshot into the current record without any database I/O; modifications to the record after `OTr_PutRecord` do not affect the stored snapshot. The legacy plugin stored a live reference to the record. |
| `OTr_ObjectToBLOB` / `OTr_ObjectToNewBLOB` / `OTr_BLOBToObject` | `OT ObjectToBLOB` / `OT ObjectToNewBLOB` / `OT BLOBToObject` | OTr uses its own binary serialisation format (`OTR1` magic bytes). Legacy OT BLOBs are **not** compatible; `OTr_BLOBToObject` will return an error and set `OK` to zero when presented with a legacy BLOB. Re-serialisation via `OTr_SaveToText` → `OTr_LoadFromText` is the recommended migration path. |
| `OTr_ObjectSize` | `OT ObjectSize` | OTr calculates size as the byte length of the JSON serialisation (`JSON Stringify`) of the object, which is an approximation. The legacy plugin reported the in-memory size of its internal structure. The two values will rarely agree. `OTr_ObjectSize` should be used for comparison and rough estimation only, not for precise memory accounting. |
| `OTr_SaveToText` / `OTr_SaveToFile` / `OTr_SaveToClipboard` | `OT SaveToText` / `OT SaveToFile` / `OT SaveToClipboard` | When the object contains BLOBs or Pictures, OTr expands `blob:N` / `pic:N` references to inline Base64 strings before serialising (`OTr_uExpandBinaries`). The resulting text representation is larger and differs structurally from the legacy format. Round-tripping through `OTr_LoadFromText` / `OTr_LoadFromFile` / `OTr_LoadFromClipboard` is safe; loading legacy OT text exports is not supported. |
| `OTr_GetBoolean` | `OT GetBoolean` | Returns an Integer (`0` or `1`) rather than a native 4D Boolean. This matches the legacy plugin's behaviour but may surprise callers expecting a Boolean expression. |
| `OTr_PutObject` / `OTr_GetObject` | `OT PutObject` / `OT GetObject` | OTr always **deep-copies** the object at storage and retrieval time. The legacy plugin used reference semantics for sub-objects in some configurations. Callers that relied on shared-reference mutation will need to use explicit `OTr_PutObject` calls to commit changes. |

---

## 7. Publishing

- [ ] All phases implemented and tested
- [ ] All TODOs above resolved
- [ ] All correctness checks above passed
- [ ] `OTr-Specification.md` version number updated
- [ ] `OTr_GetVersion` return value updated to match release version
- [ ] Git tag created for release commit
- [ ] Legacy ObjectTools plugin removed from project dependencies
