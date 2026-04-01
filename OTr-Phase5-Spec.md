# OTr Phase 5 — Complex Types: Detailed Command Specification

**Version:** 0.2
**Date:** 2026-04-02
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§9, Phase 5)

---

## Overview

Phase 5 implements the **Pointer**, **BLOB**, **Picture**, **Record**, and **Variable** put/get routines from the legacy ObjectTools 5.0 plugin. These commands handle types that cannot be stored directly as native 4D Object properties and therefore require serialisation, parallel array storage, or both.

Phase 5 depends upon the infrastructure established in Phase 1 (handle registry, locking, error handling), the path-resolution mechanism from Phase 2 (`OTr__ResolvePath`), the parallel BLOB/Picture interprocess arrays defined in §3.7 of the parent specification, and the utility serialisation methods from Phase 4 (`OTr_uPointerToText`, `OTr_uTextToPointer`, `OTr_uBlobToText`, `OTr_uTextToBlob`, `OTr_uPictureToText`, `OTr_uTextToPicture`, `OTr_uDateToText`, `OTr_uTextToDate`, `OTr_uTimeToText`, `OTr_uTextToTime`).

### Storage Mechanisms

The types addressed in Phase 5 each require a distinct storage strategy, as 4D Objects cannot natively hold BLOB, Picture, Pointer, Record, or arbitrary Variable values via `OB SET`. The parent specification (§3.6) defines the following prefixed reference conventions:

| OT Type | Stored As | Example Value | Notes |
|---|---|---|---|
| Pointer | Text | `"myVar;-1;0"` | Via `RESOLVE POINTER` — no prefix |
| BLOB | Text | `"blob:33"` | Index into `<>OTR_Blobs_ablob` |
| Picture | Text | `"pic:27"` | Index into `<>OTR_Pictures_apicic` |
| Record | Text | `"rec:5;12"` | `rec:tableNum;recordNum` |
| Variable | Text | `"var:text:Wayne"` | `var:typeName:serialisedValue` |

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

## Pointer Routines

---

### OTr_PutPointer

**Legacy:** `OT PutPointer` — version 1

```
OTr_PutPointer ($handle_i : Integer; $tag_t : Text; $value_ptr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to set |
| $value_ptr | Pointer | → | Pointer to store |

#### Discussion

`OTr_PutPointer` stores a Pointer value into the object.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type *Is Pointer*, its value is replaced.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

> **Warning:** Under no circumstances should you attempt to store a pointer to a local or process variable in a compiled database and then try to retrieve that pointer in another process. Variable addresses differ between processes in compiled mode, and the retrieved pointer will reference an invalid memory location.

#### OTr Implementation Notes

Serialise the pointer via `OTr_uPointerToText` (Phase 4) to produce a `"variableName;tableNum;fieldNum"` string. Store the resulting text as the object property value via `OTr__ResolvePath` and `OB SET`. If the tag already holds a value of a different type and `VariantItems` is off, generate a type-mismatch error.

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
| $outPointer | Pointer | ← | The retrieved pointer |

#### Discussion

`OTr_GetPointer` retrieves a Pointer value from the object. The pointer is returned via the `$outPointer` output parameter.

If the object is not a valid object handle, an error is generated, `OK` is set to zero, and a nil pointer is returned.

If no item in the object has the given tag, a nil pointer is returned. If the `FailOnNoItem` option is set, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *Is Pointer*, the value of the requested element is returned.

If an item with the given tag exists and has any other type, `OK` is set to zero, and a nil pointer is returned.

> **Warning:** Under no circumstances should you attempt to store a pointer to a local or process variable in a compiled database and then try to retrieve that pointer in another process.

#### OTr Implementation Notes

Retrieve the text property via `OTr__ResolvePath` and `OB Get`. The serialised pointer string uses the format `"variableName;tableNum;fieldNum"` with no prefix (see `OTr_uPointerToText`, Phase 4). Deserialise via `OTr_uTextToPointer` (Phase 4) and assign the result to `$outPointer`. If the string is malformed or resolution fails, generate a type-mismatch error.

> **Note:** The absence of a `ptr:` prefix means that type detection for pointer properties must rely on context (e.g., the property was written by `OTr_PutPointer`) rather than on a disambiguating prefix. Callers should not use `OTr_GetPointer` on a property that was not set with `OTr_PutPointer`.

#### See Also

[OTr_PutPointer](#otr_putpointer)

---

## BLOB Routines

BLOB values cannot be stored directly as 4D Object properties. OTr stores BLOBs in the parallel interprocess array `<>OTR_Blobs_ablob` and records a `blob:N` reference string as the object property value (see §3.7 of the parent specification).

---

### OTr_PutBLOB

**Legacy:** `OT PutBLOB` — version 1

```
OTr_PutBLOB ($handle_i : Integer; $tag_t : Text; $value_x : Blob)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to set |
| $value_x | Blob | → | 4D BLOB to store |

