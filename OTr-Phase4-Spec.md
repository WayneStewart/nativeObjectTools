# OTr Phase 4 — Array Operations: Detailed Command Specification

**Version:** 0.1
**Date:** 2026-04-01
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§9, Phase 4)

---

## Overview

Phase 4 implements the **Array Put/Get**, **Bulk Array**, and **Array Utility** routines from the legacy ObjectTools 5.0 plugin. These commands provide the ability to store, retrieve, and manipulate typed arrays within OTr objects.

Phase 4 depends upon the infrastructure established in Phase 1 (handle registry, locking, error handling), the scalar put/get and path-resolution mechanisms from Phase 2 (`OTr__ResolvePath`), and the internal helper methods `OTr__ArrayToCollection` and `OTr__CollectionToArray` (new to Phase 4).

### Array Storage Model

In the legacy plugin, arrays are stored as first-class typed items within an object. In OTr, arrays are stored as **Collection** properties on the parent 4D Object (see §3.8 of the parent specification). This provides a natural mapping:

- Bulk assignment via `OB SET($obj; $tag; $collection)`
- Element access via `$collection[$index]` (zero-based)
- Size via `$collection.length`
- Insert, delete, and resize via Collection methods

**Index mapping:** The legacy OT API uses **1-based** array indices (0 through *n*, where element 0 is reserved per 4D convention and elements 1..*n* are the usable data). OTr Collections are **0-based**. All OTr array element methods must subtract 1 from the caller's index before accessing the Collection. When returning indices to the caller (e.g., `OTr_FindInArray`), add 1 to the Collection index.

### Array Type Identity

The legacy plugin tracks each array's type (e.g., OT Array Character = 113 for String/Text arrays). In OTr, the Collection itself is untyped; however, `OTr_ItemType` returns `113` (OT Array Character) for any Collection property, as Collections map to the array concept. Type enforcement within element put/get methods is performed by the method itself — `OTr_PutArrayLong` stores Longint values, `OTr_PutArrayReal` stores Real values, and so forth.

> **Note:** String arrays and Text arrays are interchangeable in the legacy plugin (both stored as OT Character array, type 113). OTr preserves this equivalence: `OTr_PutArrayString` and `OTr_PutArrayText` operate on the same underlying Collection and differ only in their documented semantics (fixed-width vs. variable-length text). In practice, 4D Text is used for both.

### Commands in This Phase

**Internal Helpers:**
`OTr__ArrayToCollection`, `OTr__CollectionToArray`

**Bulk Array Routines:**
`OTr_PutArray`, `OTr_GetArray`

**Put Element Routines:**
`OTr_PutArrayLong`, `OTr_PutArrayReal`, `OTr_PutArrayString`, `OTr_PutArrayText`, `OTr_PutArrayDate`, `OTr_PutArrayTime`, `OTr_PutArrayBoolean`, `OTr_PutArrayBLOB`, `OTr_PutArrayPicture`, `OTr_PutArrayPointer`

**Get Element Routines:**
`OTr_GetArrayLong`, `OTr_GetArrayReal`, `OTr_GetArrayString`, `OTr_GetArrayText`, `OTr_GetArrayDate`, `OTr_GetArrayTime`, `OTr_GetArrayBoolean`, `OTr_GetArrayBLOB`, `OTr_GetArrayPicture`, `OTr_GetArrayPointer`

**Array Utility Routines:**
`OTr_SizeOfArray`, `OTr_ResizeArray`, `OTr_InsertElement`, `OTr_DeleteElement`, `OTr_FindInArray`, `OTr_SortArrays`

---

## Type Constants

For the authoritative reference of 4D type constants and their mapping to legacy OT constants, see [OTr-Types-Reference.md](OTr-Types-Reference.md).

---

## Internal Helper Methods

The following methods are private (`OTr__` prefix, `"shared":false`) and are not part of the public API. They encapsulate the conversion between 4D process-local arrays and Collections for bulk array operations.

---

### OTr__ArrayToCollection

```
OTr__ArrayToCollection ($arrayPtr : Pointer) → Collection
```

| Parameter | Type | | Description |
|---|---|---|---|
| $arrayPtr | Pointer | → | Pointer to a 4D array (any supported type) |
| Function result | Collection | ← | A Collection containing the array elements |

#### Discussion

`OTr__ArrayToCollection` converts a 4D process-local array (passed by pointer) into a Collection suitable for storage as an object property. The array type is determined at runtime via `Type($arrayPtr->)`.

Supported array types and their Collection element mappings:

| 4D Array Type | Collection Element Type | Notes |
|---|---|---|
| Longint array | Integer | Direct mapping |
| Real array | Real | Direct mapping |
| Text array | Text | Direct mapping |
| String array | Text | Widened to Text |
| Date array | Text | Formatted as `YYYY-MM-DD` |
| Time array | Text | Formatted as `HH:MM:SS` |
| Boolean array | Boolean | Direct mapping |
| BLOB array | Text | Each element stored via `blob:N` reference |
| Picture array | Text | Each element stored via `pic:N` reference |
| Pointer array | Text | Each element stored via `ptr:` serialisation |

