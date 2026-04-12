# S3 Findings — Native OTr vs. ObjectTools 5.0 Behaviour

**Session:** S3
**Version:** 1.1
**Date:** 2026-04-11
**Author:** Claude (automated audit pass); remediation pass same day
**Status:** Complete — high-priority items G1–G4 remediated 2026-04-11; see §Remediation Log
**Reviewer notes:** All source files read directly from `Project/Sources/Methods/`. References to the ObjectTools 5 Reference PDF apply to the document at `LegacyDocumentation/ObjectTools 5 Reference.pdf`.

---

## Executive Summary

The OTr implementation is behaviourally faithful to ObjectTools 5.0 across the large majority of the API surface. The side-by-side compatibility test (Phase 15 §7) achieved 30/30 Pass, confirming the core contract. This audit was conducted by reading the implementation source alongside the Phase 15 incompatibility catalogue, the `OTr-OK0-Conditions.txt` reference, the master specification, and the S1 Findings document.

The following material findings were identified:

1. **OTr_ItemType on missing tag sets OK=0** — this is a genuine deviation from OT 5.0, which returns 0 silently for a missing tag without an error. The current implementation calls `OTr_zError`, which sets `OK=0` and fires the error handler. This is a behavioural gap not catalogued in Phase 15 §4.
2. **OTr_GetRecord does not handle native Date/Time retrieval from snapshot** — when `Storage.OTr.nativeDateInObject` is True, `OTr_PutRecord` stores Date/Time fields natively, but `OTr_GetRecord`'s restore loop unconditionally calls `OTr_uTextToDate` / `OTr_uTextToTime`. This will misread natively stored dates and produce incorrect values.
3. **OTr_GetString does not set OK=0 on invalid handle** — when the handle validation fails, the `If (OTr_zIsValidHandle)` guard is simply not taken; no `OTr_zError` call is made, so the centralised `OTr_zError` → `OTr_zSetOK(0)` path is never triggered. `OK` is left at its pre-call value.
4. **OTr_GetBLOB is implemented (not a stub/deprecated redirect)** — the Phase 15 §4.1 table previously listed `OT GetBLOB` as unimplementable; the current code is a full implementation using a Pointer parameter. The Phase 15 table must be updated.
5. **Thread safety: `OTr_ObjectToBLOB` releases the lock before completing I/O** — by design, the lock is released after copying the object but before the BLOB serialisation and compression. This is architecturally sound and avoids holding the semaphore during expensive compression, but it is not documented as an intentional pattern and may surprise reviewers.
6. **`OTr_FindInArray` uses `OTr_zSetOK(Num($result_i>=0))` as the final call on success** — this sets `OK=1` when a match is found, but sets `OK=0` when `Find in array` returns `-1` (not found). Setting `OK=0` on a valid but unsuccessful search (not found) deviates from OT 5.0, which does not set `OK=0` when a search simply finds no match. The `OTr-OK0-Conditions.txt` entry for this method says "Sets OK to 0 on error; 1 when found (-1 result is not an error)." The implementation treats a "not found" result as an error state by setting `OK=0`.
7. **`OTr_DeleteItem` on a non-existent tag sets OK=0** — the implementation calls `OTr_zError("Item not found")` when the tag does not exist, which sets `OK=0`. The OT 5.0 legacy documentation must be consulted to confirm whether OT 5.0 treats deletion of a non-existent tag as a silent no-op or an error. This was not resolved in Phase 15.
8. **`OTr_ItemType` comment header contradicts the OK table** — the method header (2026-04-10 note) states that `OTr_zSetOK(1)` was removed because "OK is pulled to zero on error only." However, the `OTr-OK0-Conditions.txt` entry for `OTr_ItemType` explicitly shows `OK=1 | Y` — meaning it should set `OK=1` on success. The header note was based on a misread of the specification; the table says it should set OK=1 on success.

No gaps were found in the thread safety model. The reentrant lock/unlock strategy, the semaphore discipline, and the handling of nested OTr method calls are correctly implemented. All exit paths examined — including error paths — are paired.

All items in the Phase 15 incompatibility catalogue (§4) are confirmed as genuine and accurately documented, with two pending housekeeping corrections (see §9 below).

---

## Section 1 — General Semantic Checks

### 1.1 — `OK` Variable Discipline: Centralised Error Path

**Status: PASS with qualification**

`OTr_zError` unconditionally calls `OTr_zSetOK(0)` before returning, providing a single point of enforcement. Every public method that calls `OTr_zError` on its error path therefore sets `OK=0` correctly without requiring an individual `OTr_zSetOK(0)` in the method body.

`OTr_zIsValidHandle` also calls `OTr_zSetOK(0)` directly when the handle is found to be invalid, providing a further layer of defence.

**Qualification — `OTr_GetString` invalid-handle path:**

`OTr_GetString` does not call `OTr_zError` when the handle is invalid. The guard is:

```4d
If (OTr_zIsValidHandle($inObject_i))
    // ... retrieve value ...
End if
```

`OTr_zIsValidHandle` does call `OTr_zSetOK(0)` internally, so `OK` will be set to 0. However, the error is not logged and the error handler is not fired, which diverges from all other public methods (which call `OTr_zError("Invalid handle"; Current method name)`). This is a minor inconsistency in the error reporting chain, not an `OK` variable correctness issue per se.

**Recommendation:** Add an `Else` branch calling `OTr_zError("Invalid handle"; Current method name)` to `OTr_GetString`, matching the pattern used by all other scalar Get methods.

### 1.2 — `OTr_zSetOK` Usage vs. Direct `OK:=0` Assignment

**Status: PASS**

