# OTr Phase 4 — Array Operations: Detailed Command Specification

**Version:** 0.2
**Date:** 2026-04-02
**Status:** Complete
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§9, Phase 4)

---

## Overview

Phase 4 implements the **Array Put/Get** and **Array Utility** routines from the legacy ObjectTools 5.0 plugin. These commands provide the ability to store and manipulate typed 4D arrays within OTr objects.

Phase 4 depends upon the infrastructure established in Phase 1 (handle registry, locking, error handling) and the path-resolution mechanism from Phase 2 (`OTr_zResolvePath`).

### Array Storage Model

Each array is stored as a **4D Object** property of the parent object. This object contains:

| Property | Type | Description |
|---|---|---|
| `arrayType` | Integer | The 4D type constant of the array (e.g., `Text array` = 18) |
| `numElements` | Integer | The number of data elements (i.e., `Size of array`) |
| `currentItem` | Integer | The current element index (i.e., the value of `$array_ptr->`) |
| `"0"` | *(type)* | Element 0 (the default element per 4D convention) |
| `"1"` .. `"n"` | *(type)* | Data elements 1 through *n* |

The element properties are string-keyed by their 4D array index: `"0"` through `String(numElements)`. This structure preserves the 4D array's 1-based data elements and its element-0 default value with complete fidelity, and the `arrayType` property allows typed retrieval without ambiguity.

**Example** — a text array containing the days of the week:

```json
{
    "Days": {
        "arrayType": 18,
        "numElements": 7,
        "currentItem": 0,
        "0": "",
        "1": "Sunday",
        "2": "Monday",
        "3": "Tuesday",
        "4": "Wednesday",
        "5": "Thursday",
        "6": "Friday",
        "7": "Saturday"
    }
}
```

### Type Conversion

Scalar-compatible types (Text, String, LongInt, Integer, Real, Boolean) are stored directly as object property values. Types requiring special handling are encoded via the `OTr_u*` utility methods:

| Array Type | Stored As | Utility (store) | Utility (retrieve) |
|---|---|---|---|
| Text array / String array | Text | — (direct) | — (direct) |
| LongInt array / Integer array | Integer | — (direct) | — (direct) |
| Real array | Real | — (direct) | — (direct) |
| Boolean array | Boolean | — (direct) | — (direct) |
| Date array | Text (`YYYY-MM-DD`) | `OTr_uDateToText` | `OTr_uTextToDate` |
| Time array | Text (`HH:MM:SS`) | `OTr_uTimeToText` | `OTr_uTextToTime` |
| Pointer array | Text (`name;tableNum;fieldNum`) | `OTr_uPointerToText` | `OTr_uTextToPointer` |
| Blob array | Text (base64) or BLOB | `OTr_uBlobToText` (v19/v19R1) / direct `OB SET` (v19R2+) | `OTr_uTextToBlob` (v19/v19R1) / direct `OB Get` (v19R2+) |
| Picture array | Picture | direct `OB SET` | direct `OB Get` |

### Type Constants

For the authoritative reference of 4D type constants and their mapping to legacy OT constants, see [OTr-Types-Reference.md](OTr-Types-Reference.md).

---

## Utility Methods (`OTr_u*`)

The following methods are private helpers used by the array put/get routines and by the scalar Phase 2 and Phase 5 methods. They are marked `"invisible":true` and are **not** `"shared"`. The `OTr_u` prefix (single underscore, lowercase `u`) distinguishes them from the public API (`OTr_`) and internal infrastructure methods (`OTr_z`).

---

### OTr_uDateToText

```
OTr_uDateToText ($theDate_d : Date) → Text
```

| Parameter | Type | | Description |
|---|---|---|---|
| $theDate_d | Date | → | The date to convert |
| Function result | Text | ← | Date as `YYYY-MM-DD` |

#### Discussion

Converts a 4D Date value to an ISO 8601 text string for storage in an OTr object property. The format is `YYYY-MM-DD`, zero-padded. A null date (`!00/00/00!`) is stored as `"0000-00-00"`.

#### OTr Implementation Notes

Uses `Year of`, `Month of`, and `Day of` with `String($x; "00")` / `String($x; "0000")` formatting to construct the text value.

