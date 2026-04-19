# OTr Phase 5 — Complex Types: Detailed Command Specification

**Version:** 0.3
**Date:** 2026-04-03
**Status:** Complete
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§9, Phase 5)

---

## Overview

Phase 5 implements the **Pointer**, **BLOB**, **Picture**, **Record**, and **Variable** put/get routines from the legacy ObjectTools 5.0 plugin. These commands handle types that require serialisation for storage as 4D Object properties.

Phase 5 depends upon:
- Phase 1: handle registry (`<>OTR_Objects_ao`, `<>OTR_InUse_ab`), locking (`OTr_zLock`/`OTr_zUnlock`), error handling (`OTr_zError`, `OTr_zSetOK`), handle validation (`OTr_zIsValidHandle`)
- Phase 2: path resolution (`OTr_zResolvePath`)
- Phase 4 utility methods: `OTr_uPointerToText`, `OTr_uTextToPointer`, `OTr_uBlobToText`, `OTr_uTextToBlob`, `OTr_uDateToText`, `OTr_uTextToDate`, `OTr_uTimeToText`, `OTr_uTextToTime`

Note: `OTr_uPictureToText` and `OTr_uTextToPicture` are not dependencies — Pictures are stored natively in 4D Objects (v16R4+) and require no serialisation. `OTr_zReleaseBinaryRef` is not required — native Object properties are released automatically when overwritten or when the object slot is cleared.

---

### Storage Mechanisms

The types addressed in Phase 5 each require a distinct storage strategy, as 4D Objects cannot natively hold BLOB, Picture, Pointer, Record, or arbitrary Variable values via `OB SET`. The parent specification (§3.6) defines the following storage conventions:

| OT Type | Runtime Storage | Example Value | Notes |
|---|---|---|---|
| Pointer | Text | `"myVar;-1;0"` | Via `RESOLVE POINTER` — no prefix |
| BLOB | BLOB (or Text base64) | — | Native on v19R2+; base64 Text via `OTr_uBlobToText` on v19/v19R1 |
| Picture | Picture | — | Stored natively as an Object property (4D v16R4+) |
| Record | Object | `{__tableNum:3, LastName:"Stewart", ...}` | Sub-object snapshot; all fields serialised by name |
| Variable | Text | `"var:text:Wayne"` | `var:typeName:serialisedValue` |

**Export storage** — BLOB and Picture values stored natively in the Object are preserved inline by the JSON serialiser used in the Phase 6 export methods (`OTr_ObjectToBLOB`, `OTr_SaveToText`, etc.). No expansion or contraction step is required.

---

### Commands in This Phase

**Pointer Routines:**
`OTr_PutPointer`, `OTr_GetPointer`

**BLOB Routines:**
`OTr_PutBLOB`, `OTr_GetBLOB`, `OTr_GetNewBLOB`

**Picture Routines:**
`OTr_PutPicture`, `OTr_GetPicture`

**Record Routines:**
`OTr_PutRecord`, `OTr_GetRecord`, `OTr_GetRecordTable`

**Variable Routines:**
`OTr_PutVariable`, `OTr_GetVariable`

---

## Type Constants

For the authoritative reference of 4D type constants and their mapping to legacy OT constants, see [OTr-Types-Reference.md](OTr-Types-Reference.md).

---

## folders.json Registration

Every new method created in this phase must be added to the appropriate group in `Project/Sources/folders.json`. The groups and their new members are:

**`OT API Methods`** (public, `"shared":true`):
`OTr_PutPointer`, `OTr_GetPointer`, `OTr_PutBLOB`, `OTr_GetBLOB`, `OTr_GetNewBLOB`, `OTr_PutPicture`, `OTr_GetPicture`, `OTr_PutRecord`, `OTr_GetRecord`, `OTr_GetRecordTable`, `OTr_PutVariable`, `OTr_GetVariable`

**`Test Methods`**:
`____Test_Phase_5`

Entries within each group must be inserted in alphabetical order, consistent with the existing pattern.

---

## Naming Convention and Header Block Standard

All methods implemented in this phase must conform to the standard defined in **[OTr-Phase-007-Spec.md](OTr-Phase-007-Spec.md)**:

