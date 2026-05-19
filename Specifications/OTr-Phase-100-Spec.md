# OTr Phase 100 — Dual Storage Mechanism and Three-Layer Architecture: Detailed Specification

**Version:** 0.3
**Date:** 2026-05-19
**Status:** Future (v2.0 Roadmap) — planning thread opened 2026-05-19
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md)
**Predecessor Phase:** [OTr-Phase-008-Spec.md](OTr-Phase-008-Spec.md)

---

## Revision History


### Version: 0.1  Date: 2026-04-04 | Initial draft. 
### Version: 0.2  Date: 2026-05-19 
Reconciled with v0.5 codebase: Phase 8 confirmed shipped; mode-constant scope reduced to Middle→Inner boundary (§3.2); hybrid scalar/array lock counter per mechanism (§4); per-group lock-counter and semaphore-name collections moved to zero-based indexing aligned with trailing digit (§5.4); controller depth separated from group depth array (§4); original §10 marked **STALE** and superseded by §10A (BLOB/Picture storage in IP mode is via nested objects, not parallel arrays); dependency graph appendix added (§13). |
### Version: 0.3  Date: 2026-05-19 
W5 implemented on branch Echidna. Corrected guard-name error in §4.4 and §8 — `OTr_LockDepth_ci` and `OTr_ControllerLockDepth_i` must be initialised in the per-process `If (Not(OTR_Initialised_b))` guard, not the interprocess `If (Not(<>OTR_Initialised_b))` guard. Added §8A documenting `OTr_z_InitStorage`: `OTr_z_Init` contains non-thread-safe commands (interprocess variable writes, classic array declarations) and cannot be called from preemptive processes; a separate preemptive-capable method is required. Updated §13.1 W5 Touches. Added reconciliation rows to Appendix. |

---

## Overview

Phase 100 is a **major architectural evolution**. There are no plans to implement what is effectively version 2 of the product. It will only be implemented if there is demand from end users for a thread-safe version. The v0.5 production release has shipped; user feedback to date has been limited, partly because an updated commercial Object Tools plugin was released around the same time.

Phase 100 introduces:

1. A **dual storage mechanism** — the existing interprocess (IP) array model and a new Storage / Shared Object model — selectable at initialisation time via a mechanism flag.
2. A **three-layer method architecture** for all array accessors, cleanly separating public API, type dispatch, and locked storage operations.
3. A **per-mechanism reentrant lock counter** — the existing scalar counter is preserved for the IP Arrays mechanism; the Storage mechanism uses a per-group counter collection.
4. **Per-group semaphores** under the Storage mechanism, replacing the single global semaphore for that mechanism only.
5. An **`OTs` namespace** for all Storage-mechanism-specific internal methods.

This phase is explicitly **deferred until after the initial release**. Nothing in Phases 1–15 depends on it. It is documented now to capture the architectural reasoning while it is current and to ensure that code written in earlier phases does not inadvertently foreclose the options described here.

---

## What is Already in Place (as of v0.5)

The Phase 8 verification pass on 2026-05-19 confirmed the following infrastructure is already shipped. Phase 100 must build on it rather than replicate it.

- **Middle-layer dispatcher.** `OTr_u_AccessArrayElement` exists and is called by all 22 `OTr_GetArray*` / `OTr_PutArray*` methods. It performs type-constant binding, type-match validation, index-bounds checking, and tag resolution. It accesses IP-array storage directly (i.e. it is currently *both* Middle and Inner).
- **Mode detection.** The dispatcher uses arity (`Count parameters`) to distinguish Get (4 params) from Put (5 params). It does *not* take an `$inMode_i` parameter.
- **Reentrant locking.** `OTr_z_Lock` and `OTr_z_Unlock` exist and use a scalar process variable `OTR_LockCount_i` to track depth against a single global semaphore (`<>OTR_Semaphore_t` = `"$OTr_Registry"`).
- **Shared config object.** `OTr_z_Init` already creates `Storage.OTr` with the following properties: `mechanism` (set to `OTR IP Arrays`), `nativeBlobInObject`, `includeShadowKeys`, `loggingInitialising`, `registrationCode`, `level`.
- **Mechanism constants.** XLIFF theme `OTr Storage Mechanism` defines `OTR IP Arrays = 1` and `OTR Storage = 2`.
- **Method naming.** `OTr_z_Init` already uses the separator-underscore convention; no renaming required.

Not yet present:

- `OTs_*` namespace methods.
- `semaphoreNames`, `controllerSemaphore`, `options`, `errorHandler` properties on `Storage.OTr`.
- Per-group lock-depth collection.
- Group-by-trailing-digit infrastructure (`Storage.OTr_Group_*`).
- Object registry (`Storage.OTrController`).
- Base64 encode/decode helpers for Storage-mode BLOB/Picture handling.

---

## 1. Background and Motivation

### 1.1 The IP Array Model

The current OTr implementation stores objects in paired interprocess arrays (`<>OTR_Objects_ao`, `<>OTR_InUse_ab`). This model has served well and remains the default mechanism. It is fast — array element access is essentially a pointer dereference with an index offset — and well-understood.

Its principal limitations are:

- It is not compatible with 4D's preemptive process model, which requires shared objects rather than interprocess variables.
- Locking is currently handled by a single global semaphore (`"$OTr_Registry"`), which serialises all access across all objects regardless of whether those operations have any data dependency.

### 1.2 The Storage / Shared Object Model

4D v17+ provides `Storage`, shared objects (`New shared object`), and shared collections (`New shared collection`) as a native mechanism for inter-process data sharing that is compatible with preemptive processes. Phase 100 introduces this as an alternative internal storage model, selectable at initialisation time.

The Storage model introduces its own constraints (no Pictures, no Pointers, no BLOBs directly; all numeric values stored as Real; no interprocess variable semantics) that require encoding adaptations for certain types. These are handled at the Outer layer (see §10A).

### 1.3 Coexistence

Both mechanisms coexist in the same component. The mechanism in use is determined once, at initialisation, by the value of `Storage.OTr.mechanism`. Callers — all public API methods — are entirely unaffected by which mechanism is active.

---

## 2. Configuration: `Storage.OTr.mechanism`

### 2.1 Location and Initialisation

The mechanism flag is a numeric property on the `Storage.OTr` shared object, which is created by `OTr_z_Init`. It is initialised once and treated as read-only for the lifetime of the process.

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

Because `Storage.OTr` is a shared object, and because reads of shared object properties do not require a `Use…End use` block, any process may read `Storage.OTr.mechanism` at any time without locking overhead. The value is guaranteed stable after `OTr_z_Init` completes.

### 2.4 Storage Object Prototype (Reference)

The intended shape of the shared Storage tree after Phase 100 initialisation under `mechanism = OTR Storage`:

```json
{
  "Storage": {

    "OTr": {
      "_comment": "Config + shared metadata. Read-only after OTr_z_Init.",

      "mechanism":           2,
      "nativeBlobInObject":  true,
      "includeShadowKeys":   true,
      "loggingInitialising": false,
      "registrationCode":    "…",
      "level":               "off",

      "options":             4,
      "errorHandler":        "",
      "legacySemaphore":     "$OTr_Registry",

      "controllerSemaphore": "$OTr_controller",
      "semaphoreNames": [
        "$OTr_n0_series",
        "$OTr_n1_series",
        "$OTr_n2_series",
        "$OTr_n3_series",
        "$OTr_n4_series",
        "$OTr_n5_series",
        "$OTr_n6_series",
        "$OTr_n7_series",
        "$OTr_n8_series",
        "$OTr_n9_series"
      ]
    },

    "OTrController": {
      "_comment": "Object registry. Mutated only by OTr_New / OTr_Clear, guarded by $OTr_controller.",
      "nextHandle": 47,
      "inUse": {
        "h_11": true,
        "h_12": true,
        "h_20": true,
        "h_31": true
      }
    },

    "OTr_Group_1": {
      "_comment": "Objects whose handle % 10 == 1. Guarded by $OTr_n1_series.",
      "h_11": {
        "tags": {
          "Customer Name":  { "type": "string",        "scalar": "Acme Pty Ltd" },
          "Order Numbers":  { "type": "longInt array", "array":  [101, 102, 103] },
          "Active":         { "type": "boolean",       "scalar": true }
        }
      }
    },

    "OTr_Group_0": {
      "_comment": "Handles ending in 0 (10, 20, …). Guarded by $OTr_n0_series.",
      "h_20": { "tags": { "…": "…" } }
    }
  }
}
```

**Notes:**

1. Per-object keys are prefixed with `h_` because shared-object property keys must be Text, not Integer.
2. Tag values are wrapped in `{ "type": …, "scalar"|"array": … }` so the Inner layer can validate type matches without consulting external metadata. The `type` field stores the 4D type constant captured at first assignment.
3. BLOB and Picture array cells under the Storage mechanism are base64 strings (see §10A). The wrapper still uses `"array"` but the element type is Text.
4. Under `mechanism = OTR IP Arrays`, only `Storage.OTr` exists; the `OTr_Group_*` and `OTrController` siblings are absent and the equivalent state lives in the existing `<>OTR_*` interprocess arrays.