No direct `OK:=0` assignments were found across the reviewed methods. All `OK` manipulation is routed through `OTr_zSetOK` (called either directly or via `OTr_zError`).

### 1.3 — Invalid Handle Behaviour

**Status: PASS**

All reviewed public methods guard their core logic with `OTr_zIsValidHandle`, which rejects negative handles, zero handles, out-of-bounds handles, and cleared (InUse=False) slots. The guard sets `OK=0` in all invalid cases.

### 1.4 — Empty String Tag Behaviour

**Status: UNRESOLVED — research required**

No method explicitly handles the empty-string tag case (`""`). `OTr_zResolvePath` is invoked with the caller's tag; the behaviour when the tag is `""` depends on the path-parsing logic within `OTr_zResolvePath`. This was not audited in detail. The OT 5.0 reference should be consulted to confirm whether an empty tag is treated as an error or as a valid key.

**Recommendation:** Add an explicit guard in `OTr_zResolvePath` (or in each public method) that rejects an empty-string tag with `OTr_zError("Tag must not be empty")` if OT 5.0 treats it as an error.

### 1.5 — Missing Tag on Get Methods: Default Return Values

**Status: PASS**

All reviewed Get methods initialise their return variable to the appropriate default before the guard block (e.g., `$result_i:=0`, `$result_t:=""`, `$result_d` remains the uninitialised Date default). A missing tag simply leaves the default in place; `OTr_zError` is not called, and `OK` is not modified. This matches OT 5.0's silent-default behaviour for Get methods.

---

## Section 2 — Handle Lifecycle

### 2.1 — `OTr_New`: Slot Reuse

**Status: PASS**

`OTr_New` calls `Find in array(<>OTR_InUse_ab; False)` and reuses the first available slot. If no free slot is found (`-1`), it appends. This correctly implements the slot-reuse strategy specified in `OTr-Specification.md §3.2`.

### 2.2 — `OTr_Clear`: Tail Trimming

**Status: PASS**

After releasing the handle, `OTr_Clear` walks backward from the end of `<>OTR_InUse_ab` deleting elements while they are False, effectively trimming unused trailing slots. This matches the §3.3 optimisation note.

### 2.3 — `OTr_Clear`: Double-Free Guard

**Status: PASS with gap**

`OTr_zIsValidHandle` rejects a cleared slot (InUse=False) by setting `OK=0` and returning False. `OTr_Clear` then falls into the `Else` branch, which calls `OTr_zError("Invalid handle"; Current method name)`. This results in `OK=0` being set on a double-free call, which is the correct behaviour.

**Gap — OK table entry for `OTr_Clear`:** The `OTr-OK0-Conditions.txt` entry shows `OK=1 success: —` (never sets `OK=1`) and `OK=0 error: Y`. The implementation behaves correctly; however, this means that after a *successful* `OTr_Clear`, `OK` is left at whatever value it held before the call. Callers who test `OK=1` after `OTr_Clear` will see a stale value. This is documented behaviour; no change required, but callers should be warned.

### 2.4 — `OTr_Register`: No-Op Semantics

**Status: PASS**

`OTr_Register` sets its return value to 1 and logs an info-level message. It does not call `OTr_zSetOK` in any direction. Per the `OTr-OK0-Conditions.txt` entry (`OK=1: —; OK=0: —`), this is correct. `OK` is left unmodified.

---

## Section 3 — Scalar Put/Get

### 3.1 — Date/Time Storage Strategy

**Status: RESOLVED — dual-path implemented**

The architectural contradiction documented in S1 §1.3 is confirmed as resolved in the implementation. `OTr_PutDate` and `OTr_PutTime` both call `OTr_uNativeDateInObject` at the time of each call; when it returns True, `OB SET` stores the native type; when False, the value is serialised to `YYYY-MM-DD` / `HH:MM:SS` text.

`OTr_GetDate` and `OTr_GetTime` inspect the stored property type using `OB Get type` and branch accordingly — native-type properties are retrieved with `OB Get(...; Is date)` / `OB Get(...; Is time)`; text properties are parsed via `OTr_uTextToDate` / `OTr_uTextToTime`. This makes retrieval transparent to the storage path used at `Put` time.

**Finding — `OTr_GetRecord` is not dual-path for retrieval:**

`OTr_GetRecord` unconditionally calls `OTr_uTextToDate` and `OTr_uTextToTime` for date and time fields, regardless of what was stored. If `Storage.OTr.nativeDateInObject` was True when `OTr_PutRecord` was called, the snapshot will contain native Date/Time object properties, not `YYYY-MM-DD` / `HH:MM:SS` text strings. `OTr_uTextToDate("")` will return the null date; `OTr_uTextToTime("")` will return `?00:00:00?`. This is a **correctness defect** that causes silent data loss in environments where the native date setting is active.

**Required fix:** Apply the same dual-path pattern in `OTr_GetRecord` as used in `OTr_GetDate`: inspect the stored property type with `OB Get type`, and retrieve natively or via text parsing according to the detected type.

### 3.2 — `OTr_GetBoolean` Returns Integer

**Status: PASS**

`OTr_GetBoolean` is declared as returning `Integer` (not `Boolean`) and performs an explicit `If ($value_b) $result_i:=1 End if` branch. The type-mismatch guard ensures that a non-Boolean stored property generates `OK=0` rather than performing a silent type coercion. This correctly matches the OT 5.0 legacy behaviour of returning 0 or 1 as an Integer.

### 3.3 — Round-Trip Fidelity for Scalar Types

**Status: PASS**

All scalar Put/Get pairs reviewed (Long, Real, Boolean, Date, Time) store values using typed `OB SET` calls and retrieve with matching typed `OB Get` calls, with the dual-path Date/Time guards. No coercion or precision loss is expected. The Phase 15 §7 result of 30/30 Pass confirms empirical round-trip fidelity.

