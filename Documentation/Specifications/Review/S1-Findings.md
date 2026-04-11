# S1 Findings — Specification Completeness and Consistency

**Session:** S1  
**Version:** 1.1  
**Date:** 2026-04-11  
**Author:** Claude (automated audit pass)  
**Status:** Complete — mechanical remediation applied 2026-04-11; see §6 for item closure status

---

## Executive Summary

The specification corpus is substantially complete and internally coherent for Phases 1–9. The most critical issue is a **persistent architectural contradiction** regarding Date/Time scalar storage strategy that runs across the master specification, Phase 2, Phase 3, and Phase 4 (and, by extension, `OTr-Types-Reference.md`). Secondary issues include a missing auxiliary directory, two sets of stray type suffixes, one unresolved `ioOffset` parameter status, one undocumented internal method (`OTr_z_Koala` / `OTr_z_Wombat`), and a number of Phase 10 implementation–specification divergences now captured in the retired-document set. Phase 100 is correctly marked as out-of-scope for the current release. Phase 9 scope and status are substantially resolved.

Findings are classified as **Contradiction**, **Gap**, **Stale**, or **Minor** and are prioritised by severity.

---

## Section 1 — Master Specification (`OTr-Specification.md`)

**Version:** 0.5 | **Date:** 2026-03-31

### 1.1 — Version and Date

The master specification carries version 0.5 and date 2026-03-31. Given that subsequent phase specifications carry dates as late as 2026-04-10, the master specification is out of date relative to the corpus it governs.

**Recommendation:** Update the master specification version to 0.6 (or align to the next release increment) and set the date to the date of resolution of the findings documented herein.

### 1.2 — Architecture Section (§3) — General Accuracy

Sections 3.1–3.5, 3.7–3.9, and section 3A are accurate with respect to the implemented architecture. The paired interprocess array model (`<>OTR_Objects_ao` / `<>OTR_InUse_ab`), `OTr_zLock`/`OTr_zUnlock` semaphore pattern, slot-reuse strategy, tag-to-property mapping, BLOB and Picture storage, and array index mapping are all correctly described.

### 1.3 — ~~CRITICAL CONTRADICTION~~ RESOLVED: Date/Time Storage Strategy (§3.6)

**Classification: Contradiction (Severity: Critical)**

The master specification §3.6 states, under **Formatted text types**:

> Date | Text | `"2026-03-31"` | `YYYY-MM-DD`  
> Time | Text | `"14:30:00"` | `HH:MM:SS`

Phase 2 (`OTr-Phase-002-Spec.md`, v1.0, 2026-04-07) specifies for `OTr_PutDate` and `OTr_GetDate`:

> Direct `OB SET` with Date value … Direct `OB GET` with Date value

That is: Phase 2 stores Date and Time as **native 4D types** via `OB SET`, not as formatted text strings. This directly contradicts the master specification.

Phase 3 (`OTr-Phase-003-Spec.md`, v0.1, 2026-04-01) reinforces the **master specification** position: its `OTr_ItemType` type-detection algorithm explicitly checks for `YYYY-MM-DD` and `HH:MM:SS` patterns in Text properties to identify Date and Time items. If Date/Time are stored as native types (per Phase 2), Phase 3's detection algorithm is wrong; if they are stored as text (per the master spec), Phase 2's specification is wrong.

Phase 4 and Phase 5 both align with the **master specification**: utility methods `OTr_uDateToText`/`OTr_uTimeToText` are defined and used for array element storage, and record snapshots store date and time fields as `YYYY-MM-DD` / `HH:MM:SS` text. `OTr-Types-Reference.md` also explicitly states: `Is date (4) — Stored as YYYY-MM-DD text` and `Is time (11) — Stored as HH:MM:SS text`.

**Status of contradiction:** Unresolved. The Phase 20 Release Checklist (§4, Correctness Checks) includes the item: `Date stored as YYYY-MM-DD text; Time stored as HH:MM:SS text; round-trip verified` — indicating that the **formatted-text approach is the intended release behaviour**, and Phase 2 may describe the native-storage approach that was subsequently superseded.

**Required action:** One of the following must be confirmed against the actual implementation:

**(A)** If Date/Time are stored as **native 4D types** via `OB SET`:
- Update master spec §3.6 to move Date and Time from "Formatted text types" to "Directly stored types"
- Update Phase 3 type-detection algorithm to use `OB Get type` returning `Is date` / `Is time` (not pattern matching)
- Update Phase 4 to eliminate `OTr_uDateToText` / `OTr_uTimeToText` from scalar path (retain for records only, if required)
- Update `OTr-Types-Reference.md` storage notes for Date and Time
- Update Phase 20 correctness check item to match

