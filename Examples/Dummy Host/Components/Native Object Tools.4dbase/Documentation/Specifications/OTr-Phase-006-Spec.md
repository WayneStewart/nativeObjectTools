# OTr Phase 6 — Import/Export and Binary Storage Refactor: Detailed Command Specification

**Version:** 1.0
**Date:** 2026-04-03
**Status:** Complete
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§9, Phase 6)
**Supersedes:** [OTr-Phase-006-Spec-Retired.md](OTr-Phase-006-Spec-Retired.md)

---

## Overview

Phase 6 has two distinct concerns:

1. **Retrospective refactor** of the binary storage mechanism for BLOBs and Pictures, replacing the parallel interprocess array pattern (introduced in earlier phases) with native in-object storage.
2. **Implementation** of the Import/Export routines (`OTr_ObjectToBLOB`, `OTr_ObjectToNewBLOB`, `OTr_BLOBToObject`) and the finalisation of `OTr_uMapType`.

These two concerns are addressed together because the serialisation approach adopted in §2 (Import/Export) is the direct consequence of the architectural decisions taken in §1 (Refactor). Both must be understood as a coherent whole.

---

## Part 1 — Retrospective Binary Storage Refactor

### 1.1 Background and Motivation

The original design (Phases 4–5) stored BLOBs and Pictures in a pair of parallel interprocess arrays:

- `<>OTR_Blobs_ablob` / `<>OTR_BlobInUse_ab`
- `<>OTR_Pictures_apic` / `<>OTR_PicInUse_ab`

Properties within the 4D Object held text proxy references (`"blob:N"`, `"pic:N"`) that indexed into these arrays. This design was predicated on the assumption that neither BLOBs nor Pictures could be stored directly as 4D Object property values.

This assumption is incorrect for the target version range:

- **Pictures** have been natively supported by `OB SET` / `OB Get` since **4D v16 R4** — well prior to the v19 LTS minimum.
- **BLOBs** have been natively supported by `OB SET` / `OB Get` since **4D v19R2** (encoded as `1920` by `Application version`).

The parallel array infrastructure, the proxy reference strings, and all associated slot-management code are therefore unnecessary and are retired in this phase.

### 1.2 Version Gate

`OTr_zInit` sets a flag at initialisation time to govern BLOB storage behaviour:

```
$ApplicationVersion_i := Num(Application version)
Use (Storage)
    Storage.OTr := New shared object("structureName"; $name; \
        "nativeBlobInObject"; ($ApplicationVersion_i >= 1920))
End use
```

The flag `Storage.OTr.nativeBlobInObject` is Boolean:

- `True` — v19R2 or later: BLOBs are stored directly as native Object property values via `OB SET` / `OB Get` with type `Is BLOB`.
- `False` — v19 or v19R1: BLOBs are base64-encoded and stored as Text property values. `OTr_uBlobToText` / `OTr_uTextToBlob` handle encoding and decoding respectively.

Pictures require no version gate. They are stored natively in all supported versions.

The flag is read from `Storage.OTr.nativeBlobInObject` at the point of use. Storing the flag in `Storage` (rather than an interprocess variable) ensures that all processes share the same value without requiring a semaphore at read time, and positions the architecture correctly for any future preemptive threading requirements.

### 1.3 Components Retired

The following methods and interprocess arrays are retired in this phase. They must be removed from `Compiler_OTr`, from `OTr_zInit`, and from `folders.json`.

**Interprocess arrays (remove from `Compiler_OTr` declarations and `OTr_zInit`):**

| Array | Former purpose |
|---|---|
| `<>OTR_Blobs_ablob` | Parallel BLOB storage |
| `<>OTR_BlobInUse_ab` | BLOB slot availability tracking |
| `<>OTR_Pictures_apic` | Parallel Picture storage |
| `<>OTR_PicInUse_ab` | Picture slot availability tracking |

**Methods retired (delete source files and remove from `folders.json`):**

| Method | Former purpose |
|---|---|
| `OTr_uPictureToText` | Allocated `pic:N` slot, returned proxy string |
| `OTr_uTextToPicture` | Resolved `pic:N` proxy string to Picture |
| `OTr_uExpandBinaries` | Expanded `blob:N`/`pic:N` proxies for serialisation |
| `OTr_uCollapseBinaries` | Collapsed binaries into proxy strings after deserialisation |

**Methods retired (delete source files and remove from `folders.json`):**