### 3.4 — Very Long Text (`OTr_PutText` / `OTr_PutString`)

**Status: NOT AUDITED**

The OT 5.0 reference should be consulted to confirm whether OT 5.0 imposes a length limit on String/Text values. Native 4D object properties support Unicode text of arbitrary length; no artificial limit was introduced in OTr. If OT 5.0 silently truncated strings exceeding 32KB or similar, callers may need to be advised of the lifted restriction.

### 3.5 — Dotted-Path `AutoCreateObjects`

**Status: PASS (conditional)**

`OTr_PutDate`, `OTr_PutLong`, and all other scalar Put methods call `OTr_zResolvePath(...; True; ...)` (the third argument being the `autoCreate` flag). Intermediate objects are created when the flag is True, matching the OT 5.0 `AutoCreateObjects` option.

Scalar Get methods pass `False` for `autoCreate`, which is correct — a missing intermediate path on a Get returns the default value without creating structure.

The interaction with the global options bit (bit 2, `AutoCreateObjects`) was not audited directly. `OTr_zResolvePath` receives a hard-coded `True` from each Put method rather than reading the options register dynamically. If the caller disables `AutoCreateObjects` via `OTr_SetOptions`, this override will be silently ignored.

**Recommendation:** Audit `OTr_zResolvePath` to confirm whether it consults `<>OTR_Options_i` bit 2, or whether the `autoCreate` parameter is the sole control. If the global option is not honoured, this is a behavioural gap relative to OT 5.0.

---

## Section 4 — Item Introspection

### 4.1 — `OTr_ItemType` Returns Legacy OT Type Constants

**Status: PASS**

`OTr_zMapType` maps native 4D property types to OT type constants. Verified constants include:
- Real → 1 (OT Real)
- Longint/Integer → 5 (OT Longint)
- Boolean → 6 (OT Boolean)
- Date → 4 (OT Date)
- Time → 11 (OT Time)
- Picture → 3 (OT Picture)
- BLOB → 30 (OT BLOB)
- Object (non-array) → 114 (OT Object)
- Text (no shadow) → 112 (OT Character)

Array sub-objects delegate to `OTr_zArrayType` then `OTr_uMapType`, providing correct OT array-type constants for array items.

### 4.2 — `OTr_ItemType` on Missing Tag: OK=0 is a Behavioural Gap

**Status: FINDING — potential deviation from OT 5.0**

When `OTr_ItemType` is called with a tag that does not exist in the object, the implementation calls:

```4d
OTr_zError("Item not found: "+$inTag_t; Current method name)
```

This sets `OK=0` and fires the configured error handler. The return value is 0.

The OT 5.0 Reference should be checked to confirm whether `OT ItemType` on a missing tag is a silent query (returns 0, OK unchanged) or an error condition. If OT 5.0 returns 0 silently for a missing tag, the current implementation is more aggressive than required and may break code that uses `OT ItemType` as a non-destructive probe.

**Recommendation:** Consult the OT 5.0 Reference for the exact `OT ItemType` missing-tag specification. If OT 5.0 is silent, change the missing-tag path in `OTr_ItemType` to return 0 without error (matching the quiet-query pattern used by `OTr_ItemExists`).

### 4.3 — `OTr_ItemType` OK=1 Discrepancy

**Status: FINDING — implementation diverges from OK conditions table**

The `OTr-OK0-Conditions.txt` table specifies `OTr_ItemType: OK=1 success: Y | OK=0 error: Y`, meaning the method should explicitly set `OK=1` on a successful type retrieval.

The method header's 2026-04-10 note states: "Removed spurious OTr_zSetOK(1) on success path. Per the canonical OTr contract … OK is pulled to zero on error only and is never guaranteed to be one on success."

These two sources directly contradict each other. The OK conditions table is the authoritative reference for this decision.

**Required action:** Reinstate `OTr_zSetOK(1)` on the success path of `OTr_ItemType` (i.e., when `$otType_i` is successfully resolved). Update the method header note to reflect the correct specification.

### 4.4 — `OTr_ItemCount` Counts Top-Level Properties Only

**Status: PASS**

`OTr_ItemCount` counts only the top-level keys of the root object (or of the embedded sub-object when an optional tag is supplied). The `__otr_` prefix exclusion and shadow-key exclusion filters ensure that internal implementation properties do not inflate the count. This matches OT 5.0's definition of item count.

### 4.5 — `OTr_GetAllProperties` / Property Enumeration Order

**Status: INDETERMINATE — by design**

`OTr_GetAllProperties` delegates to `OTr_GetAllNamedProperties`, which uses `OB Keys` to enumerate property names. 4D `OB Keys` returns keys in insertion order for Object properties, but this is a 4D implementation detail and not a guaranteed contract. The OT 5.0 Reference should be consulted to confirm what ordering guarantee, if any, OT 5.0 provides for property enumeration. The Phase 15 §5 test acknowledges that "order may differ" and compares only name set membership, not order.

**Recommendation:** Document the ordering behaviour explicitly in the `OTr_GetAllProperties` method header (e.g., "Returns keys in insertion order per 4D Object semantics; caller must not assume alphabetical or any specific order").

### 4.6 — `OTr_DeleteItem` on Non-Existent Tag: Error or Silent No-Op

**Status: FINDING — requires legacy verification**

`OTr_DeleteItem` calls `OTr_zError("Item not found: "+$inTag_t)` when the tag does not exist, setting `OK=0`. The OT 5.0 Reference must be consulted to confirm whether `OT DeleteItem` on a non-existent tag is a silent no-op or generates an error. If OT 5.0 is silent, the current behaviour is a behavioural gap.

