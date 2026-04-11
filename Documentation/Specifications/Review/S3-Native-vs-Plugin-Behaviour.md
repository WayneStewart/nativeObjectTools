# Review Session S3 — Native 4D vs Plugin Behaviour

**Version:** 1.0
**Date:** 2026-04-11
**Author:** Wayne Stewart / Claude
**Dependencies:** Soft dependency on S1 (specification completeness); S3 may begin once S1's §3 (Phase-specific checks) is substantially complete. Running before S1 is finished introduces the risk that the spec used as a reference in S3 is later found to be incorrect.
**Parallel with:** S4, S5 (independent of those sessions)

---

## Purpose

Verify that the native OTr implementation faithfully reproduces the observable behaviour of the ObjectTools 5.0 plugin, within the constraints of what is achievable in a native 4D component. This session focuses on semantic correctness — edge cases, type coercion, error handling, and `OK` variable semantics — rather than structural or naming compliance (those are S2 and S5 respectively).

The authoritative reference for ObjectTools 5.0 behaviour is `LegacyDocumentation/ObjectTools 5 Reference.pdf`. The authoritative catalogue of known incompatibilities is `Documentation/Specifications/OTr-Phase-015-Spec.md §4`.

---

## Scope

### Primary references

| Document | Role |
|---|---|
| `LegacyDocumentation/ObjectTools 5 Reference.pdf` | Ground truth for OT 5.0 behaviour |
| `Documentation/Specifications/OTr-Phase-015-Spec.md` | Catalogue of known incompatibilities |
| `Documentation/Specifications/OK is Set to Zero/OTr-OK0-Conditions.txt` | `OK` variable behaviour per method |
| `OTr-Specification.md §3.6` | Internal storage strategy |

### Method groups to audit (in priority order)

1. **Core handle management** — `OTr_New`, `OTr_Clear`, `OTr_Register`
2. **Scalar Put/Get** — all `OTr_Put*` and `OTr_Get*` for Long, Real, Text, Boolean, Date, Time
3. **Object embedding** — `OTr_PutObject`, `OTr_GetObject`
4. **Item introspection** — `OTr_ItemType`, `OTr_ItemExists`, `OTr_ItemCount`, `OTr_ItemList`, `OTr_DeleteItem`
5. **Array operations** — all `OTr_PutArray*`, `OTr_GetArray*`, `OTr_GetArraySize`, `OTr_SortArrays`
6. **Complex types** — `OTr_PutBLOB`, `OTr_GetNewBLOB`, `OTr_GetBLOB` (deprecated), `OTr_PutPicture`, `OTr_GetPicture`, `OTr_PutPointer`, `OTr_GetPointer`, `OTr_PutRecord`, `OTr_GetRecord`, `OTr_PutVariable`, `OTr_GetVariable`
7. **Import/export** — `OTr_ObjectToBLOB`, `OTr_BLOBToObject`, `OTr_SaveToText`, `OTr_LoadFromText`, `OTr_SaveToFile`, `OTr_LoadFromFile`
8. **Unified array accessor** — `OTr_GetArrayElement`, `OTr_PutArrayElement` (Phase 8)

---

## Review Checklist

### 1. General semantic checks (apply to all public methods)

- [ ] `OK` is set to 0 on every error path; `OK` is not modified on success
- [ ] `OTr_zSetOK` is used consistently — no direct `OK:=0` assignments (verify uniformity)
- [ ] Invalid handle (negative, zero, out-of-bounds, cleared slot) produces `OK=0` and a safe no-op return
- [ ] Empty string tag (`""`) behaviour matches OT 5.0 (confirm: does OT reject it or treat it as a valid key?)
- [ ] Null/missing tag on Get methods: confirm return value matches OT 5.0 default (typically 0 / empty / False)

### 2. Handle lifecycle

- [ ] `OTr_New` — slot reuse: a cleared slot is reused by the next `OTr_New` call (not always appended)
- [ ] `OTr_New` — tail trimming on `OTr_Clear`: trailing unused slots are trimmed (§10.6 of master spec)
- [ ] `OTr_Clear` — calling with an already-cleared handle sets `OK=0` (guard against double-free)
- [ ] `OTr_Register` — is a no-op and returns safely; `OK` is set appropriately

### 3. Scalar Put/Get

- [ ] `OTr_GetBoolean` returns Integer (0 or 1), **not** a native 4D Boolean — legacy compatibility requirement
- [ ] `OTr_PutDate` / `OTr_GetDate` — determine definitively whether storage is via native `OB SET` (date type) or formatted text (`YYYY-MM-DD`). The master spec (§3.6) says formatted text; the Phase 20 TODO implies native. **Resolve and document the ground truth.**
- [ ] `OTr_PutTime` / `OTr_GetTime` — same question as Date above
- [ ] Round-trip fidelity: for each scalar type, `Put` then `Get` returns the original value without loss or coercion
- [ ] `OTr_PutText` with a very long string (>32k characters) — OT 5.0 limitation?
- [ ] Dotted-path `AutoCreateObjects` — intermediate objects are auto-created when not present
- [ ] Dotted-path `AutoCreateObjects` disabled — confirm behaviour when option bit 2 is cleared

