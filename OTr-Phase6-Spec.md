# OTr Phase 6 — Import/Export: Detailed Command Specification

**Version:** 0.1
**Date:** 2026-04-01
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§9, Phase 6)

---

## Overview

Phase 6 implements the **Import/Export Routines** from the legacy ObjectTools 5.0 plugin. These commands provide the ability to serialise an entire OTr object to a BLOB for persistent storage (in database fields or disk files) and to reconstitute an object from such a BLOB. Phase 6 also finalises the `OTr__MapType` internal helper used throughout the serialisation and deserialisation pipeline.

Phase 6 depends upon all preceding phases: the handle registry and locking from Phase 1, scalar storage from Phase 2, introspection from Phase 3, array/Collection support from Phase 4, and the complex type serialisation mechanisms from Phase 5 (BLOB/Picture parallel arrays, Pointer serialisation, Record references, and Variable storage).

### Serialisation Format

The legacy plugin uses a proprietary binary format for `OT ObjectToBLOB` / `OT BLOBToObject`. OTr replaces this with a **JSON-based serialisation** format, since the underlying storage model is already a native 4D Object. The serialised BLOB contains:

1. A **header** identifying the format as OTr (to distinguish from legacy ObjectTools BLOBs and from arbitrary BLOB data).
2. The **JSON representation** of the object, produced by `JSON Stringify`.
3. A **binary appendix** containing the actual BLOB and Picture data referenced by `blob:N` and `pic:N` properties within the object.

The header structure is:

| Offset | Size | Content |
|---|---|---|
| 0 | 4 bytes | Magic identifier: `"OTR1"` (ASCII) |
| 4 | 4 bytes | JSON length in bytes (Longint, big-endian) |
| 8 | *n* bytes | JSON text (UTF-8 encoded) |
| 8+*n* | 4 bytes | Number of binary attachments (Longint) |
| 12+*n* | variable | Binary attachment table (see below) |

Each binary attachment entry consists of:

| Field | Size | Content |
|---|---|---|
| Type | 1 byte | `0x01` = BLOB, `0x02` = Picture |
| Slot index | 4 bytes | Original parallel array slot index (Longint) |
| Data length | 4 bytes | Length of the binary data (Longint) |
| Data | variable | The raw binary data |

This format allows `OTr_BLOBToObject` to reconstruct both the object's property structure and its associated binary data in a single pass.

> **Note:** OTr's serialisation format is **not** compatible with the legacy ObjectTools binary format. BLOBs created by `OT ObjectToBLOB` cannot be read by `OTr_BLOBToObject`, and vice versa. Migration from legacy to OTr format requires loading via the legacy plugin and re-storing via OTr.

### Commands in This Phase

**Internal Helpers:**
`OTr__MapType`

**Import/Export Routines:**
`OTr_ObjectToBLOB`, `OTr_ObjectToNewBLOB`, `OTr_BLOBToObject`

---

## Internal Helper Methods

---

### OTr__MapType