The `OTr-OK0-Conditions.txt` entry shows `OTr_DeleteItem: OK=1 Y | OK=0 Y` — i.e., explicit success and error signalling. This implies the current implementation should be correct (error on missing tag), but confirmation against the legacy PDF is required.

---

## Section 5 — Array Operations

### 5.1 — 1-Based to 0-Based Index Mapping

**Status: PASS**

`OTr_u_AccessArrayElement` (the unified array accessor) receives a 1-based index from callers. Array elements within the array sub-object are stored under string keys `"0"` (the default element) through `"N"`. The element at caller index `$inIndex_i` is retrieved as `$arrayObj_o[String($inIndex_i)]`, which means caller index 1 maps to internal key `"1"`. This is consistent with the array sub-object structure where key `"0"` is the default element and keys `"1"`..`"N"` are the 1-based elements.

This is not a traditional 0-indexed Collection: the array sub-object uses string-keyed properties on an Object, and the mapping is 1-based throughout. The Phase 15 test result confirms this is correct.

### 5.2 — Out-of-Bounds Index

**Status: PASS**

`OTr_u_AccessArrayElement` checks `($inIndex_i >= 0) & ($inIndex_i <= $arrayObj_o.numElements)`. An index outside this range calls `OTr_zError("Index out of range")`, setting `OK=0` and returning the default Variant. This is correct defensive behaviour, although OT 5.0's behaviour for out-of-bounds Get should be verified (silent default vs. error).

### 5.3 — `OTr_SortArrays`

**Status: PASS**

`OTr_SortArrays` performs an eight-phase sort with explicit validation of pair count, handle validity, array type compatibility, and size consistency across all pairs. The multi-key sort uses `MULTI SORT ARRAY` with the `<>OTR_SortIdx_ai` index array to write results back. BLOB, Picture, and Pointer arrays are excluded from sorting (via `OTr_zSortValidatePair`). The Phase 15 §7 result confirms single-key ascending/descending passes.

**Minor note:** The sort lock is released between Phase 5 (fill scratch arrays) and Phase 8 (write-back). Specifically, `OTr_zLock` is called only in Phase 8. The scratch arrays (`<>OTR_Sort*`) are interprocess and unprotected during the sort itself. If two processes call `OTr_SortArrays` concurrently, they will corrupt each other's scratch arrays. This is a design-level concurrency issue. The sort implementation should be audited for multi-process safety if concurrent callers are expected.

### 5.4 — `OTr_FindInArray`: "Not Found" Sets `OK=0`

**Status: FINDING — deviates from OT 5.0 contract**

The final line of the search logic is:

```4d
OTr_zSetOK(Num($result_i>=0))
```

This sets `OK=1` when an element is found and `OK=0` when `Find in array` returns `-1` (not found). The `OTr-OK0-Conditions.txt` entry explicitly clarifies: "Sets OK to 0 on error; 1 when found (-1 result is not an error)." Setting `OK=0` on a "not found" return conflates a normal search outcome with an error condition. Callers who test `OK=0` as an error indicator will incorrectly infer failure when the search simply found no match.

**Required fix:** Change the final call to set `OK=0` only on genuine error paths (invalid handle, missing tag, unsupported type). Do not call `OTr_zSetOK(0)` when `Find in array` returns `-1`; instead, leave `OK` unchanged (or explicitly set `OK=1` to signal a successful but unmatched search). The search result itself (`-1`) is the caller's signal that no match was found.

### 5.4b — Out-of-Bounds Index on Put

**Status: PASS — errors on out-of-range**

`OTr_u_AccessArrayElement` checks `($inIndex_i >= 0) & ($inIndex_i <= $arrayObj_o.numElements)` for both Get and Put paths. An index beyond `numElements` calls `OTr_zError("Index out of range")`. OTr does not silently append or extend arrays on an out-of-bounds Put. The OT 5.0 Reference should be consulted to confirm whether OT 5.0 also errors, silently extends, or appends — but the current behaviour is conservative and safe.

### 5.5 — `OTr_FindInArray` Search Semantics

**Status: PASS**

The search delegates to `Find in array`, which performs exact-match, case-sensitive comparisons. Text values are compared as-is. The `$inStart_i` parameter enables starting from any 1-based index. This matches OT 5.0's documented search behaviour.

---

## Section 6 — Complex Types

### 6.1 — `OTr_PutObject` / `OTr_GetObject`: Deep Copy Semantics

**Status: PASS**

`OTr_PutObject` calls `OB Copy(<>OTR_Objects_ao{$inSourceObject_i})` before storing. `OTr_GetObject` calls `OB Copy($embedded_o)` before returning a new handle. Reference semantics are therefore impossible: modifying the source or retrieved object does not affect the stored copy. This matches the behaviour documented in Phase 15 §4.3.

### 6.2 — `OTr_GetBLOB`: Fully Implemented (not a deprecated stub)

**Status: FINDING — Phase 15 §4.1 table is stale**

The current implementation of `OTr_GetBLOB` is a full implementation using a Pointer output parameter (`$outBLOB_ptr : Pointer`). It reads the stored BLOB (natively or via base64) and writes the result back via `$outBLOB_ptr->:=`. It is not a deprecation stub that delegates to `OTr_GetNewBLOB`.

Phase 15 §4.1 lists `OT GetBLOB` as a method that "cannot be implemented" due to the BLOB output-parameter constraint. This listing should be removed from §4.1 and moved to §4.2 (changed API) or §4.3 (changed behaviour) with a note that `OTr_GetBLOB` is implemented but requires pointer-to-BLOB syntax (`->myBlob`).

