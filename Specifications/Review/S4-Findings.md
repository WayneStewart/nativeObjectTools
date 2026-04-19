# S4 — Test Coverage Audit: Findings

**Version:** 1.0
**Date:** 2026-04-11
**Author:** Claude (static review)
**Session:** S4 of the OTr Pre-Release Comprehensive Review
**Input documents:** All 24 test method `.4dm` files; phase specifications 1–10, 15, 20

---

## Executive Summary

The test suite is substantially complete for the phases that have stand-alone unit test methods (Phases 1–6, 8). Phase 15 has a sophisticated side-by-side compatibility harness. However, several significant gaps exist:

- **Phase 7 and Phase 9 have no test methods at all.** Phase 9 has no spec either.
- **`____Test_Phase_All` is critically incomplete**: it calls only Phases 15, 10, 10a, and 10b; it omits every stand-alone unit test (Phases 1–6, 8).
- **`____Test_Phase_10c` is not called from any runner**, and the call in `____Test_Phase_All` is commented out.
- Several **phase-specific scenarios** required by the S4 checklist are absent from the unit tests — most notably: `AutoCreateObjects` dotted-path creation/failure, `OTr_LoadFromText/File/Clipboard`, date/time storage-strategy confirmation, and full Phase 10 logging-behaviour verification.
- Test method quality is generally good (handle cleanup, process isolation, clear output), with the exception of `____Test_Phase_3` (one incorrect `RenameItem` assertion) and minor issues noted below.

---

## 1. Coverage Matrix

### 1.1 Phase 1 — Core Infrastructure (`____Test_Phase_1`)

| Method | Status | Notes |
|---|---|---|
| `OTr_GetVersion` | ✅ Tested | Non-empty check only |
| `OTr_Register` | ✅ Tested | Return value = 1 |
| `OTr_CompiledApplication` | ✅ Tested | 0 or 1 check |
| `OTr_GetOptions` / `OTr_SetOptions` | ✅ Tested | Round-trip with restore |
| `OTr_SetErrorHandler` | ✅ Tested | Chaining verified |
| `OTr_New` | ✅ Tested | Positive handle |
| `OTr_IsObject` | ✅ Tested | Valid, handle 0, invalid |
| `OTr_Copy` | ✅ Tested | Distinct handle, IsObject |
| `OTr_GetHandleList` | ✅ Tested | Count and membership |
| `OTr_Clear` | ✅ Tested | Invalidation confirmed |
| `OTr_ClearAll` | ✅ Tested | Empty list post-clear |
| **Slot reuse** | ✅ Tested | `$h3_i = $h1_i` after clear |
| **Tail trimming** | ❌ Not tested | `OTr_Clear` on trailing slot + check array shrinks |
| `OTr_LoadFromText` | ❌ Not tested | Flagged in Phase 20 TODO as potentially unimplemented |
| `OTr_LoadFromFile` | ❌ Not tested | Same |
| `OTr_LoadFromClipboard` | ❌ Not tested | Same |

**Phase 1.5** (`____Test_Phase_1_5`):

| Method | Status | Notes |
|---|---|---|
| `OTr_SaveToText` | ✅ Tested | Compact and pretty-print |
| `OTr_SaveToFile` | ✅ Tested | File readback via `Document to text` |
| `OTr_SaveToClipboard` | ✅ Tested | Pasteboard readback |
| `OTr_LoadFromText` | ❌ Not tested | No round-trip: save→load not exercised |
| `OTr_LoadFromFile` | ❌ Not tested | Same |
| `OTr_LoadFromClipboard` | ❌ Not tested | Same |

---

### 1.2 Phase 2 — Scalar Put/Get (`____Test_Phase_2`)

