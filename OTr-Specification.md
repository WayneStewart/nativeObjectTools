# OTr — Native ObjectTools Replacement: Specification and Goals

**Version:** 0.5
**Date:** 2026-03-31
**Author:** Wayne Stewart / Claude

> **Navigation:** [Jump to Specifications Index](#specifications-index) for a complete list of all phase specifications and retired documents.

---

## 1. Purpose

This document specifies the design, architecture, and implementation goals for **OTr** — a set of native 4D project methods that replace the legacy ObjectTools 5.0 plugin. The replacement must reproduce the plugin's API semantics as closely as practicable whilst leveraging native 4D capabilities (specifically the Object type) for internal storage.

The primary motivation is to eliminate the dependency on a third-party binary plugin, ensuring long-term maintainability, compatibility with future 4D versions, and the ability to compile and deploy without external components.

---

## 2. Constraints

| Constraint | Detail |
|---|---|
| Minimum 4D version | 4D v19 LTS |
| Class functions | **Unavailable** — all code must be project methods |
| Naming convention | `OTr_` prefix replaces `OT ` plugin prefix (e.g., `OT New` becomes `OTr_New`) |
| Coding standard | As defined in `4D-Method-Writing-Guide.md` — `#DECLARE`, named parameters, type suffixes, boxed headers |
| Parameter style | Named parameters via `#DECLARE` only; no numbered parameters or legacy declarations |
| Compatibility goal | Callers should be able to migrate from `OT` to `OTr` with minimal refactoring — ideally a near-mechanical find-and-replace of command names |
| Method visibility | **All** OTr methods must be marked `"invisible":true` in their `%attributes` line |
| Method sharing | Only public API methods (those matching the ObjectTools command set) are `"shared":true`. All internal infrastructure methods (`OTr_z` prefix), utility methods (`OTr_u` prefix), and test methods (`Test_OTr_` prefix) are `"shared":false` |
| Unit tests | A comprehensive test suite is **required**, covering every public API method |

---

## 3. Architecture

### 3.1 Storage Model — Paired Interprocess Arrays

The legacy plugin uses opaque Longint handles to reference internal memory structures. OTr preserves this handle-based calling convention by maintaining a **paired interprocess array registry**:

```4d
ARRAY OBJECT(<>OTR_Objects_ao; 0)      // Object storage
ARRAY BOOLEAN(<>OTR_InUse_ab; 0)       // Object slot availability
```

`<>OTR_Objects_ao` — each element holds a native 4D Object. The object's properties correspond to the "tags" used in the legacy API. Native types (Integer, Real, Text, Boolean, Object, Collection, Picture) are stored directly as properties. BLOBs are stored natively on 4D v19R2 or later; on earlier versions they are base64-encoded as Text via `OTr_uBlobToText`. Non-native types (Date, Time, Pointer, Record, Variable) are stored as formatted Text strings (see §3.6).

`<>OTR_InUse_ab` — each element is a Boolean flag indicating whether the corresponding slot in `<>OTR_Objects_ao` is currently allocated (`True`) or available for reuse (`False`).

The array index into `<>OTR_Objects_ao` serves as the handle (Integer) returned to callers, preserving the Longint-handle calling convention from the legacy plugin.

### 3.2 Handle Allocation (`OTr_New`)

When `OTr_New` is called:

1. Scan `<>OTR_InUse_ab` for the first element that is `False` (an available slot).
2. If found: mark it `True`, initialise the corresponding `<>OTR_Objects_ao` element as an empty object (`{}`), and return the index.
3. If not found: append one element to both arrays, mark it `True`, initialise as `{}`, and return the new index.

This slot-reuse strategy prevents unbounded array growth in long-running processes.

### 3.3 Handle Deallocation (`OTr_Clear`)

When `OTr_Clear` is called with a handle:

1. Validate the handle (bounds check, in-use check).
2. Set `<>OTR_InUse_ab{handle}` to `False`.
3. Set `<>OTR_Objects_ao{handle}` to `Null` to release the memory held by the object.

Optionally, trailing unused slots may be trimmed (as `Fnd_Dict_Release` does), though this is a secondary optimisation.

### 3.4 Thread Safety

Multiple processes may call OTr methods concurrently. All operations that read or mutate the interprocess arrays are protected by the named semaphore `<>OTR_Semaphore_t`, acquired and released exclusively via `OTr_zLock` and `OTr_zUnlock`.

**Reentrancy:** OTr implements a reentrant (nested) locking strategy using the process variable `OTR_LockCount_i` (Integer, initialised to 0). This resolves the design decision previously noted here.

- `OTr_zLock`: if `OTR_LockCount_i = 0`, spins on `Semaphore(<>OTR_Semaphore_t; 10)` until acquired, then increments the counter to 1. If `OTR_LockCount_i > 0` (already locked by this process), the semaphore call is bypassed and the counter is incremented only.
- `OTr_zUnlock`: decrements `OTR_LockCount_i`. When the counter reaches 0, `CLEAR SEMAPHORE(<>OTR_Semaphore_t)` is called to release the lock. While the counter remains above 0, the semaphore is left in place.

This means that a public OTr method may safely call another OTr method that also calls `OTr_zLock` / `OTr_zUnlock` without deadlocking. The semaphore is acquired exactly once per outermost lock/unlock pair, regardless of nesting depth.

Every `OTr_zLock` call must be paired with exactly one `OTr_zUnlock` call on every exit path, including all error paths.

### 3.5 Tag-to-Property Mapping

The legacy ObjectTools API identifies items by text "tags". Tags support dot-separated paths for nested access (e.g., `"address.city"` navigates into an embedded object named `address` and accesses its `city` property).

In OTr, tags map directly to 4D Object property paths. The `OTr_zResolvePath` internal method parses the dot-separated key path, navigates (or creates) intermediate sub-objects, and returns the leaf object together with the final property name. This is modelled on the `OBJP_GetSubObject` method in Cannon Smith's OBJ_Module library (see §13), which provides a proven implementation of this pattern in native 4D.

The legacy `AutoCreateObjects` option (bit 2, on by default) automatically creates intermediate embedded objects along a dotted path. OTr must replicate this behaviour: when setting `"address.city"`, if the `address` property does not yet exist, it is created as an empty object before `city` is set within it. The OBJ_Module's `OBJP_GetSubObject` method demonstrates this auto-creation pattern.

**Note:** Bracket notation (`[x]`) for array element access within dot paths (as supported by OBJ_Module) is explicitly out of scope. OTr is a drop-in replacement for the legacy ObjectTools API — no more, no less.

### 3.6 Internal Storage of Types

All values are stored as flat, simple properties on the object. The type information is implicit in the method name used to store/retrieve the value (`OTr_PutDate` knows it is a date; `OTr_GetDate` knows to parse it back). Non-native types use a short prefix string to identify their storage mechanism.

**Directly stored types** — stored via `OB SET` with their natural value:

| OT Type | Stored As | Example Value |
|---|---|---|
| Longint / Integer | Integer | `42` |
| Real | Real | `3.14` |
| String / Text | Text | `"Wayne"` |
| Boolean | Boolean | `true` |
| Object (embedded) | Object | `{"city": "Brisbane"}` (deep copy on put) |
| Array (all types) | Collection | `[1, 2, 3]` |

**Formatted text types** — stored as plain Text strings in a known format:

| OT Type | Stored As | Example Value | Format |
|---|---|---|---|
| Date | Text | `"2026-03-31"` | `YYYY-MM-DD` |
| Time | Text | `"14:30:00"` | `HH:MM:SS` |

**Prefixed reference types** — stored as Text strings with a type prefix:

| OT Type | Stored As | Example Value | Notes |
|---|---|---|---|
| Pointer | Text | `"ptr:myVar;0;0"` | Via `RESOLVE POINTER` |
| Record | Text | `"rec:5;12"` | `rec:tableNum;recordNum` |

**Variable type** — the only case requiring embedded type information, since the variable's type is not implied by the method name:

| OT Type | Stored As | Example Value | Notes |
|---|---|---|---|
| Variable | Text | `"var:text:Wayne"` | `var:typeName:serialisedValue` |

The resulting objects are clean and flat, identical in structure to OBJ_Module output:

```json
{
    "Name": "Wayne",
    "theDate": "2026-03-31",
    "alarm": "14:30:00",
    "ref": "ptr:myVar;0;0"
}
```

Pictures are stored natively as Object properties. BLOBs are stored natively on 4D v19R2 or later; on v19/v19R1 they are stored base64-encoded as Text (no prefix — the typed getter `OTr_GetNewBLOB` handles both forms transparently).

**`OTr_ItemType` resolution:** For the majority of cases, the caller knows the type because they chose the typed getter. `OTr_ItemType` determines type by: (1) checking the native 4D type of the property (`OB Get type`) — Integer, Real, Boolean, Object, Collection, and Picture are unambiguous; (2) for BLOB: `OB Get type` returns `Is BLOB` on v19R2+; on v19/v19R1 a base64-encoded BLOB is stored as Text and cannot be distinguished from other Text by type alone — callers must use the typed getter; (3) for Text properties, checking for known prefixes (`ptr:`, `rec:`, `var:`); (4) for unprefixed Text, attempting date (`YYYY-MM-DD`) and time (`HH:MM:SS`) pattern matching; (5) falling back to `Is text` if no pattern matches.

### 3.7 BLOB and Picture Storage

Since 4D v16R4, 4D Objects can store Picture values natively as properties via `OB SET`. Since 4D v19R2, they can also store BLOB values natively. OTr takes advantage of this directly — no parallel arrays are required.

**Picture storage:** Stored directly as an Object property using `OB SET($obj; $tag; $picture_pic)` and retrieved with `OB Get($obj; $tag; Is picture)`. This works on all supported 4D versions (v19 LTS or later).

**BLOB storage:** Determined at initialisation time by a version gate stored in `Storage.OTr.nativeBlobInObject` (Boolean):

- **True (v19R2 or later):** BLOB stored directly as an Object property using `OB SET($obj; $tag; $blob_x)`.
- **False (v19 or v19R1):** BLOB base64-encoded to Text via `OTr_uBlobToText` and stored as a Text property. Retrieved by `OTr_uTextToBlob`. No prefix string is stored — the typed getter `OTr_GetNewBLOB` inspects the property type (`OB Get type`) to determine which path to take.

**Cleanup:** When `OTr_Clear` releases an object, native Object property values (including Pictures and BLOBs) are released automatically by setting the slot to `Null`. No explicit binary cleanup is required.

### 3.8 Array Storage

The legacy plugin stores arrays as first-class items within an object, supporting typed array elements (Longint, Real, Text, Date, Time, Boolean, BLOB, Picture, Pointer) with per-element get/set and bulk get/set operations.

In OTr, arrays are stored as **Collection** properties of the parent object. This is the natural 4D equivalent and supports:

- Bulk assignment: `OB SET($obj; $tag; $collection)`
- Element access: `$collection[$index]` (noting that Collections are zero-based whilst the legacy API is one-based — OTr must adjust indices by -1 internally)
- Size: `$collection.length`
- Insert / delete / resize operations via Collection methods

**Index mapping:** The legacy OT API uses 1-based array indices. Collections in 4D are 0-based. All OTr array methods must subtract 1 from the caller's index before accessing the Collection, and add 1 when returning indices to the caller.

### 3.9 Options System

The legacy plugin manages options via bit flags in a single Longint:

| Bit | Name | Default | Behaviour |
|-----|------|---------|-----------|
| 0 | FailOnItemNotFound | Off | Raise an error when a requested tag does not exist |
| 1 | ExactTagMatch | — | Deprecated; ignore |
| 2 | AutoCreateObjects | **On** | Automatically create intermediate embedded objects on dotted paths |
| 3 | VariantItems | Off | Allow items to change type on reassignment |

OTr must maintain a global options state (interprocess variable or property) and honour these flags in all relevant methods.

---

## 3A. Method Attributes

Every OTr method file must begin with a `%attributes` line that sets visibility and sharing properties. The rules are:

**All methods are invisible.** This prevents them from appearing in 4D's method explorer unless the developer explicitly chooses to show invisible methods. The attribute is `"invisible":true`.

**Only public API methods are shared.** Methods that correspond directly to an ObjectTools command (i.e., those listed in §6) are callable from any context and must be `"shared":true`. Internal infrastructure methods (`OTr_z` prefix), utility methods (`OTr_u` prefix), and test methods (`Test_OTr_` prefix) are `"shared":false`.

Examples:

```4d
// Public API method — invisible, shared
//%attributes = {"invisible":true,"shared":true}

// Internal/private method — invisible, not shared
//%attributes = {"invisible":true,"shared":false}

// Test method — invisible, not shared
//%attributes = {"invisible":true,"shared":false}
```

The classification by method prefix:

| Prefix | Visibility | Shared | Example |
|---|---|---|---|
| `OTr_` | Invisible | **Yes** | `OTr_New`, `OTr_PutLong`, `OTr_GetText` |
| `OTr_z` | Invisible | No | `OTr_zInit`, `OTr_zLock`, `OTr_zResolvePath` |
| `OTr_u` | Invisible | No | `OTr_uDateToText`, `OTr_uMapType`, `OTr_uPointerToText` |
| `Test_OTr_` | Invisible | No | `Test_OTr_Creation`, `Test_OTr_PutGet` |

---

## 4. Initialisation

An `OTr_zInit` method (private, called lazily by `OTr_New` and other entry points) must:

1. Check whether the module has been initialised (via an interprocess Boolean flag, e.g., `<>OTR_Initialized_b`).
2. If not: declare and size all interprocess arrays to zero, set default options (AutoCreateObjects on), detect the runtime 4D version and store the result in `Storage.OTr.nativeBlobInObject`, and set the flag:
   - `ARRAY OBJECT(<>OTR_Objects_ao; 0)` — object storage
   - `ARRAY BOOLEAN(<>OTR_InUse_ab; 0)` — object slot availability
3. If already initialised: return immediately.

This mirrors the `Fnd_Dict_Init` pattern.

---

## 5. Error Handling

The legacy plugin supports a custom error handler set via `OT SetErrorHandler`. OTr must replicate this:

- Maintain an interprocess Text variable holding the current error handler method name.
- When an error condition arises (invalid handle, tag not found with FailOnItemNotFound enabled, type mismatch, etc.), invoke the handler if set; otherwise fail silently or raise a 4D error as appropriate.
- `OTr_SetErrorHandler` returns the previous handler name (allowing chaining).

---

## 6. Command Mapping — Full API

The table below maps every legacy OT command to its OTr replacement method, with notes on implementation considerations.

### 6.1 Creation / Destruction

*Detailed specification:* [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT New` | `OTr_New` | Returns Integer handle |
| `OT Clear` | `OTr_Clear` | Releases slot; nullifies object |
| `OT ClearAll` | `OTr_ClearAll` | Resets both arrays to size 0 |
| `OT Copy` | `OTr_Copy` | Deep-copies the object; returns new handle |

### 6.2 Put Values (Scalar)

*Detailed specification:* [OTr-Phase-002-Spec.md](OTr-Phase-002-Spec.md) (common types), [OTr-Phase-005-Spec.md](OTr-Phase-005-Spec.md) (BLOB, Picture, Pointer, Record, Variable)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT PutLong` | `OTr_PutLong` | `OB SET` with Integer value |
| `OT PutReal` | `OTr_PutReal` | `OB SET` with Real value |
| `OT PutString` | `OTr_PutString` | `OB SET` with Text value |
| `OT PutText` | `OTr_PutText` | `OB SET` with Text value (identical to PutString in v19+) |
| `OT PutDate` | `OTr_PutDate` | `OB SET` with Date value |
| `OT PutTime` | `OTr_PutTime` | `OB SET` with Time value |
| `OT PutBoolean` | `OTr_PutBoolean` | `OB SET` with Boolean value |
| `OT PutBLOB` | `OTr_PutBLOB` | See §3.7 |
| `OT PutPicture` | `OTr_PutPicture` | See §3.7 |
| `OT PutPointer` | `OTr_PutPointer` | Serialise via `RESOLVE POINTER`; store as Text with type metadata |
| `OT PutObject` | `OTr_PutObject` | Store a reference or copy of the embedded object |
| `OT PutRecord` | `OTr_PutRecord` | Store table + record number as sub-object |
| `OT PutVariable` | `OTr_PutVariable` | Serialise pointer; store as Text with type metadata |

### 6.3 Get Values (Scalar)

*Detailed specification:* [OTr-Phase-002-Spec.md](OTr-Phase-002-Spec.md) (common types), [OTr-Phase-005-Spec.md](OTr-Phase-005-Spec.md) (BLOB, Picture, Pointer, Record, Variable)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT GetLong` | `OTr_GetLong` | `OB Get` returning Integer |
| `OT GetReal` | `OTr_GetReal` | `OB Get` returning Real |
| `OT GetString` | `OTr_GetString` | `OB Get` returning Text |
| `OT GetText` | `OTr_GetText` | `OB Get` returning Text |
| `OT GetDate` | `OTr_GetDate` | `OB Get` returning Date |
| `OT GetTime` | `OTr_GetTime` | `OB Get` returning Time |
| `OT GetBoolean` | `OTr_GetBoolean` | `OB Get` returning Boolean (as Integer for legacy compat) |
| `OT GetBLOB` | `OTr_GetBLOB` | Deprecated; retained for compatibility. Writes to out parameter |
| `OT GetNewBLOB` | `OTr_GetNewBLOB` | Returns BLOB as function result |
| `OT GetPicture` | `OTr_GetPicture` | Returns Picture |
| `OT GetPointer` | `OTr_GetPointer` | Deserialise stored text back to Pointer via `Get pointer` |
| `OT GetObject` | `OTr_GetObject` | Returns handle (Integer) to the embedded object |
| `OT GetRecord` | `OTr_GetRecord` | Loads the stored record into current selection |
| `OT GetRecordTable` | `OTr_GetRecordTable` | Returns table number |
| `OT GetVariable` | `OTr_GetVariable` | Deserialise pointer; write to out parameter |

### 6.4 Put Values (Array Element)

*Detailed specification:* [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT PutArray` | `OTr_PutArray` | Bulk store: convert 4D array to Collection |
| `OT PutArrayLong` | `OTr_PutArrayLong` | Set element in Collection (1-based → 0-based) |
| `OT PutArrayReal` | `OTr_PutArrayReal` | As above |
| `OT PutArrayString` | `OTr_PutArrayString` | As above |
| `OT PutArrayText` | `OTr_PutArrayText` | As above |
| `OT PutArrayDate` | `OTr_PutArrayDate` | As above |
| `OT PutArrayTime` | `OTr_PutArrayTime` | As above |
| `OT PutArrayBoolean` | `OTr_PutArrayBoolean` | As above |
| `OT PutArrayBLOB` | `OTr_PutArrayBLOB` | See §3.7 for element storage |
| `OT PutArrayPicture` | `OTr_PutArrayPicture` | See §3.7 for element storage |
| `OT PutArrayPointer` | `OTr_PutArrayPointer` | Serialise each pointer |

### 6.5 Get Values (Array Element)

*Detailed specification:* [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT GetArray` | `OTr_GetArray` | Bulk retrieve: convert Collection to 4D array |
| `OT GetArrayLong` | `OTr_GetArrayLong` | Get element from Collection (1-based → 0-based) |
| `OT GetArrayReal` | `OTr_GetArrayReal` | As above |
| `OT GetArrayString` | `OTr_GetArrayString` | As above |
| `OT GetArrayText` | `OTr_GetArrayText` | As above |
| `OT GetArrayDate` | `OTr_GetArrayDate` | As above |
| `OT GetArrayTime` | `OTr_GetArrayTime` | As above |
| `OT GetArrayBoolean` | `OTr_GetArrayBoolean` | As above |
| `OT GetArrayBLOB` | `OTr_GetArrayBLOB` | See §3.7 |
| `OT GetArrayPicture` | `OTr_GetArrayPicture` | See §3.7 |
| `OT GetArrayPointer` | `OTr_GetArrayPointer` | Deserialise stored text to Pointer |

### 6.6 Array Utilities

*Detailed specification:* [OTr-Phase-004-Spec.md](OTr-Phase-004-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT SizeOfArray` | `OTr_SizeOfArray` | `$collection.length` |
| `OT ResizeArray` | `OTr_ResizeArray` | `$collection.resize()` |
| `OT InsertElement` | `OTr_InsertElement` | Insert Null elements at position (adjust index) |
| `OT DeleteElement` | `OTr_DeleteElement` | `$collection.remove()` (adjust index) |
| `OT FindInArray` | `OTr_FindInArray` | `$collection.indexOf()` (adjust returned index) |
| `OT SortArrays` | `OTr_SortArrays` | Multi-key sort across multiple tag Collections |

### 6.7 Object Info

*Detailed specification:* [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT IsObject` | `OTr_IsObject` | Check handle validity (bounds + in-use flag) |
| `OT ItemCount` | `OTr_ItemCount` | `OB Keys` then `Size of array` (or count properties of sub-object for dotted tag) |
| `OT ObjectSize` | `OTr_ObjectSize` | Serialise to JSON, measure text length (approximate), or enumerate properties |

### 6.8 Item Info

*Detailed specification:* [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT ItemExists` | `OTr_ItemExists` | `OB Is defined` on the property path |
| `OT ItemType` | `OTr_ItemType` | `OB Get type` — must map 4D type constants to OT type constants for backward compat |
| `OT IsEmbedded` | `OTr_IsEmbedded` | Check if property value is Object type |
| `OT GetItemProperties` | `OTr_GetItemProperties` | By index: enumerate `OB Keys`, access nth key |
| `OT GetNamedProperties` | `OTr_GetNamedProperties` | By tag: `OB Get type` + size information |
| `OT GetAllProperties` | `OTr_GetAllProperties` | Enumerate all top-level properties |
| `OT GetAllNamedProperties` | `OTr_GetAllNamedProperties` | Enumerate properties of a sub-object identified by tag |

### 6.9 Item Utilities

*Detailed specification:* [OTr-Phase-003-Spec.md](OTr-Phase-003-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT CopyItem` | `OTr_CopyItem` | Copy property from one object/tag to another object/tag |
| `OT CompareItems` | `OTr_CompareItems` | Compare property values across two objects |
| `OT RenameItem` | `OTr_RenameItem` | Copy property to new key, remove old key |
| `OT DeleteItem` | `OTr_DeleteItem` | `OB REMOVE` on the property |

### 6.10 Import / Export

*Detailed specification:* [OTr-Phase-006-Spec.md](OTr-Phase-006-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT ObjectToBLOB` | `OTr_ObjectToBLOB` | Serialise object (JSON + metadata for non-JSON types) to BLOB |
| `OT ObjectToNewBLOB` | `OTr_ObjectToNewBLOB` | As above, returning BLOB as function result |
| `OT BLOBToObject` | `OTr_BLOBToObject` | Deserialise BLOB back to object; return new handle |

### 6.11 Object Utilities

*Detailed specification:* [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT GetVersion` | `OTr_GetVersion` | Return OTr version string |
| `OT Register` | `OTr_Register` | No-op (no licence required); return success |
| `OT SetErrorHandler` | `OTr_SetErrorHandler` | Set/get error handler method name |
| `OT GetOptions` | `OTr_GetOptions` | Return current options bit field |
| `OT SetOptions` | `OTr_SetOptions` | Set options bit field |
| `OT CompiledApplication` | `OTr_CompiledApplication` | Return `Is compiled mode` result |
| `OT GetHandleList` | `OTr_GetHandleList` | Return Integer array of all active (in-use) handles |

### 6.12 Simple Export/Import (OTr additions — no legacy equivalent)

*Detailed specification:* [OTr-Phase-001-Spec.md](OTr-Phase-001-Spec.md) (Phase 1.5)

These methods have no counterpart in the legacy ObjectTools plugin. They are OTr-specific additions to support testing, object inspection, and data transfer. Binary data (BLOB, Picture) is stored natively in 4D Objects and serialised inline by the export methods.

| OTr Method | Notes |
|---|---|
| `OTr_SaveToText` | Serialise stored object to a self-contained JSON text string; optional pretty-print flag (default: compact) |
| `OTr_SaveToFile` | Write stored object as self-contained JSON to a file path on disk; optional pretty-print flag (default: indented) |
| `OTr_SaveToClipboard` | Place self-contained JSON representation of stored object on the system clipboard; optional pretty-print flag (default: indented) |
| `OTr_LoadFromText` | Parse a JSON text string (previously saved by `OTr_SaveToText`) into a new OTr object; returns the new handle |
| `OTr_LoadFromFile` | Read a JSON file (previously saved by `OTr_SaveToFile`) and load it into a new OTr object; returns the new handle |
| `OTr_LoadFromClipboard` | Parse JSON from the clipboard (previously saved by `OTr_SaveToClipboard`) into a new OTr object; returns the new handle |

### 6.13 Date Mode (OTr addition — no legacy equivalent)

*Detailed specification:* [OTr-Phase-002-Spec.md](Documentation/Specifications/OTr-Phase-002-Spec.md) (§Date/Time Storage Strategy)

Controls how the current process stores Date and Time values in 4D Object properties. Wraps `SET DATABASE PARAMETER (Dates inside objects; ...)`, which is a per-process setting.

| OTr Method | Notes |
|---|---|
| `OTr_SetDateMode` | Gets or sets the current process's Date/Time storage mode. Token: `"native"` (default since v17), `"iso"` (ISO text without timezone), `"iso-tz"` (ISO text with timezone). Call with no argument to query the current mode. Returns the current mode token. |

---

## 7. Command Reference by Phase

The complete API is organised into phases, each with dedicated specification documents. Refer to the appropriate phase spec for detailed method signatures, behaviour, and examples.

### Phase 1: Core Infrastructure & Handle Management (incl. 1.5 Export)
**Specification:** [OTr-Phase-001-Spec.md](Documentation/Specifications/OTr-Phase-001-Spec.md)

Creation, destruction, handle validation, options, error handlers, metadata. Includes Phase 1.5 addendum: simple JSON export (SaveToText, SaveToFile, SaveToClipboard).

| Commands |
|----------|
| **Core (Phase 1):** `OTr_New`, `OTr_Clear`, `OTr_ClearAll`, `OTr_Copy` |
| `OTr_IsObject`, `OTr_GetHandleList` |
| `OTr_GetOptions`, `OTr_SetOptions`, `OTr_SetErrorHandler` |
| `OTr_GetVersion`, `OTr_Register`, `OTr_CompiledApplication` |
| **Export (Phase 1.5):** `OTr_SaveToText`, `OTr_SaveToFile`, `OTr_SaveToClipboard` |

### Phase 2: Scalar Put/Get & Dotted-Path Navigation
**Specification:** [OTr-Phase-002-Spec.md](Documentation/Specifications/OTr-Phase-002-Spec.md)

Fundamental data storage and retrieval for scalar types and embedded objects.

| Commands |
|----------|
| `OTr_PutLong`, `OTr_GetLong` |
| `OTr_PutReal`, `OTr_GetReal` |
| `OTr_PutString`, `OTr_GetString` |
| `OTr_PutText`, `OTr_GetText` |
| `OTr_PutDate`, `OTr_GetDate` |
| `OTr_PutTime`, `OTr_GetTime` |
| `OTr_PutBoolean`, `OTr_GetBoolean` |
| `OTr_PutObject`, `OTr_GetObject` |

### Phase 3: Object Inspection & Item Utilities
**Specification:** [OTr-Phase-003-Spec.md](Documentation/Specifications/OTr-Phase-003-Spec.md)

Query object structure, enumerate properties, copy/compare/rename/delete items.

| Commands |
|----------|
| `OTr_ItemExists`, `OTr_ItemType`, `OTr_IsEmbedded`, `OTr_ItemCount`, `OTr_ObjectSize` |
| `OTr_GetItemProperties`, `OTr_GetNamedProperties`, `OTr_GetAllProperties`, `OTr_GetAllNamedProperties` |
| `OTr_CopyItem`, `OTr_CompareItems`, `OTr_RenameItem`, `OTr_DeleteItem` |

### Phase 4: Array Operations
**Specification:** [OTr-Phase-004-Spec.md](Documentation/Specifications/OTr-Phase-004-Spec.md)

Bulk array storage, typed element access, and array utilities.

| Commands |
|----------|
| `OTr_PutArray`, `OTr_GetArray` (bulk) |
| `OTr_PutArrayLong`, `OTr_GetArrayLong` (and similar for all scalar types) |
| `OTr_SizeOfArray`, `OTr_ResizeArray`, `OTr_InsertElement`, `OTr_DeleteElement`, `OTr_FindInArray`, `OTr_SortArrays` |

### Phase 5: Complex Types (BLOB, Picture, Pointer, Record, Variable)
**Specification:** [OTr-Phase-005-Spec.md](Documentation/Specifications/OTr-Phase-005-Spec.md)

Storage and retrieval of non-native types via serialisation and metadata.

| Commands |
|----------|
| `OTr_PutBLOB`, `OTr_GetBLOB`, `OTr_GetNewBLOB` |
| `OTr_PutPicture`, `OTr_GetPicture` |
| `OTr_PutPointer`, `OTr_GetPointer` |
| `OTr_PutRecord`, `OTr_GetRecord`, `OTr_GetRecordTable` |
| `OTr_PutVariable`, `OTr_GetVariable` |

### Phase 6: Full Import/Export (with Type Preservation)
**Specification:** [OTr-Phase-006-Spec.md](Documentation/Specifications/OTr-Phase-006-Spec.md)

Binary BLOB serialisation with type metadata; round-trip fidelity for all types.

| Commands |
|----------|
| `OTr_ObjectToBLOB`, `OTr_ObjectToNewBLOB` |
| `OTr_BLOBToObject` |

### Phase 7–9: Advanced Features & Quality Assurance
**Specifications:** [OTr-Phase-007-Spec.md](Documentation/Specifications/OTr-Phase-007-Spec.md), [OTr-Phase-008-Spec.md](Documentation/Specifications/OTr-Phase-008-Spec.md), [OTr-Phase-009-Spec.md](Documentation/Specifications/OTr-Phase-009-Spec.md)

**Status:** Phases 7–8 complete; Phase 9 substantially complete.

Additional features, optimisations, and pre-release audit corrections.

### Phase 10–20: Release Preparation & Testing
**Specifications:** [OTr-Phase-010-Spec.md](Documentation/Specifications/OTr-Phase-010-Spec.md), [OTr-Phase-015-Spec.md](Documentation/Specifications/OTr-Phase-015-Spec.md), [OTr-Phase-020-Spec.md](Documentation/Specifications/OTr-Phase-020-Spec.md)

**Status:** Phase 10 (logging) and Phase 15 (parallel OT vs OTr testing) currently in progress. Phase 20 (release checklist) is active as part of v0.5 release preparation.

Phases 10, 15, and 20 complete the final release cycle for v0.5, ensuring comprehensive logging, validation testing, and release readiness.

---

## 8. Type Constant Mapping

The legacy plugin defines its own type constants. OTr maps between these and native 4D type constants for backward compatibility.

**Reference:** [OTr-Types-Reference.md](OTr-Types-Reference.md)

---

## 9. Internal Methods

### Infrastructure (`OTr_z` prefix)
Lazy initialisation, locking, path resolution, error dispatch.

**Detailed specification:** See individual phase specs.

### Utilities (`OTr_u` prefix)
Type conversion, serialisation, comparison.

**Detailed specification:** See individual phase specs.

---

## 10. Coding Standard

All OTr methods must:
- Use `#DECLARE` with named parameters (no numbered parameters)
- Include type suffixes on variable names
- Be marked `"invisible":true` in their `%attributes` line
- Public API methods (`OTr_*` prefix) be marked `"shared":true`
- Internal methods (`OTr_z*`, `OTr_u*`) be marked `"shared":false`
- Follow the standard defined in `4D-Method-Writing-Guide.md`

---

## 11. Testing Strategy

Comprehensive unit tests are required for every phase. All tests use the `Test_OTr_` prefix and are marked `"invisible":true,"shared":false`.

**Test methods:**
- `____Test_Phase_1.4dm` — Core infrastructure (incl. Phase 1.5 export)
- `____Test_Phase_2.4dm` — Scalar put/get
- And similar for phases 3–6

---

## 12. Migration Guide (Summary)

For existing codebases migrating from ObjectTools to OTr:

1. **Find and replace** `OT ` with `OTr_` in all method calls (noting the space-to-underscore change).
2. **Remove** calls to `OT Register` (or leave them — `OTr_Register` is a no-op).
3. **Review** any code that relies on the binary BLOB format from `OT ObjectToBLOB`, as the OTr serialisation format may differ.
4. **Review** `OT PutObject` / `OT GetObject` usage for copy-vs-reference semantics (Phase 2).
5. **Verify** that all `OT Clear` calls are matched — the same memory management discipline applies.

---

## 13. Reference Materials

| Document | Purpose |
|---|---|
| `4D-Method-Writing-Guide.md` | Coding standard for all OTr methods |
| `OTr-Types-Reference.md` | Type constant mapping (4D ↔ legacy OT) |
| `OTr-Phase-*.md` | Detailed specification for each phase |
| ObjectTools 5 Reference (legacy) | `LegacyDocumentation/ObjectTools 5 Reference.pdf` |
| Fnd_Dict Library | Structural template — handle-based registry with semaphore locking |

---

## 14. Specifications Index {#specifications-index}

This master document is accompanied by detailed specifications for each implementation phase. Refer to the appropriate phase document for method signatures, behaviour, edge cases, and examples.

### Complete Specifications (Phases 1–8)

- **[OTr-Phase-001-Spec.md](Documentation/Specifications/OTr-Phase-001-Spec.md)** — Phase 001–1.5: Core infrastructure & simple export ✓
- **[OTr-Phase-002-Spec.md](Documentation/Specifications/OTr-Phase-002-Spec.md)** — Phase 002: Scalar put/get ✓
- **[OTr-Phase-003-Spec.md](Documentation/Specifications/OTr-Phase-003-Spec.md)** — Phase 003: Object inspection ✓
- **[OTr-Phase-004-Spec.md](Documentation/Specifications/OTr-Phase-004-Spec.md)** — Phase 004: Array operations ✓
- **[OTr-Phase-005-Spec.md](Documentation/Specifications/OTr-Phase-005-Spec.md)** — Phase 005: Complex types ✓
- **[OTr-Phase-006-Spec.md](Documentation/Specifications/OTr-Phase-006-Spec.md)** — Phase 006: Full import/export ✓
- **[OTr-Phase-007-Spec.md](Documentation/Specifications/OTr-Phase-007-Spec.md)** — Phase 007: Advanced features ✓
- **[OTr-Phase-008-Spec.md](Documentation/Specifications/OTr-Phase-008-Spec.md)** — Phase 008: Unified accessors ✓

### In-Progress Specifications

- **[OTr-Phase-009-Spec.md](Documentation/Specifications/OTr-Phase-009-Spec.md)** — Phase 009: Pre-release audit (substantially complete)
- **[OTr-Phase-010-Spec.md](Documentation/Specifications/OTr-Phase-010-Spec.md)** — Phase 010: Logging subsystem (in progress)
- **[OTr-Phase-015-Spec.md](Documentation/Specifications/OTr-Phase-015-Spec.md)** — Phase 015: Parallel OT vs OTr testing (in progress)

### Release & Roadmap Specifications

- **[OTr-Phase-020-Spec.md](Documentation/Specifications/OTr-Phase-020-Spec.md)** — Phase 020: Release checklist (v0.5 release)
- **[OTr-Phase-100-Spec.md](Documentation/Specifications/OTr-Phase-100-Spec.md)** — Phase 100: Version 2.0 roadmap and future enhancements

### Retired Specifications

Historical specifications are archived in `Documentation/Specifications/Retired/` for reference.
