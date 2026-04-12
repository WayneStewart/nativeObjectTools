# OTr Phase 3 — Item Info and Utilities: Detailed Command Specification

**Version:** 0.1
**Date:** 2026-04-01
**Status:** Complete
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§9, Phase 3)

---

## Overview

Phase 3 implements the **Object Info**, **Item Info**, and **Item Utility** routines from the legacy ObjectTools 5.0 plugin. These commands provide introspection and manipulation capabilities for items stored within OTr objects.

Phase 3 depends upon the infrastructure established in Phase 1 (handle registry, locking, error handling) and the scalar put/get and path-resolution mechanisms from Phase 2 (`OTr_zResolvePath`).

### Commands in This Phase

**Object Info Routines:**
`OTr_IsObject`, `OTr_ItemCount`, `OTr_ObjectSize`

**Item Info Routines:**
`OTr_ItemExists`, `OTr_ItemType`, `OTr_IsEmbedded`, `OTr_GetItemProperties`, `OTr_GetNamedProperties`, `OTr_GetAllProperties`, `OTr_GetAllNamedProperties`

**Item Utility Routines:**
`OTr_CompareItems`, `OTr_CopyItem`, `OTr_RenameItem`, `OTr_DeleteItem`

---

## Type Constants

For the authoritative reference of 4D type constants and their mapping to legacy OT constants, see [OTr-Types-Reference.md](OTr-Types-Reference.md).

---

## Object Info Routines

The following routines provide the ability to obtain complete information about an object as a whole. To obtain information about individual items within an object, see "Item Info Routines" below.

---

### OTr_IsObject

**Legacy:** `OT IsObject` — version 1

```
OTr_IsObject ($handle_i : Integer) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to test |
| Function result | Integer | ← | 1 if $handle_i is a valid OTr object handle, 0 if not |

#### Discussion

`OTr_IsObject` tests whether a given Integer value is a valid object handle. If `$handle_i` points to a valid object, 1 is returned. If `$handle_i` is zero or points to some other type of object, zero is returned.

Whilst it is theoretically possible to construct a value that would fool `OTr_IsObject` into thinking it was a valid handle, this is extremely unlikely given the bounds and in-use flag checks.

All OTr methods check the validity of the object handle passed in to prevent errors from occurring. Unless you are unsure about the contents of a variable or field passed to OTr as a handle, there is no need to call `OTr_IsObject` first.

#### Example

If you try to retrieve an embedded object from another object and it does not exist, a null object handle is returned. In that case you would want to test the result as shown in the example below.

```4d
C_TEXT($tag_t)
$tag_t:=Request("Item tag:")

If ((OK=1) & (Length($tag_t)>0))
    C_LONGINT($embedded_i)
    $embedded_i:=OTr_GetObject($myObject_i; $tag_t)  // tag may not be valid!

    If (OTr_IsObject($embedded_i))
        // Do something with the object
    End if
End if
```

#### OTr Implementation Notes

Implementation is straightforward: check that `$handle_i` is within the bounds of `<>OTR_InUse_ab` and that `<>OTR_InUse_ab{$handle_i}` is `True`. No locking is required for a simple read of the Boolean flag, though the implementation may choose to lock for strict consistency.

#### See Also

[OTr_ItemExists](#otr_itemexists)

---

### OTr_ItemCount

**Legacy:** `OT ItemCount` — version 1

```
OTr_ItemCount ($handle_i : Integer {; $tag_t : Text}) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| {$tag_t} | Text | → | Tag of an embedded object |
| Function result | Integer | ← | The item count |

#### Discussion

`OTr_ItemCount` returns the number of top-level items in the referenced object. Items in embedded objects are not included in the count.

If `$handle_i` is not a valid object handle, an error is generated, `OK` is set to zero, and zero is returned.

If the tag is not passed or is empty, the count of top-level items in the object is returned.

If the tag is passed, is not empty, and is a valid item reference for an embedded object, the count of top-level items in the embedded object is returned.

Otherwise an error is generated, `OK` is set to zero, and zero is returned.

