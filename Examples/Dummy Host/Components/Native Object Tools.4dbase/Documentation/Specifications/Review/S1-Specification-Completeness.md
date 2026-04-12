# Review Session S1 — Specification Completeness and Consistency

**Version:** 1.0
**Date:** 2026-04-11
**Author:** Wayne Stewart / Claude
**Dependencies:** None — may be commenced immediately
**Parallel with:** S2, S4, S5 (fully independent)

---

## Purpose

Audit all phase specification documents against the master specification (`OTr-Specification.md`) to establish that the specification corpus is internally consistent, complete, and free of obsolete or contradictory material. This session produces a clean, authoritative specification baseline on which all subsequent sessions depend.

---

## Scope

### Documents to review

| Document | Location |
|---|---|
| Master specification | `OTr-Specification.md` |
| Phase 1 (implied — no separate spec) | `OTr-Specification.md §§3–4` |
| Phase 2 (implied — no separate spec) | `OTr-Specification.md §§3–4` |
| Phase 3 spec | `Documentation/Specifications/OTr-Phase-003-Spec.md` |
| Phase 4 spec | `Documentation/Specifications/OTr-Phase-004-Spec.md` |
| Phase 5 spec | `Documentation/Specifications/OTr-Phase-005-Spec.md` |
| Phase 6 spec | `Documentation/Specifications/OTr-Phase-006-Spec.md` |
| Phase 7 spec | `Documentation/Specifications/OTr-Phase-007-Spec.md` |
| Phase 8 spec | `Documentation/Specifications/OTr-Phase-008-Spec.md` |
| Phase 9 spec | `Documentation/Specifications/OTr-Phase-009-Spec.md` |
| Phase 10 spec | `Documentation/Specifications/OTr-Phase-010-Spec.md` |
| Phase 15 spec | `Documentation/Specifications/OTr-Phase-015-Spec.md` |
| Phase 20 spec (Release Checklist) | `Documentation/Specifications/OTr-Phase-020-Spec.md` |
| Phase 100 spec | `Documentation/Specifications/OTr-Phase-100-Spec.md` |
| Types reference | `OTr-Types-Reference.md` |
| OK is Set to Zero materials | `Documentation/Specifications/OK is Set to Zero/` |

### Documents to cross-reference (retired)

Review the `Retired/` subdirectory to confirm each retired document has been cleanly superseded and contains no material that was inadvertently dropped.

| Retired document | Superseded by |
|---|---|
| `OTr-Phase-004-Spec-Retired.md` | Phase 4 spec (current) |
| `OTr-Phase-005-Spec-Retired.md` | Phase 5 spec (current) |
| `OTr-Phase-006-Spec-Retired.md` | Phase 6 spec (current) |
| `OTr-Phase-010-Spec-Retired.md` | Phase 10 spec (current) |
| `OTr-Phase-010-Spec-Retired2.md` | Phase 10 spec (current) |
| `OTr-Phase-010-SpecImplementationChanges.md` | Phase 10 spec (current) |
| `OTr-Phase-020-Spec-Retired.md` | Phase 20 spec (current) |
| `OTr-Specification-Retired.md` | Master spec (current) |
| `CHANGELOG-OTr-Phase-010-v0.4.md` | Reference only — confirm superseded content is in Phase 10 spec |

---

## Review Checklist

### 1. Master specification (`OTr-Specification.md`)

- [ ] Version number current and date up to date
- [ ] Architecture section (§3) accurately describes the implementation as it stands — particularly the paired interprocess array model, `OTr_zLock`/`OTr_zUnlock` pattern, and tag-to-property mapping
- [ ] Internal storage table (§3.6) reflects the actual storage strategy used by the implemented methods (e.g., confirm Date and Time are stored natively via `OB SET` in scalar methods, not as formatted text — the spec and the implementation have diverged on this point per Phase 20 TODO)
- [ ] The command reference table (if present) lists all public API methods with correct signatures
- [ ] Cross-references to phase spec files are correct and all files exist
- [ ] No material from the retired master spec (`OTr-Specification-Retired.md`) was inadvertently dropped

### 2. Phase specs — general checks (apply to each)

For every phase spec:

- [ ] Version number and date are current
- [ ] Method signatures match the current `4D-Method-Writing-Guide.md` naming convention (type suffixes, `#DECLARE` style)
- [ ] `OK` variable semantics are specified for every method (set to 0 on error; not modified on success — per the `OK is Set to Zero` materials)
- [ ] Every method's behaviour on an invalid handle is specified
- [ ] Every method's behaviour on a null/missing tag is specified
- [ ] Parameter names use the correct type suffixes per `OTr-Types-Reference.md`
- [ ] No stray `_p` suffix remains (known issue: Phases 4 and 5 — confirmed fixed in Phase 5, still present in Phase 4)
- [ ] Cross-references to other phase specs are correct