```
OTr__MapType ($nativeType_l : Integer {; $direction_l : Integer}) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $nativeType_l | Integer | → | A type constant (either 4D native or OT legacy) |
| {$direction_l} | Integer | → | 0 (default) = 4D → OT; 1 = OT → 4D |
| Function result | Integer | ← | The mapped type constant |

#### Discussion

`OTr__MapType` provides bidirectional mapping between native 4D type constants and legacy OT type constants. This method is used throughout OTr wherever type resolution is required — by `OTr_ItemType`, `OTr_GetAllNamedProperties`, `OTr_GetItemProperties`, `OTr_GetNamedProperties`, and the serialisation/deserialisation routines.

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

**OT → 4D mapping (direction 1):** The inverse of the above table. OT Record (115) and OT Variable (24) have no direct 4D equivalent and map to `Is text` (since they are stored as prefixed text strings).

If the input type has no known mapping, zero is returned.

#### OTr Implementation Notes

Implement as a `Case of` / series of `If` branches. The method must handle the special cases: `Is text` can represent several OT types (Character, Date, Time, BLOB, Picture, Pointer, Record, Variable) depending on the stored value's prefix — `OTr__MapType` handles only the *structural* type mapping, not the prefix-based disambiguation (which is the responsibility of `OTr_ItemType`'s resolution algorithm, described in §3.6 of the parent specification).

This method is finalised in Phase 6 because the full type mapping table is not exercised until the serialisation format needs to encode and decode all supported types.

---

## Import/Export Routines

The following routines provide the ability to import and export objects to 4D BLOB variables. This allows you to save and restore objects either to the database or to files on disk.

---

### OTr_ObjectToBLOB

**Legacy:** `OT ObjectToBLOB` — version 1

```
OTr_ObjectToBLOB ($handle_i : Integer; $ioBLOB : Blob {; $append_l : Integer})
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | An object handle |
| $ioBLOB | Blob | ↔ | A BLOB which receives the object |
| {$append_l} | Integer | → | 0 to replace `$ioBLOB`'s contents (default), non-zero to append |

#### Discussion

`OTr_ObjectToBLOB` serialises an object into a BLOB. The previous contents of the BLOB, if any, are completely replaced, unless a non-zero value is passed in `$append_l`, in which case the serialised object is appended to the existing BLOB contents.

Once stored within a BLOB, you must retrieve an object from it with `OTr_BLOBToObject`, not with `BLOB TO VARIABLE`.

If `$handle_i` is not a valid object handle, if `$ioBLOB` is not a valid BLOB, or if memory cannot be allocated to copy the object, an error is generated, `OK` is set to zero, and `$ioBLOB` is cleared.

> **Warning:** Do not attempt to pass a BLOB field or a dereferenced pointer to a BLOB field in the `$ioBLOB` parameter, as this will result in a crash. If you want to store a BLOB item into a field, either use an intermediate local variable or assign the result of `OTr_ObjectToNewBLOB` to the field. The same applies to passing a dereferenced pointer to a BLOB variable.

> **Note:** The object passed to `OTr_ObjectToBLOB` is copied into the BLOB and remains in memory. You must be sure to clear it with `OTr_Clear` when you no longer need it.

#### OTr Implementation Notes

1. Validate the handle.
2. Retrieve the object from `<>OTR_Objects_ao{$handle_i}`.
3. Serialise the object to JSON via `JSON Stringify`.
4. Scan all text properties (recursively through embedded objects) for `blob:N` and `pic:N` references. For each reference found, read the binary data from the parallel arrays and add it to the binary attachment list.
5. Build the BLOB according to the header format described in the Overview:
   - Write the `"OTR1"` magic identifier.
   - Write the JSON length and JSON data (UTF-8 encoded via `CONVERT FROM TEXT`).
   - Write the number of binary attachments and the attachment table.
6. If `$append_l` is non-zero, append the constructed BLOB to `$ioBLOB` using `COPY BLOB`. Otherwise, replace `$ioBLOB` entirely.

#### See Also

