# OTr Phase 8 — Unified Array Element Accessor: Detailed Specification

**Version:** 0.1
**Date:** 2026-04-04
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md)

---

## Overview

Phase 8 is a **refactoring phase** with no change to the public API. Its purpose is to eliminate the structural duplication between `OTr_uGetArrayElement` and `OTr_uPutArrayElement` by replacing them with a single unified internal method, `OTr_u_AccessArrayElement`, parameterised by a direction constant.

This change has no effect on any public API method or its callers. All `OTr_GetArrayXXX` and `OTr_PutArrayXXX` methods continue to work identically from the perspective of calling code.

Phase 8 is self-contained and has no dependency on the broader architectural changes described in [OTr-Phase-100-Spec.md](OTr-Phase-100-Spec.md). It may be implemented prior to the initial release.

---

## 1. Motivation

### 1.1 The Duplication Problem

`OTr_uGetArrayElement` and `OTr_uPutArrayElement` are structurally identical. Comparing the two methods line by line, the only material difference is the direction of a single assignment on the innermost line:

| Method | Assignment |
|---|---|
| `OTr_uGetArrayElement` | `$io_ArrayElement_ptr->  :=  $ItemVariable_ptr->{$inIndex_i}` |
| `OTr_uPutArrayElement` | `$ItemVariable_ptr->{$inIndex_i}  :=  $io_ArrayElement_ptr->` |

Every other line — object pointer resolution, item existence check, type check, bounds check, and all error paths — is verbatim identical. This duplication creates two concrete risks:

- A bug fix or behavioural change to the traversal logic must be applied in two places. If applied to only one, the methods silently diverge.
- This divergence has already occurred: the comment on line 22 of `OTr_uPutArrayElement` reads *"This method is called by OTX GetArray[TYPE]"* — a copy-paste artefact from `OTr_uGetArrayElement`.

### 1.2 The Solution

Replace both methods with a single `OTr_u_AccessArrayElement` method that accepts a `$inMode_i` parameter. The mode parameter takes one of two named constants (defined in the `OTr Access Mode` constant theme) indicating Get or Put direction. The outer type-specific methods pass the appropriate constant and are otherwise unchanged.

---

## 2. New Constant Theme: OTr Array Access Mode

A new constant theme `OTr Array Access Mode` is added to the XLF resource file.

| Constant Name | Value | Meaning |
|---|---|---|
| `OTR Get Element` | `1` | Read from array into the caller's variable |
| `OTR Put Element` | `2` | Write from the caller's variable into the array |

These constants are internal to the component. They are not part of the public API and must not appear in the `%attributes` shared section of any public method.

---

## 3. Method Changes

### 3.1 New Method: `OTr_u_AccessArrayElement`

**Replaces:** `OTr_uGetArrayElement` and `OTr_uPutArrayElement`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer; $inArrayType_i : Integer; $inMode_i : Integer; $io_ArrayElement_ptr : Pointer)
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `$inObject_i` | Integer | OTr object handle |
| `$inTag_t` | Text | Tag path to the array item |
| `$inIndex_i` | Integer | 1-based element index |
| `$inArrayType_i` | Integer | Expected OT array type constant |
| `$inMode_i` | Integer | `OTR Get Element` or `OTR Put Element` |
| `$io_ArrayElement_ptr` | Pointer | For Get: receives the value. For Put: supplies the value. |

**Returns:** Nothing. Sets `OK` to `0` on any failure.

**Behaviour:**

1. Resolve the object pointer via `OTr_uGetObjectPointer`. If `OK` is not `1` after this call, exit immediately.
2. Locate the item position via `OTr_uGetItemPosition`. If the item does not exist (`$ItemPosition_i = -1`), set `OK` to `0` and exit.
3. Retrieve the stored type for the item. If it does not match `$inArrayType_i`, set `OK` to `0` and exit.
4. Retrieve the pointer to the array variable. If `Size of array($ItemVariable_ptr->)` is less than `$inIndex_i`, set `OK` to `0` and exit.
5. Branch on `$inMode_i`:
   - `OTR Get Element`: `$io_ArrayElement_ptr-> := $ItemVariable_ptr->{$inIndex_i}`
   - `OTR Put Element`: `$ItemVariable_ptr->{$inIndex_i} := $io_ArrayElement_ptr->`
   - Any other value: set `OK` to `0` and exit. This branch must exist explicitly.
6. All exit paths — including all error paths — must be audited to ensure `OK` is in the correct state before the method returns. No early return is permitted that bypasses the final state of `OK`.

**Header block:**

```4d
//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_u_AccessArrayElement (inObject; inTag; inIndex; inArrayType; inMode; io_ArrayElement)

// Unified internal accessor for array element read and write operations.
// Called by all OTr_GetArrayXXX and OTr_PutArrayXXX methods.
// inMode must be OTR Get Element or OTR Put Element.

// Access: Private

// Parameters:
//   $inObject_i          : Integer : OTr object handle
//   $inTag_t             : Text    : Tag path to the array item (inTag)
//   $inIndex_i           : Integer : 1-based element index (inIndex)
//   $inArrayType_i       : Integer : Expected OT array type constant
//   $inMode_i            : Integer : OTR Get Element or OTR Put Element
//   $io_ArrayElement_ptr : Pointer : Value pointer — out for Get, in for Put

// Returns: Nothing. Sets OK to 0 on any failure.


// Created by Wayne Stewart, 2026-04-04
// ----------------------------------------------------
```