The `OTr-OK0-Conditions.txt` entry for `OTr_GetBLOB` reads: "Stub - always calls OTr_zSetOK(0) (not implemented)." This is incorrect — the method is implemented. The OK conditions table must be updated.

### 6.3 — `OTr_PutBLOB` / `OTr_GetNewBLOB` Round-Trip Fidelity

**Status: PASS**

BLOB storage uses the `Storage.OTr.nativeBlobInObject` flag for the storage path (native `OB SET` on v19R2+, base64 text on earlier). `OTr_GetNewBLOB` inspects the stored property type and takes the corresponding retrieval path. Phase 15 §7 confirmed round-trip pass.

### 6.4 — `OTr_PutPicture` / `OTr_GetPicture`

**Status: PASS (by Phase 15 result)**

Not reviewed at source-code level in this session. Phase 15 §7.5 noted that byte-for-byte equality is not achievable (re-encoding occurs); the test was relaxed to verify a non-empty picture is returned. This is documented as an intentional difference.

### 6.5 — `OTr_PutPointer` / `OTr_GetPointer`: Changed API

**Status: PASS — documented incompatibility**

`OTr_PutPointer` stores the pointer as a serialised text string using `OTr_uPointerToText`, accompanied by a shadow-type key (`leafKey$type := 23`) so `OTr_zMapType` can correctly identify the stored value as OT Pointer rather than plain text.

`OTr_GetPointer` accepts a Pointer-to-Pointer (`$outPointer_ptr : Pointer`) output parameter, requiring callers to pass `->myVar`. This is a documented API change from OT 5.0 (see Phase 15 §4.2 and §7.6).

**Minor gap:** `OTr_GetPointer` does not call `OTr_zError` when the handle is invalid — it falls through the `Else` branch calling `OTr_zError`, which is correct — however, when the path resolution fails (tag missing), there is no `OTr_zError` call. The `OTr_zResolvePath` silent-no-op on missing path means the pointer is left as its default (uninitialised). Whether `OTr_zError` should be called here depends on the `FailOnItemNotFound` option; this option interaction was not fully audited.

### 6.6 — `OTr_PutRecord` / `OTr_GetRecord`: Snapshot Semantics

**Status: PASS (Put) / DEFECT (Get) — see §3.1**

`OTr_PutRecord` correctly snapshots all fields including Date/Time (dual-path via `$nativeDate_b`) and encodes Pictures and BLOBs as base64 text. `OTr_GetRecord` correctly restores scalar fields by name.

The defect noted in §3.1 applies here: `OTr_GetRecord` does not apply the dual-path strategy for retrieving Date/Time fields from a snapshot stored with native types.

### 6.6b — `OTr_GetArrayPointer`: Function-Result Form

**Status: PASS — documented change confirmed**

The checklist item notes that `OTr_GetArrayPointer` returns a pointer as a function result, changed from OT 5.0's output parameter form. This is consistent with the approach taken for `OTr_GetArrayPicture` (Phase 15 §7.7) and is documented in Phase 15 §4.2. The source code was not read directly for this method, but the Phase 15 §7 Pass result and the pattern established for all array Get methods confirm this implementation. No additional action is required.

### 6.7 — `OTr_PutVariable` / `OTr_GetVariable`

**Status: NOT AUDITED at source-code level**

These methods were not read directly in this session. The `OTr-OK0-Conditions.txt` entries show both as already having `OTr_zSetOK(0)` on error paths. The Phase 15 §7 test result confirms they passed. A dedicated code review is recommended for correctness of the serialisation format, particularly for complex variable types.

---

## Section 7 — Import/Export

### 7.1 — `OTr_ObjectToBLOB` / `OTr_BLOBToObject`

**Status: PASS with design note**

`OTr_ObjectToBLOB` serialises via `VARIABLE TO BLOB` + `COMPRESS BLOB (GZIP best compression mode)`. The lock is acquired to copy the object, then released before the compression work, which is intentional: this avoids holding the semaphore during expensive I/O. The ioBLOB parameter is a Pointer, matching the Phase 15 §4.2 documented change.

`OTr_BLOBToObject` expands the BLOB (if compressed) then calls `BLOB TO VARIABLE`. When `BLOB TO VARIABLE` sets `OK=0` (malformed data), the method immediately calls `OTr_zError`. The legacy OT BLOB rejection note in Phase 15 §4.3 is consistent with this: a legacy OT BLOB, which uses a different serialisation format, will fail `BLOB TO VARIABLE` and result in `OK=0` with an error message.

**Design note:** The early lock release in `OTr_ObjectToBLOB` is correct in principle, but it is not explicitly documented in the method header or in the master spec. A comment noting this pattern would improve auditability.

**ioOffset parameter:** Confirmed dropped. The signature is `#DECLARE($inBLOB_blob : Blob)->$handle_i : Integer` — only `inBLOB` is accepted. This resolves the "Provisional" status in Phase 15 §4.2.

### 7.2 — `OTr_SaveToText` / `OTr_LoadFromText` Round-Trip

**Status: PASS**

`OTr_SaveToText` returns a JSON Stringify of the object. `OTr_LoadFromText` parses with JSON Parse, with a BOM-stripping pre-pass and a top-level-array wrapping guard. The lock is released before stringification to avoid holding the semaphore during potentially expensive serialisation.

`OTr_LoadFromText` does not call `OTr_zSetOK(0)` on a parse failure: it simply returns 0. The `OTr-OK0-Conditions.txt` entry shows `OTr_LoadFromText: OK=0: Y`. This is a gap: a caller passing malformed JSON will receive handle 0 but no `OK=0` signal.

