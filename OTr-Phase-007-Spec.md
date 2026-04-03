# OTr Phase 7 — API Naming Alignment: Detailed Specification

**Version:** 0.3
**Date:** 2026-04-03
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md)

---

## Overview

Phase 7 is a **documentation and naming alignment phase**. Its purpose is to ensure that every public OTr method uses parameter names that:

1. Match the semantic names from the legacy ObjectTools API (`inObject`, `inTag`, `inValue`, etc.) as their base.
2. Append the OTr type-suffix system (`_i`, `_t`, `_r`, `_b`, `_at`, `_ai`, `_ptr`, `_pic`, `_x`, etc.) to that base.

Because the `.md` documentation files in `Documentation/Methods/` are auto-generated from the `#DECLARE` line of each `.4dm` method, the names must be correct in the **`.4dm` source files** — specifically in both the `#DECLARE` line and the `Parameters:` comment block. The `.md` files will then be correct when regenerated.

`OTr_PutString` already conforms to this standard and is the reference implementation.

---

## 1. The Naming Rule

> **OT semantic name** (camelCase, no `$`) **+ OTr type suffix** (preceded by `_`) = **declared parameter name** (prefixed with `$`).

The authoritative type suffix table is in **[OTr-Types-Reference.md](OTr-Types-Reference.md)**. The summary below is derived from that document; if there is ever a discrepancy, `OTr-Types-Reference.md` takes precedence.

Examples:

| OT name | Type | Declared name |
|---|---|---|
| `inObject` | Integer | `$inObject_i` |
| `inTag` | Text | `$inTag_t` |
| `inValue` | Text | `$inValue_t` |
| `inValue` | Integer | `$inValue_i` |
| `inValue` | Real | `$inValue_r` |
| `inValue` | Boolean | `$inValue_b` |
| `inValue` | Date | `$inValue_d` |
| `inValue` | Time | `$inValue_h` |
| `inValue` | Picture | `$inValue_pic` |
| `inIndex` | Integer | `$inIndex_i` |
| `inSize` | Integer | `$inSize_i` |
| `inWhere` | Integer | `$inWhere_i` |
| `inHowMany` | Integer | `$inHowMany_i` |
| `inStart` | Integer | `$inStart_i` |
| `inAppend` | Integer | `$inAppend_i` |
| `inTable` | Integer | `$inTable_i` |
| `inDirection` | Text | `$inDirection_t` |
| `inDirection1`…`inDirection7` | Text | `$inDirection1_t`…`$inDirection7_t` |
| `inTag1`…`inTag7` | Text | `$inTag1_t`…`$inTag7_t` |
| `inNewTag` | Text | `$inNewTag_t` |
| `inOptions` | Integer | `$inOptions_i` |
| `inNewHandler` | Text | `$inNewHandler_t` |
| `inSerialNum` | Text | `$inSerialNum_t` |
| `inArray` | Pointer (to any array) | `$inArray_ptr` |
| `outArray` | Pointer (to any array) | `$outArray_ptr` |
| `outPointer` | Pointer | `$outPointer_ptr` |
| `outVarPointer` | Pointer | `$outVarPointer_ptr` |
| `inVarPointer` | Pointer | `$inVarPointer_ptr` |
| `ioBLOB` | BLOB | `$ioBLOB_blob` |
| `inBLOB` | BLOB | `$inBLOB_blob` |
| `outBLOB` | BLOB | `$outBLOB_blob` |
| `ioOffset` | Integer | `$ioOffset_i` |
| `outNames` | Pointer (to Text array) | `$outNames_ptr` |
| `outTypes` | Pointer (to Integer array) | `$outTypes_ptr` |
| `outItemSizes` | Pointer (to Integer array) | `$outItemSizes_ptr` |
| `outDataSizes` | Pointer (to Integer array) | `$outDataSizes_ptr` |
| `outName` | Text | `$outName_t` |
| `outType` | Integer | `$outType_i` |
| `outItemSize` | Integer | `$outItemSize_i` |
| `outDataSize` | Integer | `$outDataSize_i` |
| `outIndex` | Integer | `$outIndex_i` |
| `inSourceObject` | Integer | `$inSourceObject_i` |
| `inSourceTag` | Text | `$inSourceTag_t` |
| `inDestObject` | Integer | `$inDestObject_i` |
| `inDestTag` | Text | `$inDestTag_t` |
| `inCompareObject` | Integer | `$inCompareObject_i` |
| `inCompareTag` | Text | `$inCompareTag_t` |
| *(return handle)* | Integer | `$result_i` or meaningful name e.g. `$copyHandle_i` |