`OTr_zReleaseBinaryRef` and `OTr_zReleaseObjBinaries` are retired. With no parallel arrays and no proxy reference strings, there is nothing to release. Any call site that invoked these methods (e.g., the overwrite guards in `OTr_PutPicture`, `OTr_PutBLOB`, `OTr_PutArrayPicture`, `OTr_PutArrayBLOB`) must have those call lines removed.

**Methods revised (retain, but rewrite):**

`OTr_uBlobToText` and `OTr_uTextToBlob` are retained but entirely rewritten. Their new purpose is pure base64 encoding/decoding of a BLOB to/from a Text value, with no slot management, no reference strings, and no interaction with any interprocess array. They are only called when `Storage.OTr.nativeBlobInObject` is `False`.

### 1.4 Revised Method Specifications

#### OTr_PutPicture

**Change:** Remove the `OTr_zReleaseBinaryRef` call and the `OTr_uPictureToText` call. Store the Picture natively.

**Before:**
```
OTr_zReleaseBinaryRef(OB Get($parent_o; $leafKey_t; Is text))
OB SET($parent_o; $leafKey_t; OTr_uPictureToText($inValue_pic))
```

**After:**
```
OB SET($parent_o; $leafKey_t; $inValue_pic)
```

The overwrite guard (`OB Is defined` check) is retained, but the release call is removed. The existing value, if any, is simply overwritten — native Object properties require no explicit release.

---

#### OTr_GetPicture

**Change:** Remove the `OTr_uTextToPicture` call. Retrieve the Picture natively.

**Before:**
```
$result_pic := OTr_uTextToPicture(OB Get($parent_o; $leafKey_t; Is text))
```

**After:**
```
$result_pic := OB Get($parent_o; $leafKey_t; Is picture)
```

---

#### OTr_PutArrayPicture

**Change:** Remove `OTr_zReleaseBinaryRef` and `OTr_uPictureToText`. Store the Picture directly into the collection element.

**Before:**
```
$existingRef_t := $arrayObj_o[String($index_i)]
OTr_zReleaseBinaryRef($existingRef_t)
$arrayObj_o[String($index_i)] := OTr_uPictureToText($value_pic)
```

**After:**
```
$arrayObj_o[String($index_i)] := $value_pic
```

---

#### OTr_GetArrayPicture

**Change:** Remove `OTr_uTextToPicture`. Retrieve the Picture directly from the collection element.

**Before:**
```
$value_pic := OTr_uTextToPicture($arrayObj_o[String($index_i)])
```

**After:**
```
$value_pic := $arrayObj_o[String($index_i)]
```

---

#### OTr_PutBLOB

**Change:** Remove `OTr_zReleaseBinaryRef`. Branch on `Storage.OTr.nativeBlobInObject` for storage.

**Before:**
```
OTr_zReleaseBinaryRef(OB Get($parent_o; $leafKey_t; Is text))
OB SET($parent_o; $leafKey_t; OTr_uBlobToText($inValue_blob))
```

**After:**
```
If (Storage.OTr.nativeBlobInObject)
    OB SET($parent_o; $leafKey_t; $inValue_blob)
Else
    OB SET($parent_o; $leafKey_t; OTr_uBlobToText($inValue_blob))
End if
```

---

#### OTr_GetNewBLOB

**Change:** Remove `OTr_uTextToBlob` path. Branch on `Storage.OTr.nativeBlobInObject` for retrieval.

**Before:**
```
$result_blob := OTr_uTextToBlob(OB Get($parent_o; $leafKey_t; Is text))
```

**After:**
```
If (Storage.OTr.nativeBlobInObject)
    $result_blob := OB Get($parent_o; $leafKey_t; Is BLOB)
Else
    $result_blob := OTr_uTextToBlob(OB Get($parent_o; $leafKey_t; Is text))
End if
```

---

#### OTr_PutArrayBLOB

**Change:** Remove `OTr_zReleaseBinaryRef`. Branch on `Storage.OTr.nativeBlobInObject`.

**Before:**
```
$existingRef_t := $arrayObj_o[String($index_i)]
OTr_zReleaseBinaryRef($existingRef_t)
$arrayObj_o[String($index_i)] := OTr_uBlobToText($value_blob)
```

**After:**
```
If (Storage.OTr.nativeBlobInObject)
    $arrayObj_o[String($index_i)] := $value_blob
Else
    $arrayObj_o[String($index_i)] := OTr_uBlobToText($value_blob)
End if
```