| Method | Status | Notes |
|---|---|---|
| `OTr_PutLong` / `OTr_GetLong` | ✅ Tested | Round-trip |
| `OTr_PutReal` / `OTr_GetReal` | ✅ Tested | Round-trip |
| `OTr_PutString` / `OTr_GetString` | ✅ Tested | Round-trip |
| `OTr_PutText` / `OTr_GetText` | ✅ Tested | Round-trip |
| `OTr_PutDate` / `OTr_GetDate` | ✅ Tested | Round-trip (current date) |
| `OTr_PutTime` / `OTr_GetTime` | ✅ Tested | Round-trip (current time) |
| `OTr_PutBoolean` / `OTr_GetBoolean` | ✅ Tested | True→1, False→0; Integer return confirmed |
| `OTr_PutObject` / `OTr_GetObject` | ✅ Tested | Handle returned; deep-copy semantics tested |
| Missing-path defaults | ✅ Tested | Long=0, Text="" |
| **AutoCreateObjects ON (dotted path)** | ❌ Not tested | Multi-level intermediate object creation not exercised |
| **AutoCreateObjects OFF (dotted path fails)** | ❌ Not tested | Error path for absent intermediate not exercised |
| **Date/Time storage strategy** | ⚠️ Indirectly tested | Round-trip passes but does not inspect the raw stored value (text vs native); does not confirm `YYYY-MM-DD` / `HH:MM:SS` format per spec §3.6 |
| `OTr_SetOptions` (AutoCreateObjects bit) | ❌ Not tested | Options not varied in Phase 2 test |

---

### 1.3 Phase 3 — Item Introspection (`____Test_Phase_3`)

| Method | Status | Notes |
|---|---|---|
| `OTr_ItemCount` | ✅ Tested | Count on embedded object |
| `OTr_ItemExists` | ✅ Tested | Existing and missing tags |
| `OTr_ItemType` | ⚠️ Partial | Only Long and Object tested; accepts type 5 or 1 (ambiguous). Text, Boolean, Real, Date, Time, Array, Picture, BLOB types not individually tested |
| `OTr_IsEmbedded` | ✅ Tested | Object item tested |
| `OTr_GetAllNamedProperties` | ✅ Tested | Count check |
| `OTr_GetNamedProperties` | ⚠️ Partial | Only Text type tested; type constant 112 hardcoded (should be cross-referenced against spec constant table) |
| `OTr_GetItemProperties` | ⚠️ Partial | Index 1 tested, name non-empty; type not validated |
| `OTr_CopyItem` | ✅ Tested | Via CompareItems |
| `OTr_CompareItems` | ✅ Tested | Returns 1 for equal |
| `OTr_RenameItem` | ❌ Incorrect test | Test checks `OTr_ItemExists($h2_i; "b.renamed")` but the method was called as `OTr_RenameItem($h2_i; "b.text"; "renamed")`. This means it checks `"b.renamed"` after renaming `"b.text"` to `"renamed"` (at the root of `$h2_i`, not `"b.renamed"`). The test will always fail or produce incorrect pass depending on path semantics. **This is a test correctness bug.** |
| `OTr_DeleteItem` | ⚠️ Dependent | Test uses `"b.renamed"` which relies on the (buggy) RenameItem above |
| `OTr_ObjectSize` | ✅ Tested | Positive value |
| `OTr_ItemType` on missing tag | ❌ Not tested | |
| `OTr_ItemList` | ❌ Not tested | Method not called; order (insertion vs alphabetical) not verified |
| `OTr_DeleteItem` on non-existent tag | ❌ Not tested | |

---

### 1.4 Phase 4 — Array Operations (`____Test_Phase_4_Arrays`)

