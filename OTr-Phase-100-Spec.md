# OTr Phase 100 — Dual Storage Mechanism and Three-Layer Architecture: Detailed Specification

**Version:** 0.1
**Date:** 2026-04-04
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md)
**Predecessor Phase:** [OTr-Phase-008-Spec.md](OTr-Phase-008-Spec.md)

---

## Overview

Phase 100 is a **major architectural evolution**. It introduces:

1. A **dual storage mechanism** — the existing interprocess (IP) array model and a new Storage/Shared Object model — selectable at initialisation time via a mechanism flag.
2. A **three-layer method architecture** for all array accessors, cleanly separating public API, type dispatch, and locked storage operations.
3. A **reentrant per-process lock counter** to prevent nested semaphore deadlocks.
4. **Per-group semaphores** replacing the current single global semaphore, reducing unnecessary cross-object contention.
5. A **`OTs` namespace** for all Storage-mechanism-specific internal methods.

This phase is explicitly **deferred until after the initial release**. Nothing in Phases 1–15 depends on it. It is documented now to capture the architectural reasoning whilst it is current, and to ensure that code written in earlier phases does not inadvertently foreclose the options described here.

---

## 1. Background and Motivation

### 1.1 The IP Array Model

The current OTr implementation stores objects in paired interprocess arrays (`<>OTR_Objects_ao`, `<>OTR_InUse_ab`, etc.). This model has served well and remains the default mechanism. It is fast — array element access is essentially a pointer dereference with an index offset — and well-understood.

Its principal limitations are:

- It is not compatible with 4D's preemptive process model, which requires shared objects rather than interprocess variables.
- Locking is currently handled by a single global semaphore (`"$OTr_Registry"`), which serialises all access across all objects regardless of whether those operations have any data dependency.

### 1.2 The Storage/Shared Object Model

4D v17+ provides `Storage`, shared objects (`New shared object`), and shared collections (`New shared collection`) as a native mechanism for inter-process data sharing that is compatible with preemptive processes. Phase 100 introduces this as an alternative internal storage model, selectable at initialisation time.

The Storage model introduces its own constraints (no Pictures, no Pointers, no BLOBs directly; all numeric values stored as Real; no interprocess variable semantics) that require encoding adaptations for certain types. These are handled at the Outer layer (see §3).

### 1.3 Coexistence

Both mechanisms coexist in the same component. The mechanism in use is determined once, at initialisation, by the value of `Storage.OTr.mechanism`. Callers — all public API methods — are entirely unaffected by which mechanism is active.

---

## 2. Configuration: `Storage.OTr.mechanism`

### 2.1 Location and Initialisation

The mechanism flag is stored as a numeric property on the `Storage.OTr` shared object, which is created by `OTr_zInit` (or `OTr_z_Init` once the naming convention is updated). It is initialised once and treated as read-only for the lifetime of the process.

```4d
Storage.OTr.mechanism  //  Integer — see OTr Storage Mechanism constants
```

### 2.2 Constants

Defined in `Resources/OTr.xlf` under the `OTr Storage Mechanism` theme (already present):

| Constant | Value | Meaning |
|---|---|---|
| `OTR IP Arrays` | `1` | Interprocess array storage (default) |
| `OTR Storage` | `2` | Shared object / Storage-based storage |

The integer type (rather than Boolean) deliberately accommodates a theoretical third mechanism in future without any change to the flag's type or storage location.

### 2.3 Reading the Flag

Because `Storage.OTr` is a shared object, and because reads of shared object properties do not require a `Use...End use` block, any process may read `Storage.OTr.mechanism` at any time without locking overhead. The value is guaranteed stable after `OTr_zInit` completes.

---

## 3. Three-Layer Architecture

All array accessor operations are decomposed into three layers. The same pattern applies to both storage mechanisms; the mechanism-specific code is confined entirely to the Inner layer.

### 3.1 Outer Layer — Public API (unchanged signatures)

**Examples:** `OTr_GetArrayLong`, `OTr_PutArrayLong`, and all other `OTr_GetArrayXXX` / `OTr_PutArrayXXX` methods.