---

## 3. Three-Layer Architecture

All array accessor operations are decomposed into three layers. The same pattern applies to both storage mechanisms; mechanism-specific code is confined entirely to the Inner layer.

### 3.1 Outer Layer — Public API (signatures unchanged)

**Examples:** `OTr_GetArrayLong`, `OTr_PutArrayLong`, and all other `OTr_GetArrayXXX` / `OTr_PutArrayXXX` methods.

**Responsibilities:**

- Call `OTr_z_Init` (lazy initialisation guard).
- Bind the type constant for the specific type (e.g. `LongInt array`).
- For Picture and BLOB types only: perform base64 encoding (Put) or decoding (Get) when `Storage.OTr.mechanism = OTR Storage` and `Storage.OTr.nativeBlobInObject = False`. Under `OTR IP Arrays`, no encoding occurs. See §10A.
- Call the Middle layer with all parameters plus the type constant. Mode is communicated by arity (4 params Get, 5 params Put) — no change to existing call sites.
- Return the result.

The Outer layer has no knowledge of locking, storage layout, or semaphore names. It is the sole layer that performs type-specific encoding.

**Status:** Outer layer call structure already matches this spec (Phase 8). The only changes required are (a) adding the conditional base64 encoding for BLOB/Picture under Storage mode, and (b) removing the `OTr_z_Lock` / `OTr_z_Unlock` wrapper currently in place at the Outer layer once lock acquisition moves to the Inner layer (see W6 in §13).

### 3.2 Middle Layer — Mode Synthesis and Dispatch

**Method:** `OTr_u_AccessArrayElement` (extended from its Phase 8 form).

**Responsibilities:**

1. Detect mode via `Count parameters` (4 → Get, 5 → Put) as today.
2. **Synthesise** the mode constant: `$mode_i := (Count parameters = 5) ? OTR Put Element : OTR Get Element`.
3. Read `Storage.OTr.mechanism` to determine which Inner-layer method to call.
4. Call the appropriate Inner method (`OTr_u_IPArrayAccess` or `OTs_u_StorageAccess`), passing all parameters **plus the synthesised mode constant**.
5. Propagate the return value and `OK` to the caller unchanged.

The Middle layer has no knowledge of locking. It does not itself touch any shared or interprocess data. It is the routing layer.

**Note on the mode parameter.** The spec previously assumed an explicit `$inMode_i` parameter on the Middle layer. This is unnecessary and would require a breaking-change refactor of all 22 Outer-layer call sites. The Outer→Middle boundary continues to use arity detection (no change); the Middle→Inner boundary uses the explicit mode constant. This keeps the Inner layer's contract self-documenting where it matters — Inner methods cannot infer mode from arity because they receive a fixed signature regardless of how the Outer caller invoked the dispatcher.

### 3.3 Inner Layer — Locked Storage Operations

Two Inner-layer methods, one per mechanism:

| Method | Mechanism |
|---|---|
| `OTr_u_IPArrayAccess` | `OTR IP Arrays` |
| `OTs_u_StorageAccess` | `OTR Storage` |

**Responsibilities (common to both):**

1. Derive the group index from the object handle (see §5.4).
2. Acquire the reentrant lock for the relevant semaphore (see §4).
3. Locate the item within the storage structure.
4. Verify the item exists. Set `OK` to `0` and proceed to step 8 if not.
5. Verify the item type matches `$inArrayType_i`. Set `OK` to `0` and proceed to step 8 if not.
6. Verify the index is within bounds. Set `OK` to `0` and proceed to step 8 if not.
7. Perform the read or write assignment (branch on `$inMode_i`).
8. Release the reentrant lock unconditionally.

**Critical constraint:** the Inner layer must not call any other method while the lock is held, unless that method is guaranteed never to attempt to acquire the same semaphore. All validation and assignment logic is self-contained within the Inner layer.

**Error-path discipline:** every code path through the Inner layer — including all `Else` branches and all early exits — must reach step 8 (lock release) before the method returns.

**Migration note for `OTr_u_IPArrayAccess`.** This method is created by lifting the current body of `OTr_u_AccessArrayElement` out of the dispatcher, with two adjustments: (a) it receives `$inMode_i` explicitly instead of using arity, and (b) it acquires/releases the lock internally rather than relying on the Outer layer to wrap it.

---

## 4. Reentrant Lock Counter (Hybrid)