### Type Suffix Reference

See **[OTr-Types-Reference.md](OTr-Types-Reference.md)** for the authoritative table. Key suffixes:

| Suffix | 4D Type |
|---|---|
| `_i` | Integer / Longint |
| `_r` | Real |
| `_t` | Text |
| `_b` | Boolean |
| `_d` | Date |
| `_h` | Time |
| `_blob` | BLOB |
| `_ptr` | Pointer |
| `_o` | Object |
| `_pic` | Picture |
| `_c` | Collection |
| `_v` | Variant |
| `_ai` | Integer / Longint array |
| `_ar` | Real array |
| `_at` | Text array |
| `_ab` | Boolean array |
| `_ad` | Date array |
| `_ah` | Time array |
| `_ablob` | BLOB array |
| `_aptr` | Pointer array |
| `_apic` | Picture array |
| `_ao` | Object array |

---

## 2. What Changes in Each `.4dm` File

Three locations must be updated in any method that does not yet conform:

1. **The `Project Method:` comment line** — use OT-style names without `$` or type suffix (these are the display names for callers, matching the OT manual).
2. **The `Parameters:` comment block** — use the full declared name (with `$` and type suffix).
3. **The `#DECLARE` line** — use the full declared name (with `$` and type suffix). This drives the auto-generated `.md` documentation.

The description column in the `Parameters:` block should echo the OT semantic name to make the mapping explicit, e.g.:

```
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_t  : Text    : Value to store (inValue)
```

---

## 3. Standard Header Block Format

```
//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_MethodName (inObject; inTag; inValue)  {→ Longint}

// Brief one-line description using OT-style parameter names.

// **ORIGINAL DOCUMENTATION**
//
// {Verbatim text from ObjectTools 5 Reference, lightly formatted.}
// {Omit entirely for OTr-specific methods with no OT counterpart.}

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_t  : Text    : Value to store (inValue)

// Returns:                          {omit if no return value}
//   $result_i : Integer : Description

// Created by Wayne Stewart, {date}
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_t : Text)
```

### Rules

- The `Project Method:` line uses **OT-style names** (no `$`, no suffix) — these match the OT manual exactly and are what callers see in the docs.
- The `Parameters:` block and `#DECLARE` line use **declared names** (with `$` and type suffix).
- The `**ORIGINAL DOCUMENTATION**` section is included for every method with an OT counterpart; omitted for OTr-specific methods (`OTr_SaveToText`, `OTr_LoadFromText`, etc.).
- The `%attributes` line is always the first line of the file.

---

## 4. Complete OT Signature Reference

Extracted directly from *ObjectTools 5 Reference* (RTF). These are the authoritative OT-style names to use in `Project Method:` lines and as the base for declared parameter names.

### 4.1 Creation / Destruction

| OT Legacy Signature | OTr Method |
|---|---|
| `OT New()` | `OTr_New` |
| `OT Clear(ioObject)` | `OTr_Clear` |
| `OT ClearAll()` | `OTr_ClearAll` |
| `OT Copy(inObject)` | `OTr_Copy` |

### 4.2 Scalar Put