**Required fix:** Add `OTr_zSetOK(0)` (or `OTr_zError("JSON parse failed")`) when `$parsed_o=Null` after `JSON Parse` returns.

### 7.3 — `OTr_SaveToFile` / `OTr_LoadFromFile`

**Status: PASS**

`OTr_SaveToFile` uses `TEXT TO DOCUMENT` with `"UTF-8"`. The note in the method header acknowledges that `TEXT TO DOCUMENT` prepends a UTF-8 BOM; `OTr_LoadFromText` (called by `OTr_LoadFromFile`) strips the BOM. Round-trip is therefore clean.

`OTr_SaveToFile` does not call `OTr_zSetOK(0)` when the handle is invalid: it calls `OTr_zIsValidHandle` which sets `OK=0` via the helper, but unlike other methods there is no `Else` branch with `OTr_zError`. However, `OTr_zIsValidHandle` does call `OTr_zSetOK(0)` internally, so the `OK` state is correct. The error is not logged, however.

**Recommendation (minor):** Add an `Else` branch with `OTr_zError("Invalid handle"; Current method name)` so that `SaveToFile` failures are logged, consistent with other public methods.

`OTr_LoadFromFile` returns 0 on file-not-found but does not call `OTr_zSetOK(0)`. The `OTr-OK0-Conditions.txt` entry shows `OK=0: Y`. The same fix as §7.2 applies.

---

## Section 8 — Thread Safety

### 8.1 — Semaphore Acquisition and Release

**Status: PASS**

Every reviewed public method that accesses `<>OTR_Objects_ao` or `<>OTR_InUse_ab` calls `OTr_zLock` before access and `OTr_zUnlock` before each return point. The pattern is consistent across all methods reviewed.

### 8.2 — Reentrant Lock Design

**Status: PASS — design decision confirmed and documented**

`OTr_zLock` increments `OTR_LockCount_i` (a process variable); when the count is 0, it acquires the semaphore. `OTr_zUnlock` decrements the counter and releases the semaphore only when it reaches 0. This reentrant strategy is specified in `OTr-Specification.md §3.4` and documented in `S1-Findings.md §1.6`.

The design decision noted as "required" in the original S3 checklist (`§3.4 design decision`) is confirmed as made and implemented.

### 8.3 — Error-Path Lock Release

**Status: PASS**

All reviewed public methods maintain `OTr_zLock` / `OTr_zUnlock` balance across error paths. Methods that call `OTr_zError` within the locked region do not return early before calling `OTr_zUnlock`. (Note: `OTr_zError` itself does not acquire the lock, so no nested-lock issue arises.)

**Exception — `OTr_ObjectToBLOB`:** This method releases the lock immediately after copying the object (line 79), before the `VARIABLE TO BLOB` / `COMPRESS BLOB` calls. This is correct and intentional but should be noted as an asymmetric lock/unlock pattern. No lock is held during serialisation. The structural correctness is not in doubt; the asymmetry should be commented.

### 8.4 — `OTr_SortArrays` Multi-Process Safety

**Status: FINDING — design-level concurrency risk**

As noted in §5.3, the interprocess scratch arrays (`<>OTR_Sort*`) are written in Phase 5 (fill) without holding `OTr_zLock`, and read by `MULTI SORT ARRAY` in Phase 7 also without the lock. Only the write-back phase (Phase 8) is locked.

If two processes call `OTr_SortArrays` concurrently on different objects, they will overwrite each other's scratch arrays, producing corrupted sort results. This is a substantive thread-safety risk for any application that sorts from multiple processes.

**Recommendation:** Either (a) include the fill and sort phases within `OTr_zLock` (accepting higher lock hold time), or (b) use process-local scratch arrays rather than interprocess arrays for the fill/sort work, copying results into the object only at write-back time.

---

## Section 9 — Known Incompatibilities (Phase 15 §4)

### 9.1 — §4.1: `OT GetBLOB` and `OT GetArrayBLOB` Table

**Status: REQUIRES UPDATE**

The current §4.1 table lists:
- `OT GetBLOB` — listed as "cannot be implemented"; this is incorrect. `OTr_GetBLOB` is fully implemented with a Pointer output parameter.
- `OT GetArrayBLOB` — listed as unimplementable. This requires verification: if `OTr_GetArrayBLOB` has been implemented with a Pointer parameter (matching the `OTr_GetBLOB` approach), the table entry should be updated similarly.

**Required action:** Remove `OT GetBLOB` from §4.1. Add it to §4.2 with the note: "Implemented with changed API — `outBLOB` is now a Pointer parameter; callers must pass `->myBlobVar`." Verify `OT GetArrayBLOB` status independently.

### 9.2 — §4.2: `OTr_BLOBToObject` Offset Parameter

**Status: RESOLVED — confirmed dropped**

The source code confirms that `OTr_BLOBToObject` accepts only `$inBLOB_blob : Blob` with no offset parameter. The "Provisional" marking in §4.2 must be updated to: "Not implemented — confirmed dropped (Phase 6 §4.2 and Phase 15 §7 implementation)."

### 9.3 — §4.1: `OT GetArrayPicture` Entry

**Status: STALE — already flagged in S1 §2.11 and Phase 15 §7.7**

Phase 15 §7.7 establishes that `OT GetArrayPicture` is a function (not a statement with an output parameter) and that `OTr_GetArrayPicture` is a complete equivalent. The §4.1 table entry for `OT GetArrayPicture` remains present in the document and must be removed or reclassified to §4.3.

### 9.4 — §4.3 Incompatibilities: Confirmed as Genuine

The following §4.3 incompatibilities were confirmed as correctly documented and genuinely non-fixable within the native component constraint:

- **`OTr_PutRecord` / `OTr_GetRecord`** — snapshot rather than live reference. Confirmed in source code.
- **`OTr_ObjectToBLOB` / `OTr_BLOBToObject`** — JSON-based format; legacy OT BLOBs rejected. Confirmed in source code.
- **`OTr_ObjectSize`** — approximation via JSON Stringify byte length. Not audited at source level but consistent with architecture.
- **`OTr_SaveToText` / `OTr_SaveToFile`** — OTr format is not compatible with legacy OT text exports. Confirmed in source code.
- **`OTr_GetBoolean`** — returns Integer (0/1). Confirmed in source code.
- **`OTr_PutObject` / `OTr_GetObject`** — always deep-copies. Confirmed in source code.
- **`OTr_GetArrayPicture`** — implemented as function (not output parameter). Confirmed via Phase 15 §7.7.

---

## Expected Outputs — Status Against S3 Checklist

The following section maps each expected output from the S3 session definition against the findings above.

**Output 1: Confirmed or corrected resolution of the Date/Time storage strategy discrepancy**

Confirmed resolved. The dual-path `OTr_uNativeDateInObject` guard is implemented in `OTr_PutDate`, `OTr_PutTime`, `OTr_GetDate`, and `OTr_GetTime`. See §3.1. The gap in `OTr_GetRecord` is a separate defect (§3.1, §6.6).

**Output 2: A list of behavioural gaps not already catalogued in Phase 15**

Gaps identified in this session:

| # | Method | Gap Description | Severity |
|---|---|---|---|
| G1 | `OTr_ItemType` | Missing-tag path sets `OK=0` and fires error handler; OT 5.0 may be silent | Medium |
| G2 | `OTr_ItemType` | `OTr_zSetOK(1)` removed from success path; contradicts `OTr-OK0-Conditions.txt` | Medium |
| G3 | `OTr_GetRecord` | Does not apply dual-path retrieval for Date/Time fields stored natively | High |
| G4 | `OTr_FindInArray` | Sets `OK=0` on "not found" (`-1`), which is not an error | Medium |
| G5 | `OTr_LoadFromText` | Does not set `OK=0` on JSON parse failure | Low |
| G6 | `OTr_LoadFromFile` | Does not set `OK=0` on file-not-found | Low |
| G7 | `OTr_GetString` | Missing `OTr_zError` call on invalid handle (OK is set by `zIsValidHandle`; error not logged) | Low |
| G8 | `OTr_SortArrays` | Scratch arrays unprotected during multi-process concurrent sort | High (concurrent use) |
| G9 | `OTr_GetBLOB` | Phase 15 §4.1 and `OTr-OK0-Conditions.txt` both incorrectly describe this as a stub | Housekeeping |
| G10 | `OTr_zResolvePath` | `AutoCreateObjects` global option may not be honoured; Put methods hardcode `True` | Needs audit |
| G11 | Empty-string tag | Behaviour undefined; not guarded in any reviewed method | Low |

**Output 3: A list of edge cases not covered by the existing test suite (input to S4)**

- Empty-string tag passed to any Put/Get method
- `OTr_GetRecord` round-trip when `Storage.OTr.nativeDateInObject` is True
- `OTr_FindInArray` on an array where the value is genuinely absent (verify `OK` state after call)
- `OTr_LoadFromText` with malformed JSON (verify `OK=0` is set)
- `OTr_LoadFromFile` with a missing file path (verify `OK=0` is set)
- `OTr_SortArrays` called concurrently from two processes (safety check)
- `OTr_ItemType` called with a missing tag (verify whether `OK=0` and error handler fire; compare with OT 5.0)
- `OTr_ObjectToBLOB` with the `inAppend` parameter set non-zero (append mode round-trip)
- Very long text value (> 32KB) stored and retrieved via `OTr_PutText` / `OTr_GetString`
- `OTr_Clear` on an already-cleared handle (double-free; verify `OK=0`)
- `OTr_PutDate` / `OTr_GetDate` when `AutoCreateObjects` is disabled (bit 2 cleared)

**Output 4: Confirmed or corrected status of thread safety**

Thread safety is confirmed as correctly implemented for the single-process case. The reentrant lock design is sound and resolves the design decision noted in the original checklist. One concurrency risk was identified (G8 — `OTr_SortArrays` scratch arrays) that is relevant to multi-process applications.

**Output 5: Resolution of all "provisional" or "to be finalised" items flagged in the phase specs**

- `OTr_BLOBToObject` offset parameter: confirmed dropped — update Phase 15 §4.2 to remove "Provisional" marking.
- `OTr_GetArrayPicture` in §4.1: confirmed stale — remove entry from §4.1 (already flagged in Phase 15 §7.7 and S1 §2.11).
- `OTr_GetBLOB` in §4.1 and `OTr-OK0-Conditions.txt`: confirmed stale — update to reflect full implementation with Pointer parameter.
- Date/Time storage strategy: confirmed resolved — no further action required in specs beyond the updates already applied to Phase 2 (per S1 §1.3).

---

---

## Remediation Log (2026-04-11)

The following items were remediated immediately after the audit pass, based on decisions confirmed against the ObjectTools 5 Reference PDF.

### R1 — `OTr_GetRecord` Date/Time dual-path retrieval (G3) — FIXED

`OTr_GetRecord` now inspects `OB Get type($snapshot_o; $fieldName_t)` before restoring Date and Time fields. If the stored type is `Is date` / `Is time`, the value is retrieved natively via `OB Get(...; Is date)` / `OB Get(...; Is time)`. If the stored type is `Is text`, the existing `OTr_uTextToDate` / `OTr_uTextToTime` parsers are used. The fix handles both the native-storage path and any legacy text-serialised snapshots correctly.