---

#### OTr_GetArrayBLOB

**Change:** Branch on `Storage.OTr.nativeBlobInObject` for retrieval.

**Before:**
```
$value_blob := OTr_uTextToBlob($arrayObj_o[String($index_i)])
```

**After:**
```
If (Storage.OTr.nativeBlobInObject)
    $value_blob := $arrayObj_o[String($index_i)]
Else
    $value_blob := OTr_uTextToBlob($arrayObj_o[String($index_i)])
End if
```

---

#### OTr_uBlobToText (rewritten)

**New purpose:** Base64-encode a BLOB to a Text string for inline storage in an Object property. No slot management. No reference strings.

```
OTr_uBlobToText ($theBlob_x : Blob) → Text
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$theBlob_x` | Blob | → | The BLOB to encode |
| Function result | Text | ← | Base64-encoded representation |

**Implementation:** `BASE64 ENCODE` the BLOB into a Text result. Returns empty text if the BLOB is empty.

---

#### OTr_uTextToBlob (rewritten)

**New purpose:** Decode a base64 Text string back to a BLOB. No slot management.

```
OTr_uTextToBlob ($encoded_t : Text) → Blob
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$encoded_t` | Text | → | Base64-encoded text |
| Function result | Blob | ← | Decoded BLOB, or empty BLOB on failure |

**Implementation:** `BASE64 DECODE` the text into a BLOB result. Returns an empty BLOB if `$encoded_t` is empty.

---

#### OTr_uMapType

`OTr_uMapType` requires one update consequent on this refactor: the `Is picture` type no longer maps through a text-proxy path. The 4D → OT direction maps `Is picture` directly to OT Picture (3). The OT → 4D direction maps OT Picture (3) directly to `Is picture`. No special-casing or proxy handling is required.

See Part 2 §2.1 for the complete `OTr_uMapType` specification.

---

### 1.5 `Compiler_OTr` Changes

Remove the following declarations from `Compiler_OTr`:

```
// Remove — arrays no longer declared
ARRAY BOOLEAN(<>OTR_BlobInUse_ab; 0)
ARRAY BLOB(<>OTR_Blobs_ablob; 0)
ARRAY BOOLEAN(<>OTR_PicInUse_ab; 0)
ARRAY PICTURE(<>OTR_Pictures_apic; 0)

// Remove — methods retired
C_PICTURE(OTr_uPictureToText; $1)
C_TEXT(OTr_uPictureToText; $0)
C_TEXT(OTr_uTextToPicture; $1)
C_PICTURE(OTr_uTextToPicture; $0)
C_OBJECT(OTr_uExpandBinaries; $1; $0)
C_OBJECT(OTr_uCollapseBinaries; $1; $0)
C_TEXT(OTr_zReleaseBinaryRef; $1)
C_OBJECT(OTr_zReleaseObjBinaries; $1)
```

Update the `OTr_uBlobToText` and `OTr_uTextToBlob` declarations to reflect their new pure encode/decode signatures (parameters unchanged; internal implementation only differs).

---

### 1.6 `folders.json` Changes

From **`OT Utility Methods`** group, remove:
`OTr_uPictureToText`, `OTr_uTextToPicture`, `OTr_uExpandBinaries`, `OTr_uCollapseBinaries`

From **`OT Internal Methods`** group (or whichever group holds `z`-prefixed private methods), remove:
`OTr_zReleaseBinaryRef`, `OTr_zReleaseObjBinaries`

Add to **`OT API Methods`** group (public, `"shared":true`):
`OTr_BLOBToObject`, `OTr_ObjectToBLOB`, `OTr_ObjectToNewBLOB`

Add to **`OT Utility Methods`** group:
`OTr_uMapType`

Add to **`Test Methods`** group:
`____Test_Phase_6`

All entries within each group must be in alphabetical order.

---

## Part 2 — Import/Export Routines

### 2.1 Serialisation Approach

With Pictures stored natively in 4D Objects (since v16 R4) and BLOBs stored either natively (v19R2+) or as inline base64 text (v19–v19R1), the 4D Object held in `<>OTR_Objects_ao{handle}` is fully self-contained. No pre-processing is required before serialisation.

The serialisation pipeline is therefore:

**Save:**
1. Retrieve the object from `<>OTR_Objects_ao{$handle_i}`.
2. `VARIABLE TO BLOB` — serialises the object (including all native Picture and BLOB properties) into a BLOB using 4D's internal variable format.
3. `COMPRESS BLOB` with `GZIP best compression mode`.

**Load:**
1. `BLOB PROPERTIES` to determine compression state.
2. `EXPAND BLOB` if the BLOB is compressed.
3. `BLOB TO VARIABLE` — deserialises the BLOB back into a 4D Object.
4. Allocate a new handle and store the object.

This approach is modelled directly on `OBJ_Save_ToBlob` and `OBJ_Load_FromBlob` from Cannon Smith's OBJ_Module. There is no custom binary envelope, no magic header, no JSON round-trip, and no attachment table. The format is 4D's own native variable serialisation format, compressed with GZIP.

> **Compatibility note:** OTr BLOBs produced by `OTr_ObjectToBLOB` / `OTr_ObjectToNewBLOB` are **not** compatible with BLOBs produced by the legacy ObjectTools plugin commands `OT ObjectToBLOB` / `OT ObjectToNewBLOB`. The legacy format is a proprietary binary format unrelated to `VARIABLE TO BLOB`. Migration from legacy to OTr format requires loading via the legacy plugin and re-storing via OTr.

---

### 2.2 Utility Method: OTr_uMapType

```
OTr_uMapType ($nativeType_l : Integer {; $direction_l : Integer}) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$nativeType_l` | Integer | → | A type constant (either 4D native or OT legacy) |
| `{$direction_l}` | Integer | → | 0 (default) = 4D → OT; 1 = OT → 4D |
| Function result | Integer | ← | The mapped type constant |

#### Discussion

`OTr_uMapType` provides bidirectional mapping between native 4D type constants and legacy OT type constants. It is used throughout OTr wherever type resolution is required — by `OTr_ItemType`, `OTr_GetAllNamedProperties`, `OTr_GetItemProperties`, `OTr_GetNamedProperties`, and the serialisation/deserialisation routines.

**4D → OT mapping (direction 0, default):**

| 4D Type Constant | OT Type Constant | Value |
|---|---|---|
| `Is longint` / `Is integer` | OT Longint | 5 |
| `Is real` | OT Real | 1 |
| `Is text` | OT Character | 112 |
| `Is date` | OT Date | 4 |
| `Is time` | OT Time | 11 |
| `Is boolean` | OT Boolean | 6 |
| `Is BLOB` | OT BLOB | 30 |
| `Is picture` | OT Picture | 3 |
| `Is pointer` | OT Pointer | 23 |
| `Is object` | OT Object | 114 |
| `Is collection` | OT Array (Character) | 113 |

**OT → 4D mapping (direction 1):** The inverse of the above table. OT Record (115) and OT Variable (24) have no direct 4D equivalent and map to `Is text` (they are stored as prefixed text strings). If the input type has no known mapping, zero is returned.

#### OTr Implementation Notes

Implement as a `Case of` structure. Note that `Is text` in the 4D → OT direction always maps to OT Character (112); prefix-based disambiguation of Pointer, Record, and Variable stored-as-text is the responsibility of `OTr_ItemType`, not of this method. `Is picture` now maps directly to OT Picture (3) — no proxy type handling is required.

This method is finalised in Phase 6 because the full type mapping table is not exercised until the serialisation format encodes and decodes all supported types.

---

### 2.3 OTr_ObjectToBLOB

**Legacy:** `OT ObjectToBLOB` — version 1

> **Signature divergence from legacy.** The legacy plugin command declared its second parameter as a bidirectional BLOB (`↔`), which allowed the plugin to write back through the parameter directly. Native 4D methods pass BLOBs by value — any assignment to a BLOB parameter inside a method has no effect on the caller's variable. This is an irreconcilable difference between plugin and native method behaviour.
>
> The OTr signature therefore **replaces the bidirectional BLOB parameter with a Pointer to a BLOB**. This is the exact inverse of the advice given in the legacy `OT ObjectToBLOB` documentation, which explicitly warned against passing a dereferenced pointer. That warning was specific to the plugin's own parameter-passing constraints and does not apply here. The pointer approach is the correct and only viable mechanism for a native 4D method to write back to a caller's BLOB variable.
>
> Callers migrating from the legacy plugin must change `OT ObjectToBLOB(handle; myBlob)` to `OTr_ObjectToBLOB(handle; ->myBlob)`. Users who prefer not to manage a pointer should use `OTr_ObjectToNewBLOB` instead, which returns the BLOB as a function result and requires no change in calling convention.