| Method | Status | Notes |
|---|---|---|
| `OTr_PutArray` (LongInt) | ✅ Tested | |
| `OTr_PutArray` (Text) | ✅ Tested | |
| `OTr_GetArray` (LongInt) | ✅ Tested | |
| `OTr_GetArray` (Text) | ✅ Tested | |
| `OTr_SizeOfArray` | ✅ Tested | |
| `OTr_ArrayType` | ✅ Tested | |
| `OTr_ResizeArray` (grow) | ✅ Tested | |
| `OTr_ResizeArray` (shrink) | ✅ Tested | |
| `OTr_PutArrayLong` / `OTr_GetArrayLong` | ✅ Tested | Out-of-range (OK=0) and type mismatch (OK=0) tested |
| `OTr_PutArrayReal` / `OTr_GetArrayReal` | ✅ Tested | |
| `OTr_PutArrayString` / `OTr_GetArrayString` | ✅ Tested | |
| `OTr_PutArrayText` / `OTr_GetArrayText` | ✅ Tested | |
| `OTr_PutArrayDate` / `OTr_GetArrayDate` | ✅ Tested | |
| `OTr_PutArrayTime` / `OTr_GetArrayTime` | ✅ Tested | |
| `OTr_PutArrayBoolean` / `OTr_GetArrayBoolean` | ✅ Tested | |
| `OTr_InsertElement` | ✅ Tested | |
| `OTr_DeleteElement` | ✅ Tested | |
| `OTr_FindInArray` (Text) | ✅ Tested | |
| `OTr_FindInArray` (LongInt) | ✅ Tested | |
| `OTr_FindInArray` (Boolean) | ✅ Tested | |
| `OTr_FindInArray` (Date) | ✅ Tested | |
| `OTr_SortArrays` (single key, ascending) | ✅ Tested | |
| `OTr_SortArrays` (single key, descending) | ✅ Tested | |
| `OTr_SortArrays` (multi-key, mixed asc/desc, slave) | ✅ Tested | |
| `OTr_PutArrayBLOB` / `OTr_GetArrayBLOB` | ❌ Not tested in Phase 4 | Covered in Phase 8 test |
| `OTr_PutArrayPicture` / `OTr_GetArrayPicture` | ❌ Not tested in Phase 4 | Covered in Phase 8 test |
| `OTr_PutArrayPointer` / `OTr_GetArrayPointer` | ❌ Not tested in Phase 4 | Covered in Phase 8 test |
| **1-based index boundary (index 1 / last element)** | ✅ Tested | GetArrayLong at index 1 and at last index exercised |
| **Out-of-bounds (Get returns default, OK=0)** | ✅ Tested | |
| `OTr_PutArray` / `OTr_GetArray` (Boolean, Date, Time, BLOB, Picture, Pointer types) | ❌ Not tested via PutArray/GetArray | Only exercised via typed element methods in Phase 8 |

---

### 1.5 Phase 5 — Complex Types (`____Test_Phase_5`)

| Method | Status | Notes |
|---|---|---|
| `OTr_PutBLOB` / `OTr_GetBLOB` (pointer form) | ✅ Tested | Pointer-parameter round-trip; deprecation path confirmed |
| `OTr_GetNewBLOB` | ✅ Tested | Function result form |
| `OTr_PutPicture` / `OTr_GetPicture` | ✅ Tested | Synthetic picture (SET PICTURE TO JPEG); size check |
| `OTr_PutPointer` / `OTr_GetPointer` | ✅ Tested | Via `->` syntax; round-trip confirmed |
| `OTr_PutRecord` | ⚠️ Skipped | Comment in source: "no suitable test table in this project" |
| `OTr_GetRecord` | ⚠️ Skipped | Same |
| `OTr_GetRecordTable` | ⚠️ Skipped | Same |
| `OTr_PutVariable` / `OTr_GetVariable` | ✅ Tested | Cross-idiom pointer via PutVariable/GetVariable |
| `OTr_GetBLOB` deprecation warning | ✅ Tested | Pointer round-trip replaces earlier stub |
| `OTr_PutObject` / `OTr_GetObject` deep-copy | ✅ Tested | (in Phase 2 test — modify source, verify stored unchanged) |
| `OTr_GetArrayPointer` function-result signature | ❌ Not tested in Phase 5 | Covered in Phase 8 |

---

### 1.6 Phase 6 — Import/Export (`____Test_Phase_6`)

| Method | Status | Notes |
|---|---|---|
| `OTr_uMapType` | ✅ Tested | 4D→OT and OT→4D spot checks |
| `OTr_ObjectToBLOB` | ✅ Tested | Scalar round-trip |
| `OTr_ObjectToNewBLOB` | ✅ Tested | Function-result form |
| `OTr_BLOBToObject` | ✅ Tested | Scalar round-trip, invalid data error case |
| BLOB item round-trip | ✅ Tested | |
| Picture item round-trip | ✅ Tested | |
| **Legacy OT BLOB rejection (magic-byte check)** | ❌ Not tested | Spec §4.2 requires magic-byte check; `____Test_Phase_6` tests invalid data (zero BLOB) but does not test a well-formed legacy OT BLOB with mismatching magic bytes |
| **`OTr_BLOBToObject` offset parameter** | ❌ Not tested | Spec §4.2 marks offset parameter as provisional; test does not exercise non-zero offset |

---

### 1.7 Phase 7 — API Naming Alignment

**No test method exists.**

Phase 7 is a refactoring/renaming phase. All method aliases introduced (e.g. `OTr_GetString` → `OTr_PutString`, `OTr_ItemList`, etc.) are exercised through other phase tests that call those canonical names. There are no behaviour-only checks that belong exclusively to Phase 7. See §3.7 below for recommendation.