### 4.1 Problem

4D's `Semaphore` command is not reentrant. If a process attempts to acquire a semaphore it already holds, the behaviour is undefined.

### 4.2 The Hybrid Approach

Because the IP Arrays mechanism uses one global semaphore and the Storage mechanism uses ten group semaphores plus one controller semaphore, the natural shape of the lock-depth counter differs between mechanisms. Phase 100 keeps both shapes side by side and dispatches on `Storage.OTr.mechanism` inside `OTr_z_Lock` and `OTr_z_Unlock`.

| Mechanism | Counter | Shape | Purpose |
|---|---|---|---|
| `OTR IP Arrays` | `OTR_LockCount_i` | Scalar Integer (process variable) | Existing v0.5 behaviour, unchanged. |
| `OTR Storage` | `OTr_LockDepth_ci` | Collection of 10 Integers (process variable, zero-indexed) | Per-group reentrant depth. |
| `OTR Storage` | `OTr_ControllerLockDepth_i` | Scalar Integer (process variable) | Reentrant depth for the controller semaphore. |

The two `OTR Storage`-mechanism counters are **separate variables**, not slots in a unified array. This avoids reserving a special slot for the controller and keeps the group collection's indices a clean one-to-one match with the trailing-digit derivation (see §5.4).

The hybrid is deliberate: it leaves the shipped IP Arrays path bit-for-bit unchanged, eliminating regression risk, at the cost of a one-line `Case of` at the top of each lock helper.

### 4.3 Lock Procedure (`OTr_z_Lock`)

```4d
//  Pseudocode — to be expanded against current implementation.

If (Storage.OTr.mechanism = OTR IP Arrays:Knnn:m)
    //  Scalar path — exactly as today.
    OTR_LockCount_i := OTR_LockCount_i + 1
    If (OTR_LockCount_i = 1)
        Semaphore(<>OTR_Semaphore_t)
    End if
Else
    //  Storage path. $inObject_i = 0 indicates the controller.
    If ($inObject_i = 0)
        OTr_ControllerLockDepth_i := OTr_ControllerLockDepth_i + 1
        If (OTr_ControllerLockDepth_i = 1)
            Semaphore(Storage.OTr.controllerSemaphore)
        End if
    Else
        $digit_i := $inObject_i % 10  //  0..9
        OTr_LockDepth_ci[$digit_i] := OTr_LockDepth_ci[$digit_i] + 1
        If (OTr_LockDepth_ci[$digit_i] = 1)
            Semaphore(Storage.OTr.semaphoreNames[$digit_i])
        End if
    End if
End if
```

`OTr_z_Unlock` is the mirror image: decrement, and release the semaphore on transition to zero.

### 4.4 Invariant and Initialisation

The counter must never fall below zero. An unlock without a matching lock indicates a programming error; `OK` is set to `0` and an error is raised via `OTr_z_Error`.

`OTr_LockDepth_ci` is initialised in `OTr_z_Init` as a 10-element Integer collection of zeros, under the per-process `If (Not(OTR_Initialised_b))` guard (the guard that uses the process-local `OTR_Initialised_b` flag, not the interprocess `<>OTR_Initialised_b` flag). `OTr_ControllerLockDepth_i` is initialised to zero in the same block.

### 4.5 Applicability to Storage `Use…End use`

The `Use…End use` structure protects the internal consistency of a shared object during a write. However, the *approach* to the `Use` call — the sequence of reads and checks that precede it — is itself vulnerable to TOCTOU race conditions if two processes execute it concurrently. The semaphore guards this outer critical region, ensuring that the entire check-then-act sequence is atomic from the perspective of other processes.

The relationship is therefore: **semaphore guards the approach; `Use…End use` guards the write.** Both layers are necessary. Neither is redundant.

---

## 5. Per-Group Semaphores

### 5.1 Problem with a Single Global Semaphore

A single semaphore for all operations serialises writes across all objects, even those with no data dependency. Under the Storage mechanism this is unnecessary because the storage tree is naturally partitioned.

### 5.2 Object Groups

The Storage model partitions objects into ten groups based on the **trailing digit of the object handle**. Group N contains handles where `handle % 10 = N`. This includes Group 0 (handles ending in 0: 10, 20, 30, …).

The grouping is reflected in the `Storage` structure:

```
Storage.OTr_Group_0   //  objects whose handle % 10 = 0
Storage.OTr_Group_1   //  objects whose handle % 10 = 1
…
Storage.OTr_Group_9   //  objects whose handle % 10 = 9
```

### 5.3 Semaphore Names

