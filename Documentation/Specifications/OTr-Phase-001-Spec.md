# OTr Phase 1: Core Infrastructure and Handle Management

**Version:** 1.0
**Date:** 2026-04-07
**Status:** Complete
**Scope:** Foundational methods for object creation, destruction, and lifecycle management

---

## Overview

Phase 1 establishes the foundational infrastructure for OTr. It defines the initialisation protocol, handle allocation and reuse, lifecycle management, and diagnostic utilities that underpin all subsequent phases.

The phase focuses on:
- Interprocess arrays for handle-based object storage
- Lazy initialisation and startup sequence
- Handle allocation, validity checking, and slot reuse
- Bulk operations (ClearAll)
- Error handler infrastructure
- Global options and state management

---

## Commands Implemented

### Core Creation / Destruction

| Command | Method | Returns | Purpose |
|---------|--------|---------|---------|
| `OT New` | `OTr_New` | Integer | Allocate new object handle; reuse cleared slots |
| `OT Clear` | `OTr_Clear` | — | Deallocate handle; mark slot as available for reuse |
| `OT ClearAll` | `OTr_ClearAll` | — | Reset all storage; deallocate all handles |
| `OT Copy` | `OTr_Copy` | Integer | Deep-copy object; allocate new handle |

### Handle Validation & Diagnostics

| Command | Method | Returns | Purpose |
|---------|--------|---------|---------|
| `OT IsObject` | `OTr_IsObject` | Integer | Validate handle (bounds + in-use flag); return 0 or 1 |
| `OT GetHandleList` | `OTr_GetHandleList` | — | Return array of all active handles for inspection |

### Options & Configuration

| Command | Method | Returns | Purpose |
|---------|--------|---------|---------|
| `OT GetOptions` | `OTr_GetOptions` | Integer | Retrieve current global option flags |
| `OT SetOptions` | `OTr_SetOptions` | — | Set global option flags |

### Application Metadata

| Command | Method | Returns | Purpose |
|---------|--------|---------|---------|
| `OT Register` | `OTr_Register` | Integer | Register caller (legacy compatibility; returns 1) |
| `OT GetVersion` | `OTr_GetVersion` | Text | Return version string (e.g., "0.5") |
| `OT CompiledApplication` | `OTr_CompiledApplication` | Integer | Return 0 or 1 indicating compiled status |

### Error Handler Chaining

| Command | Method | Returns | Purpose |
|---------|--------|---------|---------|
| `OT SetErrorHandler` | `OTr_SetErrorHandler` | Text | Set error handler; return previous handler name (chaining) |

---

## Storage Model

### Interprocess Arrays

Two parallel interprocess arrays form the core storage model:

```4d
ARRAY OBJECT(<>OTR_Objects_ao; 0)      // Object storage; index = handle
ARRAY BOOLEAN(<>OTR_InUse_ab; 0)       // Slot allocation flags
```

- `<>OTR_Objects_ao[i]` holds the native 4D Object at index `i`
- `<>OTR_InUse_ab[i]` is `True` if slot `i` is allocated; `False` if available for reuse
- Handle returned to caller = array index (Integer)

### Initialisation Protocol

`OTr_zInit` (private, lazy-called):

1. Check if module already initialised via flag `<>OTR_Initialized_b`
2. If not:
   - Declare both arrays at size 0
   - Set default options: `AutoCreateObjects = On`; all others = Off
   - Detect 4D runtime version; store BLOB handling capability in `Storage.OTr.nativeBlobInObject`
   - Set `<>OTR_Initialized_b = True`
3. If already initialised: return immediately

This lazy-init pattern ensures the module is ready before first use.

### Handle Allocation & Reuse

`OTr_New`:

1. Call `OTr_zInit` to ensure arrays are ready
2. Search `<>OTR_InUse_ab` for first `False` slot (available for reuse)
3. If found: reuse that slot (allocate new Object; set flag to `True`); return index
4. If not found: append new slots to both arrays; allocate new Object; set flag to `True`; return new index

This strategy minimises array growth whilst recycling cleared slots.

### Handle Invalidation

`OTr_Clear`:

1. Validate handle (check bounds; verify `<>OTR_InUse_ab[handle] = True`)
2. If invalid: invoke error handler (if set) or fail silently
3. If valid:
   - Set `<>OTR_Objects_ao[handle] = Null` (release native Object)
   - Set `<>OTR_InUse_ab[handle] = False` (mark slot for reuse)

### Bulk Deallocation

`OTr_ClearAll`:

1. Set both arrays to size 0
2. This deallocates all active handles in one operation
3. Module remains initialised; next `OTr_New` will reinitialise arrays from empty state

### Handle Validation

`OTr_IsObject`:

```
Input: handle (Integer)
Output: 1 if handle is valid; 0 otherwise

Algorithm:
  if (handle < 1) return 0
  if (handle > size(<>OTR_InUse_ab)) return 0
  if (<>OTR_InUse_ab[handle] = False) return 0
  return 1
```

---

## Deep Copy Semantics

`OTr_Copy`:

1. Validate source handle
2. Allocate new handle via `OTr_New`
3. Perform **deep copy** of source object to destination
   - Copy all top-level properties (scalars, nested objects, collections, BLOBs, pictures)
   - Nested objects are recursively copied
   - Collections are cloned; elements are deep-copied
4. Return new handle

Deep copy ensures the copy is independent—modifying the copy does not affect the original.

---

## Options System

Global options are stored as bit flags in Interprocess Integer variable `<>OTR_Options_i`:

| Bit | Name | Default | Behaviour |
|-----|------|---------|-----------|
| 0 | FailOnItemNotFound | Off | Raise error when tag not found (used in Phase 2+) |
| 1 | ExactTagMatch | — | Deprecated; ignore |
| 2 | AutoCreateObjects | **On** | Auto-create intermediate objects on dotted paths (Phase 2+) |
| 3 | VariantItems | Off | Allow item type changes on reassignment (Phase 2+) |

`OTr_GetOptions` returns the current value of `<>OTR_Options_i`.

`OTr_SetOptions` accepts new value and updates `<>OTR_Options_i`.

---

## Error Handler Chaining

`OTr_SetErrorHandler`:

1. Input: method name (Text) — empty string to clear
2. Retrieve current handler from `<>OTR_ErrorHandler_t`
3. Store new handler name in `<>OTR_ErrorHandler_t`
4. Return the previous handler name (enabling chaining)

When an error condition arises (in later phases), the stored handler method is invoked with error context. If no handler is set, the method fails silently or raises a 4D error as appropriate.

---

## Diagnostic Utilities

### `OTr_GetHandleList`

Returns array of all currently active handles:

```
Input: pointer to Longint array (output parameter)
Output: array populated with all valid handles

Algorithm:
  Clear the output array
  Iterate i = 1 to size(<>OTR_InUse_ab):
    if (<>OTR_InUse_ab[i] = True):
      Append i to output array
```

Useful for debugging and state inspection.

### `OTr_GetVersion` / `OTr_CompiledApplication` / `OTr_Register`

- `OTr_GetVersion`: Returns version string (e.g., "0.5")
- `OTr_CompiledApplication`: Returns 0 (interpreted) or 1 (compiled)
- `OTr_Register`: Legacy compatibility method; accepts caller name and returns 1

---

## Test Coverage

See `____Test_Phase_1.4dm` for comprehensive unit tests covering:

- Handle allocation (`OTr_New`)
- Handle validity (`OTr_IsObject`)
- Handle reuse (clearing and reallocation)
- Bulk operations (`OTr_ClearAll`)
- Handle list retrieval (`OTr_GetHandleList`)
- Options get/set (`OTr_GetOptions`, `OTr_SetOptions`)
- Error handler chaining (`OTr_SetErrorHandler`)
- Metadata methods (`OTr_GetVersion`, `OTr_Register`, `OTr_CompiledApplication`)

All tests verify edge cases: invalid handles (0, negative, out of bounds, already cleared), option flag combinations, and handler chaining sequences.

---

## Dependencies

- 4D v19 LTS or later
- Coding standard: `4D-Method-Writing-Guide.md`
- Related: `Fnd_Dict_Init` pattern (lazy initialisation template)

---

## Addendum: Phase 1.5 — Simple Export (JSON)