---

### 3.2 Changes to `OTr_GetArrayXXX` Methods

Each type-specific Get method currently calls `OTr_uGetArrayElement`. This call is replaced with a call to `OTr_u_AccessArrayElement`, passing `OTR Get Element` as `$inMode_i`. No other change is required.

**Before:**
```4d
OTr_uGetArrayElement($inObject_i; $inTag_t; $inIndex_i; $MethodItemType_i; ->$result_i)
```

**After:**
```4d
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; $MethodItemType_i; OTR Get Element; ->$result_i)
```

Affected methods:

| Method | Array Type Constant |
|---|---|
| `OTr_GetArrayLong` | `LongInt array` |
| `OTr_GetArrayReal` | `Real array` |
| `OTr_GetArrayString` | `String array` |
| `OTr_GetArrayText` | `Text array` |
| `OTr_GetArrayDate` | `Date array` |
| `OTr_GetArrayTime` | `Time array` |
| `OTr_GetArrayBoolean` | `Boolean array` |
| `OTr_GetArrayBLOB` | `BLOB array` |
| `OTr_GetArrayPicture` | `Picture array` |
| `OTr_GetArrayPointer` | `Pointer array` |

---

### 3.3 Changes to `OTr_PutArrayXXX` Methods

Each type-specific Put method currently calls `OTr_uPutArrayElement`. This call is replaced with a call to `OTr_u_AccessArrayElement`, passing `OTR Put Element` as `$inMode_i`. No other change is required.

**Before:**
```4d
OTr_uPutArrayElement($inObject_i; $inTag_t; $inIndex_i; $MethodItemType_i; ->$inValue_i)
```

**After:**
```4d
OTr_u_AccessArrayElement($inObject_i; $inTag_t; $inIndex_i; $MethodItemType_i; OTR Put Element; ->$inValue_i)
```

Affected methods:

| Method | Array Type Constant |
|---|---|
| `OTr_PutArrayLong` | `LongInt array` |
| `OTr_PutArrayReal` | `Real array` |
| `OTr_PutArrayString` | `String array` |
| `OTr_PutArrayText` | `Text array` |
| `OTr_PutArrayDate` | `Date array` |
| `OTr_PutArrayTime` | `Time array` |
| `OTr_PutArrayBoolean` | `Boolean array` |
| `OTr_PutArrayBLOB` | `BLOB array` |
| `OTr_PutArrayPicture` | `Picture array` |
| `OTr_PutArrayPointer` | `Pointer array` |

---

### 3.4 Retirement of `OTr_uGetArrayElement` and `OTr_uPutArrayElement`

Once all callers have been updated to use `OTr_u_AccessArrayElement`, the two original methods are deleted from the project. They must not be retained as stubs or wrappers, as doing so would reintroduce the duplication this phase is intended to eliminate.

---

## 4. XLF Resource Changes

`Resources/OTr.xlf` gains a new constant theme:

```xml
<group resname="themes">
    ...
    <trans-unit id="thm_N" resname="[GUID]" translate="no">
        <source>OTr Access Mode</source>
    </trans-unit>
</group>
<group d4:groupName="[GUID]" restype="x-4DK#">
    <trans-unit d4:value="1:L" id="k_N">
        <source>OTR Get Element</source>
    </trans-unit>
    <trans-unit d4:value="2:L" id="k_N+1">
        <source>OTR Put Element</source>
    </trans-unit>
</group>
```

The GUID and sequential `id` values are assigned by the 4D IDE when the constants are created via the Constant Editor.

---

## 5. Testing

Phase 8 introduces no change to observable behaviour. The existing Phase 4 test method (`____Test_Phase_4`) constitutes the acceptance test for this phase. All array Get and Put round-trips that passed before Phase 8 must continue to pass without modification to the test method itself.

A specific regression check should confirm:

- `OK` is `1` after a successful Get via `OTr_u_AccessArrayElement`.
- `OK` is `1` after a successful Put via `OTr_u_AccessArrayElement`.
- `OK` is `0` when an invalid mode value (e.g., `0` or `99`) is passed.
- `OK` is `0` on type mismatch, as before.
- `OK` is `0` on out-of-bounds index, as before.

---

## 6. Relationship to Phase 100

Phase 8 establishes the unified `OTr_u_AccessArrayElement` method as the single point of array element access. Phase 100 will subsequently introduce a three-layer architecture with per-mechanism routing and reentrant locking. The unified method created in Phase 8 becomes the direct predecessor to the Inner layer defined in Phase 100, making the Phase 100 migration substantially simpler than it would otherwise be.

See [OTr-Phase-100-Spec.md](OTr-Phase-100-Spec.md).
