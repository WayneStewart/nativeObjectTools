# OTr API Differences from ObjectTools 5.0

**Version:** 1.0
**Date:** 2026-04-12
**Status:** Current

---

## Overview

OTr is a native 4D replacement for the ObjectTools 5.0 binary plugin. Whilst the overwhelming majority of the public API is a drop-in replacement, a small number of methods either cannot be implemented with an identical signature or exhibit materially different runtime behaviour. This document catalogues all known divergences to assist developers undertaking migration.

The differences fall into three categories:

1. Methods that cannot be implemented — signature change is mandatory
2. Methods with changed signatures — calling code must be updated
3. Methods with changed runtime behaviour — signatures are compatible but semantics differ

---

## 1. Methods That Cannot Be Implemented with the Original Signature

These ObjectTools 5.0 methods have no OTr equivalent with the same calling convention. The divergence is a consequence of a 4D component architecture constraint: BLOB output parameters are not supported in component methods.

### `OT GetBLOB(inObject; inTag; outBLOB)`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Signature** | `OT GetBLOB(inObject; inTag; outBLOB)` | `OTr_GetNewBLOB(inObject; inTag)` → BLOB |
| **Return mechanism** | Output parameter | Function result |

**Migration:** Replace all calls of the form `OT GetBLOB($handle; $tag; $myBlob)` with `$myBlob := OTr_GetNewBLOB($handle; $tag)`.

### `OT GetArrayBLOB` (legacy output-parameter form)

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Signature** | `OT GetArrayBLOB(inObject; inTag; outBLOB)` | Element accessor methods |
| **Return mechanism** | Output parameter | Function result via element accessor |

**Migration:** Use the OTr element accessor methods to retrieve individual BLOB elements from an array.

---

## 2. Methods with Changed Signatures

These methods have been renamed or have had their parameter list altered. The calling code must be updated; a direct substitution is not possible.

### `OT ObjectToBLOB` → `OTr_ObjectToBLOB`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Signature** | `OT ObjectToBLOB(inObject; ioBLOB)` | `OTr_ObjectToBLOB($handle)` → BLOB |
| **Change** | BLOB passed as an in/out parameter | BLOB returned as the function result |

**Migration:** `$myBlob := OTr_ObjectToBLOB($handle)`

---

### `OT BLOBToObject` → `OTr_BLOBToObject`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Signature** | `OT BLOBToObject(inBLOB; ioOffset)` | `OTr_BLOBToObject($blob)` → Integer |
| **Change** | `ioOffset` parameter permitted reading from an arbitrary byte position | Offset parameter is absent; reading always commences from byte 0 |

**Migration:** `$handle := OTr_BLOBToObject($myBlob)`. If your code passed a non-zero offset, you must pre-slice the BLOB before calling OTr.

---

### `OT GetBLOB` → `OTr_GetNewBLOB`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Signature** | `OT GetBLOB(inObject; inTag; outBLOB)` | `OTr_GetNewBLOB(inObject; inTag)` → BLOB |
| **Change** | Output parameter | Function result; method renamed |

**Migration:** `$myBlob := OTr_GetNewBLOB($handle; $tag)`

---

### `OT GetArrayPicture` → `OTr_GetArrayPicture`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Signature** | `OT GetArrayPicture(inObject; inTag; inIndex; outPicture)` | `OTr_GetArrayPicture(inObject; inTag; inIndex)` → Picture |
| **Change** | Picture returned via output parameter | Picture returned as the function result |

**Migration:** `$myPic := OTr_GetArrayPicture($handle; $tag; $index)`

---

## 3. Methods with Changed Runtime Behaviour

These methods retain a compatible calling signature but exhibit materially different semantics at runtime. Calling code may compile and execute without error yet produce incorrect results if these differences are not accounted for.

### 3.1 Record Storage — Snapshot vs. Live Reference

**Affected methods:** `OTr_PutRecord`, `OTr_GetRecord`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Storage model** | Live reference to the current database record | Snapshot of field values at the moment `PutRecord` is called |
| **Post-storage modifications** | Reflected in the stored object | Not reflected; snapshot is immutable after the call |
| **`GetRecord` behaviour** | Reads current field values from the database | Restores the stored snapshot; no database I/O is performed |
| **Pictures and BLOBs** | Stored by reference | Stored as Base64-encoded strings within the snapshot |

**Impact:** Code that modifies a record after calling `OTr_PutRecord` and then expects `OTr_GetRecord` to return the updated values will not behave as expected. Callers must call `OTr_PutRecord` again after any modifications if the updated state is to be preserved.

---

### 3.2 BLOB Serialisation Format — JSON vs. Proprietary Binary

**Affected methods:** `OTr_ObjectToBLOB`, `OTr_BLOBToObject`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Format** | Proprietary binary format (magic bytes, internal structure) | Compressed 4D-native object serialisation with type metadata |
| **Cross-compatibility** | — | OTr can import supported legacy OT object BLOBs; OTr BLOBs cannot be loaded by OT |

