# Review Session S2 — API Coverage Audit: Methods vs Specifications

**Version:** 1.0
**Date:** 2026-04-11
**Author:** Wayne Stewart / Claude
**Dependencies:** None — may be commenced immediately
**Parallel with:** S1, S4, S5 (fully independent)

---

## Purpose

Establish a complete, verified cross-reference between the 213 `OTr_` methods in `Project/Sources/Methods/` and the method specifications across all phase documents. Identify any method that exists without a specification, any specified method that is absent from the source, and any signature mismatch between the spec and the implementation.

---

## Scope

### Source to examine

- `Project/Sources/Methods/` — all `.4dm` files prefixed `OTr_`
- `Documentation/Methods/` — individual per-method documentation files (`.md`)
- All phase specification documents (Phases 1–10, 15, 20) for method signature tables

### Method categories

| Prefix / Pattern | Category | Expected shared | Expected invisible |
|---|---|---|---|
| `OTr_` (public, no further qualifier) | Public API — must match OT command set | `true` | `true` |
| `OTr_z*` | Private infrastructure | `false` | `true` |
| `OTr_u*` | Utility | `false` | `true` |
| `____Test_Phase_*` | Unit test | `false` | `true` |
| Other prefixes (`LOG_`, `KVP_`, `Dict_`, `OBJP_`, etc.) | Supporting infrastructure — not OTr API | — | — |

---

## Review Checklist

### Step 1 — Enumerate all `OTr_` methods

List every `.4dm` file in `Project/Sources/Methods/` with the `OTr_` prefix and categorise it as public API, `OTr_z*` private, or `OTr_u*` utility. Record the full list.

### Step 2 — Enumerate all spec-mandated methods

Extract every method name from:
- Phase spec method-signature tables
- The command reference table in `OTr-Specification.md`
- The `OTr-Phase-020-Spec.md` (Release Checklist) — look for any method names referenced there not found in specs

Produce a master list of every method the specifications require to exist.

### Step 3 — Cross-reference

Compare the two lists:

- [ ] **Methods in source, not in any spec** — undocumented methods; require either a spec or justification for their existence
- [ ] **Methods in spec, not in source** — missing implementations; require either implementation or spec retraction
- [ ] **Methods in `Documentation/Methods/` but not in source** — stale documentation
- [ ] **Methods in source but not in `Documentation/Methods/`** — undocumented methods

### Step 4 — Signature audit

For every public API method (`OTr_` non-z, non-u), compare the `#DECLARE` signature in the `.4dm` source against the spec:

- [ ] Parameter names match (including type suffixes per `OTr-Types-Reference.md`)
- [ ] Parameter types match
- [ ] Return type matches (function result vs no result)
- [ ] Parameter count matches

Known discrepancies to investigate first:
- `OTr_GetBoolean` — spec says returns Integer (0/1), not Boolean; confirm source matches
- `OTr_GetBLOB` — spec says deprecated with a warning, delegating to `OTr_GetNewBLOB`; confirm
- `OTr_BLOBToObject` — offset parameter status marked provisional; confirm current implementation
- `OTr_GetArrayPointer` — changed signature (function result, not output parameter); confirm

### Step 5 — `folders.json` registration

Open `Project/Sources/folders.json` and confirm:
- [ ] Every public API method is registered in the correct method group
- [ ] Every test method (`____Test_Phase_*`) is registered in the `Test Methods` group
- [ ] No orphaned entries exist for methods that no longer exist

### Step 6 — Utility method review

For the `OTr_u*` utility methods, assess:
- [ ] `OTr_uDateToText`, `OTr_uTextToDate`, `OTr_uTimeToText`, `OTr_uTextToTime` — determine whether these are still called or can be retired (noted as a question in Phase 20 TODO)
- [ ] `OTr_uBlobToText` — confirm whether still required (used only on pre-v19R2 where native BLOB storage is unavailable)

---

## Expected Outputs

1. A complete cross-reference table: spec'd methods vs implemented methods (green/amber/red)
2. A list of undocumented methods with recommended dispositions (add spec / delete method / reclassify)
3. A list of signature mismatches with recommended corrections
4. A list of `folders.json` registration issues
5. A recommendation on utility methods that may be eligible for retirement

---

## Notes for the Reviewer

The most efficient approach is to generate the method list programmatically — list all `.4dm` filenames in `Project/Sources/Methods/`, strip the extension, and sort. Then compare against the spec-extracted list. A simple shell `ls` or 4D method-name extraction will suffice.

Pay particular attention to the boundary between `OTr_z*` private methods and `OTr_u*` utility methods. The distinction matters for `"shared"` attribute correctness (audited in S5) and for understanding which methods have spec coverage obligations.