Element 0 of the 4D array (the "default" element per 4D convention) is **excluded** from the Collection. Only elements 1 through `Size of array` are converted.

#### OTr Implementation Notes

Use `Type($arrayPtr->)` to branch on the array type. Iterate from element 1 to `Size of array($arrayPtr->)`, appending each value to a new Collection. For Date and Time elements, format using `String` with the appropriate format constants. For BLOB and Picture elements, allocate slots in the parallel interprocess arrays and store the `blob:N` / `pic:N` reference strings. For Pointer elements, serialise via the `OTr__SerialisePointer` method (Phase 5 dependency — if Phase 5 is not yet implemented, store as `ptr:` placeholder).

---

### OTr__CollectionToArray

```
OTr__CollectionToArray ($collection : Collection; $arrayPtr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $collection | Collection | → | A Collection from an object property |
| $arrayPtr | Pointer | ← | Pointer to a 4D array to populate |

#### Discussion

`OTr__CollectionToArray` converts a Collection back into a 4D process-local array. The target array's type is determined by `Type($arrayPtr->)` and must already be declared by the caller.

The target array is resized to match the Collection's length. Collection elements are mapped back to the appropriate 4D types according to the inverse of the table in `OTr__ArrayToCollection`.

Element 0 of the target array is set to its type's default value (empty string, zero, etc.). Elements 1 through *n* are populated from Collection indices 0 through *n*−1.

#### OTr Implementation Notes

Use `ARRAY [TYPE]($arrayPtr->; $collection.length)` to resize the array. Iterate over the Collection and assign each element to the corresponding array index (Collection index + 1). For Date and Time strings, parse using `Date` and `Time` respectively. For `blob:N` and `pic:N` references, retrieve the binary data from the parallel arrays. For `ptr:` references, deserialise via `OTr__DeserialisePointer` (Phase 5 dependency).

> **Warning:** When populating a String array (fixed width), values exceeding the declared field width will be truncated silently by 4D. The legacy plugin exhibited the same behaviour in compatibility mode.

---

## Bulk Array Routines

The following routines store and retrieve entire 4D arrays to and from an object in a single operation.

---

### OTr_PutArray

**Legacy:** `OT PutArray` — version 1

```
OTr_PutArray ($handle_i : Integer; $tag_t : Text; $arrayPtr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag under which to store the array |
| $arrayPtr | Pointer | → | Pointer to a 4D array |

#### Discussion

`OTr_PutArray` stores an entire array within an object. The array may be of any supported type: Longint, Real, Text, String, Date, Time, Boolean, BLOB, Picture, or Pointer.

If `$handle_i` is not a valid object handle, an error is generated, `OK` is set to zero, and no operation is performed.

If an item with the given tag already exists and the `VariantItems` option is off, the existing item must be an array of the same type. If the types do not match, an error is generated. If the `VariantItems` option is on, the existing item is replaced regardless of its previous type.

String and Text arrays are interchangeable and both stored as OT Character array (type 113).

#### OTr Implementation Notes

Convert the 4D array to a Collection via `OTr__ArrayToCollection`, then store the Collection as a property on the object via `OB SET`. Use `OTr__ResolvePath` to navigate dotted tag paths. If the tag already references a non-Collection property (and `VariantItems` is off), generate a type-mismatch error.

#### See Also

[OTr_GetArray](#otr_getarray), [OTr_SizeOfArray](#otr_sizeofarray)

---

### OTr_GetArray

**Legacy:** `OT GetArray` — version 1

```
OTr_GetArray ($handle_i : Integer; $tag_t : Text; $arrayPtr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $arrayPtr | Pointer | ← | Pointer to a 4D array to populate |

#### Discussion

`OTr_GetArray` retrieves an array from an object and populates the given 4D array. The array pointed to by `$arrayPtr` must already be declared and must be of an appropriate type.

If `$handle_i` is not a valid object handle, the tag does not exist (and `FailOnItemNotFound` is set), or the tag does not reference an array item, an error is generated, `OK` is set to zero, and the target array is left untouched.

String and Text arrays are interchangeable.

> **Warning:** When retrieving into a fixed-width String array, values exceeding the declared width are truncated. This mirrors the legacy plugin's behaviour in compatibility mode.

#### OTr Implementation Notes

Retrieve the Collection property via `OTr__ResolvePath` and `OB Get`. Verify that it is a Collection (not a scalar or Object). Convert to the target array via `OTr__CollectionToArray`.

#### See Also

[OTr_PutArray](#otr_putarray), [OTr_SizeOfArray](#otr_sizeofarray)

---

## Put Element Routines

The following routines store individual values into specific elements of an array item. All Put element methods share a common signature pattern:

```
OTr_PutArray<Type> ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value : <Type>)
```

**Common behaviour:**

- `$index_i` ranges from 0 to `OTr_SizeOfArray`. Index 0 sets the default element (mapped to a metadata property on the Collection or ignored). Indices 1 through *n* map to Collection indices 0 through *n*−1.
- If the array does not exist, it is created with enough elements to accommodate `$index_i`.
- If `$index_i` exceeds the current array size, the array is grown to accommodate it, with new elements initialised to their type's default value.
- If the handle is invalid, an error is generated, `OK` is set to zero, and no operation is performed.
- If the tag references an existing item that is not an array (and `VariantItems` is off), a type-mismatch error is generated.

---

### OTr_PutArrayLong

**Legacy:** `OT PutArrayLong` — version 1

```
OTr_PutArrayLong ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_l : Integer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_l | Integer | → | Value to store |

#### Discussion

`OTr_PutArrayLong` stores an Integer value at the given index of a Longint array item. See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

Navigate to the property via `OTr__ResolvePath`. If the property does not exist, create a new Collection and store it. Map `$index_i` to Collection index `$index_i - 1` (for indices ≥ 1). For index 0, store the value in a companion metadata property `$tag + "__otr_default"` on the parent object, or discard it (the legacy element 0 has no practical use in most client code). Use `$collection[$index_i - 1]:=$value_l` for assignment.

#### See Also

[OTr_GetArrayLong](#otr_getarraylong), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayReal

**Legacy:** `OT PutArrayReal` — version 1

```
OTr_PutArrayReal ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_r : Real)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_r | Real | → | Value to store |

#### Discussion

`OTr_PutArrayReal` stores a Real value at the given index of a Real array item. See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

As per `OTr_PutArrayLong`, substituting Real for Integer. Use `$collection[$index_i - 1]:=$value_r`.

#### See Also

[OTr_GetArrayReal](#otr_getarrayreal), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayString

**Legacy:** `OT PutArrayString` — version 1

```
OTr_PutArrayString ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_t : Text)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_t | Text | → | Value to store |

#### Discussion

`OTr_PutArrayString` stores a Text value at the given index of a String/Text array item. String and Text arrays are interchangeable in OTr; both are stored as Collections of Text values and both carry type constant 113 (OT Array Character).

See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

As per `OTr_PutArrayLong`, substituting Text for Integer.

#### See Also

[OTr_GetArrayString](#otr_getarraystring), [OTr_PutArrayText](#otr_putarraytext), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayText

**Legacy:** `OT PutArrayText` — version 1

```
OTr_PutArrayText ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_t : Text)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_t | Text | → | Value to store |

#### Discussion

`OTr_PutArrayText` stores a Text value at the given index of a Text/String array item. Functionally identical to `OTr_PutArrayString` — both operate on the same underlying Collection of Text values.

See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

Delegates to (or shares implementation with) `OTr_PutArrayString`.

#### See Also

[OTr_GetArrayText](#otr_getarraytext), [OTr_PutArrayString](#otr_putarraystring), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayDate

**Legacy:** `OT PutArrayDate` — version 1

```
OTr_PutArrayDate ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_d : Date)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_d | Date | → | Value to store |

#### Discussion

`OTr_PutArrayDate` stores a Date value at the given index of a Date array item. The date is stored in the Collection as a Text string in `YYYY-MM-DD` format, consistent with the scalar `OTr_PutDate` storage convention.

See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

Format the date as `String($value_d; ISO date)` to produce the `YYYY-MM-DD` representation. Store the resulting Text string in the Collection element.

#### See Also

[OTr_GetArrayDate](#otr_getarraydate), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayTime

**Legacy:** `OT PutArrayTime` — version 1

```
OTr_PutArrayTime ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_h : Time)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_h | Time | → | Value to store |

#### Discussion

`OTr_PutArrayTime` stores a Time value at the given index of a Time array item. The time is stored in the Collection as a Text string in `HH:MM:SS` format, consistent with the scalar `OTr_PutTime` storage convention.

See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

Format the time as `String($value_h; HH MM SS)` to produce the `HH:MM:SS` representation. Store the resulting Text string in the Collection element.

#### See Also

[OTr_GetArrayTime](#otr_getarraytime), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayBoolean

**Legacy:** `OT PutArrayBoolean` — version 1

```
OTr_PutArrayBoolean ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_b : Boolean)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_b | Boolean | → | Value to store |

#### Discussion

`OTr_PutArrayBoolean` stores a Boolean value at the given index of a Boolean array item.

See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

As per `OTr_PutArrayLong`, substituting Boolean for Integer.

#### See Also

[OTr_GetArrayBoolean](#otr_getarrayboolean), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayBLOB

**Legacy:** `OT PutArrayBLOB` — version 1

```
OTr_PutArrayBLOB ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_x : Blob)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_x | Blob | → | Value to store |

#### Discussion

`OTr_PutArrayBLOB` stores a BLOB value at the given index of a BLOB array item. As with scalar BLOB storage, the actual binary data is held in the parallel `<>OTR_Blobs_ax` array and the Collection element stores a `blob:N` reference string.

See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

Allocate a slot in `<>OTR_Blobs_ax` (scan for a `False` entry in `<>OTR_BlobInUse_ab`, or append). Store the BLOB data and mark the slot in-use. If the Collection element previously held a `blob:N` reference, release the old slot before assigning the new one. Store `"blob:" + String($slotIndex)` in the Collection element.

#### See Also

[OTr_GetArrayBLOB](#otr_getarrayblob), [OTr_PutBLOB](OTr-Phase5-Spec.md#otr_putblob), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayPicture

**Legacy:** `OT PutArrayPicture` — version 1

```
OTr_PutArrayPicture ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_p : Picture)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_p | Picture | → | Value to store |

#### Discussion

`OTr_PutArrayPicture` stores a Picture value at the given index of a Picture array item. As with scalar Picture storage, the actual picture data is held in the parallel `<>OTR_Pictures_ap` array and the Collection element stores a `pic:N` reference string.

See "Common behaviour" above for index range semantics and error conditions.

#### OTr Implementation Notes

As per `OTr_PutArrayBLOB`, but using `<>OTR_Pictures_ap` / `<>OTR_PicInUse_ab` and the `pic:N` prefix.

#### See Also

[OTr_GetArrayPicture](#otr_getarraypicture), [OTr_PutPicture](OTr-Phase5-Spec.md#otr_putpicture), [OTr_PutArray](#otr_putarray)

---

### OTr_PutArrayPointer

**Legacy:** `OT PutArrayPointer` — version 1

```
OTr_PutArrayPointer ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_ptr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $value_ptr | Pointer | → | Value to store |

#### Discussion

`OTr_PutArrayPointer` stores a Pointer value at the given index of a Pointer array item. The pointer is serialised to a `ptr:` reference string and stored as a Text element in the Collection.

See "Common behaviour" above for index range semantics and error conditions.

> **Warning:** Pointer values are inherently process-local. A pointer stored from one process may not resolve correctly in another process, particularly in compiled databases where variable addresses can differ between processes. Exercise caution when using pointer arrays in multi-process scenarios.

#### OTr Implementation Notes

Serialise the pointer via `OTr__SerialisePointer` (Phase 5) and store the resulting `ptr:` string in the Collection element. If Phase 5 is not yet available, use `RESOLVE POINTER($value_ptr; $name; $tableNum; $fieldNum)` and store as `"ptr:" + $name + ";" + String($tableNum) + ";" + String($fieldNum)`.

#### See Also

[OTr_GetArrayPointer](#otr_getarraypointer), [OTr_PutPointer](OTr-Phase5-Spec.md#otr_putpointer), [OTr_PutArray](#otr_putarray)

---

## Get Element Routines

The following routines retrieve individual values from specific elements of an array item. All Get element methods share a common signature pattern:

```
OTr_GetArray<Type> ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → <Type>
```

**Common behaviour:**

- `$index_i` ranges from 0 to `OTr_SizeOfArray`. Index 0 retrieves the default element. Indices 1 through *n* map to Collection indices 0 through *n*−1.
- If the handle is invalid, the tag does not exist, the tag does not reference an array, or the index is out of range, the behaviour depends on the `FailOnItemNotFound` option:
  - If **on**: an error is generated, `OK` is set to zero, and the type's default value is returned.
  - If **off**: the type's default value is returned silently.
- If the element exists but contains a value of an incompatible type, an error is generated.

---

### OTr_GetArrayLong

**Legacy:** `OT GetArrayLong` — version 1

```
OTr_GetArrayLong ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| Function result | Integer | ← | The value at the given index |

#### Discussion

`OTr_GetArrayLong` retrieves an Integer value from the given index of a Longint array item. See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

Navigate to the Collection property via `OTr__ResolvePath`. Validate that the property is a Collection. Map `$index_i` to Collection index `$index_i - 1`. Return `$collection[$index_i - 1]` cast to Integer. For index 0, return the default element value (stored in the companion `__otr_default` metadata property, or zero if not present).

#### See Also

[OTr_PutArrayLong](#otr_putarraylong), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayReal

**Legacy:** `OT GetArrayReal` — version 1

```
OTr_GetArrayReal ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Real
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| Function result | Real | ← | The value at the given index |

#### Discussion

`OTr_GetArrayReal` retrieves a Real value from the given index of a Real array item. See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

As per `OTr_GetArrayLong`, substituting Real for Integer.

#### See Also

[OTr_PutArrayReal](#otr_putarrayreal), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayString

**Legacy:** `OT GetArrayString` — version 1

```
OTr_GetArrayString ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Text
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| Function result | Text | ← | The value at the given index |

#### Discussion

`OTr_GetArrayString` retrieves a Text value from the given index of a String/Text array item. String and Text arrays are interchangeable.

See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

As per `OTr_GetArrayLong`, substituting Text for Integer.

#### See Also

[OTr_PutArrayString](#otr_putarraystring), [OTr_GetArrayText](#otr_getarraytext), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayText

**Legacy:** `OT GetArrayText` — version 1

```
OTr_GetArrayText ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Text
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| Function result | Text | ← | The value at the given index |

#### Discussion

`OTr_GetArrayText` retrieves a Text value from the given index of a Text/String array item. Functionally identical to `OTr_GetArrayString`.

See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

Delegates to (or shares implementation with) `OTr_GetArrayString`.

#### See Also

[OTr_PutArrayText](#otr_putarraytext), [OTr_GetArrayString](#otr_getarraystring), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayDate

**Legacy:** `OT GetArrayDate` — version 1

```
OTr_GetArrayDate ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Date
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| Function result | Date | ← | The value at the given index |

#### Discussion

`OTr_GetArrayDate` retrieves a Date value from the given index of a Date array item. The Collection element is stored as a `YYYY-MM-DD` Text string and is parsed back to a Date on retrieval.

See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

Retrieve the Text element from the Collection. Parse using `Date($element)` which accepts the ISO date format. Return a null date (`!00-00-00!`) if parsing fails or the element is empty.

#### See Also

[OTr_PutArrayDate](#otr_putarraydate), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayTime

**Legacy:** `OT GetArrayTime` — version 1

```
OTr_GetArrayTime ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Time
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| Function result | Time | ← | The value at the given index |

#### Discussion

`OTr_GetArrayTime` retrieves a Time value from the given index of a Time array item. The Collection element is stored as an `HH:MM:SS` Text string and is parsed back to a Time on retrieval.

See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

Retrieve the Text element from the Collection. Parse using `Time($element)` which accepts the `HH:MM:SS` format. Return `?00:00:00?` if parsing fails or the element is empty.

#### See Also

[OTr_PutArrayTime](#otr_putarraytime), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayBoolean

**Legacy:** `OT GetArrayBoolean` — version 1

```
OTr_GetArrayBoolean ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Boolean
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| Function result | Boolean | ← | The value at the given index |

#### Discussion

`OTr_GetArrayBoolean` retrieves a Boolean value from the given index of a Boolean array item.

See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

As per `OTr_GetArrayLong`, substituting Boolean for Integer.

#### See Also

[OTr_PutArrayBoolean](#otr_putarrayboolean), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayBLOB

**Legacy:** `OT GetArrayBLOB` — version 1

```
OTr_GetArrayBLOB ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $outValue_x : Blob)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $outValue_x | Blob | ← | Receives the BLOB value |

#### Discussion

`OTr_GetArrayBLOB` retrieves a BLOB value from the given index of a BLOB array item. Unlike the scalar-type Get methods, the BLOB is returned via an output parameter rather than as a function result, owing to 4D's handling of BLOB parameters.

The Collection element contains a `blob:N` reference string; the actual binary data is retrieved from the parallel `<>OTR_Blobs_ax` array.

See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

Retrieve the Text element from the Collection. Parse the `blob:N` reference to extract the index. Copy the data from `<>OTR_Blobs_ax{N}` into `$outValue_x`. If the reference is invalid or the slot is not in use, generate an error and set `$outValue_x` to an empty BLOB.

#### See Also

[OTr_PutArrayBLOB](#otr_putarrayblob), [OTr_GetBLOB](OTr-Phase5-Spec.md#otr_getblob), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayPicture

**Legacy:** `OT GetArrayPicture` — version 1

```
OTr_GetArrayPicture ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $outValue_p : Picture)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| $outValue_p | Picture | ← | Receives the Picture value |

#### Discussion

`OTr_GetArrayPicture` retrieves a Picture value from the given index of a Picture array item. As with `OTr_GetArrayBLOB`, the picture is returned via an output parameter.

The Collection element contains a `pic:N` reference string; the actual picture data is retrieved from the parallel `<>OTR_Pictures_ap` array.

See "Common behaviour" above for error handling semantics.

#### OTr Implementation Notes

As per `OTr_GetArrayBLOB`, but using `<>OTR_Pictures_ap` / `<>OTR_PicInUse_ab` and the `pic:N` prefix.

#### See Also

[OTr_PutArrayPicture](#otr_putarraypicture), [OTr_GetPicture](OTr-Phase5-Spec.md#otr_getpicture), [OTr_GetArray](#otr_getarray)

---

### OTr_GetArrayPointer

**Legacy:** `OT GetArrayPointer` — version 1

```
OTr_GetArrayPointer ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Pointer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | Index of the element (0..*n*) |
| Function result | Pointer | ← | The pointer value at the given index |

#### Discussion

`OTr_GetArrayPointer` retrieves a Pointer value from the given index of a Pointer array item. The Collection element contains a `ptr:` serialised reference which is deserialised back to a live pointer.

See "Common behaviour" above for error handling semantics.

> **Warning:** Pointer values are inherently process-local. A pointer stored from one process may not resolve correctly in another process, particularly in compiled databases. The returned pointer should be validated before use.

#### OTr Implementation Notes

Retrieve the Text element from the Collection. Deserialise via `OTr__DeserialisePointer` (Phase 5). If Phase 5 is not yet available, parse the `ptr:name;tableNum;fieldNum` format and use `Get pointer($name)` or equivalent to reconstruct the pointer. Return `Null` (or a nil pointer) if deserialisation fails.

#### See Also

[OTr_PutArrayPointer](#otr_putarraypointer), [OTr_GetPointer](OTr-Phase5-Spec.md#otr_getpointer), [OTr_GetArray](#otr_getarray)

---

## Array Utility Routines

The following routines provide structural manipulation of array items — querying size, resizing, inserting and deleting elements, searching, and sorting.

---

### OTr_SizeOfArray

**Legacy:** `OT SizeOfArray` — version 1

```
OTr_SizeOfArray ($handle_i : Integer; $tag_t : Text) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| Function result | Integer | ← | The number of elements in the array |

#### Discussion

`OTr_SizeOfArray` returns the number of elements in the array item referenced by `$tag_t`. This count does not include element 0 (the default element), consistent with the legacy plugin's behaviour and 4D's `Size of array` command.

If `$handle_i` is not a valid object handle, the tag does not exist, or the tag does not reference an array item, an error is generated, `OK` is set to zero, and zero is returned.

#### OTr Implementation Notes

Navigate to the Collection property via `OTr__ResolvePath`. Return `$collection.length`. Since Collection elements map to legacy elements 1..*n*, the Collection length directly equals the legacy array size.

#### See Also

[OTr_ResizeArray](#otr_resizearray), [OTr_PutArray](#otr_putarray), [OTr_GetArray](#otr_getarray)

---

### OTr_ResizeArray

**Legacy:** `OT ResizeArray` — version 2

```
OTr_ResizeArray ($handle_i : Integer; $tag_t : Text; $size_i : Integer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $size_i | Integer | → | The new size of the array |

#### Discussion

`OTr_ResizeArray` resizes the array item to the specified number of elements (not counting element 0).

If the new size is larger than the current size, new elements are appended and initialised to the type's default value (zero, empty string, `False`, etc.). If the new size is smaller, excess elements are removed from the end of the array.

If `$handle_i` is not a valid object handle, the tag does not exist, or the tag does not reference an array item, an error is generated, `OK` is set to zero, and no operation is performed.

#### OTr Implementation Notes

Navigate to the Collection via `OTr__ResolvePath`. If `$size_i` > `$collection.length`, append default-valued elements (use `$collection.push(Null)` or type-appropriate defaults) until the length matches. If `$size_i` < `$collection.length`, use `$collection.resize($size_i)` or repeatedly call `$collection.pop()` to trim. For BLOB and Picture arrays, if shrinking, release any `blob:N` / `pic:N` references in the removed elements.

#### See Also

[OTr_SizeOfArray](#otr_sizeofarray), [OTr_InsertElement](#otr_insertelement), [OTr_DeleteElement](#otr_deleteelement)

---

### OTr_InsertElement

**Legacy:** `OT InsertElement` — version 2

```
OTr_InsertElement ($handle_i : Integer; $tag_t : Text; $where_i : Integer {; $howMany_i : Integer})
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $where_i | Integer | → | Position at which to insert (1-based) |
| {$howMany_i} | Integer | → | Number of elements to insert (default 1) |

#### Discussion

`OTr_InsertElement` inserts one or more elements at the specified position within an array item. Existing elements at and after `$where_i` are shifted down. The newly inserted elements are initialised to the type's default value.

If `$where_i` is greater than the current array size, the elements are appended at the end (i.e., the position is clamped to `size + 1`).

If `$howMany_i` is not passed, one element is inserted.

If `$handle_i` is not a valid object handle, the tag does not exist, or the tag does not reference an array item, an error is generated, `OK` is set to zero, and no operation is performed.

#### OTr Implementation Notes

Navigate to the Collection. Map `$where_i` to Collection index `$where_i - 1`. If the mapped index exceeds `$collection.length`, clamp it to `$collection.length` (append behaviour). Insert `$howMany_i` default-valued elements at the mapped position. This can be achieved by building a temporary Collection of default values and using splice logic, or by iterating and inserting one element at a time.

#### See Also

[OTr_DeleteElement](#otr_deleteelement), [OTr_ResizeArray](#otr_resizearray), [OTr_SizeOfArray](#otr_sizeofarray)

---

### OTr_DeleteElement

**Legacy:** `OT DeleteElement` — version 2

```
OTr_DeleteElement ($handle_i : Integer; $tag_t : Text; $where_i : Integer {; $howMany_i : Integer})
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $where_i | Integer | → | Position of the first element to delete (1-based) |
| {$howMany_i} | Integer | → | Number of elements to delete (default 1) |

#### Discussion

`OTr_DeleteElement` removes one or more elements from the specified position within an array item. Elements after the deleted range are shifted up to close the gap. The array size decreases accordingly.

If `$howMany_i` is not passed, one element is deleted.

If `$handle_i` is not a valid object handle, the tag does not exist, the tag does not reference an array item, or `$where_i` is out of range, an error is generated, `OK` is set to zero, and no operation is performed.

#### OTr Implementation Notes

Navigate to the Collection. Map `$where_i` to Collection index `$where_i - 1`. Before removing, check whether any of the elements being deleted contain `blob:N` or `pic:N` references; if so, release the corresponding slots in the parallel arrays. Remove `$howMany_i` elements starting at the mapped position. This can be achieved via `$collection.remove($mappedIndex; $howMany_i)` or equivalent iteration.

#### See Also

[OTr_InsertElement](#otr_insertelement), [OTr_ResizeArray](#otr_resizearray), [OTr_SizeOfArray](#otr_sizeofarray)

---

### OTr_FindInArray

**Legacy:** `OT FindInArray` — version 2

```
OTr_FindInArray ($handle_i : Integer; $tag_t : Text; $value_t : Text {; $start_i : Integer}) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $value_t | Text | → | Value to search for (as Text) |
| {$start_i} | Integer | → | 1-based index at which to begin the search (default 1) |
| Function result | Integer | ← | 1-based index of the found element, or 0 if not found |

#### Discussion

`OTr_FindInArray` searches an array item for an element matching the given value. The search value is always passed as Text and is converted to the array's element type for comparison, according to the following conversion table:

| Array Element Type | Conversion Applied to `$value_t` |
|---|---|
| Boolean | `"true"` or `"1"` → `True`; all other values → `False` |
| Date | `Date($value_t)` — e.g., `"08/27/31"` is interpreted via `Date` |
| Longint | `Num($value_t)` — e.g., `"7"` → `7` |
| Real | `Num($value_t)` — e.g., `"13.27"` → `13.27` |
| String / Text | Direct text comparison; wildcard (`@`) matching is supported |
| Time | `Time($value_t)` — e.g., `"12:30:00"` |

The search proceeds from `$start_i` (default 1) through to the end of the array. The first matching element's 1-based index is returned. If no match is found, 0 is returned.

For Text/String arrays, the comparison uses `=` which is case-insensitive and diacritical-insensitive by default in 4D. The `@` wildcard character is supported for pattern matching (e.g., `"Sm@"` matches `"Smith"`, `"Small"`, etc.).

If `$handle_i` is not a valid object handle, the tag does not exist, or the tag does not reference an array item, an error is generated, `OK` is set to zero, and 0 is returned.

#### OTr Implementation Notes

Navigate to the Collection. Determine the element type by inspecting the first element (or a stored type metadata property if available). Convert `$value_t` to the appropriate type using the conversion table. Iterate from Collection index `$start_i - 1` through `$collection.length - 1`, comparing each element. For Text comparisons, use `$element = $value_t` (which provides case-insensitive, wildcard-aware matching). For numeric types, use strict equality. Return the 1-based index (`Collection index + 1`) of the first match, or 0 if none found.

> **Note:** The legacy plugin performs the type conversion based on the declared array type, not the individual element values. OTr should maintain this behaviour — if the array was created via `OTr_PutArrayLong`, all elements are treated as Longint regardless of their current Collection representation.

#### See Also

[OTr_SizeOfArray](#otr_sizeofarray), [OTr_SortArrays](#otr_sortarrays)

---

### OTr_SortArrays

**Legacy:** `OT SortArrays` — version 1

```
OTr_SortArrays ($handle_i : Integer; $tag1_t : Text; $dir1_t : Text {; $tag2_t : Text; $dir2_t : Text {; ... $tag7_t : Text; $dir7_t : Text}})
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag1_t | Text | → | Tag of the primary sort array |
| $dir1_t | Text | → | Sort direction: `">"` ascending, `"<"` descending, `"*"` move (slave) |
| {$tag2_t} | Text | → | Tag of the second sort/move array |
| {$dir2_t} | Text | → | Direction for the second array |
| ... | ... | | Up to 7 tag/direction pairs |

#### Discussion

`OTr_SortArrays` sorts one or more array items within an object. Up to 7 tag/direction pairs may be specified. The first pair defines the primary sort key; subsequent pairs with `">"` or `"<"` define secondary, tertiary, etc. sort keys. Pairs with `"*"` are "slave" arrays — their elements are rearranged to mirror the sort order determined by the key arrays, but they do not themselves influence the sort order.

**Direction codes:**

| Code | Meaning |
|---|---|
| `">"` | Sort ascending |
| `"<"` | Sort descending |
| `"*"` | Move (slave) — rearrange to follow the sort order |

If `$handle_i` is not a valid object handle, any of the referenced tags do not exist, or any of the referenced tags do not reference array items, an error is generated, `OK` is set to zero, and no operation is performed.

All arrays referenced in a single `OTr_SortArrays` call must have the same number of elements. If they do not, an error is generated.

#### Example

```4d
// Sort employees by surname ascending, moving the given-name and age arrays to match
OTr_SortArrays($emp_i; "surname"; ">"; "givenName"; "*"; "age"; "*")
```

#### OTr Implementation Notes

This is the most complex array utility. The recommended approach is:

1. Retrieve all referenced Collections.
2. Validate that all have the same length.
3. Build a temporary index array (0 to *n*−1) representing the current element order.
4. Sort the index array using a custom comparator that evaluates the key arrays (those with `">"` or `"<"` directions) in order of priority. For each key, compare elements at the two indices being compared; if equal, proceed to the next key. Apply ascending or descending as indicated.
5. Once the index array is sorted, rearrange **all** referenced Collections (both key and slave) according to the new index order.
6. Write the rearranged Collections back to their respective object properties.

For the comparison step, use natural 4D comparison operators appropriate to each element's type: `<` / `>` for Integer and Real, `<` / `>` for Text (case-insensitive by default). For Date and Time elements stored as formatted Text strings (`YYYY-MM-DD`, `HH:MM:SS`), lexicographic comparison produces correct chronological order.

> **Note:** The legacy plugin supports up to 7 tag/direction pairs. In 4D v19 without variadic parameters, this requires accepting up to 14 optional parameters after `$handle_i`. Use `Count parameters` to determine how many pairs were supplied.

#### See Also

[OTr_FindInArray](#otr_findinarray), [OTr_SizeOfArray](#otr_sizeofarray)

---

## Cross-Reference Index

| OTr Method | Legacy Command | Category |
|---|---|---|
| `OTr__ArrayToCollection` | *(internal)* | Internal Helper |
| `OTr__CollectionToArray` | *(internal)* | Internal Helper |
| `OTr_PutArray` | `OT PutArray` (v1) | Bulk Array |
| `OTr_GetArray` | `OT GetArray` (v1) | Bulk Array |
| `OTr_PutArrayLong` | `OT PutArrayLong` (v1) | Put Element |
| `OTr_PutArrayReal` | `OT PutArrayReal` (v1) | Put Element |
| `OTr_PutArrayString` | `OT PutArrayString` (v1) | Put Element |
| `OTr_PutArrayText` | `OT PutArrayText` (v1) | Put Element |
| `OTr_PutArrayDate` | `OT PutArrayDate` (v1) | Put Element |
| `OTr_PutArrayTime` | `OT PutArrayTime` (v1) | Put Element |
| `OTr_PutArrayBoolean` | `OT PutArrayBoolean` (v1) | Put Element |
| `OTr_PutArrayBLOB` | `OT PutArrayBLOB` (v1) | Put Element |
| `OTr_PutArrayPicture` | `OT PutArrayPicture` (v1) | Put Element |
| `OTr_PutArrayPointer` | `OT PutArrayPointer` (v1) | Put Element |
| `OTr_GetArrayLong` | `OT GetArrayLong` (v1) | Get Element |
| `OTr_GetArrayReal` | `OT GetArrayReal` (v1) | Get Element |
| `OTr_GetArrayString` | `OT GetArrayString` (v1) | Get Element |
| `OTr_GetArrayText` | `OT GetArrayText` (v1) | Get Element |
| `OTr_GetArrayDate` | `OT GetArrayDate` (v1) | Get Element |
| `OTr_GetArrayTime` | `OT GetArrayTime` (v1) | Get Element |
| `OTr_GetArrayBoolean` | `OT GetArrayBoolean` (v1) | Get Element |
| `OTr_GetArrayBLOB` | `OT GetArrayBLOB` (v1) | Get Element |
| `OTr_GetArrayPicture` | `OT GetArrayPicture` (v1) | Get Element |
| `OTr_GetArrayPointer` | `OT GetArrayPointer` (v1) | Get Element |
| `OTr_SizeOfArray` | `OT SizeOfArray` (v1) | Array Utility |
| `OTr_ResizeArray` | `OT ResizeArray` (v2) | Array Utility |
| `OTr_InsertElement` | `OT InsertElement` (v2) | Array Utility |
| `OTr_DeleteElement` | `OT DeleteElement` (v2) | Array Utility |
| `OTr_FindInArray` | `OT FindInArray` (v2) | Array Utility |
| `OTr_SortArrays` | `OT SortArrays` (v1) | Array Utility |