- **Parameter names** in `#DECLARE` and the `Parameters:` comment block use the OT semantic name as the base (`inObject`, `inTag`, `inValue`, etc.) with the OTr type suffix appended (`$inObject_i`, `$inTag_t`, `$inValue_blob`, `$inTable_i`, etc.). The authoritative suffix table is in **[OTr-Types-Reference.md](OTr-Types-Reference.md)**.
- **The `Project Method:` comment line** uses OT-style names without `$` or suffix, matching the OT manual exactly.
- **The `**ORIGINAL DOCUMENTATION**` block** is included in every method header that has an OT counterpart, reproducing the relevant text from *ObjectTools 5 Reference*.

The `OTr_PutString.4dm` method is the reference implementation for the correct header format.

---

## Established Implementation Patterns

All Phase 5 public methods follow the patterns established in Phases 1–4. The key conventions are:

**Locking:** Public methods acquire `OTr_zLock` at entry and release `OTr_zUnlock` at exit. Utility and private methods (`OTr_u*`, `OTr_z*`) do not lock — they assume the caller holds the lock when operating on the parallel arrays.

**Error signalling:** Every error path calls both `OTr_zError($message_t; Current method name)` and `OTr_zSetOK(0)`. Successful paths do not call `OTr_zSetOK` — `OK` remains at its default value of 1.

**Handle validation:** Always the first operation inside the lock: `If (OTr_zIsValidHandle($handle_i))`. If invalid, call `OTr_zError("Invalid handle"; Current method name)` and `OTr_zSetOK(0)`, then fall through to the unlock.

**Binary storage — BLOB write path:** Check `Storage.OTr.nativeBlobInObject`. If `True` (v19R2+), store via `OB SET($parent_o; $leafKey_t; $value_blob)`. If `False` (v19/v19R1), encode via `OTr_uBlobToText($value_blob)` and store the resulting Text. Overwriting an existing property requires no explicit cleanup — `OB SET` replaces the previous value and native memory management handles the release.

**Binary storage — BLOB read path:** Check `Storage.OTr.nativeBlobInObject`. If `True`, retrieve via `OB Get($parent_o; $leafKey_t; Is BLOB)`. If `False`, retrieve the Text property and decode via `OTr_uTextToBlob($base64_t)`.

**Binary storage — Picture write path:** Store directly via `OB SET($parent_o; $leafKey_t; $value_pic)`. No conversion or slot management required.

**Binary storage — Picture read path:** Retrieve directly via `OB Get($parent_o; $leafKey_t; Is picture)`.

---

## Pointer Routines

---

### OTr_PutPointer

**Legacy:** `OT PutPointer` — version 1

```
OTr_PutPointer ($handle_i : Integer; $tag_t : Text; $value_pictr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to set |
| $value_pictr | Pointer | → | Pointer to store |

#### Discussion

`OTr_PutPointer` stores a Pointer value into the object.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type *Is Pointer*, its value is replaced.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

> **Warning:** Under no circumstances should you attempt to store a pointer to a local or process variable in a compiled database and then try to retrieve that pointer in another process. Variable addresses differ between processes in compiled mode, and the retrieved pointer will reference an invalid memory location.

#### OTr Implementation Notes

```
OTr_zLock

If (OTr_zIsValidHandle($handle_i))
    If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; True; ->$parent_o; ->$leafKey_t))
        OB SET($parent_o; $leafKey_t; OTr_uPointerToText($value_pictr))
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