#### Discussion

`OTr_PutBLOB` stores a BLOB value into the object.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type *Is BLOB*, its value is replaced. The previous BLOB data in the parallel array is overwritten.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

#### OTr Implementation Notes

1. If the tag already holds a `blob:N` reference, retrieve the existing slot index and overwrite `<>OTR_Blobs_ablob{N}` with the new BLOB data.
2. Otherwise, scan `<>OTR_BlobInUse_ab` for the first `False` slot. If none is found, append to both `<>OTR_Blobs_ablob` and `<>OTR_BlobInUse_ab`.
3. Store the BLOB in the slot, mark it in-use.
4. Store `"blob:" + String($slotIndex)` as the object property value.

All parallel array operations must be performed within the `OTr__Lock` / `OTr__Unlock` critical section.

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
| $outBLOB | Blob | ← | The retrieved item |

#### Discussion

`OTr_GetBLOB` retrieves a BLOB value from the object into the `$outBLOB` parameter.

If the object is not a valid object handle, an error is generated, `OK` is set to zero, and an empty BLOB is returned.

If no item in the object has the given tag, an empty BLOB is returned. If the `FailOnNoItem` option is set, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *Is BLOB*, `$outBLOB`'s contents are replaced.

If an item with the given tag exists and has any other type, `OK` is set to zero, and an empty BLOB is returned.

> **Warning:** Do not attempt to pass a BLOB field or a dereferenced pointer to a BLOB field in the `$outBLOB` parameter, as this will result in a crash. If you want to retrieve a BLOB item into a field, either use an intermediate local variable or assign the result of `OTr_GetNewBLOB` to the field. The same applies to passing a dereferenced pointer to a BLOB variable. This command is being kept for backward compatibility. Because of the problems related to this command, it is recommended that you use `OTr_GetNewBLOB` instead, as this command may be removed in future versions.

#### OTr Implementation Notes

Retrieve the text property. Parse the `blob:N` reference to extract the slot index. Copy the data from `<>OTR_Blobs_ablob{N}` into `$outBLOB`. If the reference is malformed or the slot is not in use, generate an error and set `$outBLOB` to an empty BLOB.

> **Note:** In the native OTr implementation, the crash risk described in the legacy warning is substantially mitigated because OTr does not perform direct memory manipulation. However, the warning is preserved for documentation fidelity and to alert callers that `OTr_GetNewBLOB` remains the preferred retrieval method.

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
| Function result | Blob | ← | The retrieved item |

#### Discussion

`OTr_GetNewBLOB` retrieves a BLOB value from the object as a function result. This is the recommended method for retrieving BLOB items, as it avoids the parameter-passing issues associated with `OTr_GetBLOB`.

If the object is not a valid object handle, an error is generated, `OK` is set to zero, and an empty BLOB is returned.

If no item in the object has the given tag, an empty BLOB is returned. If the `FailOnNoItem` option is set, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *Is BLOB*, the value of the requested item is returned.

If an item with the given tag exists and has any other type, `OK` is set to zero, and an empty BLOB is returned.

> **Warning:** Because of the problems related to the `OTr_GetBLOB` command, it is recommended that you use this command instead.

#### OTr Implementation Notes

Functionally identical to `OTr_GetBLOB` except that the BLOB is returned as the function result rather than via an output parameter. Retrieve the `blob:N` reference, parse the slot index, and return a copy of `<>OTR_Blobs_ablob{N}`.

#### See Also