| OT Legacy Signature | OTr Method |
|---|---|
| `OT PutLong(inObject; inTag; inValue)` | `OTr_PutLong` |
| `OT PutReal(inObject; inTag; inValue)` | `OTr_PutReal` |
| `OT PutString(inObject; inTag; inValue)` | `OTr_PutString` |
| `OT PutText(inObject; inTag; inValue)` | `OTr_PutText` |
| `OT PutDate(inObject; inTag; inValue)` | `OTr_PutDate` |
| `OT PutTime(inObject; inTag; inValue)` | `OTr_PutTime` |
| `OT PutBoolean(inObject; inTag; inValue)` | `OTr_PutBoolean` |
| `OT PutBLOB(inObject; inTag; inValue)` | `OTr_PutBLOB` |
| `OT PutPicture(inObject; inTag; inValue)` | `OTr_PutPicture` |
| `OT PutPointer(inObject; inTag; inValue)` | `OTr_PutPointer` |
| `OT PutObject(inObject; inTag; inObject)` | `OTr_PutObject` |
| `OT PutRecord(inObject; inTag; inTable)` | `OTr_PutRecord` |
| `OT PutVariable(inObject; inTag; inVarPointer)` | `OTr_PutVariable` |

### 4.3 Scalar Get

| OT Legacy Signature | OTr Method |
|---|---|
| `OT GetLong(inObject; inTag)` | `OTr_GetLong` |
| `OT GetReal(inObject; inTag)` | `OTr_GetReal` |
| `OT GetString(inObject; inTag)` | `OTr_GetString` |
| `OT GetText(inObject; inTag)` | `OTr_GetText` |
| `OT GetDate(inObject; inTag)` | `OTr_GetDate` |
| `OT GetTime(inObject; inTag)` | `OTr_GetTime` |
| `OT GetBoolean(inObject; inTag)` | `OTr_GetBoolean` |
| `OT GetBLOB(inObject; inTag; outBLOB)` | `OTr_GetBLOB` |
| `OT GetNewBLOB(inObject; inTag)` | `OTr_GetNewBLOB` |
| `OT GetPicture(inObject; inTag)` | `OTr_GetPicture` |
| `OT GetPointer(inObject; inTag; outPointer)` | `OTr_GetPointer` |
| `OT GetObject(inObject; inTag)` | `OTr_GetObject` |
| `OT GetRecord(inObject; inTag)` | `OTr_GetRecord` |
| `OT GetRecordTable(inObject; inTag)` | `OTr_GetRecordTable` |
| `OT GetVariable(inObject; inTag; outVarPointer)` | `OTr_GetVariable` |

### 4.4 Array Put

| OT Legacy Signature | OTr Method |
|---|---|
| `OT PutArray(inObject; inTag; inArray)` | `OTr_PutArray` |
| `OT PutArrayLong(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayLong` |
| `OT PutArrayReal(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayReal` |
| `OT PutArrayString(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayString` |
| `OT PutArrayText(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayText` |
| `OT PutArrayDate(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayDate` |
| `OT PutArrayTime(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayTime` |
| `OT PutArrayBoolean(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayBoolean` |
| `OT PutArrayBLOB(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayBLOB` |
| `OT PutArrayPicture(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayPicture` |
| `OT PutArrayPointer(inObject; inTag; inIndex; inValue)` | `OTr_PutArrayPointer` |

### 4.5 Array Get

| OT Legacy Signature | OTr Method |
|---|---|
| `OT GetArray(inObject; inTag; outArray)` | `OTr_GetArray` |
| `OT GetArrayLong(inObject; inTag; inIndex)` | `OTr_GetArrayLong` |
| `OT GetArrayReal(inObject; inTag; inIndex)` | `OTr_GetArrayReal` |
| `OT GetArrayString(inObject; inTag; inIndex)` | `OTr_GetArrayString` |
| `OT GetArrayText(inObject; inTag; inIndex)` | `OTr_GetArrayText` |
| `OT GetArrayDate(inObject; inTag; inIndex)` | `OTr_GetArrayDate` |
| `OT GetArrayTime(inObject; inTag; inIndex)` | `OTr_GetArrayTime` |
| `OT GetArrayBoolean(inObject; inTag; inIndex)` | `OTr_GetArrayBoolean` |
| `OT GetArrayBLOB(inObject; inTag; inIndex)` | `OTr_GetArrayBLOB` |
| `OT GetArrayPicture(inObject; inTag; inIndex)` | `OTr_GetArrayPicture` |
| `OT GetArrayPointer(inObject; inTag; inIndex; outPointer)` | `OTr_GetArrayPointer` |