Phase 1.5 extends Phase 1 with lightweight JSON export methods. These provide quick serialisation of objects to various outputs—primarily for debugging, logging, and quick inspection—without the complexity of full import/export with type preservation (see Phase 6).

### Phase 1.5 Commands Implemented

| Command | Method | Returns | Purpose |
|---------|--------|---------|---------|
| (new) | `OTr_SaveToText` | Text | Serialise object to JSON text; optional pretty-printing |
| (new) | `OTr_SaveToFile` | — | Serialise object to JSON file |
| (new) | `OTr_SaveToClipboard` | — | Serialise object to JSON on clipboard |

### `OTr_SaveToText`

```4d
#DECLARE ($hObject_i : Integer; $PrettyPrint_b : Boolean) -> $json_t : Text
```

**Input:**
- `$hObject_i`: Handle to object to serialise
- `$PrettyPrint_b` (optional): `True` for formatted output with indentation; `False` (default) for compact JSON

**Output:**
- JSON representation of the object as Text

**Behaviour:**
- Validate handle; if invalid, return empty string or invoke error handler
- Iterate all properties in the object
- For each property: if value is a native 4D type (Longint, Real, Text, Boolean, Date, Time, Picture, native BLOB, native Object, Collection), serialise natively to JSON
- Return JSON string; if `$PrettyPrint_b = True`, format with newlines and indentation

### `OTr_SaveToFile`

```4d
#DECLARE ($hObject_i : Integer; $FilePath_t : Text)
```

Write pretty-printed JSON to file using `Text to document` (UTF-8 encoding).

### `OTr_SaveToClipboard`

```4d
#DECLARE ($hObject_i : Integer)
```

Copy compact JSON string to system clipboard via `Set text to pasteboard`.

### Type Handling

**Supported:** Longint, Real, Text, Boolean, Date, Time, Picture (native), BLOB (native), Object (nested), Collection

**Excluded:** Pointer, Record, Variable (these are stored in Phase 5 but excluded from JSON output to maintain JSON purity). For full round-trip with type preservation, use Phase 6 methods (`OTr_ObjectToBLOB`, `OTr_BLOBToObject`).

### Examples

```4d
$h := OTr_New
OTr_PutLong($h; "id"; 123)
OTr_PutText($h; "name"; "Alice")

$json := OTr_SaveToText($h; False)
// Result: {"id":123,"name":"Alice"}

$json := OTr_SaveToText($h; True)
// Result:
// {
//   "id": 123,
//   "name": "Alice"
// }

OTr_SaveToFile($h; "/path/to/export.json")  // Pretty-printed to file
OTr_SaveToClipboard($h)  // Compact JSON to clipboard
```

### Test Coverage

See `____Test_Phase_1_5.4dm` for unit tests covering:
- `OTr_SaveToText` with compact and pretty output
- `OTr_SaveToFile` (file creation and readability)
- `OTr_SaveToClipboard` (clipboard placement)

### Limitations

- **No round-trip:** JSON export does not preserve type metadata; deserialisation is lossy
- **Simple export only:** No filtering, transformation, or selective serialisation

---

## Addendum: Phase 1.5b — Binary Export / Import

Phase 1.5b provides two complementary binary serialisation strategies for OTr objects. Both are implemented and confirmed present as `.4dm` files.

### Phase 1.5b Commands Implemented

| Command | Method | Returns | Purpose |
|---------|--------|---------|---------|
| (new) | `OTr_SaveToBlob` | Blob | Serialise to 4D-native compressed BLOB (`VARIABLE TO BLOB` + GZIP) |
| (new) | `OTr_LoadFromBlob` | Longint | Load from 4D-native BLOB into new handle |
| (new) | `OTr_SaveToGZIP` | Blob | Serialise to GZIPed UTF-8 JSON BLOB (portable) |
| (new) | `OTr_LoadFromGZIP` | Longint | Load from GZIPed JSON BLOB into new handle |

### `OTr_SaveToBlob`

```4d
#DECLARE ($inObject_i : Integer) -> $outBlob_blob : Blob
```

Serialises the object using `VARIABLE TO BLOB` followed by GZIP compression (`GZIP best compression mode`). The resulting BLOB is 4D-internal and **not** portable outside 4D. Use `OTr_SaveToGZIP` when portability is required.

