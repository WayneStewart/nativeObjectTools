# Review Session S4 — Test Coverage Audit

**Version:** 1.0
**Date:** 2026-04-11
**Author:** Wayne Stewart / Claude
**Dependencies:** None — may be commenced immediately
**Parallel with:** S1, S2, S5 (fully independent)

---

## Purpose

Audit the existing unit test suite against the phase specifications to identify gaps in coverage, assess the quality of existing tests, and produce a prioritised list of additional tests required before release. This session does not require running the tests — it is a static review of test method source against the spec.

---

## Scope

### Test methods to review

| Test method | Phase covered |
|---|---|
| `____Test_Phase_1.4dm` | Phase 1 — Core infrastructure |
| `____Test_Phase_1_5.4dm` | Phase 1.5 — Simple export/import |
| `____Test_Phase_2.4dm` | Phase 2 — Scalar put/get |
| `____Test_Phase_3.4dm` | Phase 3 — Item introspection |
| `____Test_Phase_4_Arrays.4dm` | Phase 4 — Array operations |
| `____Test_Phase_5.4dm` | Phase 5 — Complex types |
| `____Test_Phase_6.4dm` | Phase 6 — Import/export |
| `____Test_Phase_8.4dm` | Phase 8 — Unified array element accessor |
| `____Test_Phase_10.4dm` | Phase 10 — Logging (combined) |
| `____Test_Phase_10a.4dm` | Phase 10a — Logging subtest A |
| `____Test_Phase_10b.4dm` | Phase 10b — Logging subtest B |
| `____Test_Phase_10c.4dm` | Phase 10c — Logging subtest C |
| `____Test_Phase_10_OT.4dm` | Phase 10 — OT variant |
| `____Test_Phase_10_OTr.4dm` | Phase 10 — OTr variant |
| `____Test_Phase_10a_OT.4dm` | Phase 10a — OT variant |
| `____Test_Phase_10a_OTr.4dm` | Phase 10a — OTr variant |
| `____Test_Phase_10b_OT.4dm` | Phase 10b — OT variant |
| `____Test_Phase_10b_OTr.4dm` | Phase 10b — OTr variant |
| `____Test_Phase_10c_OT.4dm` | Phase 10c — OT variant |
| `____Test_Phase_10c_OTr.4dm` | Phase 10c — OTr variant |
| `____Test_Phase_15.4dm` | Phase 15 — Side-by-side compatibility |
| `____Test_Phase_15_OT.4dm` | Phase 15 — OT side |
| `____Test_Phase_15_OTr.4dm` | Phase 15 — OTr side |
| `____Test_Phase_All.4dm` | All phases (integration runner?) |

### Notable absences (gaps confirmed before this session)

| Missing test method | Phase | Note |
|---|---|---|
| `____Test_Phase_7.4dm` | Phase 7 — API Naming Alignment | No test method found |
| `____Test_Phase_9.4dm` | Phase 9 — (confirm scope) | No test method found |

---

## Review Checklist

### 1. Coverage mapping

For each test method, open the source and produce a list of what is actually tested:

- [ ] Which `OTr_` methods are exercised (directly called)?
- [ ] Which methods from the relevant phase spec are **not** exercised?
- [ ] Does the test method include negative / error-path tests (invalid handles, bad inputs, boundary conditions)?
- [ ] Does the test method include edge cases from the phase spec (e.g., 1-based/0-based boundary, `AutoCreateObjects`, type-specific round-trips)?

### 2. Test method quality

For each test method:

- [ ] Is the pass/fail output clear and specific (does it identify which assertion failed)?
- [ ] Are test handles cleaned up (every `OTr_New` matched with an `OTr_Clear`) to prevent handle leak across tests?
- [ ] Does the test method run standalone without requiring a specific database state or external file?
- [ ] Does the test method leave the OTr registry in a clean state after completion?

### 3. Phase-specific gaps

#### Phase 1 / 1.5
- [ ] Slot reuse tested: clear a handle, create a new one, verify it occupies the same slot
- [ ] Tail trimming tested: clear trailing handles, verify array shrinks
- [ ] `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard` tested (or flagged as untested if unimplemented)

#### Phase 2
- [ ] Dotted-path creation (`AutoCreateObjects` on): multi-level path tested
- [ ] Dotted-path failure (`AutoCreateObjects` off): intermediate object not auto-created
- [ ] All scalar types round-tripped: Long, Real, Text, Boolean, Date, Time
- [ ] Boolean return value tested as Integer (0/1), not Boolean
- [ ] Date/Time storage strategy confirmed by test (native vs formatted text)

