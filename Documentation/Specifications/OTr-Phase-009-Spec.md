# OTr Phase 9 — Pre-Release Audit and Corrections

**Version:** 0.1
**Date:** 2026-04-05
**Status:** Substantially Complete
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§9)

---

## Overview

Phase 9 is a pre-release audit and corrections phase. It does not introduce new public API methods. Instead, it consolidates and resolves all outstanding items from the Release Checklist ([OTr-Phase-020-Spec.md](OTr-Phase-020-Spec.md)) §3 TODOs, identifies inconsistencies in the implementation that were discovered during development, and establishes the correct `OK` variable behaviour for every public method.

Phase 9 depends upon all preceding phases being substantially complete. No new interprocess arrays, registry changes, or public API additions are made.

---

## 1. Undocumented Methods

The following methods exist in the codebase but have no corresponding entry in any phase specification. They must be assigned to a phase, documented, and confirmed correct before release.

### 1.1 Methods Without a Specification Entry

| Method | Nature | Disposition |
|---|---|---|
| `OTr_ArrayType` | Public API — returns the stored `arrayType` constant for an array tag | Document in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md); no legacy OT equivalent |
| `OTr_SaveToBlob` | Public — serialises object to a GZIP-compressed BLOB via `VARIABLE TO BLOB` | Document in [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md) §1.5 alongside `OTr_SaveToGZIP` |
| `OTr_LoadFromBlob` | Public — inverse of `OTr_SaveToBlob` | As above |
| `OTr_SaveToGZIP` | Public — serialises object to UTF-8 JSON then GZIP-compresses to a BLOB | Document in [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md) §1.5 |
| `OTr_LoadFromGZIP` | Public — inverse of `OTr_SaveToGZIP` | As above |
| `OTr_uEqualObjects` | Utility — deep equality comparison of two 4D Objects | Document in [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md) alongside `OTr_uEqualBLOBs` |
| `OTr_uEqualStrings` | Utility — case/diacritical-insensitive text comparison | Document in [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md) |
| `OTr_uNewValueForEmbeddedType` | Utility — returns the default value for a given array type constant | Document in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md) |
| `OTr_zArrayFromObject` | Internal — populates a typed 4D array from an OTr array Object | Document in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md) |
| `OTr_zArrayType` | Internal — reads the `arrayType` property from an OTr array Object | Document in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md) |
| `OTr_zErrIgnore` | Internal — suppresses 4D error handling temporarily | Document in [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md) |
| `OTr_zMapType` | Internal — maps a property's native type to an OT type constant | Document in [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md); consolidates `OTr_uMapType` |
| `OTr_zSortFillSlot` | Internal — used by `OTr_SortArrays` | Document in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md) |
| `OTr_zSortSlotPointer` | Internal — used by `OTr_SortArrays` | Document in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md) |
| `OTr_zSortValidatePair` | Internal — used by `OTr_SortArrays` | Document in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md) |
| `OTr_z_Koala` | Internal — purpose to be confirmed with developer | Confirm and document |
| `OTr_z_Wombat` | Internal — purpose to be confirmed with developer | Confirm and document |

### 1.2 Note on `OTr_SaveToBlob` vs `OTr_ObjectToBLOB`

`OTr_ObjectToBLOB` and `OTr_SaveToBlob` are **not** equivalent. `OTr_ObjectToBLOB` uses `VARIABLE TO BLOB` with GZIP compression and takes a Pointer to a BLOB because 4D passes BLOBs by value. `OTr_SaveToBlob` and `OTr_SaveToGZIP` are the Phase 1.5 additions: `OTr_SaveToGZIP` serialises to UTF-8 JSON before GZIP-compressing (portable), whereas `OTr_ObjectToBLOB` serialises via `VARIABLE TO BLOB` (4D-internal format only). These must be clearly differentiated in documentation and testing.

---

## 2. `OK` Variable Behaviour

### 2.1 Background

The legacy ObjectTools plugin sets the 4D `OK` system variable on error, mirroring the 4D convention for commands that can fail. OTr replicates this via `OTr_zSetOK`, which both sets `OK` in the current process and (once implemented) propagates the value to a host database's `OK` when running as a component.

Audit of the source code reveals three distinct patterns in current use:

**Pattern A — Sets `OK` to 0 on error only (no explicit 1 on success).** `OK` is left at its pre-call value on success. This is appropriate for commands that the legacy OT manual states do not affect `OK`.

**Pattern B — Sets `OK` to 1 on success and 0 on error.** This is appropriate for commands that the legacy OT manual explicitly documents as setting `OK`.

**Pattern C — Does not call `OTr_zSetOK` at all.** Either correct (the legacy command did not affect `OK`) or an omission requiring correction.

The problem with Pattern A applied to commands that *should* set `OK` to 1 is that a prior error in the same execution flow will leave `OK` at 0, giving the false impression that the successful call failed. `OTr_ItemType`, `OTr_GetString`, and `OTr_ObjectSize` all received retrospective `OTr_zSetOK(1)` additions (recorded in their method headers) after this was discovered in testing.

### 2.2 Legacy OT `OK` Behaviour — Definitive Reference

The table below records, for every public OTr method with a legacy OT counterpart, whether the legacy OT command sets `OK`. The determination is drawn from the *ObjectTools 5 Reference* documentation embedded in the method headers. Where the documentation is silent, the 4D convention is applied: commands that can fail due to an invalid handle or missing item set `OK`; pure query functions that never error (or always return a sentinel value) do not.

Methods with no legacy OT counterpart (OTr additions) follow the convention of setting `OK` when they have a meaningful failure mode.