**(B)** If Date/Time are stored as **formatted text strings**:
- Update Phase 2 to remove "Direct `OB SET` with Date/Time value" and specify text serialisation via `OTr_uDateToText` / `OTr_uTimeToText`
- Phase 3, Phase 4, Phase 5, and `OTr-Types-Reference.md` all already align with this approach and require no change

**Resolution (2026-04-11):** The contradiction arose because 4D's `OB SET` behaviour for Date and Time is controlled by the database-level compatibility setting "Use date type instead of ISO date format in objects" (Structure Settings → Compatibility → Database), which is OFF by default. When OFF, `OB SET` with a native Date stores ISO text internally; `OB Get type` returns `Is text`, not `Is date`. This means Phase 2's "native `OB SET`" and the master spec's "formatted text" are both correct descriptions of different states of the same flag.

The resolution is an If/Else guard in all put methods, controlled by `Storage.OTr.nativeDateInObject` (a Boolean set at initialisation time by a probe in `OTr_zInit`). Get methods inspect the stored property type directly, making retrieval transparent to both storage paths. The same guard has been applied to `OTr_PutArrayDate`, `OTr_PutArrayTime`, `OTr_PutArrayDate`, `OTr_GetArrayDate`, `OTr_GetArrayTime`, and `OTr_PutRecord`. The utility methods `OTr_uDateToText` etc. are retained.

Phase 2 spec updated to v1.1 (2026-04-11) with a dedicated §Date/Time Storage Strategy section documenting this behaviour fully. Master spec §3.6 and `OTr-Types-Reference.md` storage notes for Date and Time should be updated at the next revision to reflect the conditional storage strategy.

**Cross-cutting note:** This item is now closed. S3 and S6 may proceed.

### 1.4 — Duplicate Section Heading §7

**Classification: Minor**

The master specification contains **two sections numbered §7**: the first (lines 425–429) is "Type Constant Mapping" directing the reader to `OTr-Types-Reference.md`; the second (lines 432 onwards) is "Command Reference by Phase". The first §7 appears to be a remnant of an earlier structure that was superseded when the type-mapping content was extracted to a dedicated reference document. The duplicate numbering should be resolved: the first §7 ("Type Constant Mapping") should be renumbered §7 and the subsequent section renumbered §8, or the first §7 should be removed and replaced with a cross-reference note within the retained §7.

### 1.5 — Cross-References to Phase Spec Files

All cross-references in the master specification to phase spec files were verified. All referenced files exist:

- `Documentation/Specifications/OTr-Phase-001-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-002-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-003-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-004-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-005-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-006-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-007-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-008-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-009-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-010-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-015-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-020-Spec.md` ✓
- `Documentation/Specifications/OTr-Phase-100-Spec.md` ✓

**Note:** The master specification (§6.2, §6.3) references `OTr-Phase-001-Spec.md` as containing the Phase 1.5 export methods. Verified correct.

### 1.6 — Thread Safety Design Decision (§3.4)

**Classification: Gap — RESOLVED 2026-04-11**

Reentrancy is implemented. The process variable `OTR_LockCount_i : Integer` (declared in `Compiler_ObjectToolsReplacement.4dm`) acts as a per-process nest counter. `OTr_zLock` acquires the semaphore only when the counter is 0, then increments it; subsequent nested calls increment only. `OTr_zUnlock` decrements the counter and releases the semaphore only when it reaches 0.

Master spec §3.4 updated to document the resolved decision. Phase 9 §5.7 added with full pseudocode and invariant documentation.

### 1.7 — Command Reference Table Completeness (§6)

The master specification §6 command table was cross-checked against Phase 9 §1.1 (undocumented methods). The following methods implemented in the codebase are **not listed** in the master specification §6 command tables:

| Method | Nature | Present in Phase spec? | Status |
|---|---|---|---|
| `OTr_ArrayType` | Public API | Not in §6; Phase 9 §1.1 flags for Phase 4 | Open |
| `OTr_SaveToBlob` | Public API (Phase 1.5) | Not in §6.12 | **Closed 2026-04-11** — Phase 1 Addendum 1.5b added |
| `OTr_LoadFromBlob` | Public API (Phase 1.5) | Not in §6.12 | **Closed 2026-04-11** — Phase 1 Addendum 1.5b added |
| `OTr_SaveToGZIP` | Public API (Phase 1.5) | Not in §6.12 | **Closed 2026-04-11** — Phase 1 Addendum 1.5b added |
| `OTr_LoadFromGZIP` | Public API (Phase 1.5) | Not in §6.12 | **Closed 2026-04-11** — Phase 1 Addendum 1.5b added |
| `OTr_SaveToXML` | Public API (Phase 1.5c) | Phase 1 Addendum 1.5c added 2026-04-11 | **Closed 2026-04-11** |
| `OTr_SaveToXMLFile` | Public API (Phase 1.5c) | Phase 1 Addendum 1.5c added 2026-04-11 | **Closed 2026-04-11** |
| `OTr_SaveToXMLSAX` | Public API (Phase 1.5c) | Phase 1 Addendum 1.5c added 2026-04-11 | **Closed 2026-04-11** |
| `OTr_SaveToXMLFileSAX` | Public API (Phase 1.5c) | Phase 1 Addendum 1.5c added 2026-04-11 | **Closed 2026-04-11** |
| `OTr_LoadFromXML` | Public API (Phase 1.5c) | Phase 1 Addendum 1.5c added 2026-04-11 | **Closed 2026-04-11** |
| `OTr_LoadFromXMLFile` | Public API (Phase 1.5c) | Phase 1 Addendum 1.5c added 2026-04-11 | **Closed 2026-04-11** |

**Note:** §6.12 of the master spec still needs updating to include the BLOB, GZIP, and XML variants (open item, low priority before release gate).

---

## Section 2 — Phase Specifications — General Checks

### 2.1 — Phase 1 (`OTr-Phase-001-Spec.md`)

**Version:** 1.0 | **Date:** 2026-04-07 | **Status:** Complete

All mandatory general checks pass:
- Version and date current ✓
- Method signatures conform to `4D-Method-Writing-Guide.md` naming convention ✓
- `OK` variable semantics specified for all methods ✓
- Invalid handle behaviour specified ✓
- No stray `_p` suffixes ✓

**Gap:** `OTr_SaveToBlob`, `OTr_LoadFromBlob`, `OTr_SaveToGZIP`, `OTr_LoadFromGZIP` are implemented (confirmed by Phase 9 §1.1) but are not documented within Phase 1's §1.5 addendum. These must be added.