---

### 1.8 Phase 8 — Unified Array Element Accessor (`____Test_Phase_8`)

| Method | Status | Notes |
|---|---|---|
| `OTr_u_AccessArrayElement` (internal) | ✅ Tested (indirectly) | Via all typed accessor wrappers |
| `OTr_GetArrayLong` / `OTr_PutArrayLong` | ✅ Tested | |
| `OTr_GetArrayReal` / `OTr_PutArrayReal` | ✅ Tested | |
| `OTr_GetArrayString` / `OTr_PutArrayString` | ✅ Tested | |
| `OTr_GetArrayText` / `OTr_PutArrayText` | ✅ Tested | |
| `OTr_GetArrayDate` / `OTr_PutArrayDate` | ✅ Tested | |
| `OTr_GetArrayTime` / `OTr_PutArrayTime` | ✅ Tested | |
| `OTr_GetArrayBoolean` / `OTr_PutArrayBoolean` | ✅ Tested | |
| `OTr_GetArrayBLOB` / `OTr_PutArrayBLOB` | ✅ Tested | |
| `OTr_GetArrayPicture` / `OTr_PutArrayPicture` | ✅ Tested | |
| `OTr_GetArrayPointer` / `OTr_PutArrayPointer` | ✅ Tested | |
| **Invalid handle (OK=0)** | ✅ Tested | Via LongInt path |
| **Missing tag (OK=0)** | ✅ Tested | Via LongInt path |
| **Type mismatch (OK=0)** | ✅ Tested | Via LongInt path |
| **Out-of-range index (OK=0)** | ✅ Tested | Via LongInt path |
| Type-mismatch tested for all 10 types individually | ❌ Not tested | Error paths only tested once (LongInt); all others assumed |

---

### 1.9 Phase 9

**No spec document. No test method.**

Phase 9 does not appear in the Phase 20 release checklist at all. Its scope is entirely undetermined from the available documents. See §3.9 below.

---

### 1.10 Phase 10 — Logging (`____Test_Phase_10` series)

Phase 10 has twelve test methods structured as four side-by-side controller/OT/OTr triads. Their scope is as follows:

| Method set | Nature | Scope |
|---|---|---|
| `____Test_Phase_10` / `_OT` / `_OTr` | Side-by-side comparison | 9 error-condition scenarios using logically wrong calls; tests that OT and OTr produce equivalent observable results |
| `____Test_Phase_10a` / `_OT` / `_OTr` | Side-by-side comparison | Broad happy-path sweep: ~30 commands with mostly correct calls |
| `____Test_Phase_10b` / `_OT` / `_OTr` | Side-by-side comparison | Misuse suite: ~15 scenarios with invalid/wrong calls |
| `____Test_Phase_10c` / `_OT` / `_OTr` | Side-by-side comparison | Comprehensive OK=0 test: 120 error scenarios across 54 commands, three error classes each |

**Phase 10 spec behavioural requirements vs test coverage:**

| Requirement | Status | Notes |
|---|---|---|
| Worker process startup and shutdown | ❌ Not tested | Side-by-side tests do not verify log worker lifecycle; they compare OTr vs OT observable output |
| Log file created in correct directory with correct naming | ❌ Not tested | File creation is a side effect; tests do not inspect the Logs/ObjectTools directory |
| Session rotation (size threshold exceeded → new file) | ❌ Not tested | |
| Log level gating (`off` → no output, `info` → info, `debug` → debug) | ❌ Not tested | `OTr_LogLevel` getter/setter not directly tested in any method |
| Sentinel file override | ❌ Not tested | |
| `OTr_LogLevel` getter | ❌ Not tested | |
| `OTr_LogLevel` setter (session only) | ❌ Not tested | |
| `OTr_LogLevel` setter with `$permanent_b = True` (writes file) | ❌ Not tested | |
| Per-process call stack (LIFO) | ❌ Not tested | |
| Error log entry with call-stack traceback | ❌ Not tested | |
| Side-by-side: OTr vs OT equivalent observable output on error calls | ✅ Tested (Phase 10, 10b) | |
| Side-by-side: OTr vs OT equivalent observable output on happy-path calls | ✅ Tested (Phase 10a) | |
| Side-by-side: OTr vs OT OK=0 on error for all 54 commands × 3 error classes | ✅ Tested (Phase 10c) | |