### 4. Item introspection

- [ ] `OTr_ItemType` returns legacy OT type constants (not native 4D `Is longint`, `Is text`, etc.)
- [ ] `OTr_ItemType` on a missing tag returns the OT equivalent of "undefined" or 0
- [ ] `OTr_ItemCount` counts only top-level properties (not nested)
- [ ] `OTr_ItemList` returns property names in a consistent order (OT 5.0 order? Insertion order? Alphabetical?)
- [ ] `OTr_DeleteItem` on a non-existent tag: `OK=0` or silent no-op? Confirm against OT 5.0

### 5. Array operations

- [ ] 1-based index (caller) correctly maps to 0-based Collection index (internal) for every array method
- [ ] Out-of-bounds index on Get: returns default value and sets `OK=0`
- [ ] Out-of-bounds index on Put: appends, extends, or errors? Confirm against OT 5.0
- [ ] `OTr_SortArrays` with a single key ascending/descending: correct
- [ ] `OTr_SortArrays` with multiple keys (mixed ascending/descending): correct
- [ ] `OTr_FindInArray` — confirm search semantics match OT 5.0 (exact match? case sensitive?)

### 6. Complex types

- [ ] `OTr_PutObject` — always deep-copies (no reference semantics); confirmed in Phase 20 checklist
- [ ] `OTr_GetObject` — returns a deep copy; modifying the returned object does not modify the stored object
- [ ] `OTr_PutBLOB` / `OTr_GetNewBLOB` — round-trip fidelity; no data loss
- [ ] `OTr_GetBLOB` (deprecated) — fires a deprecation warning via error handler before delegating to `OTr_GetNewBLOB`
- [ ] `OTr_PutPicture` / `OTr_GetPicture` — round-trip fidelity
- [ ] `OTr_PutPointer` / `OTr_GetPointer` — `->` pointer-to-pointer syntax required (changed from OT 5.0); confirm the spec note in Phase 15 §4.2 is reflected in the implementation
- [ ] `OTr_GetArrayPointer` — returns pointer as function result (changed from OT 5.0 output parameter); confirm
- [ ] `OTr_PutRecord` / `OTr_GetRecord` — round-trip fidelity across table/record number reference
- [ ] `OTr_PutVariable` / `OTr_GetVariable` — confirm storage and retrieval semantics

### 7. Import/export

- [ ] `OTr_ObjectToBLOB` — serialises all types correctly including native BLOBs and Pictures
- [ ] `OTr_BLOBToObject` — deserialises correctly; magic-byte check rejects legacy OT BLOBs with a clear error
- [ ] `OTr_BLOBToObject` — offset parameter: determine whether the provisional workaround in Phase 6 has been resolved
- [ ] `OTr_SaveToText` / `OTr_LoadFromText` — round-trip fidelity for all supported types
- [ ] `OTr_SaveToFile` / `OTr_LoadFromFile` — round-trip fidelity; file encoding is UTF-8

### 8. Thread safety

- [ ] Semaphore is acquired at the entry of every public method that accesses `<>OTR_Objects_ao` or `<>OTR_InUse_ab`
- [ ] Semaphore is released on **every** exit path — including all error paths and early returns
- [ ] Reentrancy: if an OTr method internally calls another OTr method, confirm the lock/unlock pattern handles nested locking without deadlock
- [ ] Confirm the design decision on reentrancy (flagged as "design decision required" in master spec §3.4) has been made and documented

### 9. Known incompatibilities (Phase 15 §4)

For each incompatibility listed in `OTr-Phase-015-Spec.md §4`:
- [ ] The incompatibility is genuine (not a fixable gap)
- [ ] The incompatibility is clearly documented in the relevant phase spec
- [ ] A migration path is documented for callers

---

## Expected Outputs

1. A confirmed or corrected resolution of the Date/Time storage strategy discrepancy
2. A list of behavioural gaps where OTr does not match OT 5.0 in ways not already catalogued in Phase 15
3. A list of edge cases not covered by the existing test suite (input to S4)
4. Confirmed or corrected status of thread safety (semaphore discipline)
5. Resolution of all "provisional" or "to be finalised" items flagged in the phase specs

---

## Notes for the Reviewer

The ObjectTools 5 Reference PDF (`LegacyDocumentation/ObjectTools 5 Reference.pdf`) is the ground truth for OT 5.0 behaviour. Read the relevant sections before auditing each method group. Where the PDF and the Phase 15 incompatibility catalogue conflict, the PDF takes precedence — the catalogue may be incomplete.

The `OK is Set to Zero` materials (`Documentation/Specifications/OK is Set to Zero/`) were specifically prepared to address the `OK` variable question. Use them as the primary reference for that topic, and update them if gaps are found.