**Gap:** `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard` are listed in Phase 1 §1.5 but Phase 20 §3 flags their implementation as unconfirmed. This must be resolved (see Issue #3 in the Review Index).

### 2.2 — Phase 2 (`OTr-Phase-002-Spec.md`)

**Version:** 1.0 | **Date:** 2026-04-07 | **Status:** Complete

Primary issue already captured in §1.3 (Date/Time storage strategy contradiction).

All other general checks pass:
- Method signatures conform ✓
- `OK` semantics specified ✓
- Invalid handle behaviour specified ✓
- Dotted-path `AutoCreateObjects` behaviour specified ✓
- `OTr_zResolvePath` internal method specified ✓
- No stray suffixes ✓

### 2.3 — Phase 3 (`OTr-Phase-003-Spec.md`)

**Version:** 0.1 | **Date:** 2026-04-01 | **Status:** Complete

All general checks pass. Version 0.1 is the lowest version in the corpus; this is not in itself a deficiency (it simply reflects that this phase has not required revision), but the date (2026-04-01) is the earliest phase spec date — predating Phase 9 and Phase 10 changes. Confirm that Phase 9 §1.1 corrections (flagging `OTr_uEqualObjects`, `OTr_uEqualStrings`, `OTr_zMapType` as undocumented) have been reflected in Phase 3 or are scheduled for documentation.

**Dependency on §1.3 resolution:** Phase 3's `OTr_ItemType` detection algorithm will require update depending on the Date/Time storage strategy decision.

### 2.4 — Phase 4 (`OTr-Phase-004-Spec.md`)

**Version:** 0.2 | **Date:** 2026-04-02 | **Status:** Complete

**Stray suffix — Contradiction with Phase 7 standard:**

Phase 4 contains stray `_p` suffixes in the following method signatures:

| Method | Parameter | Current | Correct |
|---|---|---|---|
| `OTr_uPointerToText` | `$thePointer_p` | `_p` | `_ptr` |
| `OTr_PutArrayPointer` | `$value_p` | `_p` | `_ptr` |
| `OTr_GetArrayPointer` | `$value_p` | `_p` | `_ptr` |

These are explicitly flagged in the Phase 20 Release Checklist (§3) and Phase 9 §3.

**Note:** Phase 5 stray suffixes were already fixed (Phase 5 note: "✅ FIXED"). Phase 4 fixes are outstanding.

1-based ↔ 0-based index mapping explicitly specified ✓  
`OTr_SortArrays` multi-key sort specified ✓

### 2.5 — Phase 5 (`OTr-Phase-005-Spec.md`)

**Version:** 0.3 | **Date:** 2026-04-03 | **Status:** Complete

`OTr_GetBLOB` deprecation warning specified ✓  
`OTr_GetNewBLOB` and `OTr_GetPicture` function-result variants specified ✓  
Incompatible methods cross-referenced to Phase 15 ✓  
Stray `_p` suffixes: fixed per Phase 20 note ✓

**Minor:** The `$value_pictr` parameter in `OTr_PutPointer` appears to be a typographic artefact (from `_pic` + `_ptr` confusion). Phase 5 v0.3 should be checked to confirm this was corrected when other suffixes were fixed.

### 2.6 — Phase 6 (`OTr-Phase-006-Spec.md`)

**Version:** 1.0 | **Date:** 2026-04-03 | **Status:** Complete

BLOB serialisation format explicitly specified (4D `VARIABLE TO BLOB` + `COMPRESS BLOB`) ✓  
Legacy OT BLOB incompatibility and error behaviour specified ✓  

**`OTr_BLOBToObject` offset parameter status:**

Phase 6 (line 498) states explicitly: "This parameter is not implemented in OTr." Phase 15 §4.2 marks the status as "Provisional — to be finalised in Phase 6." These two documents conflict. Phase 6 as the authoritative specification for this method should be taken as conclusive: `ioOffset` is **not implemented**. Phase 15 §4.2 requires a corresponding update to remove the "Provisional" marking and confirm the final status.

**Discrepancy with master spec §3.7:** The master specification §3.7 states BLOB storage uses `VARIABLE TO BLOB` with `COMPRESS BLOB`. Phase 6 confirms this. No discrepancy.

### 2.7 — Phase 7 (`OTr-Phase-007-Spec.md`)

**Version:** 0.3 | **Date:** 2026-04-03 | **Status:** Complete

This phase establishes the definitive type suffix table and header format standard. All method signatures reviewed in other phases were cross-checked against this standard. The Phase 4 stray `_p` suffixes are the only outstanding violation.

All internal checks pass ✓

### 2.8 — Phase 8 (`OTr-Phase-008-Spec.md`)

**Version:** 0.1 | **Date:** 2026-04-04 | **Status:** Complete

`OTr_u_AccessArrayElement` unified accessor behaviour fully specified ✓  
Retirement of `OTr_uGetArrayElement` and `OTr_uPutArrayElement` specified ✓  
No issues identified ✓

### 2.9 — Phase 9 (`OTr-Phase-009-Spec.md`)

**Version:** 0.1 | **Date:** 2026-04-05 | **Status:** Substantially Complete

**Scope and status (Review Index Issue #4):**

Phase 9 is the "Pre-Release Audit and Corrections" phase. Its scope is well-defined: consolidation of outstanding items from the Release Checklist, resolution of inconsistencies, and establishment of correct `OK` variable behaviour. It does **not** appear in the Phase 20 implementation table (confirmed: Phase 20's implementation table covers Phases 1–8, 10, 15; Phase 9 is a consolidation phase, not a feature phase, so its absence from the table is appropriate, not an oversight).

**Test method for Phase 9:** No dedicated test method is specified, and none is required — Phase 9's output is a corrected codebase, not new functionality. The absence of a test method is intentional.

**Outstanding items within Phase 9:**

The following items in Phase 9 are explicitly flagged as "Still to be written" or otherwise incomplete:

1. `OTr_zSetOK` — host database propagation (§4.1): placeholder comment; logic not yet written
2. Phase 1.5 Load methods — implementation unconfirmed (§4.2)
3. `OTr_z_Koala` and `OTr_z_Wombat` — **purpose confirmed (post-audit clarification):** these are internal utility methods that read embedded image resources of a koala and a wombat respectively, returning Picture values for use as test fixtures in Picture round-trip tests (Phase 5 and Phase 15). They are internal (`OTr_z` prefix, `"shared":false`) and do not form part of the public API. They require documentation in Phase 5 (or in Phase 9 §1.1) as test-support infrastructure, but they are not a functional gap.

### 2.10 — Phase 10 (`OTr-Phase-010-Spec.md`)

**Version:** 0.4 | **Date:** 2026-04-10 | **Status:** In Progress

All three log control levels fully defined ✓  
Sentinel file mechanism fully specified ✓  
Worker process lifecycle (startup, shutdown) fully specified ✓  
Per-process LIFO call stack specification complete ✓  
`On Host Database Event` fallback specified ✓  

**Implementation–specification divergences (documented in retired set):**

The `OTr-Phase-010-SpecImplementationChanges.md` document (in `Retired/`) records eleven divergences between the v0.3 specification and the implementation. The v0.4 specification (`OTr-Phase-010-Spec.md`) was updated to resolve most of these. Confirm that the following three high-severity items were resolved in v0.4:

| Item | Issue | Resolution in v0.4? |
|---|---|---|
| Storage schema naming | `OT_Logging.*` vs. `OTr.log*` | ✅ Resolved — v0.4 uses `Storage.OT_Logging.*` |
| UTC offset / local-time conversion | §3.2 logic missing from implementation | ⚠️ Deferred to future enhancement (noted in spec) |
| Call stack ordering | Outermost-to-innermost (reversed from prior spec) | ✅ Resolved — v0.4 clarifies outermost-to-innermost |

The UTC offset item remains deferred; this is acceptable as a documented known limitation, provided it is clearly noted in the specification and the Phase 6 release checklist.

### 2.11 — Phase 15 (`OTr-Phase-015-Spec.md`)

**Version:** 0.1 | **Date:** 2026-04-04 (+Addendum 2026-04-05) | **Status:** In Progress

Platform constraint (no macOS Tahoe) prominently documented ✓  
Test method structure specified ✓  
Final test result: 30/30 Pass (per §7 Addendum) ✓  

**Stale item — §4.2 "Provisional" status:**

Phase 15 §4.2 marks `OTr_BLOBToObject` offset parameter as "Provisional — to be finalised in Phase 6." Phase 6 has been finalised and explicitly states the parameter is not implemented. Phase 15 §4.2 should be updated to remove "Provisional" and state: "Not implemented — confirmed in Phase 6 §4.2."

**Stale item — §4.1 `OT GetArrayPicture`:**

Phase 15 §4.1 lists `OT GetArrayPicture` as unimplementable due to output-parameter constraints. Phase 15 §7.7 (Addendum) documents that `OT GetArrayPicture` is actually implemented as a function returning a Picture. The §4.1 table entry is therefore incorrect and should be removed or reclassified to §4.3 (different behaviour).

### 2.12 — Phase 20 (`OTr-Phase-020-Spec.md`)

**Version:** 0.3 | **Date:** 2026-04-04 | **Status:** Active Release Checklist

**General status:** All TODO items (35+), correctness checks, migration items, and publishing items remain unchecked (`[ ]`). This is the expected state prior to release.

**Specific items relevant to S1 findings:**

The following Phase 20 items directly inform S1 conclusions:

- `[ ]` Confirm Phase 1.5 Load methods implemented — maps to Issue #3 (Review Index)
- `[ ]` Write `____Test_Phase_5` and `____Test_Phase_6` test methods — not S1 scope (deferred to S4)
- `[ ]` Date stored as `YYYY-MM-DD` text; Time stored as `HH:MM:SS` text; round-trip verified — the resolution of Issue #1 (Date/Time storage) will determine whether this check passes
- `[ ]` `OTr_ItemType` returns legacy OT type constants — dependent on §1.3 resolution
- `[ ]` Review whether `OTr_uDateToText` etc. still required — this item supports the Date/Time resolution

### 2.13 — Phase 100 (`OTr-Phase-100-Spec.md`)

**Version:** 0.1 | **Date:** 2026-04-04 | **Status:** Future / Post-Release

Phase 100 is clearly marked as the v2.0 roadmap and out-of-scope for the current release ✓  
No action required for the current release cycle ✓

---

## Section 3 — `OTr-Types-Reference.md`

**Version:** 0.1 | **Date:** 2026-04-01

All 4D type constants in use across the spec corpus are listed ✓  
Legacy OT type constant values are present ✓  
Type suffix table present ✓  

**Dependency on §1.3 resolution:**

`OTr-Types-Reference.md` explicitly states for `Is date (4)`: "Stored as `YYYY-MM-DD` text" and for `Is time (11)`: "Stored as `HH:MM:SS` text". If the resolution of §1.3 determines that native `OB SET` is the correct approach, these storage notes require updating.

**Minor — version date:**

The reference carries date 2026-04-01, predating Phase 7 (2026-04-03) and Phase 9 (2026-04-05). Confirm the type suffix table in `OTr-Types-Reference.md` is consistent with Phase 7's definitive table. On cross-check, the two tables are consistent. No action required beyond confirming the date at next revision.

---

## Section 4 — `OK is Set to Zero` Materials

**Classification: Gap (Severity: High)**

The `Documentation/Specifications/OK is Set to Zero/` directory referenced in the S1 review scope **does not exist** on the filesystem. No `OTr-OK0-Conditions.txt` file was found, nor any `.xlsx`, `.pdf`, or `.numbers` counterparts.

This is a significant gap: the S1 checklist mandates that `OTr-OK0-Conditions.txt` list every method and its `OK`-setting behaviour, and that it be consistent with the phase spec descriptions. Without this document, cross-verification cannot be performed.

**Required action:** Create the `OK is Set to Zero/` directory and the `OTr-OK0-Conditions.txt` file. Phase 9 §2 contains a comprehensive reference table of legacy `OK` behaviour (§2.2, lines 72–168) that serves as the authoritative source for this file. The `OTr-OK0-Conditions.txt` should be populated from Phase 9 §2 and cross-verified against the phase spec descriptions.

---

## Section 5 — Retired Documents

**Location:** `Documentation/Specifications/Retired/`

**Files confirmed present:**

| File | Supersedes | Status |
|---|---|---|
| `OTr-Phase-004-Spec-Retired.md` (v0.2, 2026-04-02) | Active Phase 4 | ✓ |
| `OTr-Phase-005-Spec-Retired.md` (v0.3, 2026-04-03) | Active Phase 5 | ✓ |
| `OTr-Phase-006-Spec-Retired.md` (v0.1, 2026-04-01) | Active Phase 6 | ✓ |
| `OTr-Phase-020-Spec-Retired.md` | Current Phase 20 v0.3 | ✓ |
| `OTr-Specification-Retired.md` (v0.5, 2026-03-31) | Active master spec | ✓ |
| `OTr-Phase-010-Spec-Retired.md` (v0.3, 2026-04-06) | Phase 10 v0.4 | ✓ |
| `OTr-Phase-010-Spec-Retired2.md` | Phase 10 v0.4 | ✓ |
| `OTr-Phase-010-SpecImplementationChanges.md` (2026-04-10) | Reference — analysis | ✓ |
| `CHANGELOG-OTr-Phase-010-v0.4.md` (2026-04-10) | Reference — changelog | ✓ |

**Supersession notices:** No formal "superseded by" header notices were found in the retired files. This is a minor gap — it is conventional to include a notice at the top of each retired document directing the reader to its replacement.

**Content dropped check — Phase 4 and Phase 5 retired documents:**

The retired Phase 4 and Phase 5 documents carry the same version numbers (v0.2 and v0.3 respectively) as the current active documents. This suggests the files in `Retired/` are copies of the active files at the point of retirement, not earlier versions. No content drop is expected. Cross-verification confirms no material differences between the retired and active versions for Phases 4 and 5.

**Phase 6 retired document:** The retired Phase 6 document (v0.1, 2026-04-01) predates the current Phase 6 (v1.0, 2026-04-03). The v0.1 document describes an earlier serialisation approach that was superseded. The current v1.0 is a substantial rewrite; the retired document is preserved for historical reference. No content from the retired document was identified as having been inadvertently dropped from v1.0.

**`OTr-Phase-010-SpecImplementationChanges.md`:** This is a valuable analysis document recording eleven divergences between Phase 10 v0.3 and its implementation. Its content informed the v0.4 update recorded in `CHANGELOG-OTr-Phase-010-v0.4.md`. Both documents should be retained in `Retired/` as reference material for S3 and S6. No action required.

**`CHANGELOG-OTr-Phase-010-v0.4.md`:** Confirms the major changes made from v0.3 to v0.4. Cross-verified against the current Phase 10 specification — all documented changes are reflected in v0.4. No content has been dropped.

---

## Section 6 — Consolidated Findings

### 6.1 — Contradictions

| ID | Documents | Description | Severity |
|---|---|---|---|
| C-01 | Master spec §3.6, Phase 2, Phase 3, Phase 4, Phase 5, OTr-Types-Reference.md | Date/Time scalar storage: native `OB SET` (Phase 2) vs formatted text `YYYY-MM-DD`/`HH:MM:SS` (all others) — **RESOLVED 2026-04-11** (see §1.3 addendum) | ~~Critical~~ Closed |
| C-02 | Phase 6 §4.2, Phase 15 §4.2 | `OTr_BLOBToObject` offset parameter: Phase 6 says "not implemented"; Phase 15 says "Provisional" — **RESOLVED 2026-04-11**: Phase 15 §4.2 updated to "Not implemented — confirmed Phase 6" | ~~High~~ Closed |
| C-03 | Phase 15 §4.1, Phase 15 §7.7 | `OT GetArrayPicture`: §4.1 lists as unimplementable; §7.7 confirms it is implemented as function — **RESOLVED 2026-04-11**: entry removed from §4.1 and added to §4.3 with correct description | ~~Medium~~ Closed |

### 6.2 — Gaps

| ID | Document(s) | Description | Severity |
|---|---|---|---|
| G-01 | `OK is Set to Zero/` | Directory does not exist; `OTr-OK0-Conditions.txt` absent — **RESOLVED 2026-04-11**: directory created; `OTr-OK0-Conditions.txt` populated from Phase 9 §2.2 | ~~High~~ Closed |
| G-02 | Master spec §6.12, Phase 1 §1.5 | `OTr_SaveToBlob`, `OTr_LoadFromBlob`, `OTr_SaveToGZIP`, `OTr_LoadFromGZIP` undocumented — **RESOLVED 2026-04-11**: Phase 1 Addendum 1.5b added with signatures and format comparison table | ~~High~~ Closed |
| G-03 | Phase 1 §1.5, Phase 20 §3 | `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard` — implementation unconfirmed — **RESOLVED 2026-04-11**: all three `.4dm` files confirmed present; Phase 20 checklist item ticked | ~~High~~ Closed |
| G-04 | Master spec §3.4 | Thread safety / reentrancy design decision not documented — **RESOLVED 2026-04-11**: reentrant lock count implemented via `OTR_LockCount_i`; master spec §3.4 and Phase 9 §5.7 updated | ~~Medium~~ Closed |
| G-05 | Phase 3 | `OTr_uEqualObjects`, `OTr_uEqualStrings`, `OTr_zMapType` undocumented (Phase 9 §1.1) | Medium — Open |
| G-06 | Phase 4 | `OTr_ArrayType`, `OTr_uNewValueForEmbeddedType`, `OTr_zArrayFromObject`, `OTr_zArrayType`, `OTr_zSortFillSlot`, `OTr_zSortSlotPointer`, `OTr_zSortValidatePair` undocumented (Phase 9 §1.1) | Medium — Open |
| G-07 | Phase 9 §1.1 | `OTr_z_Koala` and `OTr_z_Wombat` — purpose confirmed (see §2.9); documentation gap only | Low — Open |
| G-08 | Phase 9 §4.1 | `OTr_zSetOK` host-database propagation logic "still to be written" — **RESOLVED 2026-04-11**: propagation implemented via `EXECUTE METHOD("OT Host CheckVariable"; *; "OK"; String($newOK))`; Phase 9 §4.1 updated with full mechanism documentation | ~~Medium~~ Closed |
| G-09 | Retired/ | No formal supersession notices in retired document headers — **RESOLVED 2026-04-11**: supersession banner prepended to all 7 retired files | ~~Low~~ Closed |
| G-10 | Master spec | Version number (0.5) not updated since 2026-03-31; out of date relative to Phase 10 (2026-04-10) | Low — Open (update after all corrections applied) |

### 6.3 — Stale Content

| ID | Document | Description | Severity |
|---|---|---|---|
| ST-01 | Phase 15 §4.2 | "Provisional" marking on `ioOffset` parameter; superseded by Phase 6 v1.0 decision — **RESOLVED 2026-04-11** (see C-02) | ~~High~~ Closed |
| ST-02 | Phase 15 §4.1 | `OT GetArrayPicture` listed as unimplementable; superseded by §7.7 Addendum — **RESOLVED 2026-04-11** (see C-03) | ~~Medium~~ Closed |
| ST-03 | Master spec | Duplicate §7 heading (Type Constant Mapping / Command Reference) — **RESOLVED 2026-04-11**: first §7 "Type Constant Mapping" block removed; section numbering now unique | ~~Low~~ Closed |

### 6.4 — Parameter Naming Issues

| ID | Document | File(s) | Current | Correct |
|---|---|---|---|---|
| P-01 | Phase 4 (spec and source) | `OTr_uPointerToText.4dm` | `$thePointer_p` | `$thePointer_ptr` | **RESOLVED 2026-04-11** |
| P-02 | Phase 4 (spec and source) | `OTr_PutArrayPointer.4dm` | `$value_p` | `$value_ptr` | **RESOLVED 2026-04-11** (spec only; source already correct per Phase 9) |
| P-03 | Phase 4 (spec and source) | `OTr_GetArrayPointer.4dm` | `$value_p` | `$value_ptr` | **RESOLVED 2026-04-11** (spec only) |
| P-04 | Phase 9 §3 (source only) | `OTr_uTextToPointer.4dm` | `$thePointer_p` (comment) | `$thePointer_ptr` | **RESOLVED 2026-04-11** |
| P-05 | Phase 9 §3 (source only) | `OTr_zSortSlotPointer.4dm` | `$ptr_p` | `$ptr_ptr` | **RESOLVED 2026-04-11** |

---

## Section 7 — Recommended Actions (Prioritised)

### Priority 1 — Must resolve before S3 and S6

1. ~~**C-01 (Date/Time storage):** Confirm the actual implementation strategy.~~ **CLOSED 2026-04-11** — resolved with per-call `OTr_uNativeDateInObject` probe and If/Else guards.

2. ~~**C-02 (`ioOffset` status):** Update Phase 15 §4.2 to remove "Provisional" and confirm "Not implemented" per Phase 6.~~ **CLOSED 2026-04-11**

3. ~~**G-01 (OK is Set to Zero directory):** Create the directory and `OTr-OK0-Conditions.txt`, populating from Phase 9 §2.2.~~ **CLOSED 2026-04-11**

### Priority 2 — Should resolve before release gate (S6)

4. ~~**G-02 (Missing Phase 1.5 methods in spec):** Add `OTr_SaveToBlob`, `OTr_LoadFromBlob`, `OTr_SaveToGZIP`, `OTr_LoadFromGZIP` to Phase 1 §1.5 and master spec §6.12.~~ **CLOSED 2026-04-11** — Phase 1 Addendum 1.5b added.

5. ~~**G-03 (Phase 1.5 Load method implementation):** Confirm implementation of `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard`. Update Phase 20 checklist item accordingly.~~ **CLOSED 2026-04-11**

6. ~~**P-01 through P-05 (Stray `_p` suffixes):** Apply corrections to Phase 4 spec and to source files per Phase 20 §3 items.~~ **CLOSED 2026-04-11**

7. ~~**C-03 / ST-02 (`OT GetArrayPicture` in Phase 15 §4.1):** Move entry from §4.1 to §4.3 with updated description of the actual (function-result) implementation.~~ **CLOSED 2026-04-11**

8. **G-05 / G-06 (Undocumented methods):** Document `OTr_uEqualObjects`, `OTr_uEqualStrings`, `OTr_zMapType` in Phase 3; document array-related undocumented methods in Phase 4. — **Open**

### Priority 3 — Should resolve before release; low risk if deferred

9. ~~**G-04 (Thread safety decision):** Document the reentrancy decision in master spec §3.4.~~ **CLOSED 2026-04-11** — reentrant lock count implemented and documented.

10. **G-07 (`OTr_z_Koala` / `OTr_z_Wombat`):** Purpose confirmed — picture test fixtures returning koala and wombat images respectively. Document in Phase 5 §x or Phase 9 §1.1 as test-support infrastructure (`OTr_z` prefix, internal, not shared). — **Open**

11. ~~**G-08 (`OTr_zSetOK` host propagation):** Write and document the host-database propagation logic.~~ **CLOSED 2026-04-11** — propagation confirmed implemented; Phase 9 §4.1 updated.

12. ~~**ST-03 (Duplicate §7 in master spec):** Renumber to eliminate duplicate section heading.~~ **CLOSED 2026-04-11**

13. ~~**G-09 (Retired document headers):** Add supersession notices to each retired document.~~ **CLOSED 2026-04-11**

14. **G-10 (Master spec version/date):** Update version number and date after all corrections applied. — **Open (apply last)**

---

## Section 8 — Confirmation of OK is Set to Zero Coverage

The `OTr-OK0-Conditions.txt` file does not exist (see G-01). The following table summarises what is confirmed from Phase 9 §2 and should serve as the basis for creating that file.

The pattern across all methods is:
- **Sets `OK` to 0** on any error condition (invalid handle, missing tag with `FailOnItemNotFound` set, type mismatch, invalid path)
- **Sets `OK` to 1** only on methods where the legacy ObjectTools command was documented as explicitly setting `OK` on success
- **Does not modify `OK`** (i.e., neither sets 1 on success nor 0 on error) is not a valid pattern — all methods with error paths must at minimum set `OK := 0` on error

Methods confirmed as requiring `OK := 1` on success (from Phase 9 §2.2 and Phase 15 §7.2 retrospective fixes): `OTr_ObjectSize`, `OTr_GetString`, `OTr_GetText`, `OTr_CopyItem`, `OTr_DeleteItem`, `OTr_ItemType`, `OTr_ObjectToBLOB`, `OTr_BLOBToObject`, `OTr_RenameItem`, `OTr_ObjectSize`.

All remaining public API methods: `OK := 0` on error; no explicit `OK := 1` on success.

---

*End of S1 Findings Report*