Ten group semaphores plus one controller semaphore replace the single global semaphore under the Storage mechanism. Their names are stored on `Storage.OTr` at initialisation as a shared collection (group names) and a scalar Text property (controller name), readable without locking overhead by any process at any time.

| Slot in `semaphoreNames` (0-indexed) | Group | Semaphore Name |
|---|---|---|
| 0 | Group 0 (digit 0) | `$OTr_n0_series` |
| 1 | Group 1 | `$OTr_n1_series` |
| 2 | Group 2 | `$OTr_n2_series` |
| 3 | Group 3 | `$OTr_n3_series` |
| 4 | Group 4 | `$OTr_n4_series` |
| 5 | Group 5 | `$OTr_n5_series` |
| 6 | Group 6 | `$OTr_n6_series` |
| 7 | Group 7 | `$OTr_n7_series` |
| 8 | Group 8 | `$OTr_n8_series` |
| 9 | Group 9 | `$OTr_n9_series` |

`Storage.OTr.controllerSemaphore = "$OTr_controller"` is a separate scalar Text property, used exclusively by `OTr_New` and `OTr_Clear` (the only methods that add or remove objects from the registry).

### 5.4 Deriving the Group Index

Object handles are strictly positive (`> 0`); this invariant is established by `OTr_New`, which allocates from 1 and grows on demand. As a result the trailing digit can be 0 (for handles 10, 20, …) but the handle itself is never 0.

The group index is the trailing digit, directly:

```4d
$groupIndex_i := $inObject_i % 10   //  yields 0..9, matches collection slot 1:1
```

Both `Storage.OTr.semaphoreNames` and the process-scoped `OTr_LockDepth_ci` use this index without transformation. **There is no off-by-one and no special-case for digit 0.** The controller semaphore and its counter are separate variables (`Storage.OTr.controllerSemaphore`, `OTr_ControllerLockDepth_i`), reached only via the `$inObject_i = 0` sentinel passed by `OTr_New` / `OTr_Clear`.

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

The existing codebase already uses the separator-underscore convention (`OTr_z_Init`, `OTr_z_Lock`, etc.). No housekeeping rename is required as a prerequisite to Phase 100. New methods introduced in Phase 100 follow the same convention.

---

## 8. Changes to `OTr_z_Init`

The following additions are made to `OTr_z_Init` within the existing `If (Storage.OTr = Null)` guard:

1. Add `semaphoreNames` as a shared collection of ten strings on `Storage.OTr`, populated in trailing-digit order (slot 0 = `$OTr_n0_series`, slot 1 = `$OTr_n1_series`, …, slot 9 = `$OTr_n9_series`). The collection is created inline within the `Use(Storage)` block so it joins Storage's share group automatically.
2. Add `controllerSemaphore` as a scalar string property on `Storage.OTr`, set to `"$OTr_controller"`.
3. Add `options`, `errorHandler`, and `legacySemaphore` properties — see §9.

**Ordering note.** The `options`, `errorHandler`, and `legacySemaphore` values are copied from the interprocess variables `<>OTR_Options_i`, `<>OTR_ErrorHandler_t`, and `<>OTR_Semaphore_t` respectively. Those variables are normally set in the `If (Not(<>OTR_Initialised_b))` guard which runs after the `If (Storage.OTr = Null)` guard. To ensure correct values are available when `Storage.OTr` is created, the three IP variables are assigned their defaults at the top of the `If (Storage.OTr = Null)` block (before `Use(Storage)`). The `If (Not(<>OTR_Initialised_b))` guard then sets them again to the same values — no observable change.

Within the per-process `If (Not(OTR_Initialised_b))` guard, initialise:

- `OTr_LockDepth_ci` as a 10-element Integer collection of zeros.
- `OTr_ControllerLockDepth_i` as Integer zero.

**Note:** the guard that protects these per-process initialisations is `If (Not(OTR_Initialised_b))` — the one using the process-local Boolean — not `If (Not(<>OTR_Initialised_b))` (the interprocess Boolean). The interprocess guard fires only once across all processes; the per-process guard fires once per process, which is the correct scope for process-variable initialisation.

The existing scalar `OTR_LockCount_i` is **retained unchanged** for the IP Arrays mechanism.

The existing `<>OTR_Semaphore_t` interprocess variable is retained for backwards compatibility during the transition. New code should read `Storage.OTr.legacySemaphore` (for the IP Arrays mechanism) or `Storage.OTr.semaphoreNames` / `Storage.OTr.controllerSemaphore` (for the Storage mechanism).