**Responsibilities:**

- Call `OTr_zInit` (lazy initialisation guard).
- Bind the type constant for the specific type (e.g., `LongInt array`).
- For Picture and BLOB types only: perform base64 encoding (Put) or decoding (Get) as required by the active storage mechanism. The `Storage.OTr.nativeBlobInObject` flag (set during `OTr_zInit` based on the 4D version) determines whether BLOB encoding is necessary under the Storage mechanism.
- Call the Middle layer, passing all parameters plus the type constant and direction constant.
- Return the result to the caller.

The Outer layer has no knowledge of locking, storage layout, or semaphore names. It is the sole layer that performs type-specific encoding.

### 3.2 Middle Layer — Type Dispatch and Validation

**Method:** `OTr_u_AccessArrayElement` (as introduced in Phase 8, extended here).

**Responsibilities:**

- Validate that `$inMode_i` is a recognised constant (`OTR Get Element` or `OTR Put Element`). Set `OK` to `0` and exit on any unrecognised value.
- Read `Storage.OTr.mechanism` to determine which Inner layer method to call.
- Call the appropriate Inner layer method, passing all parameters including mode and type constant.
- Propagate `OK` back to the caller unchanged.

The Middle layer has no knowledge of locking. It does not itself touch any shared or interprocess data. It is the routing layer.

### 3.3 Inner Layer — Locked Storage Operations

Two Inner layer methods are provided, one per mechanism:

| Method | Mechanism |
|---|---|
| `OTr_u_IPArrayAccess` | `OTR IP Arrays` |
| `OTs_u_StorageAccess` | `OTR Storage` |

**Responsibilities (common to both):**

1. Acquire the reentrant lock (see §4) for the relevant semaphore group (see §5).
2. Locate the item within the storage structure.
3. Verify the item exists. Set `OK` to `0` and proceed to step 7 if not.
4. Verify the item type matches `$inArrayType_i`. Set `OK` to `0` and proceed to step 7 if not.
5. Verify the index is within bounds. Set `OK` to `0` and proceed to step 7 if not.
6. Perform the read or write assignment (branch on `$inMode_i`).
7. Release the reentrant lock unconditionally.

**Critical constraint:** The Inner layer must not call any other method whilst the lock is held, unless that method is guaranteed never to attempt to acquire the same semaphore. All validation and assignment logic is self-contained within the Inner layer. No outward method calls occur inside the critical section.

**Error path discipline:** Every code path through the Inner layer — including all `Else` branches and all early exits — must reach step 7 (lock release) before the method returns. No path may exit without releasing the lock.

---

## 4. Reentrant Lock Counter

### 4.1 Problem

4D's `Semaphore` command is not reentrant. If a process attempts to acquire a semaphore it already holds, the behaviour is undefined (deadlock or silent failure, depending on context). This risk is real when the Inner layer is called from within a context that has already acquired the semaphore — for example, during a compound operation implemented at a higher layer.

### 4.2 Solution: Per-Process Lock Depth Counter

A process variable `<OTr_LockDepth_ai>` (an array of Integers, indexed by semaphore group number — see §5) tracks the current lock depth for each group in the current process.

**Lock procedure (`OTr_u_Lock`):**

1. Increment `<OTr_LockDepth_ai>{$groupIndex_i}`.
2. If the counter is now exactly `1` (first acquisition): call `WAIT FOR SEMAPHORE` to acquire the semaphore.
3. If the counter is greater than `1` (reentrant acquisition): do nothing further. The semaphore is already held by this process.

**Unlock procedure (`OTr_u_Unlock`):**

1. Decrement `<OTr_LockDepth_ai>{$groupIndex_i}`.
2. If the counter is now `0`: call `CLEAR SEMAPHORE` to release the semaphore.
3. If the counter is still positive: do nothing further. Other nested acquisitions remain outstanding.

**Invariant:** The counter must never fall below zero. An unlock without a matching lock indicates a programming error. If this condition is detected, `OK` is set to `0` and an error is raised via `OTr_zSetOK`.