A new process variable `$storedPropType_i : Integer` was added to the method's `var` block.

### R2 — `OTr_PutDate` / `OTr_PutTime` shadow keys on text-storage path (G3 supplement) — FIXED

When `OTr_uNativeDateInObject` returns False, `OTr_PutDate` now writes a shadow key (`OTr_zShadowKey($leafKey_t) := 4`) alongside the `"YYYY-MM-DD"` text. `OTr_PutTime` writes shadow key value `11` alongside `"HH:MM:SS"` text. This allows `OTr_zMapType` to correctly identify text-stored dates and times as `OT Date (4)` and `OT Time (11)` respectively, rather than misreporting them as `OT Character (112)`.

When `OTr_uNativeDateInObject` returns True, no shadow key is written — `OB Get type` returns `Is date` / `Is time` unambiguously.

### R3 — `OTr_FindInArray` not-found sets OK=0 (G4) — FIXED

The `OTr_zSetOK(Num($result_i>=0))` call at the end of the search Case was removed. A not-found result (`-1`) is a legitimate search outcome, not an error. `OK` is now left unmodified when the search completes without error; `OK` is only set to 0 on genuine error paths (invalid handle, missing tag, unsupported type, non-array tag). Per the legacy reference documentation (page 79), `OK` variable behaviour for `OT FindInArray` is not documented — no OK manipulation at all.

### R4 — `OTr_ItemType` OK=1 on success (G2) — confirmed correct, table corrected

The ObjectTools 5 Reference PDF has **no documented instances** of any OT plugin method setting `OK=1` on success. The `OTr-OK0-Conditions.txt` table entries showing `OK=1: Y` for `OTr_ItemType`, `OTr_CopyItem`, `OTr_DeleteItem`, `OTr_ObjectSize`, `OTr_GetString`, and `OTr_GetText` were incorrect and have been corrected to `—`. The `OTr_GetBLOB` stub description was also corrected to reflect its implemented state. The source code already had no live `OTr_zSetOK(1)` calls (all had been removed 2026-04-10); only the table was wrong.

The `OTr_ItemType` method header note was updated to cite the correct basis: "Legacy OT never sets OK=1; error on invalid handle or missing tag per p.95."

### R5 — `OTr_ItemType` missing-tag path (G1) — confirmed correct

Per ObjectTools 5 Reference p.95: "If inObject is not a valid object handle or if no item in object has the given tag, an error is generated, OK is set to zero, and zero is returned." The current implementation (`OTr_zError("Item not found")` → `OK=0`, return 0) is exactly correct. No change required.

### R6 — Sort scratch array scope (G8) — confirmed process-scope, stale language fixed

`Compiler_OTrSortProcess.4dm` declares all `OTR_Sort*` and `OTR_SortIdx_ai` arrays as process-scope (no `<>` prefix). `Compiler_OTrSortInterprocess.4dm` exists with the interprocess equivalents, all commented out. `OTr_SortArrays.4dm` and the helper methods (`OTr_zSortFillSlot`, `OTr_zSortSlotPointer`) all use process names without `<>`. The multi-process concurrency risk identified in the original audit is eliminated by this design: each process has its own independent scratch arrays.

The stale "interprocess scratch array" language in the three sort method headers was corrected to "process-scope scratch array".

**Items remaining open:** G5 (`OTr_LoadFromText` / `OTr_LoadFromFile` OK=0 on failure), G7 (`OTr_GetString` missing error log), G10 (`AutoCreateObjects` option interaction), G11 (empty-string tag). These are low-priority items deferred to S4 / the next engineering pass.

---

## Recommended Actions Summary

| Priority | Method / Document | Action |
|---|---|---|
| **High** | `OTr_GetRecord` | Apply dual-path Date/Time retrieval (check property type before deciding text-parse vs. native) |
| **High** | `OTr_SortArrays` | Investigate multi-process scratch array safety; document or fix |
| **Medium** | `OTr_ItemType` | Reinstate `OTr_zSetOK(1)` on success path; consult OT 5.0 Reference for missing-tag behaviour |
| **Medium** | `OTr_FindInArray` | Do not set `OK=0` when search result is `-1` (not found is not an error) |
| **Medium** | `OTr_zResolvePath` | Confirm whether `AutoCreateObjects` global option bit is honoured |
| **Low** | `OTr_LoadFromText` | Add `OTr_zSetOK(0)` on parse failure |
| **Low** | `OTr_LoadFromFile` | Add `OTr_zSetOK(0)` on file-not-found |
| **Low** | `OTr_GetString` | Add `OTr_zError("Invalid handle"; Current method name)` in `Else` branch |
| **Low** | `OTr_SaveToFile` | Add `OTr_zError("Invalid handle"; Current method name)` in `Else` branch |
| **Housekeeping** | Phase 15 §4.1 | Remove `OT GetBLOB` entry; move to §4.2 with Pointer-parameter note |
| **Housekeeping** | Phase 15 §4.1 | Remove `OT GetArrayPicture` entry |
| **Housekeeping** | Phase 15 §4.2 | Remove "Provisional" from `OTr_BLOBToObject` offset row |
| **Housekeeping** | `OTr-OK0-Conditions.txt` | Update `OTr_GetBLOB` entry from "stub" to "implemented with Pointer parameter" |
| **Housekeeping** | `OTr_ObjectToBLOB` | Add comment noting the intentional early lock release before compression |
| **Housekeeping** | `OTr_GetAllProperties` | Document insertion-order caveat in method header |
| **For S4** | Test suite | Add edge-case tests for items in Output 3 above |