Under `mechanism = OTR Storage`, `OTr_z_Init` also creates the ten `Storage.OTr_Group_N` shared objects (empty) and the `Storage.OTrController` shared object (`{ nextHandle: 1, inUse: {} }`).

---

## 8A. `OTr_z_InitStorage` — Thread-Safe Per-Process Initialisation

`OTr_z_Init` contains non-thread-safe commands: it writes to interprocess variables (`<>OTR_Options_i`, `<>OTR_Semaphore_t`, etc.), calls `Compiler_ObjectToolsReplacement` which declares interprocess arrays, and uses classic array commands. In 4D, a method marked `"preemptive":"capable"` cannot call any method that contains such commands. Therefore `OTr_z_Init` can never be called from a preemptive process.

`OTr_z_InitStorage` is a separate method, marked `"preemptive":"capable"`, that provides an equivalent per-process initialisation for preemptive callers using the Storage mechanism. It contains only thread-safe commands:

```4d
If (Not(OTr_StorageInitialised_b))
    OTr_LockDepth_ci := New collection(0; 0; 0; 0; 0; 0; 0; 0; 0; 0)
    OTr_ControllerLockDepth_i := 0
    OTr_StorageInitialised_b := True
End if
```

`OTr_StorageInitialised_b` is a Boolean process variable declared in `Compiler_ObjectToolsReplacement`. Its guard ensures the assignments run exactly once per process, matching the pattern of `OTR_Initialised_b` for the cooperative path.

**Calling convention:**

| Process type | Mechanism | Lazy init called |
|---|---|---|
| Cooperative | IP Arrays | `OTr_z_Init` |
| Cooperative | Storage | `OTr_z_Init` |
| Preemptive | Storage | `OTr_z_InitStorage` |