OTr_zUnlock
```

Serialise the pointer via `OTr_uPointerToText` to produce a `"variableName;tableNum;fieldNum"` string. Store the resulting text as the object property value. Note that Pointer properties carry no disambiguating prefix — type is known from context. Type-mismatch checking against `VariantItems` follows the same pattern as the Phase 2 Put methods.

#### See Also

[OTr_GetPointer](#otr_getpointer)

---

### OTr_GetPointer

**Legacy:** `OT GetPointer` — version 1

```
OTr_GetPointer ($handle_i : Integer; $tag_t : Text; $outPointer : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to retrieve |
| $outPointer | Pointer | ← | The retrieved pointer (Null on error) |

#### Discussion

`OTr_GetPointer` retrieves a Pointer value from the object. The pointer is returned via the `$outPointer` output parameter.

If the object is not a valid object handle, an error is generated, `OK` is set to zero, and a Null pointer is returned.

If no item in the object has the given tag, a Null pointer is returned. If the `FailOnItemNotFound` option is set, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *Is Pointer*, the value of the requested element is returned.

If an item with the given tag exists and has any other type, an error is generated, `OK` is set to zero, and a Null pointer is returned.

> **Warning:** Under no circumstances should you attempt to store a pointer to a local or process variable in a compiled database and then try to retrieve that pointer in another process.

#### OTr Implementation Notes

```
OTr_zLock

If (OTr_zIsValidHandle($handle_i))
    If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; ->$parent_o; ->$leafKey_t))
        If (OB Is defined($parent_o; $leafKey_t))
            $outPointer:=OTr_uTextToPointer(OB Get($parent_o; $leafKey_t; Is text))
        End if
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

OTr_zUnlock
```

`OTr_uTextToPointer` returns `Null` if the stored text is malformed or the named variable cannot be resolved. If `Null` is returned and the caller supplied a typed output variable, the output will remain at its default value.

> **Note:** The absence of a `ptr:` prefix means that type detection for Pointer properties must rely on context. Callers should not use `OTr_GetPointer` on a property that was not set with `OTr_PutPointer`.

#### See Also

[OTr_PutPointer](#otr_putpointer)

---

## BLOB Routines

BLOB values are stored natively as Object properties on 4D v19R2 or later. On v19 and v19R1, BLOBs are base64-encoded as Text via `OTr_uBlobToText`. The correct path is selected at runtime using the `Storage.OTr.nativeBlobInObject` flag set during initialisation. See §3.7 of the parent specification.

---

### OTr_PutBLOB

**Legacy:** `OT PutBLOB` — version 1

```
OTr_PutBLOB ($handle_i : Integer; $tag_t : Text; $value_blob : Blob)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to set |
| $value_blob | Blob | → | 4D BLOB to store |

#### Discussion

`OTr_PutBLOB` stores a BLOB value into the object.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type *Is BLOB*, its value is replaced. No explicit cleanup of the previous value is required — `OB SET` releases it automatically.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

#### OTr Implementation Notes

```
OTr_zLock

If (OTr_zIsValidHandle($handle_i))
    If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; True; ->$parent_o; ->$leafKey_t))
        If (Storage.OTr.nativeBlobInObject)
            OB SET($parent_o; $leafKey_t; $value_blob)
        Else
            OB SET($parent_o; $leafKey_t; OTr_uBlobToText($value_blob))
        End if
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

OTr_zUnlock
```

On v19R2 or later (`Storage.OTr.nativeBlobInObject` = `True`), the BLOB is stored natively via `OB SET`. On v19/v19R1, `OTr_uBlobToText` base64-encodes the BLOB to Text for storage.

#### See Also

[OTr_GetBLOB](#otr_getblob), [OTr_GetNewBLOB](#otr_getnewblob)

---

### OTr_GetBLOB

**Legacy:** `OT GetBLOB` — version 1

```
OTr_GetBLOB ($handle_i : Integer; $tag_t : Text; $outBLOB : Blob)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to retrieve |
| $outBLOB | Blob | ← | The retrieved item (empty on error) |

#### Discussion

`OTr_GetBLOB` retrieves a BLOB value from the object into the `$outBLOB` parameter.

If the object is not a valid object handle, an error is generated, `OK` is set to zero, and an empty BLOB is returned.

If no item in the object has the given tag, an empty BLOB is returned. If the `FailOnItemNotFound` option is set, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *Is BLOB*, `$outBLOB`'s contents are replaced.

If an item with the given tag exists and has any other type, an error is generated, `OK` is set to zero, and an empty BLOB is returned.

> **Warning:** Do not attempt to pass a BLOB field or a dereferenced pointer to a BLOB field in the `$outBLOB` parameter. If you want to retrieve a BLOB item into a field, either use an intermediate local variable or assign the result of `OTr_GetNewBLOB` to the field. This command is retained for backward compatibility. Use `OTr_GetNewBLOB` in preference.

#### OTr Implementation Notes

```
OTr_zLock

If (OTr_zIsValidHandle($handle_i))
    If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; ->$parent_o; ->$leafKey_t))
        If (OB Is defined($parent_o; $leafKey_t))
            If (Storage.OTr.nativeBlobInObject)
                $outBLOB:=OB Get($parent_o; $leafKey_t; Is BLOB)
            Else
                $outBLOB:=OTr_uTextToBlob(OB Get($parent_o; $leafKey_t; Is text))
            End if
        End if
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

OTr_zUnlock
```

The crash risk described in the legacy warning is substantially mitigated in the native OTr implementation, but the warning is preserved for documentation fidelity. Delegates to the same branched logic as `OTr_GetNewBLOB`.

#### See Also

