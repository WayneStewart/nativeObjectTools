# OTr Comprehensive Review — Session Index

**Version:** 1.0
**Date:** 2026-04-11
**Author:** Wayne Stewart / Claude
**Purpose:** Index and dependency map for the pre-release comprehensive review of OTr

---

## Overview

This folder contains six structured review session documents. Each document is self-contained: it defines the scope, provides a complete checklist, specifies expected outputs, and includes notes to orient the reviewer. Begin each new session by opening the relevant document and working through it systematically.

The review covers:
- Specification completeness and internal consistency
- Method-vs-specification coverage and API compliance
- Native 4D vs ObjectTools 5.0 behavioural equivalence
- Test suite coverage and quality
- Coding standard and `%attributes` compliance
- Final release gate (consolidates all prior sessions)

---

## Session List

| ID | Document | Focus |
|---|---|---|
| **S1** | [S1-Specification-Completeness.md](S1-Specification-Completeness.md) | Spec corpus audit — gaps, contradictions, stale content |
| **S2** | [S2-API-Coverage-Audit.md](S2-API-Coverage-Audit.md) | Methods vs specs — missing implementations, signature mismatches |
| **S3** | [S3-Native-vs-Plugin-Behaviour.md](S3-Native-vs-Plugin-Behaviour.md) | Semantic correctness — edge cases, `OK` discipline, thread safety |
| **S4** | [S4-Test-Coverage-Audit.md](S4-Test-Coverage-Audit.md) | Test suite — coverage gaps, test quality |
| **S5** | [S5-Coding-Standard-Compliance.md](S5-Coding-Standard-Compliance.md) | `%attributes`, `#DECLARE`, type suffixes, headers, semaphore discipline |
| **S6** | [S6-Release-Checklist-Gate.md](S6-Release-Checklist-Gate.md) | Release gate — consolidates S1–S5, go/no-go decision |

---

## Dependency Map

```
S1 ──────────────────────────────────────┐
                                         │
S2 ──────────────────────────────────────┤
                                         ├──▶  S6
S4 ──────────────────────────────────────┤
                                         │
S5 ──────────────────────────────────────┤
                                         │
S1 (§3 Phase-specific checks complete) ──┤
                                         │
S3 ──────────────────────────────────────┘
```

**Interpretation:**

- **S1, S2, S4, S5** are fully independent of one another and may be commenced simultaneously or in any order.
- **S3** has a soft dependency on S1: S3 uses the phase specifications as its reference for expected behaviour. If S1 identifies that a spec is incorrect or stale, S3 may reach incorrect conclusions. In practice, S3 can begin once S1's phase-specific checks (§3) are substantially complete, even if S1's retired-document review is still in progress.
- **S6** depends on S1–S5 all being substantially complete. It should not be started until findings from all prior sessions have been compiled.

---

## Concurrency Guidance

### Can these sessions run simultaneously?

**Yes — with the caveats above.** The table below shows which sessions may run in parallel:

| | S1 | S2 | S3 | S4 | S5 | S6 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| **S1** | — | ✅ | ⚠️ | ✅ | ✅ | ❌ |
| **S2** | ✅ | — | ✅ | ✅ | ✅ | ❌ |
| **S3** | ⚠️ | ✅ | — | ✅ | ✅ | ❌ |
| **S4** | ✅ | ✅ | ✅ | — | ✅ | ❌ |
| **S5** | ✅ | ✅ | ✅ | ✅ | — | ❌ |
| **S6** | ❌ | ❌ | ❌ | ❌ | ❌ | — |

**Legend:**
- ✅ Fully independent — may run concurrently
- ⚠️ Soft dependency — S3 may begin once S1 §3 is complete; minor rework risk if run earlier
- ❌ Must not run concurrently (S6 requires all others substantially complete)

### Recommended execution order

**If working alone (sequential):** S1 → S2 → S5 → S4 → S3 → S6

Rationale: S1 establishes the canonical spec; S2 establishes the method inventory (useful for S5 and S4); S5 is largely mechanical and can be partially automated; S4 builds on the method inventory from S2; S3 is the deepest and benefits from all prior context; S6 consolidates.

**If working with Claude (parallel):** Launch S1, S2, S4, and S5 simultaneously. When S1 §3 is complete, launch S3. When all five are substantially complete, begin S6.

---

## Key Cross-Cutting Issues

The following issues are flagged across multiple sessions and should be prioritised:

### 1. Date/Time storage strategy discrepancy (S1, S3, S6)
The master spec (§3.6) states Date and Time are stored as formatted text strings (`YYYY-MM-DD`, `HH:MM:SS`). The Phase 20 TODO implies the scalar Put/Get methods use native `OB SET`/`OB Get` instead. This discrepancy must be resolved: the spec, the Phase 20 correctness check, and `OTr-OK0-Conditions.txt` must all agree with the actual implementation.

### 2. Stray `_p` suffix (S1, S5)
Five source files contain a stray `_p` suffix on Pointer and Picture variables (should be `_ptr` and `_pic` respectively). One spec file also contains the error. These are mechanical corrections but must be captured and applied consistently.

### 3. Phase 1.5 Load methods (S1, S2, S4, S6)
`OTr_LoadFromText`, `OTr_LoadFromFile`, and `OTr_LoadFromClipboard` are flagged in Phase 20 TODO as potentially unimplemented. These must be confirmed as implemented (or the Phase 20 checklist updated to reflect their status).

### 4. Phase 9 scope and status (S1, S4, S6)
Phase 9 has a spec document but does not appear in Phase 20's implementation table, and has no test method. Its scope, implementation status, and release-blocking status must be determined.

### 5. `OTr_BLOBToObject` offset parameter (S1, S3, S6)
Phase 15 §4.2 marks this as provisional. The provisional status must be resolved — either the implementation matches the spec, or the spec must be updated.

### 6. Thread safety design decision (S1, S3)
The master spec §3.4 flags a "design decision required" on reentrancy. This decision must be documented and the implementation confirmed to match it.

---

## Files in This Folder

```
Review/
├── 00-Review-Index.md                  (this document)
├── S1-Specification-Completeness.md
├── S2-API-Coverage-Audit.md
├── S3-Native-vs-Plugin-Behaviour.md
├── S4-Test-Coverage-Audit.md
├── S5-Coding-Standard-Compliance.md
└── S6-Release-Checklist-Gate.md
```

---

## Relationship to Existing Documents

These review session documents are task guides for the review process. They do not replace or supersede any existing specification or checklist. The authoritative documents remain:

- `OTr-Specification.md` — master architecture and command reference
- `Documentation/Specifications/OTr-Phase-0NN-Spec.md` — phase specifications
- `Documentation/Specifications/OTr-Phase-020-Spec.md` — release checklist
- `4D-Method-Writing-Guide.md` — coding standard
- `OTr-Types-Reference.md` — type constant and suffix reference