`OTr_z_Init` must be called once from a cooperative startup context (e.g., the host's `On Startup` event method) before any preemptive workers that use OTr are spawned. It sets up all shared state — `Storage.OTr`, `Storage.OTr_Group_*`, `Storage.OTrController` — that `OTr_z_InitStorage` relies on being present.

**Note on `OTr_LockDepth_ci` in both methods.** The per-process lock-depth collection is initialised by `OTr_z_Init` (for cooperative processes) and by `OTr_z_InitStorage` (for preemptive processes). Both use separate per-process boolean guards so there is no double-initialisation risk in any single process.

---

## 9. Migration of IP Array Preferences into `Storage.OTr`

The following interprocess variables are migrated into `Storage.OTr` properties during Phase 100:

| Current Variable | New Property | Notes |
|---|---|---|
| `<>OTR_Options_i` | `Storage.OTr.options` | Integer |
| `<>OTR_ErrorHandler_t` | `Storage.OTr.errorHandler` | Text |
| `<>OTR_Semaphore_t` | `Storage.OTr.legacySemaphore` | Retained for reference; superseded by group semaphores under Storage mechanism |

After migration the interprocess variables are retained during a transitional period to allow any external code that references them directly to continue functioning. They are marked for removal in a subsequent housekeeping phase.

---

## 10. ~~Encoding Responsibilities for Picture and BLOB Types~~ (STALE)

> **STALE — see §10A.** This section described BLOB/Picture storage in terms of parallel interprocess arrays (`<>OTR_Blobs_ax`, `<>OTR_Pictures_ap`) that were planned at the time of v0.1 but never implemented. The shipped v0.5 IP-Arrays mechanism stores BLOBs and Pictures inside the per-object nested object accessed via `OB Get` / `OB SET`. The text below is preserved for historical context only.

<details>
<summary>Original §10 text (do not implement)</summary>

Under the Storage mechanism, Pictures and BLOBs cannot be stored directly in shared objects (which do not support these types). They must be encoded before storage and decoded after retrieval.

**Encoding (Put path, Outer layer):**

- If `Storage.OTr.nativeBlobInObject` is `True` (4D v19.2+): native BLOB storage may be available; confirm against 4D documentation at time of implementation.
- If `Storage.OTr.nativeBlobInObject` is `False`: base64-encode the BLOB or Picture to a Text value before passing it to the Middle layer.

**Decoding (Get path, Outer layer):**

- Reverse of the above. Decode the Text value back to BLOB or Picture after the Middle layer returns.

**IP Arrays mechanism:** No encoding is required. BLOBs and Pictures are stored directly in the respective parallel arrays (`<>OTR_Blobs_ax`, `<>OTR_Pictures_ap`). The Outer layer performs no encoding under this mechanism.

The Outer layer determines which path to follow by reading `Storage.OTr.mechanism` once per call. This read is unguarded (no lock required).

</details>

---

## 10A. Encoding Responsibilities for Picture and BLOB Types (Current)

Under the Storage mechanism, Pictures cannot be stored directly in shared objects. BLOBs can be stored natively from 4D v19.2 onwards (gated by `Storage.OTr.nativeBlobInObject`). When native storage is not available, the value must be base64-encoded before storage and decoded after retrieval.

| Type | IP Arrays mechanism | Storage mechanism, `nativeBlobInObject = True` | Storage mechanism, `nativeBlobInObject = False` |
|---|---|---|---|
| BLOB | Stored as-is inside per-object nested object via `OB Get` / `OB SET`. No encoding. | Stored as-is. No encoding. | Base64-encode (Put) / decode (Get) at the Outer layer. |
| Picture | Stored as-is inside per-object nested object via `OB Get` / `OB SET`. No encoding. | Convert to BLOB via `PICTURE TO BLOB`, then store. Reverse on Get. | Convert to BLOB, base64-encode, store as Text. Reverse on Get. |

All encoding and decoding happens **at the Outer layer** (`OTr_GetArrayBLOB`, `OTr_PutArrayBLOB`, `OTr_GetArrayPicture`, `OTr_PutArrayPicture`). The Outer layer reads `Storage.OTr.mechanism` and `Storage.OTr.nativeBlobInObject` once per call; both reads are unguarded.

The Middle and Inner layers are unaware of encoding. From their perspective, BLOB-array cells under the Storage mechanism are either BLOBs (native path) or Text (base64 path), and the `type` field on the tag wrapper records which.

---

## 11. Relationship to Other Phases

| Phase | Dependency |
|---|---|
| Phase 8 | **Complete (v0.5).** Phase 100 extends `OTr_u_AccessArrayElement` and the type-constant binding scheme introduced in Phase 8. |
| Phases 1–7 | No dependency. Phase 100 does not affect the public API. |
| Phase 15 | Phase 100 may be implemented before or after further work in Phase 15 (side-by-side compatibility testing). The IP Arrays mechanism is unchanged and will continue to pass Phase 15 tests. |
| Phase 16 (OT BLOB compatibility) | Coordinate with §10A — both phases touch the BLOB code path. |

---

## 12. Deferred Items (Post-Phase-100)

- Removal of transitional interprocess variables (`<>OTR_Options_i`, `<>OTR_ErrorHandler_t`, `<>OTR_Semaphore_t`) once confirmed no external code references them directly.
- Performance benchmarking: IP Arrays vs Storage mechanism under representative load, to validate the assumption that IP Arrays are faster for the common case.
- Consideration of whether scalar Put/Get methods (`OTr_PutLong`, etc.) require the same three-layer decomposition, or whether the current two-layer model is sufficient for scalars given their simpler access patterns.
- Consolidation of the hybrid lock counter (§4) into a single unified collection-based counter once the IP Arrays mechanism has either been retired or migrated to the new shape.

---

## 13. Implementation Plan: Dependency Graph and Waves

The work decomposes into twelve workstreams (W1–W12), grouped into five sequential waves. Workstreams within a wave are parallelisable.

### 13.1 Workstreams

| # | Workstream | Touches |
|---|---|---|
| W1 | Middle→Inner mode-constant synthesis (Middle dispatcher computes `$mode_i`; Inner methods receive it explicitly) | `OTr_u_AccessArrayElement`, two new Inner methods |
| W2 | Per-group lock-depth collection (`OTr_LockDepth_ci`) + controller depth scalar (`OTr_ControllerLockDepth_i`); mechanism-aware `OTr_z_Lock` / `OTr_z_Unlock` | `OTr_z_Lock`, `OTr_z_Unlock`, `OTr_z_Init` |
| W3 | Per-group semaphores and `controllerSemaphore` populated on `Storage.OTr` | `OTr_z_Init` |
| W4 | Group-index derivation (`handle % 10`) used at the Inner layer | New utility or inline at Inner-layer entry |
| W5 | `OTr_z_Init` property additions (`options`, `errorHandler`, `legacySemaphore`, `semaphoreNames`, `controllerSemaphore`); collection and scalar lock-depth initialisation; creation of `Storage.OTr_Group_*` and `Storage.OTrController` under Storage mechanism; new `OTr_z_InitStorage` for preemptive per-process init | `OTr_z_Init`, `OTr_z_InitStorage` (new), `Compiler_ObjectToolsReplacement` |
| W6 | Move lock acquisition from Outer to Inner layer | All 22 Outer-layer Get/Put methods; both Inner methods |
| W7 | Three-layer split: extract current IP-array logic from `OTr_u_AccessArrayElement` into `OTr_u_IPArrayAccess`; reshape `OTr_u_AccessArrayElement` as pure dispatcher | `OTr_u_AccessArrayElement` (+ new `OTr_u_IPArrayAccess`) |
| W8 | `OTs_u_StorageAccess` — Storage-mode Inner implementation | New file |
| W9 | Storage data-model design: per-object shape inside `Storage.OTr_Group_N`; type-wrapper representation; cross-checking against `Storage` API constraints | Design / spec amendment (no code) |
| W10 | BLOB / Picture encoding at the Outer layer, gated on mechanism and `nativeBlobInObject` | `OTr_GetArrayBLOB`, `OTr_PutArrayBLOB`, `OTr_GetArrayPicture`, `OTr_PutArrayPicture` |
| W11 | IP-var → `Storage.OTr` migration with transitional retention of `<>OTR_*` | `OTr_z_Init` + any readers |
| W12 | `OTr_New` / `OTr_Clear` Storage-aware paths, using `$OTr_controller` semaphore and `Storage.OTrController` registry | `OTr_New`, `OTr_Clear` |

### 13.2 Dependency Edges

```
W1 ──┐
     ├──► W7 ──► W6 ──► W8 ──► W10
W4 ──┤              ▲          ▲
     ├──► W2 ──────┘          │
W5 ──┤                         │
     ├──► W3 ────────► W12 ────┘
     └──► W11
W9 ──────► W8
W9 ──────► W12
```

### 13.3 Waves

| Wave | Workstreams | Notes |
|---|---|---|
| A — Foundations | W1, W4, W5, W9 | Fully parallelisable. W9 is design only — ideal candidate for a focused planning sub-thread that emits a spec amendment to §2.4. |
| B — Locking + init | W2, W3, W11 | Depend on W5. Within the wave, all three can proceed in parallel. |
| C — Architectural refactor | W7, then W6 | Sequential within the wave. W7 splits the dispatcher; W6 relocates the lock. |
| D — Storage mechanism | W8, W12 | Parallelisable. Both depend on Wave C and on W9 (data-model design). |
| E — Encoding | W10 | Last. Depends on W8 being callable for end-to-end testing. |

### 13.4 Test Strategy

Each workstream lands with side-by-side tests using the existing `____Test_Phase_All_SideBySide` harness pattern. The IP Arrays mechanism continues to pass the v0.5 test suite unchanged; the Storage mechanism is exercised by a parallel suite that toggles `Storage.OTr.mechanism = OTR Storage` at process start.

---

## Appendix: Codebase-vs-Spec Reconciliation (as of v0.5)

| Spec assumption | Codebase reality | Resolution |
|---|---|---|
| Middle layer takes explicit `$inMode_i` | Arity detection (`Count parameters`) | Keep arity at Outer→Middle; synthesise mode at Middle, pass explicitly to Inner. (§3.2) |
| Reentrant lock counter is new | `OTR_LockCount_i` scalar already exists | Retain scalar for IP Arrays; introduce collection only for Storage mechanism. (§4) |
| BLOB/Picture stored in `<>OTR_Blobs_ax` / `<>OTR_Pictures_ap` parallel arrays | Stored inline in per-object nested object | §10 marked STALE; §10A describes the actual encoding boundary. |
| `OTr_zInit` → `OTr_z_Init` rename required | `OTr_z_Init` already in use | No rename needed; §7 reflects this. |
| Group-index mapping has off-by-one (digit 0 → slot 10, controller at slot 0) | n/a | Switched to direct trailing-digit indexing (0–9); controller depth and name are separate variables. (§5.4) |
| `Storage.OTr.mechanism` already initialised | Already set to `OTR IP Arrays` in `OTr_z_Init` | Confirmed; no work needed. |
| §4.4 / §8 stated `OTr_LockDepth_ci` init belongs in `If (Not(<>OTR_Initialised_b))` guard | That guard uses the interprocess flag — fires once across all processes; per-process variables placed there are never initialised for any process other than the first | Corrected to `If (Not(OTR_Initialised_b))` (per-process guard). Spec updated in §4.4, §8, and §8A. |
| No spec mention of thread-safety constraint on `OTr_z_Init` | `OTr_z_Init` contains non-thread-safe commands and cannot be called from preemptive processes | `OTr_z_InitStorage` created as a preemptive-capable parallel init method. Documented in §8A; W5 Touches updated in §13.1. |