### 3. Phase-specific checks

#### Phase 1 / 1.5 (implied in master spec)
- [ ] Confirm the spec clearly defines `OTr_New`, `OTr_Clear`, `OTr_Register`, `OTr_zInit`, `OTr_zLock`, `OTr_zUnlock`, `OTr_GetVersion`
- [ ] Slot-reuse strategy for `OTr_New` is specified
- [ ] Lazy initialisation via `OTr_zInit` is specified (called at top of every public method)
- [ ] `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard` are specified (noted as potentially unimplemented — see Phase 20 TODO)

#### Phase 2 (implied in master spec)
- [ ] All scalar Put/Get methods are listed: Long, Real, Text, Boolean, Date, Time
- [ ] Dotted-path behaviour (including `AutoCreateObjects`) is specified
- [ ] `OTr_zResolvePath` internal method is specified

#### Phase 3
- [ ] `OTr_ItemType` return values are specified as legacy OT type constants (not native 4D constants)
- [ ] All item-utility methods are listed

#### Phase 4
- [ ] 1-based ↔ 0-based index mapping is explicitly specified
- [ ] `OTr_SortArrays` multi-key sort behaviour is specified
- [ ] Stray `_p` suffix issue (noted in Phase 20 TODO) is documented for resolution

#### Phase 5
- [ ] `OTr_GetBLOB` deprecation warning behaviour is specified
- [ ] `OTr_GetNewBLOB` and `OTr_GetPicture` are specified as function-result variants
- [ ] Incompatible methods (`OT GetBLOB`, `OT GetArrayBLOB`, `OT GetArrayPicture`) are cross-referenced to Phase 15

#### Phase 6
- [ ] BLOB serialisation format is fully specified (magic bytes, type metadata)
- [ ] Legacy OT BLOB incompatibility and error behaviour are specified
- [ ] `OTr_BLOBToObject` offset parameter status is resolved (noted as provisional in Phase 15 spec)

#### Phase 7
- [ ] All public API methods have confirmed parameter names matching the legacy OT API plus OTr type suffixes
- [ ] Any remaining naming discrepancies are documented

#### Phase 8
- [ ] Unified array element accessor behaviour is fully specified

#### Phase 9
- [ ] Confirm scope and status — README indicates Phase 9 is "substantially complete"; confirm what remains

#### Phase 10
- [ ] All three log control levels (`off`, `info`, `debug`) are fully defined
- [ ] Sentinel file mechanism is fully specified
- [ ] Worker process lifecycle (startup, shutdown, crash recovery) is fully specified
- [ ] Per-process LIFO call stack specification is complete
- [ ] `On Host Database Event` fallback is specified

#### Phase 15
- [ ] All incompatibilities in §4 have been reviewed against the current implementation
- [ ] Platform constraint (no macOS Tahoe) is prominently documented
- [ ] Test method `____Test_OT_Compatibility` structure is specified

#### Phase 100
- [ ] Confirm this is clearly marked post-release / out of scope for current release

### 4. `OTr-Types-Reference.md`
- [ ] All type constants used across the spec corpus are listed
- [ ] Legacy OT type constant values are correct
- [ ] Type suffix table matches the `4D-Method-Writing-Guide.md`

### 5. `OK is Set to Zero` materials
- [ ] `OTr-OK0-Conditions.txt` lists every method and its `OK`-setting behaviour
- [ ] The conditions listed are consistent with the phase spec descriptions
- [ ] The `.xlsx` / `.pdf` / `.numbers` versions are consistent with the `.txt`

### 6. Retired documents
- [ ] Each retired document contains a clear supersession notice at the top
- [ ] No content from retired documents was dropped in the current version
- [ ] `CHANGELOG-OTr-Phase-010-v0.4.md` content is reflected in Phase 10 spec

---

## Expected Outputs

1. A list of specification gaps — items mandated by the architecture but absent from any spec
2. A list of contradictions — items described differently in two or more documents
3. A list of stale content — references to methods, files, or approaches that no longer exist
4. Recommended edits to the affected documents, prioritised by severity
5. Confirmation (or otherwise) that the `OK is Set to Zero` materials are complete and accurate

---

## Notes for the Reviewer

Begin with `OTr-Specification.md` as the canonical reference. Read it in full before opening any phase spec. When a phase spec contradicts the master spec, the master spec takes precedence unless the phase spec is clearly a deliberate refinement with a higher version number and more recent date.

Pay particular attention to the storage strategy for Date and Time scalars: the master spec (§3.6) states these are stored as formatted text strings, but the Phase 20 TODO suggests the scalar Put/Get methods use native `OB SET`/`OB Get` instead. This discrepancy needs resolution.