```
OTr_ObjectToBLOB ($inObject_i : Integer; $ioBLOB_ptr : Pointer {; $inAppend_i : Integer})
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$inObject_i` | Integer | → | An object handle |
| `$ioBLOB_ptr` | Pointer | → | Pointer to a BLOB variable which receives the object |
| `{$inAppend_i}` | Integer | → | 0 to replace the target BLOB's contents (default), non-zero to append |

#### Discussion

`OTr_ObjectToBLOB` serialises an object into the BLOB pointed to by `$ioBLOB_ptr`. The previous contents of that BLOB, if any, are completely replaced, unless a non-zero value is passed in `$inAppend_i`, in which case the serialised object is appended to the existing BLOB contents.

Once stored within a BLOB, an object must be retrieved with `OTr_BLOBToObject`, not with `BLOB TO VARIABLE` called directly by the caller.

If `$inObject_i` is not a valid object handle, or if `$ioBLOB_ptr` is Nil, an error is generated, `OK` is set to zero, and the target BLOB is cleared.

> **Note:** The object passed to `OTr_ObjectToBLOB` is copied into the BLOB and remains in memory. You must clear it with `OTr_Clear` when you no longer need it.

> **Note:** To store the serialised object directly into a BLOB field, either use `OTr_ObjectToNewBLOB` and assign its result to the field, or use an intermediate local variable with `OTr_ObjectToBLOB` and then assign the local variable to the field.

#### OTr Implementation Notes

1. Validate the handle via `OTr_zIsValidHandle`. Validate that `$ioBLOB_ptr # Nil`. On any failure, clear the target BLOB (`$ioBLOB_ptr-> := <empty blob>`), generate an error, set OK to zero, and return.
2. Retrieve the object: `$obj_o := <>OTR_Objects_ao{$inObject_i}`.
3. Serialise: `VARIABLE TO BLOB($obj_o; $serialised_blob)`.
4. Compress: `COMPRESS BLOB($serialised_blob; GZIP best compression mode)`.
5. If `$inAppend_i` is non-zero, append `$serialised_blob` to `$ioBLOB_ptr->` via `COPY BLOB`. Otherwise, assign `$ioBLOB_ptr-> := $serialised_blob`.

#### See Also

