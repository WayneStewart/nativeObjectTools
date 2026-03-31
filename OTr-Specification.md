# OTr — Native ObjectTools Replacement: Specification and Goals

**Version:** 0.5
**Date:** 2026-03-31
**Author:** Wayne Stewart / Claude

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
| Method sharing | Only public API methods (those matching the ObjectTools command set) are `"shared":true`. All internal/private methods (`OTr__` prefix) and test methods (`Test_OTr_` prefix) are `"shared":false` |
| Unit tests | A comprehensive test suite is **required**, covering every public API method |

---

## 3. Architecture

### 3.1 Storage Model — Paired Interprocess Arrays

The legacy plugin uses opaque Longint handles to reference internal memory structures. OTr preserves this handle-based calling convention by maintaining a **paired interprocess array registry**:

```4d
ARRAY OBJECT(<>OTR_Objects_ao; 0)      // Object storage
ARRAY BOOLEAN(<>OTR_InUse_ab; 0)       // Object slot availability

ARRAY BLOB(<>OTR_Blobs_ax; 0)          // BLOB binary data
ARRAY BOOLEAN(<>OTR_BlobInUse_ab; 0)   // BLOB slot availability

ARRAY PICTURE(<>OTR_Pictures_ap; 0)    // Picture binary data
ARRAY BOOLEAN(<>OTR_PicInUse_ab; 0)    // Picture slot availability
```

`<>OTR_Objects_ao` — each element holds a native 4D Object. The object's properties correspond to the "tags" used in the legacy API. Native types (Integer, Real, Text, Boolean, Object, Collection) are stored directly as properties. Non-native types (Date, Time, BLOB, Picture, Pointer, Record, Variable) are stored as wrapper sub-objects with `__otr_type` metadata (see §3.6).

`<>OTR_InUse_ab` — each element is a Boolean flag indicating whether the corresponding slot in `<>OTR_Objects_ao` is currently allocated (`True`) or available for reuse (`False`).

`<>OTR_Blobs_ax` / `<>OTR_Pictures_ap` — parallel arrays holding actual BLOB and Picture binary data. Object properties reference these via an index stored in the `__otr_ref` field of the wrapper sub-object (see §3.7).

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

Multiple processes may call OTr methods concurrently. All operations that read or mutate the interprocess arrays must be protected by a named semaphore:

```4d
Semaphore("OTr_Registry")
// ... perform operation ...
CLEAR SEMAPHORE("OTr_Registry")
```

The `Fnd_Dict` library in this codebase provides a proven pattern for this, including a reentrant lock count via `Fnd_Dict_LockInternalState`. OTr should implement an equivalent `OTr__Lock` / `OTr__Unlock` internal method pair (or a single `OTr__LockRegistry` method accepting a Boolean parameter).

**Design decision required:** Whether reentrancy (nested locking from the same process) is needed for OTr. If an OTr method internally calls another OTr method that also acquires the lock, reentrancy is essential. The `Fnd_Dict` pattern (lock count + semaphore) handles this cleanly.

### 3.5 Tag-to-Property Mapping

The legacy ObjectTools API identifies items by text "tags". Tags support dot-separated paths for nested access (e.g., `"address.city"` navigates into an embedded object named `address` and accesses its `city` property).