**Initialisation:** `<OTr_LockDepth_ai>` is initialised to an array of ten zeros in `OTr_zInit`, once per process. This occurs within the `If (Not(<>OTR_Initialised_b))` guard that already protects process-variable initialisation.

### 4.3 Applicability

The reentrant lock counter is used for **both** the IP Arrays mechanism (semaphore-based) and the Storage mechanism (which uses `Use...End use` in conjunction with the semaphore — see §4.4).

### 4.4 Storage Mechanism Locking

The `Use...End use` structure protects the internal consistency of a shared object during a write. However, the *approach* to the `Use` call — the sequence of reads and checks that precede it — is itself vulnerable to TOCTOU race conditions if two processes execute it concurrently. The semaphore guards this outer critical region, ensuring that the entire check-then-act sequence is atomic from the perspective of other processes.

The relationship is therefore: **semaphore guards the approach; `Use...End use` guards the write**. Both layers are necessary. Neither is redundant.

---

## 5. Per-Group Semaphores

### 5.1 Problem with a Single Global Semaphore

The current implementation uses a single semaphore (`"$OTr_Registry"`) for all operations across all objects. This means a write to an object in one group blocks all concurrent reads and writes to objects in all other groups, even when those operations are entirely independent.

### 5.2 Object Groups

The Storage model partitions objects into ten groups based on the trailing digit of the object handle. Objects whose handles end in `1` belong to Group 1, those ending in `2` to Group 2, and so on, with Group 0 covering handles ending in `0`.

This grouping is reflected in the `Storage` structure:

```
Storage.OTr_Group_1   //  objects with handle % 10 = 1
Storage.OTr_Group_2   //  objects with handle % 10 = 2
...
Storage.OTr_Group_0   //  objects with handle % 10 = 0
```

### 5.3 Semaphore Names

Ten group semaphores replace the single global semaphore. Their names are stored in `Storage.OTr` at initialisation time as a collection of strings, allowing them to be read without locking overhead by any process at any time.

| Group | Semaphore Name |
|---|---|
| Group 1 | `"$OTr_n1_series"` |
| Group 2 | `"$OTr_n2_series"` |
| Group 3 | `"$OTr_n3_series"` |
| Group 4 | `"$OTr_n4_series"` |
| Group 5 | `"$OTr_n5_series"` |
| Group 6 | `"$OTr_n6_series"` |
| Group 7 | `"$OTr_n7_series"` |
| Group 8 | `"$OTr_n8_series"` |
| Group 9 | `"$OTr_n9_series"` |
| Group 0 | `"$OTr_n0_series"` |

A separate semaphore, `"$OTr_controller"`, guards operations on `Storage.OTrController` (the object registry / ObjectTable). This semaphore is used exclusively by `OTr_New` and `OTr_Clear`, which are the only methods that add or remove objects from the registry.

### 5.4 Deriving the Group Index

The group index is derived from the object handle:

```4d
$groupIndex_i := ($inObject_i % 10)  //  yields 0..9
```

For the `<OTr_LockDepth_ai>` counter array, indices 1–9 correspond to Groups 1–9, and index 10 is used for Group 0 (to avoid a zero index, which would be ambiguous). Index 0 is reserved for the controller semaphore.

---

## 6. `OTs` Namespace

Internal methods specific to the Storage mechanism use the `OTs` prefix (`s` = Storage), distinct from the `OTr` prefix used for the IP Arrays mechanism and all public API methods.

| Prefix | Scope |
|---|---|
| `OTr_` | Public API; mechanism-agnostic infrastructure |
| `OTr_u_` | Internal utilities; mechanism-agnostic |
| `OTr_z_` | Lifecycle and initialisation |
| `OTs_u_` | Internal utilities specific to the Storage mechanism |

No `OTs` methods are ever marked `"shared":true`. They are entirely internal.

---

## 7. Method Naming Convention Note