| OTr Method | Legacy Command | Sets OK to 1 on success? | Sets OK to 0 on error? | Notes |
|---|---|:---:|:---:|---|
| `OTr_New` | `OT New` | — | — | No documented OK behaviour; `OTr_New` always succeeds |
| `OTr_Clear` | `OT Clear` | — | ✅ | Error on invalid handle; OK on error only |
| `OTr_ClearAll` | `OT ClearAll` | — | — | Always succeeds |
| `OTr_Copy` | `OT Copy` | — | ✅ | Returns 0 on error; should set OK to 0 |
| `OTr_GetVersion` | `OT GetVersion` | — | — | Always succeeds |
| `OTr_Register` | `OT Register` | — | — | No-op; always succeeds |
| `OTr_CompiledApplication` | `OT CompiledApplication` | — | — | Always succeeds |
| `OTr_SetErrorHandler` | `OT SetErrorHandler` | — | — | Always succeeds |
| `OTr_GetOptions` | `OT GetOptions` | — | — | Always succeeds |
| `OTr_SetOptions` | `OT SetOptions` | — | — | Always succeeds |
| `OTr_GetHandleList` | `OT GetHandleList` | — | — | Always succeeds |
| `OTr_IsObject` | `OT IsObject` | — | — | Returns 0/1; never errors |
| `OTr_ItemCount` | `OT ItemCount` | — | ✅ | Error on invalid handle |
| `OTr_ObjectSize` | `OT ObjectSize` | ✅ | ✅ | Documented as setting OK; already fixed |
| `OTr_PutLong` | `OT PutLong` | — | ✅ | Error on invalid handle only |
| `OTr_PutReal` | `OT PutReal` | — | ✅ | As above |
| `OTr_PutString` | `OT PutString` | — | ✅ | As above |
| `OTr_PutText` | `OT PutText` | — | ✅ | As above |
| `OTr_PutDate` | `OT PutDate` | — | ✅ | As above |
| `OTr_PutTime` | `OT PutTime` | — | ✅ | As above |
| `OTr_PutBoolean` | `OT PutBoolean` | — | ✅ | As above |
| `OTr_PutObject` | `OT PutObject` | — | ✅ | As above |
| `OTr_PutPointer` | `OT PutPointer` | — | ✅ | As above; already calls `OTr_zSetOK(0)` |
| `OTr_PutBLOB` | `OT PutBLOB` | — | ✅ | As above; already calls `OTr_zSetOK(0)` |
| `OTr_PutPicture` | `OT PutPicture` | — | ✅ | As above; already calls `OTr_zSetOK(0)` |
| `OTr_PutRecord` | `OT PutRecord` | — | ✅ | As above; already calls `OTr_zSetOK(0)` |
| `OTr_PutVariable` | `OT PutVariable` | — | ✅ | As above; already calls `OTr_zSetOK(0)` |
| `OTr_GetLong` | `OT GetLong` | — | ✅ | Error on invalid handle; silent on missing tag |
| `OTr_GetReal` | `OT GetReal` | — | ✅ | As above |
| `OTr_GetString` | `OT GetString` | ✅ | ✅ | Sets OK 1 on success — confirmed per source comment |
| `OTr_GetText` | `OT GetText` | ✅ | ✅ | Delegates to `OTr_GetString`; inherits its OK behaviour |
| `OTr_GetDate` | `OT GetDate` | — | ✅ | Error on invalid handle; silent on missing tag |
| `OTr_GetTime` | `OT GetTime` | — | ✅ | As above |
| `OTr_GetBoolean` | `OT GetBoolean` | — | ✅ | As above |
| `OTr_GetObject` | `OT GetObject` | — | ✅ | Returns 0 on error |
| `OTr_GetPointer` | `OT GetPointer` | — | ✅ | Already calls `OTr_zSetOK(0)` on error |
| `OTr_GetBLOB` | `OT GetBLOB` | — | ✅ | Stub — always calls `OTr_zSetOK(0)` (not implemented) |
| `OTr_GetNewBLOB` | `OT GetNewBLOB` | — | ✅ | Already calls `OTr_zSetOK(0)` |
| `OTr_GetPicture` | `OT GetPicture` | — | ✅ | Already calls `OTr_zSetOK(0)` |
| `OTr_GetRecord` | `OT GetRecord` | — | ✅ | Already calls `OTr_zSetOK(0)` |
| `OTr_GetRecordTable` | `OT GetRecordTable` | — | ✅ | Already calls `OTr_zSetOK(0)` |
| `OTr_GetVariable` | `OT GetVariable` | — | ✅ | Already calls `OTr_zSetOK(0)` |
| `OTr_ItemExists` | `OT ItemExists` | — | ✅ | Error on invalid handle; no error on missing tag (query) |
| `OTr_ItemType` | `OT ItemType` | ✅ | ✅ | Already fixed; sets OK 1 on success |
| `OTr_IsEmbedded` | `OT IsEmbedded` | — | ✅ | Error on invalid handle |
| `OTr_GetItemProperties` | `OT GetItemProperties` | — | ✅ | Error on invalid handle |
| `OTr_GetNamedProperties` | `OT GetNamedProperties` | — | ✅ | Error on invalid handle |
| `OTr_GetAllProperties` | `OT GetAllProperties` | — | ✅ | Error on invalid handle |
| `OTr_GetAllNamedProperties` | `OT GetAllNamedProperties` | — | ✅ | Error on invalid handle |
| `OTr_CopyItem` | `OT CopyItem` | ✅ | ✅ | Already fixed; sets OK 1 on success |
| `OTr_CompareItems` | `OT CompareItems` | — | ✅ | Returns –1 on error; no explicit OK 1 needed |
| `OTr_RenameItem` | `OT RenameItem` | — | ✅ | Error on invalid handle |
| `OTr_DeleteItem` | `OT DeleteItem` | ✅ | ✅ | Already fixed; sets OK 1 on success |
| `OTr_PutArray` | `OT PutArray` | — | ✅ | Error on invalid handle |
| `OTr_GetArray` | `OT GetArray` | — | ✅ | Error on invalid handle |
| `OTr_PutArrayLong` | `OT PutArrayLong` | — | ✅ | Error only |
| `OTr_GetArrayLong` | `OT GetArrayLong` | — | ✅ | Error only |
| `OTr_PutArrayReal` | `OT PutArrayReal` | — | ✅ | Error only |
| `OTr_GetArrayReal` | `OT GetArrayReal` | — | ✅ | Error only |
| `OTr_PutArrayString` | `OT PutArrayString` | — | ✅ | Error only |
| `OTr_GetArrayString` | `OT GetArrayString` | — | ✅ | Error only |
| `OTr_PutArrayText` | `OT PutArrayText` | — | ✅ | Error only |
| `OTr_GetArrayText` | `OT GetArrayText` | — | ✅ | Error only |
| `OTr_PutArrayDate` | `OT PutArrayDate` | — | ✅ | Error only |
| `OTr_GetArrayDate` | `OT GetArrayDate` | — | ✅ | Error only |
| `OTr_PutArrayTime` | `OT PutArrayTime` | — | ✅ | Error only |
| `OTr_GetArrayTime` | `OT GetArrayTime` | — | ✅ | Error only |
| `OTr_PutArrayBoolean` | `OT PutArrayBoolean` | — | ✅ | Error only |
| `OTr_GetArrayBoolean` | `OT GetArrayBoolean` | — | ✅ | Error only |
| `OTr_PutArrayBLOB` | `OT PutArrayBLOB` | — | ✅ | Error only |
| `OTr_GetArrayBLOB` | `OT GetArrayBLOB` | — | ✅ | Error only |
| `OTr_PutArrayPicture` | `OT PutArrayPicture` | — | ✅ | Error only |
| `OTr_GetArrayPicture` | `OT GetArrayPicture` | — | ✅ | Error only |
| `OTr_PutArrayPointer` | `OT PutArrayPointer` | — | ✅ | Error only |
| `OTr_GetArrayPointer` | `OT GetArrayPointer` | — | ✅ | Error only |
| `OTr_SizeOfArray` | `OT SizeOfArray` | — | ✅ | Error on invalid handle or non-array tag |
| `OTr_ResizeArray` | `OT ResizeArray` | — | ✅ | Already calls `OTr_zSetOK(0)` on error |
| `OTr_InsertElement` | `OT InsertElement` | — | ✅ | Error on invalid handle |
| `OTr_DeleteElement` | `OT DeleteElement` | — | ✅ | Error on invalid handle |
| `OTr_FindInArray` | `OT FindInArray` | — | ✅ | Sets OK to 0 on error; 1 when found (–1 result is not an error) |
| `OTr_SortArrays` | `OT SortArrays` | — | ✅ | Already calls `OTr_zSetOK(0)` on error |
| `OTr_ObjectToBLOB` | `OT ObjectToBLOB` | ✅ | ✅ | Already calls both; confirmed |
| `OTr_ObjectToNewBLOB` | `OT ObjectToNewBLOB` | — | ✅ | Error on invalid handle |
| `OTr_BLOBToObject` | `OT BLOBToObject` | ✅ | ✅ | Already calls both; confirmed |
| `OTr_ArrayType` | *(OTr addition)* | — | ✅ | Returns –1 on error; no explicit OK needed |
| `OTr_SaveToText` | *(OTr addition)* | — | — | Always succeeds if handle valid; error returns empty |
| `OTr_SaveToFile` | *(OTr addition)* | — | ✅ | File I/O can fail |
| `OTr_SaveToClipboard` | *(OTr addition)* | — | — | Always succeeds |
| `OTr_SaveToBlob` | *(OTr addition)* | — | — | Returns empty BLOB on failure; no OK signal needed |
| `OTr_SaveToGZIP` | *(OTr addition)* | — | — | Returns empty BLOB on failure; no OK signal needed |
| `OTr_LoadFromText` | *(OTr addition)* | — | ✅ | Returns 0 on parse failure |
| `OTr_LoadFromFile` | *(OTr addition)* | — | ✅ | File I/O can fail |
| `OTr_LoadFromClipboard` | *(OTr addition)* | — | ✅ | Returns 0 on parse failure |
| `OTr_LoadFromBlob` | *(OTr addition)* | — | ✅ | Returns 0 on failure |
| `OTr_LoadFromGZIP` | *(OTr addition)* | — | ✅ | Returns 0 on failure |