**Impact:** OTr detects ObjectTools object BLOBs and converts supported item payloads into native OTr storage when `OTr_BLOBToObject` is called. The current importer supports the legacy character, date, and character-array payloads covered by the supplied migration samples. Unsupported legacy item markers fail cleanly with `OK=0`. OTr-generated BLOBs remain OTr-only.

---

### 3.3 Object Size Calculation

**Affected methods:** `OTr_SizeOf` (or equivalent size introspection method)

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Metric** | In-memory byte size of the internal plugin structure | Byte length of the JSON serialisation (`JSON Stringify`) |
| **Comparability** | — | Values are numerically incommensurable |

**Impact:** Code that compares or thresholds size values across the two systems will produce incorrect results. OTr size values should be treated as relative estimates for comparison within OTr only.

---

### 3.4 Text Export/Import Format

**Affected methods:** `OTr_SaveToText`, `OTr_LoadFromText` (and equivalent file-based methods)

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Format** | OT-specific serialisation | JSON-based serialisation |
| **Cross-compatibility** | — | Formats are mutually incompatible |
| **Round-trip safety** | Safe within OT | Safe within OTr |

**Impact:** Text or files exported by ObjectTools 5.0 cannot be imported by OTr. See §3.2 above for the recommended migration strategy.

---

### 3.5 Boolean Return Type

**Affected methods:** All methods that return a Boolean value (e.g., `OTr_IsObject`, `OTr_ItemExists`, `OTr_IsEmbedded`)

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Return type** | Native Boolean (True/False) | Integer (1 or 0) |

**Impact:** In most 4D contexts, Boolean and Integer are interchangeable in conditional expressions. However, code that uses strict type-checking or passes the return value to a typed variable declared as Boolean should be reviewed.

---

### 3.6 Object Copy Semantics

**Affected methods:** `OTr_PutObject`, `OTr_GetObject`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Semantics** | Reference semantics in certain configurations | Always performs a deep copy at storage and retrieval time |

**Impact:** Code that relies on shared mutation — that is, modifying a retrieved object and expecting the change to be visible in the OTr store without an explicit `PutObject` call — will not behave correctly. All modifications must be committed back to the store via an explicit `OTr_PutObject` call.

---

### 3.7 Pointer Round-Trip Limitation

**Affected methods:** `OTr_PutPointer`, `OTr_GetPointer`

| | ObjectTools 5.0 | OTr |
|---|---|---|
| **Local variable pointers (`$` prefix)** | Round-trip supported | Cannot be reliably round-tripped; known limitation of `Get pointer` scope resolution within component methods |
| **Process variable pointers (no `$` prefix)** | Round-trip supported | Round-trip supported correctly |

**Impact:** Code that stores and retrieves pointers to local variables will not function correctly under OTr. Refactor such code to use process variables if pointer round-tripping is required.

---

## Summary Table

| ObjectTools 5.0 Method | OTr Equivalent | Category | Nature of Change |
|---|---|---|---|
| `OT GetBLOB(obj; tag; outBLOB)` | `OTr_GetNewBLOB(obj; tag)` | Cannot implement | BLOB returned as function result; method renamed |
| `OT GetArrayBLOB` (output-param form) | Element accessor methods | Cannot implement | BLOB output parameter unsupported in components |
| `OT ObjectToBLOB(obj; ioBLOB)` | `OTr_ObjectToBLOB(obj)` | Changed signature | BLOB returned as function result |
| `OT BLOBToObject(blob; ioOffset)` | `OTr_BLOBToObject(blob)` | Changed signature | `ioOffset` parameter removed; always reads from byte 0 |
| `OT GetArrayPicture(obj; tag; idx; outPic)` | `OTr_GetArrayPicture(obj; tag; idx)` | Changed signature | Picture returned as function result |
| `OT PutRecord` / `OT GetRecord` | `OTr_PutRecord` / `OTr_GetRecord` | Changed behaviour | Snapshot semantics replace live reference semantics |
| `OT ObjectToBLOB` / `OT BLOBToObject` | `OTr_ObjectToBLOB` / `OTr_BLOBToObject` | Changed behaviour | OTr can import supported legacy OT BLOB payloads; OTr BLOBs remain OTr-only |
| Size introspection methods | OTr equivalents | Changed behaviour | JSON byte length rather than in-memory structure size |
| `OT SaveToText` / `OT LoadFromText` | `OTr_SaveToText` / `OTr_LoadFromText` | Changed behaviour | JSON format; incompatible with legacy OT text exports |
| Boolean-returning methods | OTr equivalents | Changed behaviour | Returns Integer (0/1) rather than native Boolean |
| `OT PutObject` / `OT GetObject` | `OTr_PutObject` / `OTr_GetObject` | Changed behaviour | Always deep-copies; reference semantics not supported |
| `OT PutPointer` / `OT GetPointer` | `OTr_PutPointer` / `OTr_GetPointer` | Changed behaviour | Local variable pointers cannot be round-tripped |

---

## See Also

- `OTr-Specification.md` — Master specification, §4 (Compatibility Constraints)
- `OTr-Phase-015-Spec.md` — Side-by-side compatibility testing specification
- `LegacyDocumentation/ObjectTools 5 Reference.pdf` — Original plugin reference
