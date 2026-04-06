# OTr Phase 2: Scalar Put/Get and Basic Object Navigation

**Version:** 1.0
**Date:** 2026-04-07
**Status:** Complete
**Scope:** Fundamental data storage and retrieval; dotted-path object navigation; type conversions

---

## Overview

Phase 2 implements the core put/get methods for scalar types and embedded objects. This is the workhorse of the OTr API, enabling applications to populate objects with strongly-typed values, retrieve them, and navigate nested object hierarchies via dotted-path syntax.

The phase covers:
- **Scalar put/get pairs** for all basic 4D types (Long, Real, String, Text, Date, Time, Boolean)
- **Object put/get** for embedding and retrieving nested objects
- **Dotted-path navigation** for accessing deeply nested properties (e.g., `"a.b.c.d"`)
- **AutoCreateObjects option** to automatically create intermediate objects on missing paths
- **Type defaults** for missing values (0 for numbers, empty string for text, etc.)

---

## Commands Implemented

### Scalar Put Methods

| Legacy Command | OTr Method | Stores | Notes |
|---|---|---|---|
| `OT PutLong` | `OTr_PutLong` | Integer (native) | Direct `OB SET` with Integer value |
| `OT PutReal` | `OTr_PutReal` | Real (native) | Direct `OB SET` with Real value |
| `OT PutString` | `OTr_PutString` | Text (native) | Direct `OB SET` with Text value |
| `OT PutText` | `OTr_PutText` | Text (native) | Identical to PutString (legacy compat) |
| `OT PutDate` | `OTr_PutDate` | Date (native) | Direct `OB SET` with Date value |
| `OT PutTime` | `OTr_PutTime` | Time (native) | Direct `OB SET` with Time value |
| `OT PutBoolean` | `OTr_PutBoolean` | Boolean (native) | Direct `OB SET` with Boolean value |

### Scalar Get Methods

| Legacy Command | OTr Method | Returns | Notes |
|---|---|---|---|
| `OT GetLong` | `OTr_GetLong` | Integer | `OB Get` with type coercion; default 0 |
| `OT GetReal` | `OTr_GetReal` | Real | `OB Get` with type coercion; default 0.0 |
| `OT GetString` | `OTr_GetString` | Text | `OB Get` returning Text; default "" |
| `OT GetText` | `OTr_GetText` | Text | Identical to GetString (legacy compat) |
| `OT GetDate` | `OTr_GetDate` | Date | `OB Get` returning Date; default !00-00-00! |
| `OT GetTime` | `OTr_GetTime` | Time | `OB Get` returning Time; default ?00:00:00? |
| `OT GetBoolean` | `OTr_GetBoolean` | Integer | `OB Get` returning Integer (0 or 1); default 0 |

### Object Put/Get

| Command | Method | Purpose | Notes |
|---|---|---|---|
| `OT PutObject` | `OTr_PutObject` | Embed or reference object | Store handle reference; see deep-copy semantics below |
| `OT GetObject` | `OTr_GetObject` | Retrieve nested object | Return new handle to embedded object; see deep-copy semantics below |

---

## Method Specifications

### Generic Scalar Put

```4d
#DECLARE ($hObject_i : Integer; $ItemPath_t : Text; $Value : [TypeName])
```

**Input:**
- `$hObject_i`: Handle to target object
- `$ItemPath_t`: Tag or dotted path (e.g., `"name"` or `"user.profile.name"`)
- `$Value`: Value to store (type-specific)

**Behaviour:**
1. Validate handle; fail if invalid
2. Resolve dotted path: navigate/create nested objects as needed (see Path Resolution below)
3. Set the property at the final path using `OB SET($targetObject; $finalKey; $value)`
4. Return (no return value)

**Dotted-Path Behaviour:**
- `"name"` → set top-level property `name`
- `"user.profile.name"` → navigate to `obj.user.profile`, then set `name`
- If intermediate path does not exist:
  - If `AutoCreateObjects` option is **On** (default): create intermediate nested objects automatically
  - If `AutoCreateObjects` option is **Off**: fail or invoke error handler

### Generic Scalar Get

```4d
#DECLARE ($hObject_i : Integer; $ItemPath_t : Text) -> $Value : [TypeName]
```

**Input:**
- `$hObject_i`: Handle to source object
- `$ItemPath_t`: Tag or dotted path (e.g., `"name"` or `"user.profile.name"`)

**Output:**
- Value at path, coerced to target type; or type-specific default if missing

**Behaviour:**
1. Validate handle; if invalid, return type default
2. Resolve dotted path (see Path Resolution below)
3. If property exists at final path: retrieve via `OB Get($targetObject; $finalKey)` and coerce to target type
4. If property does not exist:
   - If `FailOnItemNotFound` option is **On**: invoke error handler; return type default
   - If `FailOnItemNotFound` option is **Off** (default): silently return type default
5. Return result

**Type Defaults:**
| Type | Default | Notes |
|------|---------|-------|
| Integer | `0` | |
| Real | `0.0` | |
| Text | `""` | Empty string |
| Date | `!00-00-00!` | Undefined date |
| Time | `?00:00:00?` | 00:00:00 |
| Boolean | `0` | Equivalent to False |

### Object Put/Get with Deep-Copy Semantics

#### `OTr_PutObject`

```4d
#DECLARE ($hObject_i : Integer; $ItemPath_t : Text; $hEmbeddedObject_i : Integer)
```

**Behaviour:**
1. Validate both handles
2. Resolve dotted path in target object
3. **Create a deep copy** of the embedded object
4. Store the copy as a native 4D Object property at the target path
5. The embedded object handle remains valid and independent