**Key finding:** The Phase 10 tests are entirely side-by-side behavioural comparison tests, not unit tests of the logging subsystem itself. None of the logging-specific requirements from Phase 10 spec §§2–8 are directly exercised.

---

### 1.11 Phase 15 — Side-by-Side Compatibility (`____Test_Phase_15` series)

| Requirement | Status | Notes |
|---|---|---|
| Platform constraint noted in test method | ✅ Present | "PLATFORM NOTE: On macOS Tahoe 26.4+ …" in controller header and OT half |
| OT plugin availability check | ✅ Present | OT half marks all OT columns "Skip: plugin not available" if OT New returns 0 |
| 30 test scenarios covering all Phase 15 methods | ✅ Present | Full scenario inventory confirmed in OT and OTr halves |
| Known incompatibilities documented in test source | ✅ Present | Phase 15 spec incompatibility catalogue cross-referenced in test comments |
| `____Test_OT_Compatibility` | ⚠️ Effectively implemented | Phase 20 TODO calls for `____Test_OT_Compatibility` by that name; the actual method is `____Test_Phase_15` (same purpose, different name). The TODO should be updated or the method renamed |

---

## 2. Test Method Quality Assessment

| Test method | Handle cleanup | Output clarity | Standalone | Registry clean on exit | Notes |
|---|---|---|---|---|---|
| `____Test_Phase_1` | ✅ `OTr_ClearAll` at end | ✅ ALERT + pasteboard | ✅ | ✅ | Good |
| `____Test_Phase_1_5` | ✅ `OTr_ClearAll` at end | ✅ ALERT + pasteboard | ✅ | ✅ | Commented-out old ALERT block is dead code; harmless |
| `____Test_Phase_2` | ✅ `OTr_ClearAll` at end | ✅ ALERT + pasteboard | ✅ | ✅ | Good; also commented-out old ALERT block |
| `____Test_Phase_3` | ✅ `OTr_ClearAll` at end | ✅ ALERT + pasteboard | ✅ | ✅ | **Test correctness bug** in `RenameItem` assertion (see §1.3) |
| `____Test_Phase_4_Arrays` | ✅ `OTr_ClearAll` at end | ✅ ALERT + pasteboard | ✅ | ✅ | Good |
| `____Test_Phase_5` | ✅ `OTr_ClearAll` (inferred from header notes) | ✅ ALERT + pasteboard | ✅ | ✅ | `OTr_PutRecord/GetRecord` skipped with comment |
| `____Test_Phase_6` | ✅ | ✅ | ✅ | ✅ | Good |
| `____Test_Phase_8` | ✅ | ✅ | ✅ | ✅ | Good; error paths centralised on LongInt only |
| `____Test_Phase_10` (controller) | ✅ Accumulator cleared | ✅ Writes TSV file to Logs | ✅ | ✅ | Passes `$suppressAlert_b` flag; suitable for runner |
| `____Test_Phase_10a/b/c` (controllers) | ✅ | ✅ | ✅ | ✅ | Same structure |
| `____Test_Phase_10*_OT/OTr` (sub-methods) | N/A (no independent handles) | N/A (results via accumulator) | ❌ Require accumulator handle | N/A | By design; controller owns lifecycle |
| `____Test_Phase_15` (controller) | ✅ `OTr_Clear($accum_i)` at end | ✅ Writes TSV file to Logs | ✅ | ✅ | Good; `$suppressAlert_b` supported |
| `____Test_Phase_15_OTr` | ✅ Does not call `OTr_ClearAll` | ✅ Via accumulator | ❌ Requires accumulator | N/A | By design |
| `____Test_Phase_15_OT` | N/A | ✅ Via accumulator | ❌ Requires accumulator | N/A | By design; skip path if plugin absent |
| `____Test_Phase_All` | ✅ (delegates) | ✅ Final ALERT | ✅ | ✅ | **Critical gap**: only runs 15, 10, 10a, 10b; omits 1–6, 8 entirely; Phase 10c commented out |

---

## 3. Phase-Specific Gap Assessment (S4 Checklist Items)

### 3.1 Phase 1 / 1.5