In OTr, tags map directly to 4D Object property paths. The `OTr__ResolvePath` internal method parses the dot-separated key path, navigates (or creates) intermediate sub-objects, and returns the leaf object together with the final property name. This is modelled on the `OBJP_GetSubObject` method in Cannon Smith's OBJ_Module library (see §13), which provides a proven implementation of this pattern in native 4D.

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
| BLOB | Text | `"blob:33"` | Index into `<>OTR_Blobs_ax` |
| Picture | Text | `"pic:27"` | Index into `<>OTR_Pictures_ap` |
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
    "myAvatar": "pic:27",
    "myEncryptedCreditCard": "blob:33",
    "ref": "ptr:myVar;0;0"
}
```

**`OTr_ItemType` resolution:** For the majority of cases, the caller knows the type because they chose the typed getter. `OTr_ItemType` determines type by: (1) checking the native 4D type of the property (`OB Get type`) — Integer, Real, Boolean, Object, and Collection are unambiguous; (2) for Text properties, checking for known prefixes (`blob:`, `pic:`, `ptr:`, `rec:`, `var:`); (3) for unprefixed Text, attempting date (`YYYY-MM-DD`) and time (`HH:MM:SS`) pattern matching; (4) falling back to `Is text` if no pattern matches.

### 3.7 BLOB and Picture Storage

4D Objects cannot natively hold BLOB or Picture values as properties via `OB SET`. OTr uses **parallel interprocess arrays** for binary data:

```4d
ARRAY BLOB(<>OTR_Blobs_ax; 0)
ARRAY BOOLEAN(<>OTR_BlobInUse_ab; 0)
ARRAY PICTURE(<>OTR_Pictures_ap; 0)
ARRAY BOOLEAN(<>OTR_PicInUse_ab; 0)
```

**Storage process (`OTr_PutBLOB`):**
1. Scan `<>OTR_BlobInUse_ab` for a `False` slot; if none, append to both arrays.
2. Store the BLOB in `<>OTR_Blobs_ax{N}`, set `<>OTR_BlobInUse_ab{N}` to `True`.
3. Store the string `"blob:N"` as the object property value.

**Retrieval process (`OTr_GetNewBLOB`):**
1. Read the property value (e.g., `"blob:33"`); parse out the index.
2. Return `<>OTR_Blobs_ax{33}`.

**Picture storage** follows the same pattern with `<>OTR_Pictures_ap` / `<>OTR_PicInUse_ab`, using the prefix `"pic:N"`.

**Cleanup:** When `OTr_Clear` releases an object, it scans all Text properties for `blob:` and `pic:` prefixes and releases the corresponding slots (zeroes the data, marks `InUse` as `False`). Trailing unused slots are trimmed (see §10.6).

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

**Only public API methods are shared.** Methods that correspond directly to an ObjectTools command (i.e., those listed in §6) are callable from any context and must be `"shared":true`. Internal helper methods (`OTr__` prefix) and test methods (`Test_OTr_` prefix) are `"shared":false`.

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
| `OTr__` | Invisible | No | `OTr__Init`, `OTr__Lock`, `OTr__ResolvePath` |
| `Test_OTr_` | Invisible | No | `Test_OTr_Creation`, `Test_OTr_PutGet` |

---

## 4. Initialisation

An `OTr__Init` method (private, called lazily by `OTr_New` and other entry points) must:

1. Check whether the module has been initialised (via an interprocess Boolean flag, e.g., `<>OTR_Initialized_b`).
2. If not: declare and size all interprocess arrays to zero, set default options (AutoCreateObjects on), and set the flag:
   - `ARRAY OBJECT(<>OTR_Objects_ao; 0)` — object storage
   - `ARRAY BOOLEAN(<>OTR_InUse_ab; 0)` — object slot availability
   - `ARRAY BLOB(<>OTR_Blobs_ax; 0)` — BLOB binary data
   - `ARRAY BOOLEAN(<>OTR_BlobInUse_ab; 0)` — BLOB slot availability
   - `ARRAY PICTURE(<>OTR_Pictures_ap; 0)` — Picture binary data
   - `ARRAY BOOLEAN(<>OTR_PicInUse_ab; 0)` — Picture slot availability
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

*Detailed specification:* [OTr-Phase1-Spec.md](OTr-Phase1-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT New` | `OTr_New` | Returns Integer handle |
| `OT Clear` | `OTr_Clear` | Releases slot; nullifies object |
| `OT ClearAll` | `OTr_ClearAll` | Resets both arrays to size 0 |
| `OT Copy` | `OTr_Copy` | Deep-copies the object; returns new handle |

### 6.2 Put Values (Scalar)

*Detailed specification:* [OTr-Phase2-Spec.md](OTr-Phase2-Spec.md) (common types), [OTr-Phase5-Spec.md](OTr-Phase5-Spec.md) (BLOB, Picture, Pointer, Record, Variable)

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

*Detailed specification:* [OTr-Phase2-Spec.md](OTr-Phase2-Spec.md) (common types), [OTr-Phase5-Spec.md](OTr-Phase5-Spec.md) (BLOB, Picture, Pointer, Record, Variable)

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

*Detailed specification:* [OTr-Phase4-Spec.md](OTr-Phase4-Spec.md)

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

*Detailed specification:* [OTr-Phase4-Spec.md](OTr-Phase4-Spec.md)

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