### 2.3 Current OK Gaps — Methods Requiring `OTr_zSetOK(0)` on Error That Do Not Yet Call It

Cross-referencing §2.2 against the source audit, the following public methods have error paths (invalid handle, type mismatch, or other failure condition) but do not currently call `OTr_zSetOK(0)`. Each must be corrected:

| Method | Missing call | Notes |
|---|---|---|
| `OTr_Clear` | `OTr_zSetOK(0)` on invalid handle | Source calls `OTr_zError` but not `OTr_zSetOK` |
| `OTr_Copy` | `OTr_zSetOK(0)` on invalid handle | Returns 0 but `OK` is not set |
| `OTr_ItemCount` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_PutLong` | `OTr_zSetOK(0)` on invalid handle | Common pattern: all scalar Put methods |
| `OTr_PutReal` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_PutString` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_PutDate` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_PutTime` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_PutBoolean` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_PutObject` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetLong` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetReal` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetDate` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetTime` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetBoolean` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetObject` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_ItemExists` | `OTr_zSetOK(0)` on invalid handle | Missing tag is not an error |
| `OTr_IsEmbedded` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetItemProperties` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetNamedProperties` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetAllProperties` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetAllNamedProperties` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_CompareItems` | `OTr_zSetOK(0)` on invalid handle or type mismatch | Returns –1; `OK` should also be set |
| `OTr_RenameItem` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_PutArray` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_GetArray` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_PutArrayLong` | `OTr_zSetOK(0)` on any failure | Via `OTr_u_AccessArrayElement` |
| `OTr_GetArrayLong` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayReal` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayReal` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayString` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayString` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayText` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayText` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayDate` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayDate` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayTime` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayTime` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayBoolean` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayBoolean` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayBLOB` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayBLOB` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayPicture` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayPicture` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_PutArrayPointer` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_GetArrayPointer` | `OTr_zSetOK(0)` on any failure | As above |
| `OTr_SizeOfArray` | `OTr_zSetOK(0)` on invalid handle or non-array tag | |
| `OTr_InsertElement` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_DeleteElement` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_ObjectToNewBLOB` | `OTr_zSetOK(0)` on invalid handle | |
| `OTr_LoadFromText` | `OTr_zSetOK(0)` on parse failure | |
| `OTr_LoadFromFile` | `OTr_zSetOK(0)` on file or parse failure | |
| `OTr_LoadFromClipboard` | `OTr_zSetOK(0)` on parse failure | |
| `OTr_LoadFromBlob` | `OTr_zSetOK(0)` on decode failure | |
| `OTr_LoadFromGZIP` | `OTr_zSetOK(0)` on decode failure | |

### 2.4 Note on `OTr_u_AccessArrayElement` and the Per-Element Array Methods

The per-element array methods (`OTr_PutArrayLong`, `OTr_GetArrayLong`, etc.) all delegate to `OTr_u_AccessArrayElement`. If `OTr_zSetOK(0)` is added to `OTr_u_AccessArrayElement`'s error paths, all delegating methods inherit correct `OK` behaviour without individual modification. Confirm whether `OTr_u_AccessArrayElement` is a utility method (no lock, no OK) or a thin public delegator before deciding where to place the `OTr_zSetOK` calls.

---

## 3. Parameter Naming Corrections

### 3.1 Stray `_p` Suffix in Source Files

The `_p` suffix is ambiguous — it was historically used for both Pointer and Picture. The authoritative convention (per [OTr-Types-Reference.md](OTr-Types-Reference.md)) is `_ptr` for Pointer and `_pic` for Picture. The following source files contain the stray suffix and must be corrected:

| File | Current | Correct |
|---|---|---|
| `OTr_uPointerToText.4dm` | `$thePointer_p` | `$thePointer_ptr` |
| `OTr_uTextToPointer.4dm` | `$thePointer_p` (in comment) | `$thePointer_ptr` |
| `OTr_PutArrayPointer.4dm` | `$value_p` | `$value_ptr` |
| `OTr_GetArrayPointer.4dm` | `$value_p` | `$value_ptr` |
| `OTr_zSortSlotPointer.4dm` | `$ptr_p` | `$result_ptr` (or `$ptr_ptr` if semantically appropriate) |

### 3.2 Stray `_p` / `_x` Suffix in Spec Documents

| File | Location | Current | Correct |
|---|---|---|---|
| `OTr-Phase-004-Spec.md` | `OTr_uPointerToText` signature | `$thePointer_p` | `$thePointer_ptr` |
| `OTr-Phase-004-Spec.md` | `OTr_PutArrayPointer` / `OTr_GetArrayPointer` | `$value_p` | `$value_ptr` |

---

## 4. Implementation Checks

The following items from the Release Checklist §3 require implementation work, not merely documentation:

### 4.1 `OTr_zSetOK` — Component Host Propagation

The `OTr_zSetOK` method currently contains a placeholder comment: `// Alert HOST database — Still to be written`. For deployment as a component, `OK` must be propagated to the host database's process `OK` variable. This is the primary outstanding infrastructure gap. The propagation mechanism must be implemented and tested before release.