**Deep-Copy Semantics:**
- When `OTr_PutObject` is called, the source object is **copied** (not referenced)
- Subsequent modifications to the source object do **not** affect the stored copy
- Subsequent modifications to the stored copy do **not** affect the source object
- This preserves object independence and prevents unintended cross-references

#### `OTr_GetObject`

```4d
#DECLARE ($hObject_i : Integer; $ItemPath_t : Text) -> $hEmbeddedObject_i : Integer
```

**Behaviour:**
1. Validate source handle
2. Resolve dotted path
3. If property at final path is a native Object:
   - **Create a deep copy** of the nested object
   - Allocate a new handle via `OTr_New`
   - Store the copy in the new handle's slot
   - Return new handle
4. If property is not an Object or does not exist: return 0 or invoke error handler

**Deep-Copy Semantics:**
- When `OTr_GetObject` is called, the nested object is **copied** to a new handle
- The returned handle is independent and can be modified without affecting the original
- When done with the retrieved object, caller should invoke `OTr_Clear` to deallocate its handle

---

## Path Resolution

Both put and get methods support **dotted paths** for navigation and creation of nested objects.

### Single-Level Paths

```4d
OTr_PutLong($h; "name"; 42)
// Sets $h.name = 42
```

### Dotted Paths

```4d
OTr_PutLong($h; "user.profile.age"; 30)
// Sets $h.user.profile.age = 30
// Creates $h.user and $h.user.profile if they don't exist (if AutoCreateObjects is On)
```

### Algorithm (Simplified)

```
Input: $hObject, $dotted_path (e.g., "a.b.c")
1. Split path into components: ["a", "b", "c"]
2. Start at $hObject
3. For each component except the last:
   - If property exists and is an Object: navigate into it
   - If property does not exist:
     - If AutoCreateObjects is On: create new Object property; navigate into it
     - If AutoCreateObjects is Off: fail or error
4. At final component: set/get the value
```

### Missing Intermediate Objects

| Scenario | AutoCreateObjects=On | AutoCreateObjects=Off |
|---|---|---|
| Set value on missing path | Create all intermediate objects; set value | Fail or error |
| Get value on missing path | Return default (intermediate objects don't exist for Get) | Return default |

---

## Examples

### Basic Scalar Put/Get

```4d
$h := OTr_New

// Put scalars
OTr_PutLong($h; "id"; 123)
OTr_PutText($h; "name"; "Alice")
OTr_PutDate($h; "birthDate"; Date("2000-01-01"))
OTr_PutBoolean($h; "active"; True)

// Get scalars
$id := OTr_GetLong($h; "id")              // 123
$name := OTr_GetText($h; "name")          // "Alice"
$born := OTr_GetDate($h; "birthDate")     // 2000-01-01
$active := OTr_GetBoolean($h; "active")   // 1
```

### Dotted-Path Navigation

```4d
$h := OTr_New
OTr_SetOptions(4)  // AutoCreateObjects = On (bit 2)

// Set nested value; intermediate objects auto-created
OTr_PutText($h; "user.profile.contact.email"; "alice@example.com")

// Retrieve from nested path
$email := OTr_GetText($h; "user.profile.contact.email")  // "alice@example.com"

// Missing deep path returns default
$missing := OTr_GetText($h; "user.profile.contact.phone")  // ""
```

### Object Embedding

```4d
$hParent := OTr_New
$hChild := OTr_New

OTr_PutText($hChild; "name"; "ChildObject")
OTr_PutLong($hChild; "value"; 42)

// Embed child into parent (deep copy)
OTr_PutObject($hParent; "child"; $hChild)

// Retrieve as new handle (deep copy)
$hRetrieved := OTr_GetObject($hParent; "child")

// Modify retrieved copy
OTr_PutText($hRetrieved; "name"; "Modified")

// Original child is unchanged
$originalName := OTr_GetText($hChild; "name")  // "ChildObject"

// Parent's stored copy is also unchanged (independent copy)
$storedName := OTr_GetText($hParent; "child.name")  // "ChildObject"
```

### Type Coercion & Defaults

```4d
$h := OTr_New
OTr_PutText($h; "value"; "42")

// Get as integer (coerce text "42" to integer 42)
$int := OTr_GetLong($h; "value")    // 42

// Get missing value (returns default)
$missing := OTr_GetLong($h; "missing")  // 0
$text := OTr_GetText($h; "missing")     // ""
```

---

## Options Affecting Phase 2

| Option | Default | Effect |
|---|---|---|
| `AutoCreateObjects` | **On** | Create intermediate objects on dotted paths; if Off, fail on missing path |
| `FailOnItemNotFound` | Off | If On, invoke error handler when getting a missing property; otherwise return default |

---

## Error Handling

- **Invalid handle**: Fail silently or invoke error handler
- **Missing path with AutoCreateObjects=Off (Put)**: Invoke error handler or fail
- **Missing path with FailOnItemNotFound=On (Get)**: Invoke error handler; return type default
- **Type mismatch on retrieval**: Attempt coercion; return default if not coercible

---

## Test Coverage

See `____Test_Phase_2.4dm` for unit tests covering:

- Scalar put/get pairs (Long, Real, String, Text, Date, Time, Boolean)
- Round-trip fidelity (value stored via Put = value retrieved via Get)
- Object put/get with deep-copy verification
- Dotted-path navigation and intermediate object creation
- Missing value defaults
- FailOnItemNotFound and AutoCreateObjects options

---

## Dependencies

- 4D v19 LTS or later
- Phase 1 (handle management, initialisation)

---

## Next Steps

- **Phase 3** adds object inspection and item utilities (ItemExists, ItemType, ItemCount, etc.)
- **Phase 4** adds array storage and manipulation
- **Phase 5** adds complex types (BLOB, Picture, Pointer, Record, Variable)