#### See Also

[OTr_uTextToDate](#otr_utexttodate)

---

### OTr_uTextToDate

```
OTr_uTextToDate ($dateAsText_t : Text) → Date
```

| Parameter | Type | | Description |
|---|---|---|---|
| $dateAsText_t | Text | → | Date as `YYYY-MM-DD` |
| Function result | Date | ← | Parsed date, or `!00/00/00!` if input is empty |

#### Discussion

Parses an ISO 8601 text string back into a 4D Date value. If `$dateAsText_t` is empty, the null date `!00/00/00!` is returned.

#### OTr Implementation Notes

Extracts year, month, and day substrings via `Substring` and converts via `Num`. Reconstructs the date using `Add to date(!00-00-00!; year; month; day)`.

#### See Also

[OTr_uDateToText](#otr_udatetotext)

---

### OTr_uTimeToText

```
OTr_uTimeToText ($theTime_h : Time) → Text
```

| Parameter | Type | | Description |
|---|---|---|---|
| $theTime_h | Time | → | The time to convert |
| Function result | Text | ← | Time as `HH:MM:SS` |

#### Discussion

Converts a 4D Time value to an `HH:MM:SS` text string for storage in an OTr object property.

#### OTr Implementation Notes

Uses `String($theTime_h; HH MM SS)`.

#### See Also

[OTr_uTextToTime](#otr_utexttotime)

---

### OTr_uTextToTime

```
OTr_uTextToTime ($timeAsText_t : Text) → Time
```

| Parameter | Type | | Description |
|---|---|---|---|
| $timeAsText_t | Text | → | Time as `HH:MM:SS` |
| Function result | Time | ← | Parsed time, or `?00:00:00?` if input is empty |

#### Discussion

Parses an `HH:MM:SS` text string back into a 4D Time value. If `$timeAsText_t` is empty, `?00:00:00?` is returned.

#### OTr Implementation Notes

Uses `Time($timeAsText_t)` which accepts the `HH:MM:SS` format directly.

#### See Also

[OTr_uTimeToText](#otr_utimetotext)

---

### OTr_uPointerToText

```
OTr_uPointerToText ($thePointer_ptr : Pointer) → Text
```

| Parameter | Type | | Description |
|---|---|---|---|
| $thePointer_ptr | Pointer | → | The pointer to serialise |
| Function result | Text | ← | Serialised string: `variableName;tableNum;fieldNum` |

#### Discussion

Serialises a 4D Pointer to a storable text string using `RESOLVE POINTER`. The format is `variableName;tableNum;fieldNum`, where the fields encode the pointer's target:

| Pointer target | Example serialised form |
|---|---|
| Variable pointer | `myVar;-1;0` |
| Array element pointer | `myArr;3;0` |
| Table pointer | `;2;0` |
| Field pointer | `;2;5` |

> **Note:** There is no `ptr:` prefix in the serialised format. The type is known from context (the parent array's `arrayType` is `Pointer array` = 20, or the scalar item was stored via `OTr_PutPointer`).

#### OTr Implementation Notes

Uses `RESOLVE POINTER($thePointer_p; $variableName_t; $tableNum_i; $fieldNum_i)`, then concatenates the three components with `;` separators.

#### See Also

[OTr_uTextToPointer](#otr_utexttopointer)

---

### OTr_uTextToPointer

```
OTr_uTextToPointer ($pointerAsText_t : Text) → Pointer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $pointerAsText_t | Text | → | Serialised pointer string |
| Function result | Pointer | ← | Reconstructed pointer, or `Null` if unresolvable |

#### Discussion

Deserialises a pointer from its stored text representation. The four cases are handled as follows:

| Condition | Reconstruction |
|---|---|
| `variableName` non-empty, `tableNum` = -1 | `Get pointer(variableName)` |
| `variableName` non-empty, `tableNum` > 0 | `Get pointer(variableName + "{" + tableNum + "}")` |
| `variableName` empty, `tableNum` > 0, `fieldNum` = 0 | `Table(tableNum)` |
| `tableNum` > 0, `fieldNum` > 0 | `Field(tableNum; fieldNum)` |

If the input is empty or the pointer cannot be reconstructed, `Null` is returned.

> **Warning:** Variable and array-element pointers are resolved via `Get pointer`, which requires the variable to exist in the current process scope. Pointers to local variables from other methods cannot be resolved. Cross-process use requires a host-side wrapper.

#### See Also

[OTr_uPointerToText](#otr_upointeritotext)

---

### OTr_uBlobToText

```
OTr_uBlobToText ($theBlob_x : Blob) → Text
```

| Parameter | Type | | Description |
|---|---|---|---|
| $theBlob_x | Blob | → | The BLOB to encode |
| Function result | Text | ← | Base64-encoded text representation of the BLOB |

#### Discussion

Encodes a BLOB to a base64 Text string for storage as an Object property on 4D v19 and v19R1, where native BLOB storage in Objects is unavailable. This method performs pure base64 encoding with no slot management or reference strings. It is only called when `Storage.OTr.nativeBlobInObject` is `False`.

On v19R2 or later, BLOBs are stored directly via `OB SET` and this method is not called.

#### OTr Implementation Notes

Uses `BASE64 ENCODE($theBlob_x; $result_t)`. Returns the encoded text.

#### See Also

[OTr_uTextToBlob](#otr_utexttoblob)

---

### OTr_uTextToBlob

```
OTr_uTextToBlob ($base64_t : Text) → Blob
```

| Parameter | Type | | Description |
|---|---|---|---|
| $base64_t | Text | → | Base64-encoded text representation of the BLOB |
| Function result | Blob | ← | The decoded BLOB, or an empty BLOB if input is empty |

#### Discussion

Decodes a base64 Text string back to a BLOB. This is the inverse of `OTr_uBlobToText` and is only called when `Storage.OTr.nativeBlobInObject` is `False`. If `$base64_t` is empty, an empty BLOB is returned.

#### OTr Implementation Notes

Uses `BASE64 DECODE($base64_t; $result_x)`. Returns the decoded BLOB.

#### See Also

[OTr_uBlobToText](#otr_ublobtotext)

---

### ~~OTr_uPictureToText~~ — Retired (Phase 6)

This method was removed in Phase 6. Pictures are stored natively as Object properties using `OB SET($parent_o; $key_t; $picture_pic)` on all supported 4D versions (v16R4 or later). The `pic:N` parallel-array reference design was superseded. See [OTr-Phase-006-Spec.md](OTr-Phase-006-Spec.md).

---

### ~~OTr_uTextToPicture~~ — Retired (Phase 6)

This method was removed in Phase 6. Pictures are retrieved natively using `OB Get($parent_o; $key_t; Is picture)`. See [OTr-Phase-006-Spec.md](OTr-Phase-006-Spec.md).

---

## Bulk Array Routines

---

### OTr_PutArray

**Legacy:** `OT PutArray` — version 1

```
OTr_PutArray ($handle_i : Integer; $tag_t : Text; $array_ptr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag path under which to store the array |
| $array_ptr | Pointer | → | Pointer to a 4D array |

#### Discussion

`OTr_PutArray` stores an entire 4D array into an OTr object. The array may be of any supported type: LongInt, Integer, Real, Text, String, Date, Time, Boolean, Blob, Picture, or Pointer.

If `$handle_i` is not a valid object handle, an error is generated and `OK` is set to zero.

The array is serialised as a 4D Object with `arrayType`, `numElements`, `currentItem`, and string-keyed element properties `"0"` through `"n"` (see "Array Storage Model" above). If an array item already exists at the given tag, it is replaced entirely.

Dotted tag paths are supported via `OTr_zResolvePath` with `AutoCreateObjects` enabled: `OTr_PutArray($h_i; "All.Days"; ->$days_at)` will create the embedded object `"All"` if it does not already exist.

String and Text arrays are interchangeable — both are stored with `arrayType` = `Text array` (18).

#### OTr Implementation Notes

1. Validate the handle; acquire the lock.
2. Call `OTr_zResolvePath($anObj_o; $tag_t; True; ->$parent_o; ->$leafKey_t)` to resolve the parent object and leaf key.
3. Determine the array type via `Type($array_ptr->)` and size via `Size of array($array_ptr->)`.
4. Capture the current element index via `$array_ptr->` (the array itself evaluates to its current element index in 4D).
5. Create a new `$arrayObject_o` via `New object("arrayType"; $type_i; "numElements"; $count_i; "currentItem"; $currentItem_i)`.
6. Iterate from index 0 through `$count_i`, assigning `$array_ptr->{$index_i}` to `$arrayObject_o[String($index_i)]` for direct types, or via the appropriate `OTr_u*` utility for Date, Time, Pointer, Blob, and Picture types.
7. Store the completed array object via `OB SET($parent_o; $leafKey_t; $arrayObject_o)`.
8. Release the lock.

#### See Also

[OTr_GetArray](#otr_getarray), [OTr_SizeOfArray](#otr_sizeofarray)

---

### OTr_GetArray

**Legacy:** `OT GetArray` — version 1

```
OTr_GetArray ($handle_i : Integer; $tag_t : Text; $array_ptr : Pointer)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $array_ptr | Pointer | ← | Pointer to a 4D array to populate |

#### Discussion

`OTr_GetArray` retrieves an array from an OTr object and populates the pointed-to 4D array. The target array must already be declared and of a compatible type.

If `$handle_i` is not a valid object handle, or the tag does not reference an array item (i.e., the stored property is not an Object containing `arrayType`), an error is generated, `OK` is set to zero, and the target array is left untouched.

The target array is resized to `numElements` and populated from element 0 through `numElements`. The `currentItem` value is restored to the array.

String and Text arrays are interchangeable.

> **Warning:** When retrieving into a fixed-width String array, values exceeding the declared width are truncated by 4D.

#### OTr Implementation Notes

1. Validate the handle; acquire the lock.
2. Navigate to the property via `OTr_zResolvePath` (read-only, `AutoCreate` = `False`).
3. Retrieve the stored Object via `OB Get` and verify it has an `arrayType` property.
4. Resize the target array to `numElements` via `ARRAY [TYPE]($array_ptr->; $numElements)`.
5. Restore the current element index: `$array_ptr->:=$currentItem_i`.
6. Iterate from 0 through `numElements`, retrieving `$arrayObject_o[String($index_i)]` and assigning to `$array_ptr->{$index_i}`, applying the appropriate `OTr_uTextTo*` utility for Date, Time, Pointer, Blob, and Picture types.
7. Release the lock.

#### See Also

[OTr_PutArray](#otr_putarray), [OTr_SizeOfArray](#otr_sizeofarray)

---

## Array Utility Routines

The following routines provide structural manipulation of array items — querying size, resizing, inserting and deleting elements, searching, and sorting. All routines operate on the array Object stored at the given tag path.

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
| Function result | Integer | ← | The number of data elements in the array |

#### Discussion

`OTr_SizeOfArray` returns the value of `numElements` from the stored array Object. This equals `Size of array` on the original 4D array — it does not count element 0.

If `$handle_i` is not a valid object handle, the tag does not exist, or the tag does not reference an array item, an error is generated, `OK` is set to zero, and zero is returned.

#### OTr Implementation Notes

Navigate to the property via `OTr_zResolvePath`. Return `OB Get($arrayObject_o; "numElements")`.

#### See Also

[OTr_ResizeArray](#otr_resizearray), [OTr_PutArray](#otr_putarray)

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
| $size_i | Integer | → | The new number of data elements |

#### Discussion

`OTr_ResizeArray` adjusts the stored array Object to contain `$size_i` data elements. If growing, new element properties are appended and initialised to the type's default value (zero, empty string, `False`, null date, etc.). If shrinking, excess element properties are removed. The `numElements` property is updated accordingly.

If `$handle_i` is not a valid object handle, the tag does not exist, or the tag does not reference an array item, an error is generated, `OK` is set to zero, and no operation is performed.

#### OTr Implementation Notes

After navigating to the array Object, compare `$size_i` to the current `numElements`. For growth, iterate from `numElements + 1` through `$size_i`, adding default-valued properties. For shrinkage, iterate from `$size_i + 1` through `numElements`, calling `OB REMOVE` on each property key. Native Object properties (including Pictures and BLOBs) are released automatically when removed. Update `numElements` via `OB SET`.

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
| $where_i | Integer | → | 1-based position at which to insert |
| {$howMany_i} | Integer | → | Number of elements to insert (default 1) |

#### Discussion

`OTr_InsertElement` inserts one or more elements at the specified position within an array item. Existing elements at and after `$where_i` are shifted down (their string keys incremented by `$howMany_i`). The newly inserted elements are initialised to the type's default value.

If `$where_i` exceeds the current `numElements`, the elements are appended at the end.

If `$howMany_i` is not passed, one element is inserted.

If `$handle_i` is not a valid object handle, the tag does not exist, or the tag does not reference an array item, an error is generated, `OK` is set to zero, and no operation is performed.

#### OTr Implementation Notes

Since element properties are string-keyed, insertion requires re-keying all elements from the insertion point downwards. Iterate from `numElements` down to `$where_i`, renaming each property key from `String($i)` to `String($i + $howMany_i)` (via read, write new key, remove old key). Then write default values to the `$howMany_i` new keys. Update `numElements`.

#### See Also

[OTr_DeleteElement](#otr_deleteelement), [OTr_ResizeArray](#otr_resizearray)

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
| $where_i | Integer | → | 1-based position of the first element to delete |
| {$howMany_i} | Integer | → | Number of elements to delete (default 1) |

#### Discussion

`OTr_DeleteElement` removes one or more elements from the specified position within an array item. Elements after the deleted range are shifted up (their string keys decremented). The `numElements` property is updated accordingly.

If `$howMany_i` is not passed, one element is deleted.

If `$handle_i` is not a valid object handle, the tag does not exist, the tag does not reference an array item, or `$where_i` is out of range, an error is generated, `OK` is set to zero, and no operation is performed.

#### OTr Implementation Notes

Remove the `$howMany_i` properties from `$where_i` through `$where_i + $howMany_i - 1` via `OB REMOVE`. Native Object properties (including Pictures and BLOBs) are released automatically when removed. Re-key all subsequent properties (from `$where_i + $howMany_i` through `numElements`) downward by `$howMany_i`. Update `numElements`.

#### See Also

[OTr_InsertElement](#otr_insertelement), [OTr_ResizeArray](#otr_resizearray)

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
| {$start_i} | Integer | → | 1-based index at which to begin (default 1) |
| Function result | Integer | ← | 1-based index of the found element, or -1 if not found |

#### Discussion

`OTr_FindInArray` searches the stored array for a matching element. The search value is always passed as Text and is converted to the array's element type (read from `arrayType`) before comparison, according to the following table:

| `arrayType` | Conversion applied to `$value_t` |
|---|---|
| `Boolean array` (22) | `"true"` or `"1"` → `True`; all other values → `False` |
| `Date array` (17) | `OTr_uTextToDate($value_t)` |
| `LongInt array` / `Integer array` (16/15) | `Num($value_t)` |
| `Real array` (14) | `Num($value_t)` |
| `Text array` / `String array` (18/21) | Direct text comparison; `@` wildcard supported |
| `Time array` (32) | `OTr_uTextToTime($value_t)` |

The search proceeds from `$start_i` (default 1) through `numElements`. The first matching element's 1-based index is returned. If no match is found, -1 is returned.

For Text/String arrays, comparison is case-insensitive and diacritical-insensitive, and the `@` wildcard character is supported.

If `$handle_i` is not a valid object handle, the tag does not exist, or the tag does not reference an array item, an error is generated, `OK` is set to zero, and -1 is returned.

#### OTr Implementation Notes

Read `arrayType` from the array Object to determine the comparison type. Iterate from `$start_i` through `numElements`, reading each property by `String($index_i)` and comparing. For Text, use the `=` operator. For numeric types, compare against `Num($value_t)`. For dates and times, convert via `OTr_uTextToDate` / `OTr_uTextToTime`.

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
| ... | | | Up to 7 tag/direction pairs |

#### Discussion

`OTr_SortArrays` sorts one or more array items stored within an OTr object. Up to 7 tag/direction pairs may be specified. Arrays with direction `">"` (ascending) or `"<"` (descending) act as sort keys. Arrays with direction `"*"` are "slave" arrays — their elements are rearranged to mirror the sort order determined by the key arrays but do not themselves influence the sort.

All referenced arrays must have the same `numElements` value. If they do not, an error is generated.

If `$handle_i` is not a valid object handle, or any referenced tag does not point to an array item, an error is generated, `OK` is set to zero, and no operation is performed.

**Direction codes:**

| Code | Meaning |
|---|---|
| `">"` | Sort ascending |
| `"<"` | Sort descending |
| `"*"` | Move (slave) — rearrange to follow the sort order |

#### Example

```4d
// Sort employees by surname ascending, moving the givenName and age arrays to match
OTr_SortArrays($emp_i; "surname"; ">"; "givenName"; "*"; "age"; "*")
```

#### OTr Implementation Notes

Since all array data resides in string-keyed object properties, sorting requires:

1. Read all referenced array Objects from the parent object.
2. Validate that all `numElements` values match.
3. Build a temporary index array (1 to *n*) representing the current order.
4. Sort this index array by evaluating the key arrays (direction `">"` / `"<"`) in priority order. Compare element values by reading `$arrayObject_o[String($i)]` for the two indices being swapped. Use `arrayType` to determine the appropriate comparison (numeric, text, or date/time string).
5. Rearrange all referenced array Objects — both key and slave — by writing new element values in the sorted order.
6. Write the rearranged Objects back to the parent object via `OB SET`.

> **Note:** Up to 7 tag/direction pairs are supported. In 4D v19 without variadic parameters, this requires up to 14 optional parameters after `$handle_i`. Use `Count parameters` to determine how many pairs were supplied.

#### See Also

[OTr_FindInArray](#otr_findinarray), [OTr_SizeOfArray](#otr_sizeofarray)

---

## Per-Element Get and Put Routines

The legacy plugin provides per-element put and get methods for each type (e.g., `OT PutArrayLong`, `OT GetArrayLong`). In the OTr implementation, these are thin wrappers that navigate to the stored array Object, apply type-appropriate conversion, and read or write a single string-keyed element property.

All element methods share the same index semantics as `OTr_PutArray` / `OTr_GetArray`: index 0 accesses the default element, indices 1 through `numElements` access data elements, and the `numElements` property bounds-checks the index.

For brevity, the put and get pairs for each type are documented together below.

---

### OTr_PutArrayLong / OTr_GetArrayLong

**Legacy:** `OT PutArrayLong` / `OT GetArrayLong` — version 1

```
OTr_PutArrayLong ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_i : Integer)
OTr_GetArrayLong ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index (0 = default element) |
| $value_i | Integer | → / ← | Value to store / retrieved value |

#### Discussion

Stores or retrieves a single Integer element in a LongInt or Integer array item. The value is stored directly as a numeric object property under the key `String($index_i)`.

If the tag does not reference an existing array item, `OTr_PutArrayLong` creates a new LongInt array Object containing only the specified element. If the index exceeds `numElements`, the array is grown to accommodate it.

#### See Also

[OTr_PutArray](#otr_putarray), [OTr_GetArray](#otr_getarray)

---

### OTr_PutArrayReal / OTr_GetArrayReal

**Legacy:** `OT PutArrayReal` / `OT GetArrayReal` — version 1

```
OTr_PutArrayReal ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_r : Real)
OTr_GetArrayReal ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Real
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index |
| $value_r | Real | → / ← | Value to store / retrieved value |

#### Discussion

Stores or retrieves a single Real element in a Real array item. Stored directly as a numeric property.

#### See Also

[OTr_PutArray](#otr_putarray), [OTr_GetArray](#otr_getarray)

---

### OTr_PutArrayString / OTr_GetArrayString / OTr_PutArrayText / OTr_GetArrayText

**Legacy:** `OT PutArrayString` / `OT GetArrayString` / `OT PutArrayText` / `OT GetArrayText` — version 1

```
OTr_PutArrayString ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_t : Text)
OTr_GetArrayString ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Text
OTr_PutArrayText   ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_t : Text)
OTr_GetArrayText   ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Text
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index |
| $value_t | Text | → / ← | Value to store / retrieved value |

#### Discussion

Stores or retrieves a single Text element in a Text or String array item. String and Text arrays are interchangeable — both use `arrayType` = `Text array` (18). Values are stored directly as text properties.

#### See Also

[OTr_PutArray](#otr_putarray), [OTr_GetArray](#otr_getarray)

---

### OTr_PutArrayDate / OTr_GetArrayDate

**Legacy:** `OT PutArrayDate` / `OT GetArrayDate` — version 1

```
OTr_PutArrayDate ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_d : Date)
OTr_GetArrayDate ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Date
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index |
| $value_d | Date | → / ← | Value to store / retrieved value |

#### Discussion

Stores or retrieves a single Date element. Dates are encoded via `OTr_uDateToText` on storage and decoded via `OTr_uTextToDate` on retrieval.

#### See Also

[OTr_uDateToText](#otr_udatetotext), [OTr_uTextToDate](#otr_utexttodate)

---

### OTr_PutArrayTime / OTr_GetArrayTime

**Legacy:** `OT PutArrayTime` / `OT GetArrayTime` — version 1

```
OTr_PutArrayTime ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_h : Time)
OTr_GetArrayTime ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Time
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index |
| $value_h | Time | → / ← | Value to store / retrieved value |

#### Discussion

Stores or retrieves a single Time element. Times are encoded via `OTr_uTimeToText` on storage and decoded via `OTr_uTextToTime` on retrieval.

#### See Also

[OTr_uTimeToText](#otr_utimetotext), [OTr_uTextToTime](#otr_utexttotime)

---

### OTr_PutArrayBoolean / OTr_GetArrayBoolean

**Legacy:** `OT PutArrayBoolean` / `OT GetArrayBoolean` — version 1

```
OTr_PutArrayBoolean ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_b : Boolean)
OTr_GetArrayBoolean ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Boolean
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index |
| $value_b | Boolean | → / ← | Value to store / retrieved value |

#### Discussion

Stores or retrieves a single Boolean element. Stored directly as a Boolean property.

#### See Also

[OTr_PutArray](#otr_putarray), [OTr_GetArray](#otr_getarray)

---

### OTr_PutArrayBLOB / OTr_GetArrayBLOB

**Legacy:** `OT PutArrayBLOB` / `OT GetArrayBLOB` — version 1

```
OTr_PutArrayBLOB ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_x : Blob)
OTr_GetArrayBLOB ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $outValue_x : Blob)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index |
| $value_x | Blob | → | Value to store |
| $outValue_x | Blob | ← | Retrieved value (Get only) |

#### Discussion

Stores or retrieves a single BLOB element. The storage path branches on `Storage.OTr.nativeBlobInObject`: on v19R2 or later, the element is stored directly as a native BLOB value; on v19/v19R1, the BLOB is base64-encoded via `OTr_uBlobToText` and stored as Text. Retrieval applies the corresponding inverse path. The Get method returns the BLOB via an output parameter rather than a function result.

#### See Also

[OTr_uBlobToText](#otr_ublobtotext), [OTr_uTextToBlob](#otr_utexttoblob)

---

### OTr_PutArrayPicture / OTr_GetArrayPicture

**Legacy:** `OT PutArrayPicture` / `OT GetArrayPicture` — version 1

```
OTr_PutArrayPicture ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_g : Picture)
OTr_GetArrayPicture ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $outValue_g : Picture)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index |
| $value_g | Picture | → | Value to store |
| $outValue_g | Picture | ← | Retrieved value (Get only) |

#### Discussion

Stores or retrieves a single Picture element. Pictures are stored natively as Object property values via `OB SET` (no utility method required) and retrieved via `OB Get` with the `Is picture` type specifier. The Get method returns the Picture via an output parameter.

#### See Also

[OTr_PutArrayPicture](#otr_putarraypicture)

---

### OTr_PutArrayPointer / OTr_GetArrayPointer

**Legacy:** `OT PutArrayPointer` / `OT GetArrayPointer` — version 1

```
OTr_PutArrayPointer ($handle_i : Integer; $tag_t : Text; $index_i : Integer; $value_ptr : Pointer)
OTr_GetArrayPointer ($handle_i : Integer; $tag_t : Text; $index_i : Integer) → Pointer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the array item |
| $index_i | Integer | → | 1-based element index |
| $value_ptr | Pointer | → / ← | Value to store / retrieved value |

#### Discussion

Stores or retrieves a single Pointer element. Pointers are serialised via `OTr_uPointerToText` and deserialised via `OTr_uTextToPointer`.

> **Warning:** Pointer values are inherently process-local. A pointer stored from one process may not resolve correctly in another, particularly in compiled databases.

#### See Also

[OTr_uPointerToText](#otr_upointertotext), [OTr_uTextToPointer](#otr_utexttopointer)

---

## Cross-Reference Index

| OTr Method | Legacy Command | Category |
|---|---|---|
| `OTr_uDateToText` | *(internal utility)* | Utility |
| `OTr_uTextToDate` | *(internal utility)* | Utility |
| `OTr_uTimeToText` | *(internal utility)* | Utility |
| `OTr_uTextToTime` | *(internal utility)* | Utility |
| `OTr_uPointerToText` | *(internal utility)* | Utility |
| `OTr_uTextToPointer` | *(internal utility)* | Utility |
| `OTr_uBlobToText` | *(internal utility — v19/v19R1 only)* | Utility |
| `OTr_uTextToBlob` | *(internal utility — v19/v19R1 only)* | Utility |
| ~~`OTr_uPictureToText`~~ | *(retired — Phase 6)* | Utility |
| ~~`OTr_uTextToPicture`~~ | *(retired — Phase 6)* | Utility |
| `OTr_PutArray` | `OT PutArray` (v1) | Bulk Array |
| `OTr_GetArray` | `OT GetArray` (v1) | Bulk Array |
| `OTr_PutArrayLong` | `OT PutArrayLong` (v1) | Put/Get Element |
| `OTr_GetArrayLong` | `OT GetArrayLong` (v1) | Put/Get Element |
| `OTr_PutArrayReal` | `OT PutArrayReal` (v1) | Put/Get Element |
| `OTr_GetArrayReal` | `OT GetArrayReal` (v1) | Put/Get Element |
| `OTr_PutArrayString` | `OT PutArrayString` (v1) | Put/Get Element |
| `OTr_GetArrayString` | `OT GetArrayString` (v1) | Put/Get Element |
| `OTr_PutArrayText` | `OT PutArrayText` (v1) | Put/Get Element |
| `OTr_GetArrayText` | `OT GetArrayText` (v1) | Put/Get Element |
| `OTr_PutArrayDate` | `OT PutArrayDate` (v1) | Put/Get Element |
| `OTr_GetArrayDate` | `OT GetArrayDate` (v1) | Put/Get Element |
| `OTr_PutArrayTime` | `OT PutArrayTime` (v1) | Put/Get Element |
| `OTr_GetArrayTime` | `OT GetArrayTime` (v1) | Put/Get Element |
| `OTr_PutArrayBoolean` | `OT PutArrayBoolean` (v1) | Put/Get Element |
| `OTr_GetArrayBoolean` | `OT GetArrayBoolean` (v1) | Put/Get Element |
| `OTr_PutArrayBLOB` | `OT PutArrayBLOB` (v1) | Put/Get Element |
| `OTr_GetArrayBLOB` | `OT GetArrayBLOB` (v1) | Put/Get Element |
| `OTr_PutArrayPicture` | `OT PutArrayPicture` (v1) | Put/Get Element |
| `OTr_GetArrayPicture` | `OT GetArrayPicture` (v1) | Put/Get Element |
| `OTr_PutArrayPointer` | `OT PutArrayPointer` (v1) | Put/Get Element |
| `OTr_GetArrayPointer` | `OT GetArrayPointer` (v1) | Put/Get Element |
| `OTr_SizeOfArray` | `OT SizeOfArray` (v1) | Array Utility |
| `OTr_ResizeArray` | `OT ResizeArray` (v2) | Array Utility |
| `OTr_InsertElement` | `OT InsertElement` (v2) | Array Utility |
| `OTr_DeleteElement` | `OT DeleteElement` (v2) | Array Utility |
| `OTr_FindInArray` | `OT FindInArray` (v2) | Array Utility |
| `OTr_SortArrays` | `OT SortArrays` (v1) | Array Utility |