- **Slot reuse:** ✅ Tested (`____Test_Phase_1`: clear h1, create h3, verify h3 = h1).
- **Tail trimming:** ❌ Not tested. The spec (Phase 20 Correctness Check §4) requires that clearing the trailing handle shrinks the internal array. No test exercises this.
- **`OTr_LoadFromText/File/Clipboard`:** ❌ Not tested. Phase 20 TODO flags these as potentially unimplemented. `____Test_Phase_1_5` exercises only the Save/export direction; no Load/import round-trip is present.

### 3.2 Phase 2

- **AutoCreateObjects ON (multi-level path):** ❌ Not tested. The test uses dotted paths (e.g. `"long.value"`) but never explicitly sets the `AutoCreateObjects` option bit or verifies that an intermediate object is created.
- **AutoCreateObjects OFF (path failure):** ❌ Not tested.
- **All scalar types round-tripped:** ✅ Long, Real, String, Text, Date, Time, Boolean all present.
- **Boolean as Integer (0/1):** ✅ Tested explicitly.
- **Date/Time storage strategy confirmed:** ❌ Not confirmed. Tests verify round-trip equality but do not inspect the raw stored representation. The Phase 20 correctness check and master spec §3.6 require that dates are stored as `YYYY-MM-DD` text and times as `HH:MM:SS` text. A test should use `OTr_SaveToText` and inspect the JSON to confirm the stored format.

### 3.3 Phase 3

- **`OTr_ItemType` for every type constant:** ❌ Partial. Only Long (with ambiguous acceptance of types 5 or 1) and Object tested. Text, Boolean, Real, Date, Time, Array, BLOB, Picture not individually verified.
- **`OTr_ItemType` on missing tag:** ❌ Not tested.
- **`OTr_ItemList` order:** ❌ `OTr_ItemList` is not called in any test method.
- **`OTr_DeleteItem` on non-existent tag:** ❌ Not tested.
- **RenameItem assertion bug:** The test checks `OTr_ItemExists($h2_i; "b.renamed")` after `OTr_RenameItem($h2_i; "b.text"; "renamed")`. The rename moves `"b.text"` to `"renamed"` (a top-level key within `$h2_i`), not to `"b.renamed"`. The test should check `OTr_ItemExists($h2_i; "renamed")`.

### 3.4 Phase 4 — Arrays

- **1-based index boundary:** ✅ Index 1 and last element exercised in `OTr_PutArrayLong`/`OTr_GetArrayLong`.
- **Out-of-bounds (OK=0):** ✅ Tested.
- **Multi-key sort with mixed ascending/descending:** ✅ Tested.
- **All typed array Put/Get methods round-tripped:** ✅ All 9 typed pairs (Long, Real, String, Text, Date, Time, Boolean, BLOB, Picture) covered across Phase 4 and Phase 8 tests. Pointer covered in Phase 8.

### 3.5 Phase 5 — Complex Types

- **All complex type round-trips (Phase 20 TODO):** ✅ `____Test_Phase_5` now exists and covers BLOB, Picture, Pointer, Variable. Record skipped with documented reason.
- **`OTr_GetBLOB` deprecation warning:** ✅ Exercised (pointer-form round-trip replaces earlier stub).
- **`OTr_PutObject` / `OTr_GetObject` deep-copy semantics:** ✅ Tested in `____Test_Phase_2` (modify source, verify stored unchanged).
- **Pointer round-trip with `->` syntax:** ✅ Tested.
- **`OTr_GetArrayPointer` function-result signature:** ✅ Tested in `____Test_Phase_8`.

### 3.6 Phase 6 — Import/Export

- **BLOB serialisation round-trips (Phase 20 TODO):** ✅ `____Test_Phase_6` exists and covers scalar, BLOB, and Picture round-trips.
- **Legacy OT BLOB rejection (magic-byte check):** ❌ Not tested. `____Test_Phase_6` tests an invalid/empty BLOB but does not construct a well-formed legacy OT BLOB with the correct magic signature to verify the incompatibility error fires correctly.
- **Round-trip with native BLOB and Picture:** ✅ Tested.
- **`OTr_BLOBToObject` offset parameter:** ❌ Not tested (spec marks as provisional).

### 3.7 Phase 7 — API Naming Alignment

**No test method exists.** Assessment: Phase 7 is a renaming/aliasing phase. Its verifiable component is that the new canonical names are callable and produce correct results — this is already covered by Phases 1–6 and 8, which use the Phase 7 names throughout. A separate `____Test_Phase_7` method would necessarily duplicate those tests.