[OTr_PutBLOB](#otr_putblob), [OTr_GetNewBLOB](#otr_getnewblob)

---

### OTr_GetNewBLOB

**Legacy:** `OT GetNewBLOB` — version 1.5

```
OTr_GetNewBLOB ($handle_i : Integer; $tag_t : Text) → Blob
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to retrieve |
| Function result | Blob | ← | The retrieved item (empty on error) |

#### Discussion

`OTr_GetNewBLOB` retrieves a BLOB value from the object as a function result. This is the recommended method for retrieving BLOB items, as it avoids the parameter-passing issues associated with `OTr_GetBLOB`.

If the object is not a valid object handle, an error is generated, `OK` is set to zero, and an empty BLOB is returned.

If no item in the object has the given tag, an empty BLOB is returned. If the `FailOnItemNotFound` option is set, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *Is BLOB*, the value of the requested item is returned.

If an item with the given tag exists and has any other type, an error is generated, `OK` is set to zero, and an empty BLOB is returned.

#### OTr Implementation Notes

Functionally identical to `OTr_GetBLOB` except that the BLOB is returned as the function result rather than via an output parameter. The implementation is structurally the same — the only difference is the `#DECLARE` signature. May delegate to the same internal logic or be written in parallel.

#### See Also

[OTr_PutBLOB](#otr_putblob), [OTr_GetBLOB](#otr_getblob)

---

## Picture Routines

Picture values are stored directly as native 4D Object properties using `OB SET` with the `Is picture` type (supported since 4D v16R4). No serialisation, parallel arrays, or reference strings are required. See §3.7 of the parent specification.

---

### OTr_PutPicture

**Legacy:** `OT PutPicture` — version 1

```
OTr_PutPicture ($handle_i : Integer; $tag_t : Text; $value_pic : Picture)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to set |
| $value_pic | Picture | → | Picture to store |

#### Discussion

`OTr_PutPicture` stores a Picture value into the object.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type *Is Picture*, its value is replaced. No explicit cleanup is required — `OB SET` releases the previous value automatically.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

#### OTr Implementation Notes

```
OTr_zLock

If (OTr_zIsValidHandle($handle_i))
    If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; True; ->$parent_o; ->$leafKey_t))
        OB SET($parent_o; $leafKey_t; $value_pic)
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

OTr_zUnlock
```

Pictures are stored natively as Object properties on all supported 4D versions. No version gate or utility method is required.

#### See Also

[OTr_GetPicture](#otr_getpicture)

---

### OTr_GetPicture

**Legacy:** `OT GetPicture` — version 1

```
OTr_GetPicture ($handle_i : Integer; $tag_t : Text) → Picture
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to retrieve |
| Function result | Picture | ← | The retrieved item (empty Picture on error) |

#### Discussion

`OTr_GetPicture` retrieves a Picture value from the object.

If the object is not a valid object handle, an error is generated, `OK` is set to zero, and an empty Picture is returned.

If no item in the object has the given tag, an empty Picture is returned. If the `FailOnItemNotFound` option is set, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *Is Picture*, the value of the requested item is returned.

If an item with the given tag exists and has any other type, an error is generated, `OK` is set to zero, and an empty Picture is returned.

#### OTr Implementation Notes

```
OTr_zLock

If (OTr_zIsValidHandle($handle_i))
    If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; ->$parent_o; ->$leafKey_t))
        If (OB Is defined($parent_o; $leafKey_t))
            $result_pic:=OB Get($parent_o; $leafKey_t; Is picture)
        End if
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

OTr_zUnlock
```

Pictures are retrieved natively via `OB Get` with the `Is picture` type specifier. If the property is not a Picture, `OB Get` returns an empty Picture.

#### See Also