[OTr_BLOBToObject](#otr_blobtoobject), [OTr_ObjectToNewBLOB](#otr_objecttonewblob)

---

### 2.4 OTr_ObjectToNewBLOB

**Legacy:** `OT ObjectToNewBLOB` — version 1.5

```
OTr_ObjectToNewBLOB ($inObject_i : Integer) → Blob
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$inObject_i` | Integer | → | An object handle |
| Function result | Blob | ← | A new BLOB containing the serialised object, or empty BLOB on error |

#### Discussion

`OTr_ObjectToNewBLOB` serialises an object into a new BLOB returned as the function result. This is the recommended form for serialising objects destined for storage in a BLOB field, as it avoids the parameter-passing constraints of `OTr_ObjectToBLOB`.

If `$inObject_i` is not a valid object handle, an error is generated, `OK` is set to zero, and an empty BLOB is returned.

> **Note:** The object remains in memory after serialisation. Clear it with `OTr_Clear` when no longer needed.

#### OTr Implementation Notes

Functionally identical to `OTr_ObjectToBLOB` with `$inAppend_i` = 0, except the BLOB is returned as the function result. Implementation may share internal logic with `OTr_ObjectToBLOB`.

#### See Also

[OTr_BLOBToObject](#otr_blobtoobject), [OTr_ObjectToBLOB](#otr_objecttoblob)

---

### 2.5 OTr_BLOBToObject

**Legacy:** `OT BLOBToObject` — version 1

```
OTr_BLOBToObject ($inBLOB_blob : Blob) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$inBLOB_blob` | Blob | → | A BLOB containing a serialised object |
| Function result | Integer | ← | A handle to the new object, or 0 on error |

#### Discussion

`OTr_BLOBToObject` deserialises an object from a BLOB into a new object handle. The BLOB must have been produced by `OTr_ObjectToBLOB` or `OTr_ObjectToNewBLOB`.

If the BLOB is empty, malformed, or does not contain a valid serialised 4D Object, an error is generated, `OK` is set to zero, and zero is returned.

> **Note:** The original legacy `OT BLOBToObject` accepted an optional `ioOffset` parameter to support reading multiple objects sequentially from a single BLOB. This parameter is not implemented in OTr. If multiple objects must be stored together, use separate BLOBs or store handles as an array.

> **Warning:** The handle returned is a new object added to OTr's internal registry. You must clear it with `OTr_Clear` when you no longer need it.

#### OTr Implementation Notes

1. Check that `BLOB size($inBLOB_blob) > 0`. On failure, generate an error, set OK to zero, return 0.
2. Work on a local copy: `$work_blob := $inBLOB_blob`.
3. Check compression: `BLOB PROPERTIES($work_blob; $compressed_i)`. If `$compressed_i # Is not compressed`, call `EXPAND BLOB($work_blob)`.
4. Deserialise: `BLOB TO VARIABLE($work_blob; $obj_o)`. Confirm that `$obj_o` is a valid Object (i.e. `OB Is defined` or type check). On failure, generate an error, set OK to zero, return 0.
5. Allocate a new handle via the standard slot-scanning algorithm (as per `OTr_New`).
6. Store: `<>OTR_Objects_ao{$handle} := $obj_o`.
7. Mark in use: `<>OTR_InUse_ab{$handle} := True`.
8. Return `$handle`.

#### See Also

[OTr_ObjectToBLOB](#otr_objecttoblob), [OTr_ObjectToNewBLOB](#otr_objecttonewblob)

---

## Part 3 — Naming Convention

All methods implemented or revised in this phase must conform to the standard defined in **[OTr-Phase-007-Spec.md](OTr-Phase-007-Spec.md)**:

- **Parameter names** in `#DECLARE` and the `Parameters:` comment block use the OT semantic name as the base with the OTr type suffix appended. The authoritative suffix table is in **[OTr-Types-Reference.md](OTr-Types-Reference.md)**.
- **The `Project Method:` comment line** uses OT-style names without `$` or suffix.
- **The `**ORIGINAL DOCUMENTATION**` block** is included in every method header that has an OT counterpart.

`OTr_PutString.4dm` remains the reference implementation for the correct header format.

---

## Cross-Reference Index

| OTr Method | Legacy Command | Category | Action |
|---|---|---|---|
| `OTr_uMapType` | *(utility)* | Utility | Implement (finalise) |
| `OTr_ObjectToBLOB` | `OT ObjectToBLOB` (v1) | Import/Export | Implement |
| `OTr_ObjectToNewBLOB` | `OT ObjectToNewBLOB` (v1.5) | Import/Export | Implement |
| `OTr_BLOBToObject` | `OT BLOBToObject` (v1) | Import/Export | Implement |
| `OTr_PutPicture` | `OT PutPicture` | Scalar Put | Revise |
| `OTr_GetPicture` | `OT GetPicture` | Scalar Get | Revise |
| `OTr_PutArrayPicture` | `OT PutArrayPicture` | Array Put | Revise |
| `OTr_GetArrayPicture` | `OT GetArrayPicture` | Array Get | Revise |
| `OTr_PutBLOB` | `OT PutBLOB` | Scalar Put | Revise |
| `OTr_GetNewBLOB` | `OT GetNewBLOB` | Scalar Get | Revise |
| `OTr_PutArrayBLOB` | `OT PutArrayBLOB` | Array Put | Revise |
| `OTr_GetArrayBLOB` | `OT GetArrayBLOB` | Array Get | Revise |
| `OTr_uBlobToText` | *(utility)* | Utility | Rewrite (base64 only) |
| `OTr_uTextToBlob` | *(utility)* | Utility | Rewrite (base64 only) |
| `OTr_uPictureToText` | *(utility)* | Utility | **Retire** |
| `OTr_uTextToPicture` | *(utility)* | Utility | **Retire** |
| `OTr_uExpandBinaries` | *(utility)* | Utility | **Retire** |
| `OTr_uCollapseBinaries` | *(utility)* | Utility | **Retire** |
| `OTr_zReleaseBinaryRef` | *(internal)* | Internal | **Retire** |
| `OTr_zReleaseObjBinaries` | *(internal)* | Internal | **Retire** |
| `Compiler_OTr` | *(declarations)* | Infrastructure | Revise |
| `OTr_zInit` | *(initialisation)* | Infrastructure | Revised (already done) |