### 4.6 Array Utilities

| OT Legacy Signature | OTr Method |
|---|---|
| `OT SizeOfArray(inObject; inTag)` | `OTr_SizeOfArray` |
| `OT ResizeArray(inObject; inTag; inSize)` | `OTr_ResizeArray` |
| `OT InsertElement(inObject; inTag; inWhere {; inHowMany})` | `OTr_InsertElement` |
| `OT DeleteElement(inObject; inTag; inWhere {; inHowMany})` | `OTr_DeleteElement` |
| `OT FindInArray(inObject; inTag; inValue {; inStart})` | `OTr_FindInArray` |
| `OT SortArrays(inObject; inTag1; inDirection1 {; …inTag7; inDirection7})` | `OTr_SortArrays` |

### 4.7 Object Info

| OT Legacy Signature | OTr Method |
|---|---|
| `OT IsObject(inObject)` | `OTr_IsObject` |
| `OT ItemCount(inObject {; inTag})` | `OTr_ItemCount` |
| `OT ObjectSize(inObject)` | `OTr_ObjectSize` |

### 4.8 Item Info

| OT Legacy Signature | OTr Method |
|---|---|
| `OT ItemExists(inObject; inTag)` | `OTr_ItemExists` |
| `OT ItemType(inObject; inTag)` | `OTr_ItemType` |
| `OT IsEmbedded(inObject; inTag)` | `OTr_IsEmbedded` |
| `OT GetItemProperties(inObject; inIndex; outName {; outType {; outItemSize {; outDataSize}}})` | `OTr_GetItemProperties` |
| `OT GetNamedProperties(inObject; inTag; outType {; outItemSize {; outDataSize {; outIndex}}})` | `OTr_GetNamedProperties` |
| `OT GetAllProperties(inObject; outNames {; outTypes {; outItemSizes {; outDataSizes}}})` | `OTr_GetAllProperties` |
| `OT GetAllNamedProperties(inObject; inTag; outNames {; outTypes {; outItemSizes {; outDataSizes}}})` | `OTr_GetAllNamedProperties` |

### 4.9 Item Utilities

| OT Legacy Signature | OTr Method |
|---|---|
| `OT CopyItem(inSourceObject; inSourceTag; inDestObject; inDestTag)` | `OTr_CopyItem` |
| `OT CompareItems(inSourceObject; inSourceTag; inCompareObject; inCompareTag)` | `OTr_CompareItems` |
| `OT RenameItem(inObject; inTag; inNewTag)` | `OTr_RenameItem` |
| `OT DeleteItem(inObject; inTag)` | `OTr_DeleteItem` |

### 4.10 Import / Export

| OT Legacy Signature | OTr Method |
|---|---|
| `OT ObjectToBLOB(inObject; ioBLOB {; inAppend})` | `OTr_ObjectToBLOB` |
| `OT ObjectToNewBLOB(inObject)` | `OTr_ObjectToNewBLOB` |
| `OT BLOBToObject(inBLOB {; ioOffset})` | `OTr_BLOBToObject` |

### 4.11 Object Utilities

| OT Legacy Signature | OTr Method |
|---|---|
| `OT GetVersion()` | `OTr_GetVersion` |
| `OT Register(inSerialNum)` | `OTr_Register` |
| `OT SetErrorHandler(inNewHandler)` | `OTr_SetErrorHandler` |
| `OT GetOptions()` | `OTr_GetOptions` |
| `OT SetOptions(inOptions)` | `OTr_SetOptions` |
| `OT CompiledApplication()` | `OTr_CompiledApplication` |
| `OT GetHandleList(outHandles)` | `OTr_GetHandleList` |