[OTr_PutBLOB](#otr_putblob), [OTr_GetBLOB](#otr_getblob)

---

## Picture Routines

Picture values cannot be stored directly as 4D Object properties. OTr stores Pictures in the parallel interprocess array `<>OTR_Pictures_apic` and records a `pic:N` reference string as the object property value (see §3.7 of the parent specification).

---

### OTr_PutPicture

**Legacy:** `OT PutPicture` — version 1

```
OTr_PutPicture ($handle_i : Integer; $tag_t : Text; $value_p : Picture)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to set |
| $value_p | Picture | → | Picture to store |

#### Discussion

`OTr_PutPicture` stores a Picture value into the object.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type *Is Picture*, its value is replaced. The previous picture data in the parallel array is overwritten.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

#### OTr Implementation Notes

As per `OTr_PutBLOB`, but using `<>OTR_Pictures_apic` / `<>OTR_PicInUse_ab` and the `pic:N` prefix. Storage is managed by `OTr_uPictureToText` (Phase 4): if a free slot exists in `<>OTR_PicInUse_ab`, it is reused; otherwise a new element is appended to both parallel arrays. If the tag already holds a `pic:N` reference, the existing slot should be overwritten in place rather than allocating a new one.

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
| Function result | Picture | ← | The retrieved item |

#### Discussion

`OTr_GetPicture` retrieves a Picture value from the object.

If the object is not a valid object handle, an error is generated, `OK` is set to zero, and an empty picture is returned.

If no item in the object has the given tag, an empty picture is returned. If the `FailOnNoItem` option is set, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *Is Picture*, the value of the requested item is returned.

If an item with the given tag exists and has any other type, `OK` is set to zero, and an empty picture is returned.

#### OTr Implementation Notes

Retrieve the text property. Parse the `pic:N` reference to extract the slot index. Verify that the slot index is within bounds and that `<>OTR_PicInUse_ab{N}` is `True`. Return a copy of `<>OTR_Pictures_apic{N}`. The retrieval logic mirrors `OTr_uTextToPicture` (Phase 4). If the reference is malformed or the slot is not in use, generate an error and return an empty picture.

#### See Also

[OTr_PutPicture](#otr_putpicture)

---

## Record Routines

The legacy plugin stores records in a packed binary format. In OTr, record storage uses the `rec:tableNum;recordNum` text convention (see §3.6 of the parent specification). The table number and record number of the current record are captured at storage time and used to reload the record at retrieval time.

---

### OTr_PutRecord

**Legacy:** `OT PutRecord` — version 1.5

```
OTr_PutRecord ($handle_i : Integer; $tag_t : Text; $table_ptr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to set |
| $table_ptr | Pointer | → | Table or field pointer identifying the table whose current record to store |

#### Discussion

`OTr_PutRecord` stores a reference to the current record of the specified table into the object. The contents of the item can only be retrieved with `OTr_GetRecord`.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type *OT Is Record (115)*, its value is replaced.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero.

If `$table_ptr` is not a valid table or field pointer, or if there is no current record for the given table, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

> **Warning:** Once a record is stored with `OTr_PutRecord`, it must be retrieved into the same table. Otherwise the results are undefined (and potentially disastrous).

#### OTr Implementation Notes

1. Resolve the table pointer: if `$table_ptr` points to a field, use `Table(Field number($table_ptr))` to obtain the table pointer, then `Table($table_ptr)` to get the table number. Alternatively, use `RESOLVE POINTER` and extract the table number.
2. Obtain the current record number via `Record number(Table($tableNum)->)`.
3. If no current record exists (record number = -1), generate an error.
4. Store the string `"rec:" + String($tableNum) + ";" + String($recordNum)` as the object property value.

> **Note:** Unlike the legacy plugin, which stores the record in a packed binary format, OTr stores only the table and record numbers as a reference. This means that `OTr_GetRecord` will load whatever data is currently in that record at retrieval time, not a snapshot of the record as it existed at storage time. This is a behavioural difference from the legacy plugin. If snapshot semantics are required, the caller should use `OTr_PutVariable` with a pointer to a record-mirroring structure, or serialise the record fields individually.

#### See Also

[OTr_GetRecord](#otr_getrecord), [OTr_GetRecordTable](#otr_getrecordtable)

---

### OTr_GetRecord

**Legacy:** `OT GetRecord` — version 1.5

```
OTr_GetRecord ($handle_i : Integer; $tag_t : Text)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to retrieve |

#### Discussion

`OTr_GetRecord` sets the current record of a table from the record reference stored in the object. The contents of the item must have been set with `OTr_PutRecord`. The table used to store the record reference is the table which will have its current record set.

If the object is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in object has the given tag, nothing happens.

If an item with the given tag exists and has the type *OT Is Record*, the current record of the item's original table is set.

If there is no current record for the item's table or the current record is locked, an error is generated and `OK` is set to zero.

> **Warning:** Once a record is stored with `OTr_PutRecord`, it must be retrieved into the same table. Otherwise the results are undefined (and potentially disastrous). You can use the `OTr_GetRecordTable` command to find the source table for a stored record.

#### OTr Implementation Notes

1. Retrieve the text property and verify the `rec:` prefix.
2. Parse the table number and record number from the `rec:tableNum;recordNum` format.
3. Use `GOTO RECORD(Table($tableNum)->; $recordNum)` to set the current record.
4. Verify that the operation succeeded by checking `Record number(Table($tableNum)->)` equals `$recordNum`. If not (e.g., record was deleted or is locked), generate an error.

#### See Also

[OTr_PutRecord](#otr_putrecord), [OTr_GetRecordTable](#otr_getrecordtable)

---

### OTr_GetRecordTable

**Legacy:** `OT GetRecordTable` — version 1.5

```
OTr_GetRecordTable ($handle_i : Integer; $tag_t : Text) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to retrieve |
| Function result | Integer | ← | The table number of the stored record |

#### Discussion

`OTr_GetRecordTable` retrieves the table number from the record reference stored in the object. The contents of the item must have been set with `OTr_PutRecord`. The table used to store the packed record is the table whose number will be returned.

If the object is not a valid object handle, or no item in object has the given tag, zero is returned, an error is generated and `OK` is set to zero.

If an item with the given tag exists and has the type *OT Is Record*, the number of the item's original table is returned.

If an item with the given tag exists and has any other type, zero is returned, an error is generated and `OK` is set to zero.

#### OTr Implementation Notes

Retrieve the text property. Verify the `rec:` prefix. Parse the table number from the first component of the `rec:tableNum;recordNum` format. Return the table number as an Integer.

#### See Also

[OTr_GetRecord](#otr_getrecord), [OTr_PutRecord](#otr_putrecord)

---

## Variable Routines

The Variable type provides a generic storage mechanism that can hold any 4D variable type (except 2D arrays). The variable's type and value are both captured and stored. This is the only OTr type where the stored item carries explicit type metadata, since the type is not implied by the method name.

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

`OTr_PutVariable` stores the contents of the variable pointed to by `$varPtr` into the object. Every 4D variable type but 2D arrays can be stored with this command, including Boolean variables and arrays. Once stored, the data can either be retrieved with `OTr_GetVariable` or with the `OTr_Get<type>` command appropriate to the variable's type.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in the object has the given tag, a new item is created.

If an item with the given tag exists and has the type `Type($varPtr->)`, its value is replaced.

If an item with the given tag exists and has any other type, an error is generated and `OK` is set to zero if the `VariantItems` option is not set, otherwise the existing item is deleted and a new item is created.

#### OTr Implementation Notes

1. Determine the variable's type via `Type($varPtr->)`.
2. Map the 4D type to a type name string (e.g., `Is longint` → `"longint"`, `Is real` → `"real"`, `Is text` → `"text"`, `Is date` → `"date"`, `Is time` → `"time"`, `Is boolean` → `"boolean"`, `Is picture` → `"picture"`, `Is BLOB` → `"blob"`, `Is pointer` → `"pointer"`).
3. Serialise the value to text using the Phase 4 utility methods where applicable:
   - For scalars (Longint, Real, Text, Boolean): use `String` or direct text conversion.
   - For Date: use `OTr_uDateToText` → `YYYY-MM-DD`.
   - For Time: use `OTr_uTimeToText` → `HH:MM:SS`.
   - For BLOB: use `OTr_uBlobToText` to allocate a parallel array slot; stored value is `"blob:N"`.
   - For Picture: use `OTr_uPictureToText` to allocate a parallel array slot; stored value is `"pic:N"`.
   - For Pointer: use `OTr_uPointerToText` → `"variableName;tableNum;fieldNum"`.
   - For arrays: use `OTr_PutArray` to write the array into a nested sub-object at the given tag, rather than encoding into the `var:` string. In this case the `var:` wrapper is not used.
4. Store the string `"var:" + $typeName + ":" + $serialisedValue` as the object property value (scalar types only).

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
| $varPtr | Pointer | ← | Pointer to a variable to receive the named item |

#### Discussion

`OTr_GetVariable` retrieves a value from the object into the variable pointed to by `$varPtr`. Every 4D variable type but 2D arrays can be retrieved with this command, including Boolean variables and arrays.

If the object is not a valid object handle, an error is generated and `OK` is set to zero.

If no item in object has the given tag, nothing happens.

If an item with the given tag exists and has the same type as the type of the destination variable, the variable's data is replaced with the data stored in the object.

If an item with the given tag exists and has a type other than the type of the destination variable, an error is generated and `OK` is set to zero.

#### OTr Implementation Notes

1. Retrieve the text property. Verify the `var:` prefix.
2. Parse the type name and serialised value from the `var:typeName:serialisedValue` format.
3. Determine the destination variable's type via `Type($varPtr->)`.
4. Verify that the stored type matches the destination type. If not, generate a type-mismatch error.
5. Deserialise the value according to the type, using the Phase 4 utility methods where applicable:
   - For scalars: use `Num`, `Date`, `Time`, or direct text assignment.
   - For Boolean: `$serialisedValue = "true"` or `$serialisedValue = "1"` → `True`.
   - For Date: use `OTr_uTextToDate`.
   - For Time: use `OTr_uTextToTime`.
   - For BLOB: use `OTr_uTextToBlob` to retrieve from the parallel array.
   - For Picture: use `OTr_uTextToPicture` to retrieve from the parallel array.
   - For Pointer: use `OTr_uTextToPointer`.
   - For arrays: use `OTr_GetArray` to read the nested sub-object at the given tag into the destination array.
6. Assign the deserialised value to `$varPtr->`.

#### See Also

[OTr_PutVariable](#otr_putvariable)

---

## Cross-Reference Index

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