**Recommendation:** No standalone `____Test_Phase_7` is required. The S2 audit (API coverage) constitutes the appropriate verification. A brief rationale comment should be added to `____Test_Phase_All` to explain the absence.

### 3.8 Phase 8 — Unified Array Element Accessor

- **All supported element types tested:** ✅ All 10 types tested.
- **Type-mismatch error behaviour:** ✅ Tested (for LongInt path; shared error logic means one representative test is sufficient, but see coverage gap for type-specific testing).

### 3.9 Phase 9

Phase 9 is intentionally absent. Phase numbers were not assigned sequentially in order to leave room for unanticipated implementation issues without requiring renumbering. Phase 9 has no spec, no implementation, and no test method. It is not a release blocker. Phase 20 §1 has been updated to document this explicitly. No further action required from the S4 perspective.

### 3.10 Phase 10 — Logging

The Phase 10 test suite is a behavioural side-by-side comparison, not a unit test of the logging subsystem. The following S4 checklist items are entirely absent:

- Worker process startup and shutdown — not tested
- Log file creation, directory, and naming convention — not tested
- Session rotation — not tested
- Log level gating (`off`, `info`, `debug`) — not tested
- Sentinel file override — not tested
- `OTr_LogLevel` getter/setter — not tested
- Per-process LIFO call stack — not tested
- Error log entry with call-stack traceback — not tested

These are significant gaps relative to the Phase 10 spec. However, some of these require filesystem access and process lifecycle inspection that are difficult to unit test in 4D. See §4 for prioritised recommendations.

### 3.11 `____Test_Phase_All`

Current content:

```4d
____Test_Phase_15(True)
____Test_Phase_10(True)
____Test_Phase_10a(True)
____Test_Phase_10b(True)
// ____Test_Phase_10c(True)
ALERT("Finished")
```

**Gaps:**

- `____Test_Phase_1` through `____Test_Phase_8` are not called at all.
- `____Test_Phase_10c` is commented out.
- The method is described in-source as "Quick and dirty test", which is accurate but insufficient for a pre-release runner.
- No fail-fast or failure-collection mechanism; ALERT fires regardless of individual results.

---

## 4. Prioritised List of Missing Tests

### Priority 1 — Must fix before release

| ID | Gap | Recommended action |
|---|---|---|
| T1 | `____Test_Phase_3`: `RenameItem` assertion checks wrong path (`"b.renamed"` should be `"renamed"`) | Fix assertion: `OTr_ItemExists($h2_i; "renamed")` and update `DeleteItem` assertion accordingly |
| T2 | `____Test_Phase_All` does not call Phases 1–6 or 8 | Add calls to all stand-alone unit test methods; uncomment Phase 10c |
| T3 | `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard` untested | Add round-trip tests to `____Test_Phase_1_5` (or a new method): save an object with known content, load it back, verify content equality |
| T4 | Date/Time storage strategy not confirmed by test | In `____Test_Phase_2`: after `OTr_PutDate`/`OTr_PutTime`, call `OTr_SaveToText` and verify the JSON contains `"YYYY-MM-DD"` / `"HH:MM:SS"` text representation |

### Priority 2 — Should fix before release

| ID | Gap | Recommended action |
|---|---|---|
| T5 | Tail-trimming not tested | In `____Test_Phase_1`: after `OTr_ClearAll`, create 3 handles, clear the last, call `OTr_GetHandleList` and assert size = 2 (not 3 with a gap). Verify internal array does not contain a trailing empty slot |
| T6 | `AutoCreateObjects` ON/OFF not tested in Phase 2 | Add to `____Test_Phase_2`: set AutoCreateObjects bit, put to multi-level path (`"a.b.c.d"`), verify all intermediates created; then clear bit, put again to a different path, verify OK=0 |
| T7 | `OTr_ItemType` tested for only 2 of 9 type constants | Extend `____Test_Phase_3` to store one value of each type and verify the corresponding OT type constant is returned |
| T8 | `OTr_ItemList` not tested at all | Add to `____Test_Phase_3`: call `OTr_ItemList`, verify returned array contains all expected keys; verify ordering |
| T9 | `OTr_DeleteItem` on non-existent tag not tested | Add negative test: delete a tag that does not exist, verify OK=0 and no crash |
| T10 | `OTr_ItemType` on missing tag not tested | Add: `OTr_ItemType` for a non-existent path; verify returned type = 0 or appropriate constant |
| T11 | Legacy OT BLOB rejection (magic-byte check) not tested | Add to `____Test_Phase_6`: construct a minimal valid legacy OT BLOB header (or use a known fixture), call `OTr_BLOBToObject`, verify error fires and OK=0 |