**Approach:** When running as a component (`Is compiled` may not be the correct test — check whether the method is executing in a component context), execute a method named `OTr_zSetOK_Host` (or equivalent twin) in the host database via `EXECUTE METHOD`. The host twin simply does `OK:=$newOK`. This is the standard 4D component pattern for propagating `OK`.

### 4.2 Phase 1.5 Load Methods

Confirm that `OTr_LoadFromText`, `OTr_LoadFromFile`, and `OTr_LoadFromClipboard` are fully implemented. The source file listing confirms they exist; their correctness must be verified against the Phase 1.5 specification in [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md).

### 4.3 Test Methods

The following test methods are required but not yet confirmed as written:

- `____Test_Phase_5` — complex type round-trips (Pointer, BLOB, Picture, Record, Variable)
- `____Test_Phase_6` — BLOB serialisation/deserialisation round-trips (`OTr_ObjectToBLOB` / `OTr_BLOBToObject`)
- `____Test_OT_Compatibility` — per [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md)

---

## 5. Structural Audit Checklist

The following is the working checklist for Phase 9 implementation. Each item must be checked off before the release gate in [OTr-Phase-020-Spec.md](OTr-Phase-020-Spec.md) §6 can be satisfied.

### 5.1 `OK` Variable Corrections

- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_Clear`
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_Copy`
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_ItemCount`
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in all scalar Put methods: `OTr_PutLong`, `OTr_PutReal`, `OTr_PutString`, `OTr_PutDate`, `OTr_PutTime`, `OTr_PutBoolean`, `OTr_PutObject`
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in all scalar Get methods: `OTr_GetLong`, `OTr_GetReal`, `OTr_GetDate`, `OTr_GetTime`, `OTr_GetBoolean`, `OTr_GetObject`
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_ItemExists` (missing tag is NOT an error)
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_IsEmbedded`
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_GetItemProperties`, `OTr_GetNamedProperties`, `OTr_GetAllProperties`, `OTr_GetAllNamedProperties`
- [ ] Add `OTr_zSetOK(0)` to error paths in `OTr_CompareItems` (invalid handle; type mismatch)
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_RenameItem`
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_PutArray` and `OTr_GetArray`
- [ ] Add `OTr_zSetOK(0)` to error paths in `OTr_SizeOfArray` (invalid handle; non-array tag)
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_InsertElement` and `OTr_DeleteElement`
- [ ] Add `OTr_zSetOK(0)` to the invalid-handle error path in `OTr_ObjectToNewBLOB`
- [ ] Add `OTr_zSetOK(0)` to failure paths in `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard`, `OTr_LoadFromBlob`, `OTr_LoadFromGZIP`
- [ ] Resolve whether `OTr_zSetOK(0)` belongs in `OTr_u_AccessArrayElement` (covering all per-element array methods) or in each per-element method individually

### 5.2 Parameter Naming

- [ ] Fix `$thePointer_p` → `$thePointer_ptr` in `OTr_uPointerToText.4dm`
- [ ] Fix `$thePointer_p` comment → `$thePointer_ptr` in `OTr_uTextToPointer.4dm`
- [ ] Fix `$value_p` → `$value_ptr` in `OTr_PutArrayPointer.4dm`
- [ ] Fix `$value_p` → `$value_ptr` in `OTr_GetArrayPointer.4dm`
- [ ] Fix `$ptr_p` → `$result_ptr` (or confirm correct name) in `OTr_zSortSlotPointer.4dm`
- [ ] Fix `$thePointer_p` → `$thePointer_ptr` in `OTr-Phase-004-Spec.md` (OTr_uPointerToText section)
- [ ] Fix `$value_p` → `$value_ptr` in `OTr-Phase-004-Spec.md` (OTr_PutArrayPointer / OTr_GetArrayPointer section)

### 5.3 Undocumented Methods

- [ ] Document `OTr_ArrayType` in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md)
- [ ] Document `OTr_SaveToBlob` / `OTr_LoadFromBlob` in [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md) §1.5
- [ ] Document `OTr_SaveToGZIP` / `OTr_LoadFromGZIP` in [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md) §1.5
- [ ] Document `OTr_uEqualObjects` and `OTr_uEqualStrings` in [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md)
- [ ] Document `OTr_uNewValueForEmbeddedType` in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md)
- [ ] Document `OTr_zArrayFromObject`, `OTr_zArrayType` in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md)
- [ ] Document `OTr_zErrIgnore` in [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md)
- [ ] Document `OTr_zMapType` in [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md)
- [ ] Document `OTr_zSortFillSlot`, `OTr_zSortSlotPointer`, `OTr_zSortValidatePair` in [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md)
- [ ] Confirm purpose of `OTr_z_Koala` and `OTr_z_Wombat` with developer; document or remove

### 5.4 Infrastructure

- [ ] Implement `OTr_zSetOK` host-database propagation (§4.1)
- [ ] Confirm `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard` are correct (§4.2)
- [ ] Register all undocumented methods in the correct group in `Project/Sources/folders.json`

### 5.5 Headers and Attributes

- [ ] Confirm `%attributes` line is correct on every method (`"invisible":true`, correct `"shared"` value)
- [ ] Confirm documentation header in every `.4dm` follows the standard defined in [OTr-Phase-007-Spec.md](OTr-Phase-007-Spec.md)
- [ ] Confirm `OTr_zInit` is called (lazily) at the top of every public method

### 5.6 Semaphore Discipline

- [ ] Confirm the semaphore is released on every exit path in all public methods — including error paths that call `OTr_zSetOK(0)` before `OTr_zUnlock`. Note: `OTr_ObjectToBLOB` was observed to call `OTr_zSetOK(0)` and `OTr_zUnlock` in a specific order on the error path — verify this pattern is applied consistently

---

## 6. Cross-Reference Index

| OTr Method | Category | Phase 9 Action |
|---|---|---|
| `OTr_Clear` | Core | Add `OTr_zSetOK(0)` |
| `OTr_Copy` | Core | Add `OTr_zSetOK(0)` |
| `OTr_ItemCount` | Info | Add `OTr_zSetOK(0)` |
| `OTr_PutLong` … `OTr_PutObject` | Scalar Put | Add `OTr_zSetOK(0)` |
| `OTr_GetLong` … `OTr_GetObject` | Scalar Get | Add `OTr_zSetOK(0)` |
| `OTr_ItemExists` | Info | Add `OTr_zSetOK(0)` (invalid handle only) |
| `OTr_IsEmbedded` | Info | Add `OTr_zSetOK(0)` |
| `OTr_GetItemProperties` … `OTr_GetAllNamedProperties` | Info | Add `OTr_zSetOK(0)` |
| `OTr_CompareItems` | Utility | Add `OTr_zSetOK(0)` |
| `OTr_RenameItem` | Utility | Add `OTr_zSetOK(0)` |
| `OTr_PutArray`, `OTr_GetArray` | Array | Add `OTr_zSetOK(0)` |
| `OTr_SizeOfArray` | Array | Add `OTr_zSetOK(0)` |
| `OTr_InsertElement`, `OTr_DeleteElement` | Array | Add `OTr_zSetOK(0)` |
| Per-element array methods (×24) | Array | Via `OTr_u_AccessArrayElement` or individually |
| `OTr_ObjectToNewBLOB` | Export | Add `OTr_zSetOK(0)` |
| `OTr_LoadFrom*` (×5) | Import | Add `OTr_zSetOK(0)` |
| `OTr_uPointerToText` | Utility | Rename `$thePointer_ptr` |
| `OTr_uTextToPointer` | Utility | Rename `$thePointer_ptr` in comment |
| `OTr_PutArrayPointer` | Array | Rename `$value_ptr` |
| `OTr_GetArrayPointer` | Array | Rename `$value_ptr` |
| `OTr_zSortSlotPointer` | Internal | Rename `$result_ptr` |
| `OTr_zSetOK` | Internal | Implement host propagation |
| Undocumented methods (×17) | Various | Document or confirm |