### 4.12 OTr-Specific (No OT Counterpart)

These methods have no legacy equivalent. Their headers omit the `**ORIGINAL DOCUMENTATION**` section.

| OTr Method |
|---|
| `OTr_SaveToText` |
| `OTr_SaveToFile` |
| `OTr_SaveToClipboard` |
| `OTr_LoadFromText` |
| `OTr_LoadFromFile` |
| `OTr_LoadFromClipboard` |
| `OTr_ArrayType` |

---

## 5. Worked Examples

### 5.1 OTr_PutString — Already Conformant (Reference)

```4d
//%attributes = {"invisible":true,"shared":true}
// ----------------------------------------------------
// Project Method: OTr_PutString (inObject; inTag; inValue)

// Stores a String/Text inValue at the specified inTag path.

// **ORIGINAL DOCUMENTATION**
//
// *OT PutString* puts *inValue* into *inObject*.
// ...

// Access: Shared

// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path (inTag)
//   $inValue_t  : Text    : Value to store (inValue)

// Returns: Nothing
// ----------------------------------------------------

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inValue_t : Text)
```

### 5.2 OTr_GetArrayLong — Before and After

**Before:**
```4d
// Project Method: OTr_GetArrayLong ($handle_i : Integer; \
//   $tag_t : Text; $index_i : Integer) -> $value_i : Integer
// Parameters:
//   $handle_i : Integer : OTr handle
//   $tag_t    : Text    : Tag path to the array item
//   $index_i  : Integer : Element index (0 = default element)
// Returns:
//   $value_i : Integer : Element value, or 0 on any failure

#DECLARE($handle_i : Integer; $tag_t : Text; $index_i : Integer)->$value_i : Integer
```

**After:**
```4d
// Project Method: OTr_GetArrayLong (inObject; inTag; inIndex) → Longint
// Parameters:
//   $inObject_i : Integer : OTr inObject
//   $inTag_t    : Text    : Tag path to the array item (inTag)
//   $inIndex_i  : Integer : Element index, 1-based (inIndex)
// Returns:
//   $result_i : Integer : Element value, or 0 on any failure

#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_i : Integer
```

### 5.3 OTr_GetAllProperties — Before and After

**Before:**
```4d
// Project Method: OTr_GetAllProperties ($handle_i : Integer; \
//   $outNames_ptr : Pointer ...)
// Parameters:
//   $handle_i         : Integer : A handle to an object
//   $outNames_ptr     : Pointer : Receives item names (Text array)

#DECLARE($handle_i : Integer; $outNames_ptr : Pointer ...)
```

**After:**
```4d
// Project Method: OTr_GetAllProperties (inObject; outNames {; outTypes \
//   {; outItemSizes {; outDataSizes}}})
// Parameters:
//   $inObject_i        : Integer : OTr inObject
//   $outNames_ptr      : Pointer : Receives item names — Text array (outNames)
//   $outTypes_ptr      : Pointer : Receives OT type constants — Longint array (outTypes) (optional)
//   $outItemSizes_ptr  : Pointer : Receives item sizes — Longint array (outItemSizes) (optional)
//   $outDataSizes_ptr  : Pointer : Receives data sizes — Longint array (outDataSizes) (optional)

#DECLARE($inObject_i : Integer; $outNames_ptr : Pointer ...)
```

---

## 6. Implementation Notes

- The `.md` files in `Documentation/Methods/` are **auto-generated** from the `#DECLARE` line and comment block of each `.4dm` file. They do not need to be edited directly; correcting the `.4dm` source is sufficient.
- Original documentation text should be taken from `LegacyDocumentation/ObjectTools 5 Reference.rtf` in preference to the PDF.
- Where the original text contains page cross-references (e.g., *"See page 13"*), these are retained verbatim.
- The internal variable names used *within the method body* (loop counters, intermediate objects, etc.) are not subject to this convention — only the declared parameters are affected.