### Priority 3 — Recommended before release, lower risk

| ID | Gap | Recommended action |
|---|---|---|
| T12 | Phase 10 logging: `OTr_LogLevel` getter/setter not tested | Add a minimal test: call `OTr_LogLevel` with no arguments, confirm text result is one of `"off"`, `"info"`, `"debug"`; call setter with `OTR Log Debug`, verify return changes |
| T13 | Phase 10 logging: log file creation not verified | Add to a Phase 10 test: after running a command that triggers a log write, enumerate the `Logs/ObjectTools` directory and confirm at least one `.txt` file exists with the expected naming pattern |
| T14 | `OTr_BLOBToObject` offset parameter | Once spec marks offset as non-provisional, add a test exercising a non-zero start offset |
| T15 | Dead code (commented-out ALERT blocks) in Phase 1_5 and Phase 2 test methods | Remove to reduce maintenance noise |
| T16 | Phase 20 TODO for `____Test_OT_Compatibility` | Either rename `____Test_Phase_15` to `____Test_OT_Compatibility` (and update `____Test_Phase_All`) or update Phase 20 TODO to reference the current name |

---

## 5. Phase 7 — Rationale for No Standalone Test Method

Phase 7 introduces canonical API names for methods that previously had variant names (e.g. `OTr_GetString`, `OTr_PutString`, `OTr_ItemList`). There is no behaviour change — Phase 7 is purely a naming alignment. Every Phase 7 method is exercised by its primary semantic test (e.g. `OTr_GetString` is called in `____Test_Phase_2`). A standalone `____Test_Phase_7` would be either a duplicate of existing tests (unhelpful) or a shallow "can we call the method" check (insufficient). The S2 audit (which inventories every public method against the spec) is the correct verification vehicle for Phase 7 completeness. A note to this effect should be added to `____Test_Phase_All` and to Phase 20 §1.

---

## 6. Phase 5 and Phase 6 — Confirmation per Phase 20 TODO

Phase 20 TODO (at review baseline) contained:
- "Write test method `____Test_Phase_5` covering all complex type round-trips" — ✅ **Done.** `____Test_Phase_5` exists and covers BLOB, Picture, Pointer, Variable. Record skipped with documented rationale. The TODO item may be marked resolved.
- "Write test method `____Test_Phase_6` covering BLOB serialisation round-trips" — ✅ **Done.** `____Test_Phase_6` exists and covers scalar, BLOB, and Picture serialisation. The TODO item may be marked resolved.
- "Write test method `____Test_OT_Compatibility` per OTr-Phase-015-Spec.md" — ⚠️ **Effectively done** under the name `____Test_Phase_15`. The TODO item should be updated to reference the actual method name.

---

## 7. Summary Table

| Phase | Unit test exists | Test quality | Key gaps |
|---|---|---|---|
| 1 | ✅ | Good | Tail trimming; `LoadFrom*` methods |
| 1.5 | ✅ | Good | `LoadFrom*` round-trips absent |
| 2 | ✅ | Good | `AutoCreateObjects`; Date/Time storage-strategy confirmation |
| 3 | ✅ | **Test bug (RenameItem)** | Bug in assertion; `ItemList`; `ItemType` for all types; `DeleteItem` negative |
| 4 | ✅ | Good | `PutArray`/`GetArray` for BLOB/Picture/Pointer types via `PutArray` bulk form |
| 5 | ✅ | Good | `PutRecord`/`GetRecord` skipped (documented) |
| 6 | ✅ | Good | Legacy OT magic-byte rejection; offset parameter |
| 7 | ❌ (none needed) | n/a | Rationale documented above |
| 8 | ✅ | Good | Type-mismatch only tested via LongInt path |
| 9 | ❌ | n/a | Scope unknown; Phase 9 absent from Phase 20 |
| 10 | ✅ (side-by-side) | Good for its purpose | Logging subsystem unit tests entirely absent |
| 15 | ✅ | Good | Method name mismatch vs Phase 20 TODO |
| All-runner | ⚠️ Incomplete | — | Omits Phases 1–6, 8; Phase 10c commented out |