Returns an empty BLOB if the handle is invalid.

### `OTr_LoadFromBlob`

```4d
#DECLARE ($inBlob_blob : Blob) -> $handle_i : Integer
```

Loads a 4D-native BLOB produced by `OTr_SaveToBlob` into a new OTr handle. Expands the BLOB automatically if it is compressed before calling `BLOB TO VARIABLE`. Returns `0` if the BLOB is empty or cannot be decoded.

### `OTr_SaveToGZIP`

```4d
#DECLARE ($inObject_i : Integer; $inPrettyPrint_b : Boolean) -> $outBlob_blob : Blob
```

Serialises the object to a UTF-8 JSON string (`JSON Stringify`), then compresses it with GZIP. Suitable for network transmission or file storage where portability outside 4D is required. The optional `$inPrettyPrint_b` parameter (default `False`) controls indented formatting.

Returns an empty BLOB if the handle is invalid.

### `OTr_LoadFromGZIP`

```4d
#DECLARE ($inBlob_blob : Blob) -> $handle_i : Integer
```

Loads a GZIPed JSON BLOB produced by `OTr_SaveToGZIP` into a new OTr handle. Expands the BLOB, converts the result to UTF-8 text, then delegates parsing to `OTr_LoadFromText`. Returns `0` if the BLOB is empty or cannot be decoded.

### Format Comparison

| Method pair | Format | Portable outside 4D | Round-trip safe |
|---|---|---|---|
| `OTr_SaveToBlob` / `OTr_LoadFromBlob` | 4D-native VARIABLE BLOB + GZIP | No | Yes (same 4D version) |
| `OTr_SaveToGZIP` / `OTr_LoadFromGZIP` | GZIPed UTF-8 JSON | Yes | Yes (JSON type limitations apply) |

---

## Addendum: Phase 1.5c — XML Export / Import (SAX Variants)

Phase 1.5c documents the XML serialisation methods, including two SAX-based variants introduced alongside the DOM variants. All four methods are implemented and present as `.4dm` files.

### Phase 1.5c Commands Implemented

| Command | Method | Returns | Purpose |
|---------|--------|---------|---------|
| (new) | `OTr_SaveToXML` | Text | Serialise object to XML text (DOM) |
| (new) | `OTr_SaveToXMLFile` | — | Serialise object to XML file (DOM) |
| (new) | `OTr_SaveToXMLSAX` | Text | Serialise object to XML text (SAX) |
| (new) | `OTr_SaveToXMLFileSAX` | — | Serialise object to XML file (SAX) |
| (new) | `OTr_LoadFromXML` | Longint | Load from XML text into new handle |
| (new) | `OTr_LoadFromXMLFile` | Longint | Load from XML file into new handle |

### Signatures

```4d
#DECLARE($inObject_i : Integer; $inPrettyPrint_b : Boolean)->$xml_t : Text        // OTr_SaveToXML, OTr_SaveToXMLSAX
#DECLARE($inObject_i : Integer; $inFilePath_t : Text; $inPrettyPrint_b : Boolean) // OTr_SaveToXMLFile, OTr_SaveToXMLFileSAX
#DECLARE($inXML_t : Text)->$handle_i : Integer                                    // OTr_LoadFromXML
#DECLARE($inFilePath_t : Text)->$handle_i : Integer                               // OTr_LoadFromXMLFile
```

### DOM vs SAX Variants

The SAX variants (`OTr_SaveToXMLSAX`, `OTr_SaveToXMLFileSAX`) produce output equivalent to the DOM variants but use 4D's SAX XML writing commands rather than the DOM tree API. The two approaches are interchangeable at the call site; the choice is an implementation detail. Both variants accept the same parameters and return the same types.

> **Internal use note:** The SAX variants exist because the DOM and SAX approaches were both explored during development. Both are retained. Either may be called; the output format is identical.

---

## Next Steps

Phase 1 (with 1.5, 1.5b, and 1.5c addenda) provides the foundation for all subsequent phases:
- **Phase 2** adds scalar put/get and basic object navigation
- **Phase 3+** add object inspection, array operations, complex types, import/export