#### Phase 3
- [ ] `OTr_ItemType` tested for every type constant (not just common ones)
- [ ] `OTr_ItemType` on missing tag tested
- [ ] `OTr_ItemList` order tested (insertion order? alphabetical?)
- [ ] `OTr_DeleteItem` on non-existent tag tested

#### Phase 4 — Arrays
- [ ] 1-based index boundary: first element (index 1 → Collection index 0) and last element tested
- [ ] Out-of-bounds index: Get returns default, `OK=0`
- [ ] Multi-key sort with mixed ascending/descending tested
- [ ] All typed array Put/Get methods round-tripped (not only common types)

#### Phase 5 — Complex types
- [ ] Per Phase 20 TODO: `____Test_Phase_5` covering all complex type round-trips — confirm this now exists and what it covers
- [ ] `OTr_GetBLOB` deprecation warning tested
- [ ] `OTr_PutObject` / `OTr_GetObject` deep-copy semantics tested (modify returned object, verify stored object unchanged)
- [ ] Pointer round-trip with `->` syntax tested
- [ ] `OTr_GetArrayPointer` function-result signature tested

#### Phase 6 — Import/export
- [ ] Per Phase 20 TODO: `____Test_Phase_6` covering BLOB serialisation round-trips — confirm this now exists
- [ ] Legacy OT BLOB rejection (magic-byte check) tested
- [ ] Round-trip with all types including native BLOB and Picture tested

#### Phase 7 — API Naming Alignment
- [ ] **No test method exists** — determine whether Phase 7 is testable (it is primarily a naming/documentation alignment phase) or whether the audit in S2 constitutes sufficient verification
- [ ] If testable, recommend creation of `____Test_Phase_7.4dm`

#### Phase 8 — Unified array element accessor
- [ ] All supported element types tested via the unified accessor
- [ ] Type-mismatch error behaviour tested

#### Phase 9
- [ ] Confirm scope of Phase 9 and what `____Test_Phase_9.4dm` would need to cover (or why none exists)

#### Phase 10 — Logging
- [ ] Worker process startup and shutdown tested
- [ ] Log file created in correct directory with correct naming convention
- [ ] Session rotation tested (size threshold exceeded → new file)
- [ ] Log level gating tested: `off` produces no output, `info` produces info entries, `debug` produces debug entries
- [ ] Sentinel file override tested
- [ ] `OTr_LogLevel` getter/setter tested
- [ ] Per-process call stack (LIFO) tested
- [ ] Error log entry with call-stack traceback tested

#### Phase 15 — Side-by-side compatibility
- [ ] Platform constraint is noted in the test method (cannot run on macOS Tahoe)
- [ ] All methods with known incompatibilities (Phase 15 §4) are tested, with expected differences documented in the test method
- [ ] `____Test_OT_Compatibility` exists and covers the full incompatibility catalogue

### 4. `____Test_Phase_All.4dm`

- [ ] Confirm this is a runner that calls all individual test methods in sequence
- [ ] Confirm it fails fast (stops on first failure) or collects all failures — document behaviour
- [ ] Confirm all existing test methods are called from this runner

---

## Expected Outputs

1. A coverage matrix: each public API method vs test status (tested / partially tested / untested)
2. A prioritised list of missing test cases, grouped by phase, with specific test scenarios described
3. A recommended test for Phase 7 (or a documented rationale for why none is required)
4. Confirmation or otherwise that Phase 5 and Phase 6 test methods now exist and cover the scenarios listed in Phase 20 TODO
5. An assessment of test method quality (handle cleanup, output clarity, isolation)

---

## Notes for the Reviewer

Read each test method source in full. The test methods are the most reliable indicator of what the implementation actually does — discrepancies between the test and the spec often reveal either a spec error or an implementation gap.

Note that Phase 10 has an unusually large number of test methods (twelve, counting OT/OTr variants and sub-tests). Understanding the structure of these before assessing coverage will save time.

The Phase 15 tests (`____Test_Phase_15_OT.4dm`, `____Test_Phase_15_OTr.4dm`) cannot be run in the current environment (macOS Tahoe). The static review here should focus on whether the test method source is complete and correct, independent of whether it can currently be executed.