This specification uses the `OTr_z_Init` style (with separator underscore before the grouping character) rather than `OTr_zInit`. The renaming of existing `OTr_z` and `OTr_u` methods is deferred to a separate housekeeping phase and is not a prerequisite for Phase 100. New methods introduced in Phase 100 use the new convention from the outset.

---

## 8. Changes to `OTr_zInit`

The following additions are made to `OTr_zInit` (within the existing `If (Storage.OTr = Null)` guard):

1. Add `semaphoreNames` as a shared collection of strings on `Storage.OTr`, populated with the ten group semaphore names in index order (index 1 = `"$OTr_n1_series"`, …, index 10 = `"$OTr_n0_series"`).
2. Add `controllerSemaphore` as a string property on `Storage.OTr`, set to `"$OTr_controller"`.

Within the `If (Not(<>OTR_Initialised_b))` guard, initialise `<OTr_LockDepth_ai>` as an Integer array of 11 elements (indices 0–10), all set to zero.

The existing `<>OTR_Semaphore_t` interprocess variable is retained for backwards compatibility during the transition but is superseded by the group semaphore collection for all new code.

---

## 9. Migration of IP Array Preferences into `Storage.OTr`

The following interprocess variables are migrated into `Storage.OTr` properties during Phase 100:

| Current Variable | New Property | Notes |
|---|---|---|
| `<>OTR_Options_i` | `Storage.OTr.options` | Integer |
| `<>OTR_ErrorHandler_t` | `Storage.OTr.errorHandler` | Text |
| `<>OTR_Semaphore_t` | `Storage.OTr.legacySemaphore` | Retained for reference; superseded by group semaphores |

After migration, the interprocess variables are retained during a transitional period to allow any external code that references them directly to continue functioning. They are marked for removal in a subsequent housekeeping phase.

---

## 10. Encoding Responsibilities for Picture and BLOB Types

Under the Storage mechanism, Pictures and BLOBs cannot be stored directly in shared objects (which do not support these types). They must be encoded before storage and decoded after retrieval.

**Encoding (Put path, Outer layer):**

- If `Storage.OTr.nativeBlobInObject` is `True` (4D v19.2+): native BLOB storage may be available; confirm against 4D documentation at time of implementation.
- If `Storage.OTr.nativeBlobInObject` is `False`: base64-encode the BLOB or Picture to a Text value before passing it to the Middle layer.

**Decoding (Get path, Outer layer):**

- Reverse of the above. Decode the Text value back to BLOB or Picture after the Middle layer returns.

**IP Arrays mechanism:** No encoding is required. BLOBs and Pictures are stored directly in the respective parallel arrays (`<>OTR_Blobs_ax`, `<>OTR_Pictures_ap`). The Outer layer performs no encoding under this mechanism.

The Outer layer determines which path to follow by reading `Storage.OTr.mechanism` once per call. This read is unguarded (no lock required).

---

## 11. Relationship to Other Phases

| Phase | Dependency |
|---|---|
| Phase 8 | **Prerequisite.** Phase 100 extends `OTr_u_AccessArrayElement` introduced in Phase 8. Phase 8 must be complete before Phase 100 begins. |
| Phases 1–7 | No dependency. Phase 100 does not affect the public API. |
| Phase 15 | Phase 100 may be implemented before or after Phase 15 (side-by-side compatibility testing). The IP Arrays mechanism is unchanged and will continue to pass Phase 15 tests. |

---

## 12. Deferred Items (Post-Phase-100)

The following items are noted for subsequent phases:

- Formal renaming of `OTr_zInit` → `OTr_z_Init` and all `OTr_z*` / `OTr_u*` methods to the separator-underscore convention.
- Removal of transitional interprocess variables (`<>OTR_Options_i`, `<>OTR_ErrorHandler_t`, `<>OTR_Semaphore_t`) once confirmed no external code references them directly.
- Performance benchmarking: IP Arrays vs Storage mechanism under representative load, to validate the assumption that IP Arrays are faster for the common case.
- Consideration of whether scalar Put/Get methods require the same three-layer decomposition, or whether the current two-layer model is sufficient for scalars given their simpler access patterns.