[OTr_PutPicture](#otr_putpicture)

---

## Record Routines

The legacy plugin stores records in a packed binary format. OTr replaces this with a **snapshot model** based on Cannon Smith's `OBJ_FromRecord` / `OBJ_ToRecord` pattern.

`OTr_PutRecord` serialises every field of the current record into a native 4D Object sub-object stored at the tag path. Each field becomes a property keyed by field name. Pictures and BLOBs are encoded as base64 text strings (using a `.png` codec by default for pictures) so that the snapshot is entirely self-contained within the OTr object — no database access is required to read it back, and it survives process boundaries, serialisation to JSON, and BLOB export without loss.

`OTr_GetRecord` is the inverse: it reads the sub-object at the tag path and writes each property back into the corresponding field of the current record of the specified table. The table is identified by its number, matching the original OT API exactly; `Table($inTable_i)` is used internally to obtain the pointer needed for field iteration.

`OTr_GetRecordTable` returns the table number that was captured at snapshot time (stored as a reserved property `__tableNum` in the sub-object).

> **Behavioural difference from the legacy plugin:** The legacy plugin stores a reference (table and record number). OTr stores a **complete snapshot**. This is strictly superior — the snapshot is portable, process-safe, and does not go stale if the underlying record changes or is deleted. There is no need for callers to manage record locks or worry about the record being modified between Put and Get.

> **Note on `OTr_GetRecordTable`:** With the snapshot model, `OTr_GetRecordTable` returns the table number recorded at snapshot time. Its primary use is to verify which table a snapshot belongs to before calling `OTr_GetRecord`. It does not perform any database access.

### Sub-object Storage Format

The sub-object stored at the tag path has the following structure:

```json
{
  "__tableNum": 3,
  "LastName": "Stewart",
  "FirstName": "Wayne",
  "DOB": "1965-04-03",
  "StartTime": "09:00:00",
  "Active": true,
  "Photo": "iVBORw0KGgoAAAANSUhEUg...",
  "DataBlob": "SGVsbG8gV29ybGQ="
}
```

| Property | Content |
|---|---|
| `__tableNum` | Integer — table number captured at `OTr_PutRecord` time |
| *field name* | Field value — scalar types stored natively; Date as `YYYY-MM-DD` text; Time as `HH:MM:SS` text; Picture as base64 text (`.png` codec by default); BLOB as base64 text |

Field names that are not valid 4D object property names are stored as-is; `OTr_GetRecord` will skip any property it cannot match to a field. The `__tableNum` property is reserved and must not collide with a field name.

---

### OTr_PutRecord

**Legacy:** `OT PutRecord` — version 1.5

```
OTr_PutRecord ($inObject_i : Integer; $inTag_t : Text; $inTable_i : Integer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$inObject_i` | Integer | → | OTr inObject |
| `$inTag_t` | Text | → | Tag path (inTag) |
| `$inTable_i` | Integer | → | Table number (inTable) — the table whose current record to snapshot |

#### Discussion

`OTr_PutRecord` serialises all fields of the current record of the specified table into a sub-object stored at `inTag` in `inObject`. The snapshot includes the table number, all scalar field values, and base64-encoded representations of all Picture and BLOB fields.

If `$inObject_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If `$inTable_i` is not a valid table number (`Table($inTable_i)` returns Nil), or there is no current record for the table (record number = −1), an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type *OT Record (115)*, its value is replaced.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

#### OTr Implementation Notes

Based on `OBJ_FromRecord` (Cannon Smith). Resolve the table pointer via `Table($inTable_i)`, then iterate all fields using `Get last field number` / `Is field number valid` / `Field` / `Field name`. For each valid field:

- **Scalar types** (text, integer, real, boolean): `OB SET($snapshot_o; $fieldName_t; $field_ptr->)`
- **Date**: store as `YYYY-MM-DD` text via `OTr_uDateToText`
- **Time**: store as `HH:MM:SS` text via `OTr_uTimeToText`
- **Picture**: `PICTURE TO BLOB($field_ptr->; $tempBlob_blob; ".png")`, `BASE64 ENCODE($tempBlob_blob)`, store as text via `Convert to text`
- **BLOB**: copy to temp, `BASE64 ENCODE`, store as text via `Convert to text`

Set `$snapshot_o.__tableNum` to `$inTable_i` before storing.

```
OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
    $tableRef_ptr:=Table($inTable_i)
    If ($tableRef_ptr=Nil pointer)
        OTr_zError("Invalid table number"; Current method name)
        OTr_zSetOK(0)
    Else
        $recordNum_i:=Record number($tableRef_ptr->)
        If ($recordNum_i<0)
            OTr_zError("No current record"; Current method name)
            OTr_zSetOK(0)
        Else
            $snapshot_o:=New object
            OB SET($snapshot_o; "__tableNum"; $tableNum_i)
            // ... iterate fields and populate $snapshot_o ...
            If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; True; ->$parent_o; ->$leafKey_t))
                OB SET($parent_o; $leafKey_t; $snapshot_o)
            End if
        End if
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