[OTr_BLOBToObject](#otr_blobtoobject), [OTr_ObjectToNewBLOB](#otr_objecttonewblob)

---

### OTr_ObjectToNewBLOB

**Legacy:** `OT ObjectToNewBLOB` — version 1.5

```
OTr_ObjectToNewBLOB ($handle_i : Integer) → Blob
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | An object handle |
| Function result | Blob | ← | A new BLOB which contains the object |

#### Discussion

`OTr_ObjectToNewBLOB` serialises an object into a new BLOB, returned as the function result. This is the recommended method for serialising objects, as it avoids the parameter-passing issues associated with `OTr_ObjectToBLOB`.

Once stored within a BLOB, you must retrieve an object from it with `OTr_BLOBToObject`, not with `BLOB TO VARIABLE`.

If `$handle_i` is not a valid object handle or if memory cannot be allocated to copy the object, an error is generated, `OK` is set to zero, and an empty BLOB is returned.

> **Note:** The object passed to `OTr_ObjectToNewBLOB` is copied into the BLOB and remains in memory. You must be sure to clear it with `OTr_Clear` when you no longer need it.

#### OTr Implementation Notes

Functionally identical to `OTr_ObjectToBLOB` with `$append_l` = 0, except that the BLOB is returned as the function result rather than via an in/out parameter. Implementation may delegate to the same internal serialisation logic.

#### See Also

[OTr_BLOBToObject](#otr_blobtoobject), [OTr_ObjectToBLOB](#otr_objecttoblob)

---

### OTr_BLOBToObject

**Legacy:** `OT BLOBToObject` — version 1

```
OTr_BLOBToObject ($inBLOB : Blob {; $ioOffset_l : Integer}) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $inBLOB | Blob | → | A BLOB which contains an object |
| {$ioOffset_l} | Integer | ↔ | The offset within the BLOB where the object can be found; updated to point past the object on return |
| Function result | Integer | ← | A handle to the new object, or 0 on error |

#### Discussion

`OTr_BLOBToObject` deserialises an object from a BLOB into a new object handle. The object must have been stored in the BLOB with `OTr_ObjectToBLOB` or `OTr_ObjectToNewBLOB`, not with `VARIABLE TO BLOB`.

If `$ioOffset_l` is not passed, it defaults to zero (read from the beginning of the BLOB).

If the bytes at the given offset do not describe an object stored with `OTr_ObjectToBLOB` / `OTr_ObjectToNewBLOB`, an error is generated, `OK` is set to zero, `$ioOffset_l` is left untouched, and a null handle (0) is returned.

> **Warning:** The handle returned is a new object that is added to OTr's internal list of objects. You must be sure to clear the new object with `OTr_Clear` when you no longer need it.

#### OTr Implementation Notes

1. Read 4 bytes at `$ioOffset_l` and verify the `"OTR1"` magic identifier. If the magic does not match, this may be a legacy ObjectTools BLOB — generate an appropriate error message indicating format incompatibility and return 0.
2. Read the JSON length (4 bytes), then read the JSON text (UTF-8, convert via `Convert to text`).
3. Parse the JSON into a 4D Object via `JSON Parse`.
4. Read the binary attachment count and iterate over the attachment table:
   - For each BLOB attachment (`0x01`): allocate a slot in `<>OTR_Blobs_ax`, store the binary data, and mark it in-use. The `blob:N` references in the JSON object already contain the original slot indices; these must be remapped to the newly allocated slot indices. Update the corresponding object properties accordingly.
   - For each Picture attachment (`0x02`): allocate a slot in `<>OTR_Pictures_ap`, store the picture data, and mark it in-use. Remap `pic:N` references similarly.
5. Allocate a new handle via the standard `OTr_New` slot-scanning algorithm.
6. Store the reconstructed object in `<>OTR_Objects_ao{$handle}`.
7. Update `$ioOffset_l` to point past the end of the serialised data.
8. Return the new handle.

> **Note:** The slot index remapping in step 4 is critical — the original slot indices from the source process/session will almost certainly not correspond to available slots in the current session. The deserialiser must build a mapping table (old index → new index) and perform a find-and-replace across all `blob:N` and `pic:N` references in the reconstructed object.

#### See Also

[OTr_ObjectToBLOB](#otr_objecttoblob), [OTr_ObjectToNewBLOB](#otr_objecttonewblob)

---

## Cross-Reference Index

| OTr Method | Legacy Command | Category |
|---|---|---|
| `OTr__MapType` | *(internal)* | Internal Helper |
| `OTr_ObjectToBLOB` | `OT ObjectToBLOB` (v1) | Import/Export |
| `OTr_ObjectToNewBLOB` | `OT ObjectToNewBLOB` (v1.5) | Import/Export |
| `OTr_BLOBToObject` | `OT BLOBToObject` (v1) | Import/Export |