*Detailed specification:* [OTr-Phase4-Spec.md](OTr-Phase4-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT SizeOfArray` | `OTr_SizeOfArray` | `$collection.length` |
| `OT ResizeArray` | `OTr_ResizeArray` | `$collection.resize()` |
| `OT InsertElement` | `OTr_InsertElement` | Insert Null elements at position (adjust index) |
| `OT DeleteElement` | `OTr_DeleteElement` | `$collection.remove()` (adjust index) |
| `OT FindInArray` | `OTr_FindInArray` | `$collection.indexOf()` (adjust returned index) |
| `OT SortArrays` | `OTr_SortArrays` | Multi-key sort across multiple tag Collections |

### 6.7 Object Info

*Detailed specification:* [OTr-Phase3-Spec.md](OTr-Phase3-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT IsObject` | `OTr_IsObject` | Check handle validity (bounds + in-use flag) |
| `OT ItemCount` | `OTr_ItemCount` | `OB Keys` then `Size of array` (or count properties of sub-object for dotted tag) |
| `OT ObjectSize` | `OTr_ObjectSize` | Serialise to JSON, measure text length (approximate), or enumerate properties |

### 6.8 Item Info

*Detailed specification:* [OTr-Phase3-Spec.md](OTr-Phase3-Spec.md)

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

*Detailed specification:* [OTr-Phase3-Spec.md](OTr-Phase3-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT CopyItem` | `OTr_CopyItem` | Copy property from one object/tag to another object/tag |
| `OT CompareItems` | `OTr_CompareItems` | Compare property values across two objects |
| `OT RenameItem` | `OTr_RenameItem` | Copy property to new key, remove old key |
| `OT DeleteItem` | `OTr_DeleteItem` | `OB REMOVE` on the property |

### 6.10 Import / Export

*Detailed specification:* [OTr-Phase6-Spec.md](OTr-Phase6-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT ObjectToBLOB` | `OTr_ObjectToBLOB` | Serialise object (JSON + metadata for non-JSON types) to BLOB |
| `OT ObjectToNewBLOB` | `OTr_ObjectToNewBLOB` | As above, returning BLOB as function result |
| `OT BLOBToObject` | `OTr_BLOBToObject` | Deserialise BLOB back to object; return new handle |

### 6.11 Object Utilities

*Detailed specification:* [OTr-Phase1-Spec.md](OTr-Phase1-Spec.md)

| Legacy Command | OTr Method | Notes |
|---|---|---|
| `OT GetVersion` | `OTr_GetVersion` | Return OTr version string |
| `OT Register` | `OTr_Register` | No-op (no licence required); return success |
| `OT SetErrorHandler` | `OTr_SetErrorHandler` | Set/get error handler method name |
| `OT GetOptions` | `OTr_GetOptions` | Return current options bit field |
| `OT SetOptions` | `OTr_SetOptions` | Set options bit field |
| `OT CompiledApplication` | `OTr_CompiledApplication` | Return `Is compiled mode` result |
| `OT GetHandleList` | `OTr_GetHandleList` | Return Integer array of all active (in-use) handles |

### 6.12 Simple Export (OTr additions — no legacy equivalent)

*Detailed specification:* [OTr-Phase1-Spec.md](OTr-Phase1-Spec.md) (Phase 1.5)

These methods have no counterpart in the legacy ObjectTools plugin. They are OTr-specific additions to support testing and object inspection.

| OTr Method | Notes |
|---|---|
| `OTr_SaveToText` | Serialise stored object to a JSON text string; optional pretty-print flag (default: compact) |
| `OTr_SaveToFile` | Write stored object as JSON to a file path on disk; optional pretty-print flag (default: indented) |
| `OTr_SaveToClipboard` | Place JSON representation of stored object on the system clipboard; optional pretty-print flag (default: indented) |

---

## 7. Type Constant Mapping

The legacy plugin defines its own type constants. OTr must map between these and native 4D type constants for backward compatibility in methods such as `OTr_ItemType`.

The authoritative reference for all 4D type constants, variable name suffixes, and the legacy OT → 4D mapping table is maintained in **[OTr-Types-Reference.md](OTr-Types-Reference.md)**.

An `OTr__MapType` internal method handles bidirectional mapping; its detailed specification is in [OTr-Phase6-Spec.md](OTr-Phase6-Spec.md).

---

## 8. Internal (Private) Methods

In addition to the public API methods, OTr requires several internal helper methods. These are prefixed with `OTr__` (double underscore) to distinguish them from the public API. All internal methods are marked `"invisible":true,"shared":false` in their `%attributes` line (see §3A):

| Method | Purpose |
|---|---|
| `OTr__Init` | Lazy initialisation of interprocess arrays and default options |
| `OTr__Lock` | Acquire semaphore (with optional reentrancy support) |
| `OTr__Unlock` | Release semaphore |
| `OTr__IsValidHandle` | Bounds check + in-use check; returns Boolean |
| `OTr__GetObject` | Given a handle, return a pointer to the object in the array (or the object itself) |
| `OTr__ResolvePath` | Given a dotted tag, navigate/create intermediate objects; return the leaf object and final key |
| `OTr__ParsePrefix` | Parse a prefixed string (e.g., `"blob:33"`) and return the prefix and index/value |
| `OTr__Error` | Invoke the error handler (if set) or raise an error |
| `OTr__ArrayToCollection` | Convert a 4D array (via Pointer) to a Collection |
| `OTr__CollectionToArray` | Convert a Collection to a 4D array (via Pointer) |
| `OTr__SerialisePointer` | `RESOLVE POINTER` → Text representation |
| `OTr__DeserialisePointer` | Text representation → Pointer via `Get pointer` |

---

## 9. Implementation Phases

### Phase 1 — Core Infrastructure
- `OTr__Init`, `OTr__Lock`, `OTr__Unlock`, `OTr__IsValidHandle`, `OTr__GetObject`, `OTr__Error`
- `OTr_New`, `OTr_Clear`, `OTr_ClearAll`, `OTr_Copy`
- `OTr_GetOptions`, `OTr_SetOptions`
- `OTr_GetVersion`, `OTr_Register`, `OTr_CompiledApplication`
- `OTr_SetErrorHandler`, `OTr_GetHandleList`
- `OTr_IsObject`

### Phase 1.5 — Simple Export

No legacy ObjectTools equivalent. These methods provide a JSON view of a stored object for testing and inspection. They are implemented as part of the Phase 1 baseline because they depend only on the handle registry and are required before Phase 2 testing begins.

- `OTr_SaveToText` — serialise object to JSON Text; optional `$prettyPrint_b` flag (default `False`)
- `OTr_SaveToFile` — write JSON to a file path using UTF-8 encoding; optional `$prettyPrint_b` flag (default `True`)
- `OTr_SaveToClipboard` — place JSON on the system clipboard; optional `$prettyPrint_b` flag (default `True`)

### Phase 2 — Scalar Put/Get (Common Types)
- `OTr__ResolvePath` (with AutoCreateObjects support)
- `OTr_PutLong`, `OTr_PutReal`, `OTr_PutString`, `OTr_PutText`, `OTr_PutDate`, `OTr_PutTime`, `OTr_PutBoolean`
- `OTr_GetLong`, `OTr_GetReal`, `OTr_GetString`, `OTr_GetText`, `OTr_GetDate`, `OTr_GetTime`, `OTr_GetBoolean`
- `OTr_PutObject`, `OTr_GetObject`

### Phase 3 — Item Info and Utilities
- `OTr_ItemExists`, `OTr_ItemType`, `OTr_IsEmbedded`, `OTr_ItemCount`, `OTr_ObjectSize`
- `OTr_GetItemProperties`, `OTr_GetNamedProperties`, `OTr_GetAllProperties`, `OTr_GetAllNamedProperties`
- `OTr_CopyItem`, `OTr_CompareItems`, `OTr_RenameItem`, `OTr_DeleteItem`

### Phase 4 — Array Operations
- `OTr__ArrayToCollection`, `OTr__CollectionToArray`
- `OTr_PutArray`, `OTr_GetArray`
- All `OTr_PutArray*` and `OTr_GetArray*` element methods
- `OTr_SizeOfArray`, `OTr_ResizeArray`, `OTr_InsertElement`, `OTr_DeleteElement`
- `OTr_FindInArray`, `OTr_SortArrays`

### Phase 5 — Complex Types
- `OTr__SerialisePointer`, `OTr__DeserialisePointer`
- `OTr_PutPointer`, `OTr_GetPointer`
- `OTr_PutBLOB`, `OTr_GetBLOB`, `OTr_GetNewBLOB`, `OTr_PutPicture`, `OTr_GetPicture`
- `OTr_PutRecord`, `OTr_GetRecord`, `OTr_GetRecordTable`
- `OTr_PutVariable`, `OTr_GetVariable`

### Phase 6 — Import/Export
- `OTr_ObjectToBLOB`, `OTr_ObjectToNewBLOB`, `OTr_BLOBToObject`
- `OTr__MapType` (finalised for serialisation format)

---

## 10. Design Decisions (Resolved)

All design questions have been resolved. This section records each decision and its rationale.

**10.1 — BLOB and Picture storage.** `OB SET` cannot store BLOB or Picture values directly. **Decision:** Parallel interprocess arrays (`<>OTR_Blobs_ax`, `<>OTR_Pictures_ap`) with paired `InUse` Boolean arrays. Object properties store a simple prefixed string (`"blob:33"`, `"pic:27"`) referencing the array index. See §3.7 for full detail.

**10.2 — `OTr_PutObject` semantics.** **Decision:** Default to deep copy (`OB Copy`), matching legacy `OT PutObject` behaviour. No optional reference parameter — OTr is a drop-in replacement, nothing more.

**10.3 — `OTr_GetObject` return type.** **Decision:** Copy the embedded object into a new registry slot and return the new handle (Integer). Matches legacy `OT GetObject` semantics exactly. The caller is responsible for calling `OTr_Clear` on the returned handle.

**10.4 — Lock reentrancy.** **Decision:** Simple, non-reentrant locking. A single `Semaphore` / `CLEAR SEMAPHORE` pair with no lock counter. The core rule is: **never call a lock-acquiring method while the lock is already held** — doing so will deadlock. In practice this means public `OTr_` methods acquire the lock, delegate only to `OTr__` internal helpers (which do not lock), then release the lock before doing any further work. A public method *may* call another public method provided the lock has been fully released first — the safe pattern is: acquire → snapshot with `OB Copy` → release → then call other methods freely. Mutation methods (those that write to the registry) should never call other public methods from within a locked section.

**10.5 — Import/Export format.** **Decision:** JSON-based format with bundled binaries. `OTr_ObjectToBLOB` serialises the object to JSON (wrapper sub-objects are preserved), then appends referenced BLOBs and Pictures from the parallel arrays with an index table. Not compatible with the legacy OT binary format (reverse-engineering the proprietary format is impractical).

**10.6 — Tail-trimming on Clear.** **Decision:** Hybrid approach. On `OTr_Clear($handle)`: (a) scan the object for BLOB/Picture wrapper references and release those slots immediately (zero out data, mark `InUse` as `False`); (b) set the object slot to empty and mark `InUse` as `False`; (c) if the cleared slot is at the tail of the arrays, trim consecutive trailing unused slots from all arrays. Mid-array slots are left for reuse.

**10.7 — Deprecated `OT GetBLOB` retention.** **Decision:** Implement `OTr_GetBLOB` as a stub that fires a deprecation warning via the error handler, then delegates to `OTr_GetNewBLOB` and assigns the result to the out parameter.

**10.8 — Time storage.** **Decision:** Store as plain formatted text string `"HH:MM:SS"`. Consistent with Date storage (§10.10). The typed getter `OTr_GetTime` parses the string back to a Time value.

**10.9 — Bracket notation `[x]`.** **Decision:** Not implemented. OTr is a drop-in replacement for the legacy ObjectTools API — no extensions. `OTr__ResolvePath` handles dot-separated paths only.

**10.10 — Date storage format.** **Decision:** Store as plain formatted text string `"YYYY-MM-DD"`. Consistent with OBJ_Module's approach and with Time storage (§10.8). The typed getter `OTr_GetDate` parses the string back to a Date value.

---

## 11. Testing Strategy

A comprehensive unit test suite is **required** and must be maintained alongside the implementation. All test methods use the `Test_OTr_` prefix, are marked `"invisible":true` and `"shared":false`, and follow the coding standard defined in `4D-Method-Writing-Guide.md`.

### 11.1 Test Method Organisation

Tests are grouped by functional area, with one or more test methods per group:

| Test Method | Covers |
|---|---|
| `Test_OTr_Creation` | `OTr_New`, `OTr_Clear`, `OTr_ClearAll`, `OTr_Copy`; handle allocation, slot reuse, deallocation, deep copy fidelity |
| `Test_OTr_PutGetScalar` | All scalar put/get pairs: Long, Real, String, Text, Date, Time, Boolean |
| `Test_OTr_PutGetComplex` | Object (embedded), BLOB, Picture, Pointer, Record, Variable |
| `Test_OTr_DotPath` | Dotted-path navigation, AutoCreateObjects, intermediate object creation, multi-level nesting |
| `Test_OTr_Arrays` | `OTr_PutArray`, `OTr_GetArray`, all typed `PutArray*`/`GetArray*` methods, 1-based to 0-based index mapping |
| `Test_OTr_ArrayUtils` | `OTr_SizeOfArray`, `OTr_ResizeArray`, `OTr_InsertElement`, `OTr_DeleteElement`, `OTr_FindInArray`, `OTr_SortArrays` |
| `Test_OTr_ItemInfo` | `OTr_ItemExists`, `OTr_ItemType`, `OTr_IsEmbedded`, `OTr_ItemCount`, `OTr_ObjectSize`, all `GetProperties` variants |
| `Test_OTr_ItemUtils` | `OTr_CopyItem`, `OTr_CompareItems`, `OTr_RenameItem`, `OTr_DeleteItem` |
| `Test_OTr_ImportExport` | `OTr_ObjectToBLOB`, `OTr_ObjectToNewBLOB`, `OTr_BLOBToObject`; round-trip fidelity for all stored types |
| `Test_OTr_Options` | `OTr_GetOptions`, `OTr_SetOptions`; FailOnItemNotFound, AutoCreateObjects, VariantItems behaviour |
| `Test_OTr_ErrorHandler` | `OTr_SetErrorHandler`; error handler invocation, chaining, invalid handle errors |
| `Test_OTr_Utilities` | `OTr_GetVersion`, `OTr_Register`, `OTr_CompiledApplication`, `OTr_GetHandleList`, `OTr_IsObject` |
| `Test_OTr_All` | Runner method that calls all individual test methods and reports aggregate pass/fail |

### 11.2 Test Requirements

Each test method must verify:

- **Round-trip fidelity:** Values stored via `Put` methods must be retrieved identically via the corresponding `Get` methods, for every supported type.
- **Dot-path navigation:** Multi-level dotted paths (e.g., `"a.b.c.d"`) must correctly create and navigate nested objects.
- **AutoCreateObjects:** Setting a value on a non-existent dotted path must auto-create intermediate objects when the option is enabled, and must fail or return an error when it is disabled.
- **Handle lifecycle:** Handles returned by `OTr_New` must be valid, handles passed to `OTr_Clear` must become invalid, and cleared slots must be reused by subsequent `OTr_New` calls.
- **Edge cases:** Invalid handles (0, negative, out of bounds, already cleared), empty tags, non-existent tags (with and without FailOnItemNotFound), type mismatches.
- **Array index mapping:** Callers use 1-based indices; internal Collections are 0-based. Verify correct mapping at boundaries (first element, last element, out-of-bounds).
- **Import/export round-trip:** An object serialised to BLOB and deserialised back must be identical to the original for all stored types.
- **Backward compatibility:** Where the legacy ObjectTools plugin is available in the same database, OTr results should match OT results for identical operations. This is a validation test, not a hard dependency.

### 11.3 Test Output

Test methods should use `ASSERT` (where available) or a simple pass/fail accumulator pattern. `Test_OTr_All` should output a summary indicating the total number of tests, passes, and failures, suitable for display in the 4D debugger or log.

---

## 12. Migration Guide (Summary)

For existing codebases migrating from ObjectTools to OTr:

1. **Find and replace** `OT ` with `OTr_` in all method calls (noting the space-to-underscore change).
2. **Remove** calls to `OT Register` (or leave them — `OTr_Register` is a no-op).
3. **Review** any code that relies on the binary BLOB format from `OT ObjectToBLOB`, as the OTr serialisation format may differ.
4. **Review** `OT PutObject` / `OT GetObject` usage for copy-vs-reference semantics (pending design decision §10.2).
5. **Verify** that all `OT Clear` calls are matched — the same memory management discipline applies.

---

## 13. Reference Materials

| Document | Location | Purpose |
|---|---|---|
| ObjectTools 5 Reference | `/LegacyDocumentation/ObjectTools 5 Reference.pdf` | Complete legacy API specification (116 pages) |
| 4D Method Writing Guide | `/4D-Method-Writing-Guide.md` | Coding standard for all OTr methods |
| Fnd_Dict Library | `/Fnd_Dict/` | Structural template — handle-based registry with semaphore locking |
| OBJ_Module (Cannon Smith) | `https://github.com/cannonsmith/OBJ_Module.git` | Native 4D object utilities — dot-path resolution, base64 blob/picture, array handling, record conversion, deep comparison. Key methods: `OBJP_GetSubObject` (path resolver), `OBJ_Set_Blob`/`OBJ_Set_Picture` (base64 encoding), `OBJ_Set_Object` (copy vs reference), `OBJ_Set_Array` (type-aware array storage), `OBJ_FromRecord`/`OBJ_ToRecord` (record serialisation), `OBJ_IsEqual` (deep comparison) |