OTr_zUnlock
```

#### See Also

[OTr_GetRecord](#otr_getrecord), [OTr_GetRecordTable](#otr_getrecordtable)

---

### OTr_GetRecord

**Legacy:** `OT GetRecord` — version 1.5

```
OTr_GetRecord ($inObject_i : Integer; $inTag_t : Text; $inTable_i : Integer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$inObject_i` | Integer | → | OTr inObject |
| `$inTag_t` | Text | → | Tag path (inTag) |
| `$inTable_i` | Integer | → | Table number (inTable) — the table whose current record to populate |

#### Discussion

`OTr_GetRecord` writes the field values from the snapshot sub-object at `inTag` into the current record of the specified table. It is up to the caller to ensure a record is loaded in read/write mode before calling this method, and to save the record afterwards.

Field matching is by name. Fields present in the table but absent from the snapshot are left unchanged. Properties in the snapshot that do not match any field name are silently ignored.

If `$inObject_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If `$inTable_i` is not a valid table number, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, or the item is not a record snapshot sub-object, an error is generated and `OK` is set to zero.

> **Note:** Unlike the legacy `OT GetRecord`, which reloaded the record from the database, `OTr_GetRecord` writes snapshot values into *whatever record is currently loaded* in the specified table. No database read is performed. Use `OTr_GetRecordTable` beforehand to confirm the snapshot's source table if in doubt.

#### OTr Implementation Notes

Based on `OBJ_ToRecord` (Cannon Smith). Resolve `Table($inTable_i)` to obtain the table pointer, then retrieve the sub-object at the tag path. Iterate all fields as in `OTr_PutRecord`. For each valid field, check whether the snapshot sub-object has a matching property (`OB Is defined`), and if so:

- **Scalar types**: `$field_ptr->:=OB Get($snapshot_o; $fieldName_t)`
- **Date**: parse `YYYY-MM-DD` text via `OTr_uTextToDate`
- **Time**: parse `HH:MM:SS` text via `OTr_uTextToTime`
- **Picture**: `Convert from text` → `BASE64 DECODE` → `BLOB TO PICTURE($tempBlob_blob; $field_ptr->; ".png")`
- **BLOB**: `Convert from text` → `BASE64 DECODE` → assign to field

No database I/O is performed. The lock may be held for the full duration since no disk operations occur.

```
OTr_zLock

If (OTr_zIsValidHandle($inObject_i))
    $tableRef_ptr:=Table($inTable_i)
    If ($tableRef_ptr=Nil pointer)
        OTr_zError("Invalid table number"; Current method name)
        OTr_zSetOK(0)
    Else
        If (OTr_zResolvePath(<>OTR_Objects_ao{$inObject_i}; $inTag_t; False; ->$parent_o; ->$leafKey_t))
            If (OB Is defined($parent_o; $leafKey_t))
                $snapshot_o:=OB Get($parent_o; $leafKey_t; Is object)
                If (OB Is defined($snapshot_o; "__tableNum"))
                    // ... iterate fields of $tableRef_ptr and populate from $snapshot_o ...
                Else
                    OTr_zError("Tag is not a record snapshot"; Current method name)
                    OTr_zSetOK(0)
                End if
            End if
        End if
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

OTr_zUnlock
```

#### See Also

[OTr_PutRecord](#otr_putrecord), [OTr_GetRecordTable](#otr_getrecordtable)

---

### OTr_GetRecordTable

**Legacy:** `OT GetRecordTable` — version 1.5

```
OTr_GetRecordTable ($inObject_i : Integer; $inTag_t : Text) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| `$inObject_i` | Integer | → | OTr inObject |
| `$inTag_t` | Text | → | Tag path (inTag) |
| Function result | Integer | ← | The table number captured at snapshot time, or 0 on error |

#### Discussion

`OTr_GetRecordTable` retrieves the table number stored in the `__tableNum` property of the record snapshot sub-object at `inTag`. Use this to verify which table a snapshot belongs to before calling `OTr_GetRecord`.

If `$inObject_i` is not a valid object handle, or the item at the tag is not a record snapshot, zero is returned, an error is generated, and `OK` is set to zero.

#### OTr Implementation Notes

Retrieve the sub-object at the tag path and return `OB Get($snapshot_o; "__tableNum"; Is longint)`. If the `__tableNum` property is absent, the sub-object is not a valid record snapshot — generate an error.

#### See Also

[OTr_GetRecord](#otr_getrecord), [OTr_PutRecord](#otr_putrecord)

---

## Variable Routines

The Variable type provides a generic storage mechanism that can hold any 4D variable type except 2D arrays. The variable's type and value are both captured at storage time. This is the only OTr type where the stored item carries explicit type metadata embedded in the value string, since the type is not implied by the method name.

---

### OTr_PutVariable

**Legacy:** `OT PutVariable` — version 1.5

```
OTr_PutVariable ($handle_i : Integer; $tag_t : Text; $varPtr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to set |
| $varPtr | Pointer | → | Pointer to the variable whose value is to be stored |

#### Discussion

`OTr_PutVariable` stores the contents of the variable pointed to by `$varPtr` into the object. Every 4D variable type except 2D arrays can be stored with this command, including Boolean variables and arrays. Once stored, the data can be retrieved with `OTr_GetVariable` or with the `OTr_Get<type>` command appropriate to the variable's type.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has a matching type, its value is replaced.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is replaced.

#### OTr Implementation Notes

```
OTr_zLock

If (OTr_zIsValidHandle($handle_i))
    $type_i:=Type($varPtr->)

    Case of
        // Array types — delegate to OTr_PutArray (releases lock internally if needed)
        : ($type_i=Text array) | ($type_i=LongInt array) | ($type_i=Real array) \
            | ($type_i=Boolean array) | ($type_i=Date array) | ($type_i=Time array) \
            | ($type_i=Integer array) | ($type_i=Blob array) | ($type_i=Picture array) \
            | ($type_i=Pointer array)
            OTr_zUnlock
            OTr_PutArray($handle_i; $tag_t; $varPtr)
            $unlocked_b:=True

        // Scalar types — encode as "var:typeName:serialisedValue"
        : ($type_i=Is longint) | ($type_i=Is integer)
            $stored_t:="var:longint:"+String($varPtr->)
        : ($type_i=Is real)
            $stored_t:="var:real:"+String($varPtr->)
        : ($type_i=Is text) | ($type_i=Is string var)
            $stored_t:="var:text:"+String($varPtr->)
        : ($type_i=Is boolean)
            $stored_t:="var:boolean:"+Choose($varPtr->; "true"; "false")
        : ($type_i=Is date)
            $stored_t:="var:date:"+OTr_uDateToText($varPtr->)
        : ($type_i=Is time)
            $stored_t:="var:time:"+OTr_uTimeToText($varPtr->)
        : ($type_i=Is pointer)
            $stored_t:="var:pointer:"+OTr_uPointerToText($varPtr->)
        : ($type_i=Is BLOB)
            // BLOB variable: delegate to OTr_PutBLOB (handles version gate internally)
            OTr_zUnlock
            OTr_PutBLOB($handle_i; $tag_t; $varPtr->)
            $unlocked_b:=True
        : ($type_i=Is picture)
            // Picture variable: delegate to OTr_PutPicture (native OB SET)
            OTr_zUnlock
            OTr_PutPicture($handle_i; $tag_t; $varPtr->)
            $unlocked_b:=True
        Else
            OTr_zError("Unsupported variable type"; Current method name)
            OTr_zSetOK(0)
    End case

    If (Not($unlocked_b) & (OTr_zSetOK=1))
        If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; True; ->$parent_o; ->$leafKey_t))
            OB SET($parent_o; $leafKey_t; $stored_t)
        End if
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

If (Not($unlocked_b))
    OTr_zUnlock
End if
```

Array variables bypass the `var:` encoding entirely and are delegated to `OTr_PutArray`. BLOB and Picture variables are similarly delegated to `OTr_PutBLOB` and `OTr_PutPicture` respectively, which apply native storage (with the appropriate version gate for BLOBs). `OTr_zSetOK` is called with no parameter (getter form) to check whether a prior error in the Case of branch should suppress the write.

#### See Also

[OTr_GetVariable](#otr_getvariable)

---

### OTr_GetVariable

**Legacy:** `OT GetVariable` — version 1.5

```
OTr_GetVariable ($handle_i : Integer; $tag_t : Text; $varPtr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to retrieve |
| $varPtr | ← | Pointer | Pointer to a variable to receive the named item |

#### Discussion

`OTr_GetVariable` retrieves a value from the object into the variable pointed to by `$varPtr`. Every 4D variable type except 2D arrays can be retrieved with this command.

If the object is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, nothing happens.

If an item with the given tag exists and the stored type matches the type of the destination variable, the variable's data is replaced with the stored data.

If the stored type does not match the type of the destination variable, an error is generated and `OK` is set to zero.

#### OTr Implementation Notes

```
OTr_zLock

If (OTr_zIsValidHandle($handle_i))
    If (OTr_zResolvePath(<>OTR_Objects_ao{$handle_i}; $tag_t; False; ->$parent_o; ->$leafKey_t))
        If (OB Is defined($parent_o; $leafKey_t))
            $raw_t:=OB Get($parent_o; $leafKey_t; Is text)

            If (Substring($raw_t; 1; 4)="var:")
                // Scalar variable — parse "var:typeName:serialisedValue"
                $rest_t:=Substring($raw_t; 5)
                $sep_i:=Position(":"; $rest_t)
                $typeName_t:=Substring($rest_t; 1; $sep_i-1)
                $serialised_t:=Substring($rest_t; $sep_i+1)
                $destType_i:=Type($varPtr->)

                Case of
                    : ($typeName_t="longint")
                        $varPtr->:=Num($serialised_t)
                    : ($typeName_t="real")
                        $varPtr->:=Num($serialised_t)
                    : ($typeName_t="text")
                        $varPtr->:=$serialised_t
                    : ($typeName_t="boolean")
                        $varPtr->:=($serialised_t="true")
                    : ($typeName_t="date")
                        $varPtr->:=OTr_uTextToDate($serialised_t)
                    : ($typeName_t="time")
                        $varPtr->:=OTr_uTextToTime($serialised_t)
                    : ($typeName_t="pointer")
                        $varPtr->:=OTr_uTextToPointer($serialised_t)
                    : ($typeName_t="blob")
                        // BLOB variable was stored via OTr_PutBLOB — delegate to OTr_GetNewBLOB
                        OTr_zUnlock
                        $varPtr->:=OTr_GetNewBLOB($handle_i; $tag_t)
                        $unlocked_b:=True
                    : ($typeName_t="picture")
                        // Picture variable was stored via OTr_PutPicture — delegate to OTr_GetPicture
                        OTr_zUnlock
                        $varPtr->:=OTr_GetPicture($handle_i; $tag_t)
                        $unlocked_b:=True
                    Else
                        OTr_zError("Unknown variable type in stored value"; Current method name)
                        OTr_zSetOK(0)
                End case
            Else
                // Array variable — stored as a sub-object; delegate to OTr_GetArray
                OTr_zUnlock
                OTr_GetArray($handle_i; $tag_t; $varPtr)
                $unlocked_b:=True
            End if
        End if
    End if
Else
    OTr_zError("Invalid handle"; Current method name)
    OTr_zSetOK(0)
End if

If (Not($unlocked_b))
    OTr_zUnlock
End if
```

For array variables, the tag holds the array sub-object written by `OTr_PutArray`, and retrieval is delegated entirely to `OTr_GetArray`. For BLOB and Picture variables, retrieval is delegated to `OTr_GetNewBLOB` and `OTr_GetPicture` respectively, which apply the correct native retrieval path.

#### See Also

[OTr_PutVariable](#otr_putvariable)

---

## Cross-Reference Index

> *Note: `OTr_uExpandBinaries` and `OTr_uCollapseBinaries` were designed for this phase but retired in Phase 6 when binary data moved to native 4D Object storage. Their full specifications are preserved in `OTr-Phase-006-Spec.md` for reference.*

| OTr Method | Legacy Command | Category |
|---|---|---|

| OTr Method | Legacy Command | Category |
|---|---|---|
| `OTr_PutPointer` | `OT PutPointer` (v1) | Pointer |
| `OTr_GetPointer` | `OT GetPointer` (v1) | Pointer |
| `OTr_PutBLOB` | `OT PutBLOB` (v1) | BLOB |
| `OTr_GetBLOB` | `OT GetBLOB` (v1) | BLOB |
| `OTr_GetNewBLOB` | `OT GetNewBLOB` (v1.5) | BLOB |
| `OTr_PutPicture` | `OT PutPicture` (v1) | Picture |
| `OTr_GetPicture` | `OT GetPicture` (v1) | Picture |
| `OTr_PutRecord` | `OT PutRecord` (v1.5) | Record |
| `OTr_GetRecord` | `OT GetRecord` (v1.5) | Record |
| `OTr_GetRecordTable` | `OT GetRecordTable` (v1.5) | Record |
| `OTr_PutVariable` | `OT PutVariable` (v1.5) | Variable |
| `OTr_GetVariable` | `OT GetVariable` (v1.5) | Variable |