#### OTr Implementation Notes

Use `OB Keys` to obtain a text array of property names, then return `Size of array` on that array. When `$tag_t` is provided, use `OTr_zResolvePath` to navigate to the embedded object first. Properties beginning with `__otr_` (internal metadata) must be excluded from the count if any are present at the top level.

#### See Also

[OTr_IsObject](#otr_isobject), [OTr_IsEmbedded](#otr_isembedded)

---

### OTr_ObjectSize

**Legacy:** `OT ObjectSize` — version 1

```
OTr_ObjectSize ($handle_i : Integer) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| Function result | Integer | ← | The total size of the object in bytes |

#### Discussion

`OTr_ObjectSize` returns the total size of an object in memory. If `$handle_i` is not a valid object handle, an error is generated, `OK` is set to zero, and zero is returned.

#### OTr Implementation Notes

An exact byte-level measurement is not available for native 4D objects in the same manner as the legacy plugin's internal memory structures. The recommended approach is to serialise the object to JSON via `JSON Stringify` and return `Length` of the resulting text as an approximation. This provides a useful relative measure of object complexity, though it will not precisely match the legacy plugin's byte counts. The size of any referenced BLOBs and Pictures in the parallel arrays should be added to the total for completeness.

#### See Also

[OTr_GetAllProperties](#otr_getallproperties), [OTr_GetItemProperties](#otr_getitemproperties)

---

## Item Info Routines

The following routines provide the ability to obtain various information about each item in an object. These routines are useful if you want to deal with objects in a generic way and need to know how to classify each item.

---

### OTr_ItemExists

**Legacy:** `OT ItemExists` — version 1

```
OTr_ItemExists ($handle_i : Integer; $tag_t : Text) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to query |
| Function result | Integer | ← | 1 if the given item exists, 0 if not |

#### Discussion

`OTr_ItemExists` tests for the existence of the given item. `$tag_t` may refer to a top-level item, an embedded object, or an embedded item.

If `$handle_i` is not a valid object handle, an error is generated, `OK` is set to zero, and zero is returned.

If an item with the given tag exists, 1 is returned. Otherwise zero is returned.

#### OTr Implementation Notes

Use `OTr_zResolvePath` to navigate the dot-separated path. If the path resolves successfully and the final property exists (checked via `OB Is defined`), return 1. If any intermediate object along the path does not exist, return 0 without generating an error (unlike `OTr_zResolvePath` in auto-create mode, this must be a read-only traversal). The `AutoCreateObjects` option must **not** apply here — this is a query, not a mutation.

#### See Also

[OTr_ItemType](#otr_itemtype), [OTr_IsEmbedded](#otr_isembedded)

---

### OTr_ItemType

**Legacy:** `OT ItemType` — version 1

```
OTr_ItemType ($handle_i : Integer; $tag_t : Text) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to query |
| Function result | Integer | ← | The type of the item (OT type constant) |

#### Discussion

`OTr_ItemType` returns the type of the item referenced by `$tag_t`.

If `$handle_i` is not a valid object handle or if no item in object has the given tag, an error is generated, `OK` is set to zero, and zero is returned.

If an item with the given tag exists, its type is returned.

#### OTr Implementation Notes

Type resolution must follow the algorithm described in §3.6 of the parent specification:

1. Obtain the native 4D type of the property via `OB Get type`. Integer, Real, Boolean, Object, and Collection types are unambiguous and map directly to their OT constants.
2. For Text properties, check for known prefixes: `blob:` → OT BLOB (30), `pic:` → OT Picture (3), `ptr:` → OT Pointer (23), `rec:` → OT Record (115), `var:` → OT Variable (24).
3. For unprefixed Text, attempt date pattern matching (`YYYY-MM-DD`) → OT Date (4), then time pattern matching (`HH:MM:SS`) → OT Time (11).
4. Fall back to OT Character (112) if no pattern matches.

The return value must be an OT type constant (not a native 4D type constant) for backward compatibility. Use `OTr_uMapType` or inline logic to perform this mapping.

#### See Also

[OTr_GetAllNamedProperties](#otr_getallnamedproperties), [OTr_GetAllProperties](#otr_getallproperties), [OTr_GetNamedProperties](#otr_getnamedproperties), [OTr_GetItemProperties](#otr_getitemproperties)

---

### OTr_IsEmbedded

**Legacy:** `OT IsEmbedded` — version 1

```
OTr_IsEmbedded ($handle_i : Integer; $tag_t : Text) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to query |
| Function result | Integer | ← | 1 if the given item is an embedded object, 0 if not |

#### Discussion

`OTr_IsEmbedded` tests the item referenced by `$tag_t` to see if it is an embedded object.

If `$handle_i` is not a valid object handle or if no item in object has the given tag, an error is generated, `OK` is set to zero, and zero is returned.

If an item with the given tag exists and has the type OT Object, 1 is returned.

If an item with the given tag exists and has any other type, zero is returned.

#### OTr Implementation Notes

Navigate to the property via `OTr_zResolvePath` (read-only), then check `OB Get type` = `Is object`. Return 1 if true, 0 otherwise.

#### See Also

[OTr_ItemType](#otr_itemtype), [OTr_GetItemProperties](#otr_getitemproperties), [OTr_GetNamedProperties](#otr_getnamedproperties)

---

### OTr_GetAllNamedProperties

**Legacy:** `OT GetAllNamedProperties` — version 3

```
OTr_GetAllNamedProperties ($handle_i : Integer; $tag_t : Text; $outNames : Pointer {; $outTypes : Pointer {; $outItemSizes : Pointer {; $outDataSizes : Pointer}}})
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of an embedded object |
| $outNames | Pointer | ← | Receives item names (String/Text array) |
| {$outTypes} | Pointer | ← | Receives item types (Longint array) |
| {$outItemSizes} | Pointer | ← | Receives item sizes in bytes (Longint array) |
| {$outDataSizes} | Pointer | ← | Receives item data sizes in bytes (Longint array) |

#### Discussion

`OTr_GetAllNamedProperties` returns information about all items in the object (or embedded object) referenced by `$handle_i` and `$tag_t`. If `$tag_t` is empty, information on `$handle_i` is returned. The information is returned in the given arrays. The arrays will contain one element for each item in object.

If the object is not a valid object handle, `$tag_t` is non-empty and does not reference an embedded object, or if the arrays are not of the type specified, an error is generated, the arrays are cleared, and `OK` is set to zero.

The sizes in `$outItemSizes` represent the total size of the item within the object, including the item's data, tag, and other internal information. The sizes in `$outDataSizes` represent the size of the item's data.

> **Note:** Item names are returned in an indeterminate order, so you may want to sort the arrays after making this call.

#### OTr Implementation Notes

Use `OB Keys` on the target object (or the embedded object navigated to via `$tag_t`) to populate `$outNames`. For each property, determine its OT type constant using the `OTr_ItemType` resolution algorithm and populate `$outTypes`. For `$outItemSizes` and `$outDataSizes`, compute an approximation: for Text values, use `Length`; for Objects, serialise to JSON and measure; for Collections, serialise and measure; for native BLOBs, use `BLOB size`; for native Pictures, use `Picture size`. Properties beginning with `__otr_` must be excluded.

#### See Also

[OTr_GetAllProperties](#otr_getallproperties), [OTr_GetItemProperties](#otr_getitemproperties), [OTr_GetNamedProperties](#otr_getnamedproperties)

---

### OTr_GetAllProperties

**Legacy:** `OT GetAllProperties` — version 1, modified version 2.0

```
OTr_GetAllProperties ($handle_i : Integer; $outNames : Pointer {; $outTypes : Pointer {; $outItemSizes : Pointer {; $outDataSizes : Pointer}}})
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $outNames | Pointer | ← | Receives item names (String/Text array) |
| {$outTypes} | Pointer | ← | Receives item types (Longint array) |
| {$outItemSizes} | Pointer | ← | Receives item sizes in bytes (Longint array) |
| {$outDataSizes} | Pointer | ← | Receives item data sizes in bytes (Longint array) |

#### Discussion

`OTr_GetAllProperties` returns information about all items in `$handle_i` into the given arrays. The arrays will contain one element for each item in object.

If the object is not a valid object handle or if the arrays are not of the type specified, an error is generated, the arrays are cleared, and `OK` is set to zero.

The sizes in `$outItemSizes` represent the total size of the item within the object, including the item's data, tag, and other internal information. The sizes in `$outDataSizes` represent the size of the item's data.

> **Note:** Item names are returned in an indeterminate order, so you may want to sort the arrays after making this call.

#### OTr Implementation Notes

This is functionally identical to `OTr_GetAllNamedProperties` with an empty `$tag_t` — it always operates on the top-level object. Implementation may delegate to `OTr_GetAllNamedProperties($handle_i; ""; ...)` internally.

#### See Also

[OTr_GetAllNamedProperties](#otr_getallnamedproperties), [OTr_GetItemProperties](#otr_getitemproperties), [OTr_GetNamedProperties](#otr_getnamedproperties)

---

### OTr_GetItemProperties

**Legacy:** `OT GetItemProperties` — version 1, modified version 2.0

```
OTr_GetItemProperties ($handle_i : Integer; $index_i : Integer; $outName : Pointer {; $outType : Pointer {; $outItemSize : Pointer {; $outDataSize : Pointer}}})
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $index_i | Integer | → | An index from 1 to the number of items in the object |
| $outName | Pointer | ← | Receives the item's name (Text) |
| {$outType} | Pointer | ← | Receives the item's type (Longint) |
| {$outItemSize} | Pointer | ← | Receives the item's size (Longint) |
| {$outDataSize} | Pointer | ← | Receives the item's data size (Longint) |

#### Discussion

`OTr_GetItemProperties` returns the properties of a given item. Items are numbered according to the number of items in an object, starting with 1. In conjunction with `OTr_ItemCount`, this allows you to iterate over all of the items in the object.

If `$handle_i` is not a valid object handle or if the index is out of range, an error is generated, `OK` is set to zero, and the return variables are left untouched.

> **Note:** This command has been kept for backwards compatibility. It is recommended that you not use this command, as the object items are stored in indeterminate order, thus making the item index useless. You should use `OTr_GetNamedProperties` instead.

#### OTr Implementation Notes

Use `OB Keys` to obtain the property names array. Access the element at `$index_i` (1-based, mapping directly to the 4D array index). For each property, determine the OT type, item size, and data size as per the approach described in `OTr_GetAllNamedProperties`. Properties beginning with `__otr_` must be excluded from the enumeration.

#### See Also

[OTr_GetAllNamedProperties](#otr_getallnamedproperties), [OTr_GetAllProperties](#otr_getallproperties), [OTr_GetNamedProperties](#otr_getnamedproperties)

---

### OTr_GetNamedProperties

**Legacy:** `OT GetNamedProperties` — version 1, modified version 2.0

```
OTr_GetNamedProperties ($handle_i : Integer; $tag_t : Text; $outType : Pointer {; $outItemSize : Pointer {; $outDataSize : Pointer {; $outIndex : Pointer}}})
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | An item tag |
| $outType | Pointer | ← | Receives the item's type (Longint) |
| {$outItemSize} | Pointer | ← | Receives the item's size including the tag (Longint) |
| {$outDataSize} | Pointer | ← | Receives the item's size excluding the tag (Longint) |
| {$outIndex} | Pointer | ← | Receives the item's index (Longint) |

#### Discussion

`OTr_GetNamedProperties` returns the properties of the item identified by the tag `$tag_t`.

If `$handle_i` is not a valid object handle or if no item in object has the given tag, an error is generated, `OK` is set to zero, and the return variables are left untouched.

> **Note:** `$outIndex` will always be zero, as it is meaningless. It has been kept for backwards compatibility.

#### OTr Implementation Notes

Navigate to the property via `OTr_zResolvePath` (read-only). Determine the OT type using the standard type resolution algorithm. For sizes, compute as per the `OTr_GetAllNamedProperties` approach. `$outIndex` should always be set to zero as per the legacy behaviour.

#### See Also

[OTr_GetAllNamedProperties](#otr_getallnamedproperties), [OTr_GetAllProperties](#otr_getallproperties), [OTr_GetItemProperties](#otr_getitemproperties)

---

## Item Utility Routines

The following routines allow you to fold, spindle and otherwise manipulate individual items within an object.

---

### OTr_CompareItems

**Legacy:** `OT CompareItems` — version 1

```
OTr_CompareItems ($srcHandle_i : Integer; $srcTag_t : Text; $cmpHandle_i : Integer; $cmpTag_t : Text) → Integer
```

| Parameter | Type | | Description |
|---|---|---|---|
| $srcHandle_i | Integer | → | A handle to an object |
| $srcTag_t | Text | → | An item tag |
| $cmpHandle_i | Integer | → | A handle to an object |
| $cmpTag_t | Text | → | An item tag |
| Function result | Integer | ← | 0 if not identical, 1 if identical, -1 if an error occurred |

#### Discussion

`OTr_CompareItems` compares two items for equality. `$srcHandle_i` and `$cmpHandle_i` may be the same object.

If `$srcHandle_i` or `$cmpHandle_i` is not a valid object handle, if either of the two items do not exist, or if the two items do not have the same type, an error is generated, `OK` is set to zero, and -1 is returned.

Otherwise, the items are compared according to the rules of equality used for equivalent variable types in 4D, with the addition that you may compare array, BLOB, Picture, and embedded object items.

- Arrays are considered identical if they are the same size and the corresponding elements would be considered equal in 4D. This means that when comparing elements of character arrays, case and diacriticals are not significant and wildcards are used.
- BLOB and Picture items are considered identical if they contain the same data byte for byte.
- Embedded objects are considered identical if each of their items are considered identical according to the rules for non-object types.

#### OTr Implementation Notes

Retrieve both values and compare. For scalar types (Integer, Real, Text, Boolean, Date, Time), use standard 4D comparison operators. For Objects, use `JSON Stringify` on both and compare the resulting text (this handles recursive comparison). For Collections (arrays), compare element-by-element after checking length equality. For native BLOBs, use `OTr_uEqualBLOBs`; for native Pictures, use `OTr_uEqualPictures`. Text comparison for character arrays should use the `=` operator which is case-insensitive and diacritical-insensitive in 4D by default.

#### See Also

[OTr_CopyItem](#otr_copyitem), [OTr_ItemType](#otr_itemtype)

---

### OTr_CopyItem

**Legacy:** `OT CopyItem` — version 1

```
OTr_CopyItem ($srcHandle_i : Integer; $srcTag_t : Text; $destHandle_i : Integer; $destTag_t : Text)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $srcHandle_i | Integer | → | A handle to an object |
| $srcTag_t | Text | → | An item tag |
| $destHandle_i | Integer | → | A handle to an object |
| $destTag_t | Text | → | An item tag |

#### Discussion

`OTr_CopyItem` copies the item referenced by `$srcTag_t` to the item referenced by `$destTag_t`. The item referenced by `$destTag_t` need not exist; it will be created if necessary. The source and destination objects may be the same, allowing either duplication of an item at the same level of embedding within an object, or copying an item from one level of embedding to another.

If either object handle is not valid, or if the source item does not exist, or if the source item and destination item do not have the same type, an error is generated, `OK` is set to zero, and no copy is performed.

> **Note:** Copying an embedded object recursively copies all of its items.

#### OTr Implementation Notes

Read the source property value and write it to the destination property. For embedded objects (Object type), perform a deep copy using `OB Copy` to ensure independence. For native BLOBs and Pictures, `OB Copy` on the parent object (or direct `OB Get`/`OB SET`) produces an independent copy of the binary data automatically. For all other types, a simple property copy suffices. Use `OTr_zResolvePath` on both source and destination paths.

#### See Also

[OTr_CompareItems](#otr_compareitems), [OTr_RenameItem](#otr_renameitem), [OTr_DeleteItem](#otr_deleteitem)

---

### OTr_RenameItem

**Legacy:** `OT RenameItem` — version 2

```
OTr_RenameItem ($handle_i : Integer; $tag_t : Text; $newTag_t : Text)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | A full item tag |
| $newTag_t | Text | → | The new item name (leaf name only) |

#### Discussion

`OTr_RenameItem` renames the item referenced by `$tag_t` to the item referenced by `$newTag_t`. Note that `$tag_t` must be a full tag if the target item is in an embedded object, whereas `$newTag_t` is the new item name only. For example:

```4d
OTr_RenameItem($obj_i; "foo.bar.old_name"; "new_name")
```

The above example will rename the item *old_name* to *new_name* within the embedded object *foo.bar*. To access the renamed item you would use the tag `"foo.bar.new_name"`.

If the object handle is invalid, or if the item does not exist, or if an existing item has the same name as `$newTag_t`, an error is generated, `OK` is set to zero, and no rename is performed.

#### OTr Implementation Notes

Use `OTr_zResolvePath` to navigate to the parent object containing the leaf property. Read the property value under the old leaf name, write it under `$newTag_t` on the same parent object, then remove the old property via `OB REMOVE`. If the value is a BLOB or Picture reference, no new parallel array slot is needed — the reference string is simply copied to the new property name.

#### See Also

[OTr_CopyItem](#otr_copyitem), [OTr_DeleteItem](#otr_deleteitem)

---

### OTr_DeleteItem

**Legacy:** `OT DeleteItem` — version 1

```
OTr_DeleteItem ($handle_i : Integer; $tag_t : Text)
```

| Parameter | Type | | Description |
|---|---|---|---|
| $handle_i | Integer | → | A handle to an object |
| $tag_t | Text | → | Tag of the item to delete |

#### Discussion

`OTr_DeleteItem` deletes an item from an object. `$tag_t` may refer to embedded items and objects.

If `$handle_i` is not a valid object handle or `$tag_t` refers to an item that does not exist, an error is generated, `OK` is set to zero, and no delete is performed.

> **Note:** Deleting an embedded object recursively deletes all of its items.

#### OTr Implementation Notes

Use `OTr_zResolvePath` to navigate to the parent object, then remove the leaf property via `OB REMOVE`. Native Object properties — including BLOBs and Pictures — are released automatically when removed. If the property is an embedded object, its properties (including any nested binary values) are released transitively when the parent is removed.

#### See Also

[OTr_CopyItem](#otr_copyitem), [OTr_RenameItem](#otr_renameitem)

---

## Cross-Reference Index

| OTr Method | Legacy Command | Category |
|---|---|---|
| `OTr_IsObject` | `OT IsObject` (v1) | Object Info |
| `OTr_ItemCount` | `OT ItemCount` (v1) | Object Info |
| `OTr_ObjectSize` | `OT ObjectSize` (v1) | Object Info |
| `OTr_ItemExists` | `OT ItemExists` (v1) | Item Info |
| `OTr_ItemType` | `OT ItemType` (v1) | Item Info |
| `OTr_IsEmbedded` | `OT IsEmbedded` (v1) | Item Info |
| `OTr_GetAllNamedProperties` | `OT GetAllNamedProperties` (v3) | Item Info |
| `OTr_GetAllProperties` | `OT GetAllProperties` (v1, mod v2.0) | Item Info |
| `OTr_GetItemProperties` | `OT GetItemProperties` (v1, mod v2.0) | Item Info |
| `OTr_GetNamedProperties` | `OT GetNamedProperties` (v1, mod v2.0) | Item Info |
| `OTr_CompareItems` | `OT CompareItems` (v1) | Item Utility |
| `OTr_CopyItem` | `OT CopyItem` (v1) | Item Utility |
| `OTr_RenameItem` | `OT RenameItem` (v2) | Item Utility |
| `OTr_DeleteItem` | `OT DeleteItem` (v1) | Item Utility |
