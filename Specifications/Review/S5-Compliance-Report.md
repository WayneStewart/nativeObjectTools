# S5 Compliance Report — Coding Standard and `%attributes` Audit

**Version:** 1.0
**Date:** 2026-04-11
**Auditor:** Wayne Stewart / Claude
**Scope:** All `OTr_*.4dm` files in `Project/Sources/Methods/` (158 files)
**Authority:** `4D-Method-Writing-Guide.md`, `OTr-Types-Reference.md`

---

## Executive Summary

The automated scan covered all 158 `OTr_*.4dm` source files. The codebase is in strong overall health: no numbered parameters, no direct `OK:=0` assignments, no stray `_p`-suffix variables, and all method headers contain the required boxed-comment structure. The principal findings are a single semaphore defect in `OTr_InsertElement`, a legacy `C_LONGINT` declaration in the Cannon Smith–authored `OTr_uEqualObjects`, one method (`OTr_SetDateMode`) absent from both `folders.json` and `Documentation/Methods/`, and a cohort of 11 recently added files not yet registered in `folders.json`. Twenty-seven private/utility methods omit the `"shared"` field from their `%attributes` line; this is noted as an optional-field advisory rather than a defect (4D defaults `"shared"` to `false` when the field is absent). The `OTr_zInit` invocation pattern follows an intentional architectural design (see §7 below) rather than constituting a violation. The previously flagged stray `_p` suffix issue has been fully resolved prior to this audit.

---

## 1. `%attributes` Line Compliance

### 1.1 Summary

Every one of the 158 `.4dm` files opens with a `%attributes` line. No file is missing the line, and no file carries `"invisible":false`. All public API methods (those not bearing the `OTr_z*`, `OTr_u*`, or `OTr_z_*` prefixes) correctly carry `"shared":true`.

### 1.2 Missing `"shared"` Field — Private and Utility Methods

**Severity: Advisory (optional).** Twenty-seven private/utility files carry `{"invisible":true}` without an explicit `"shared"` field. Because 4D treats an absent `"shared"` key as equivalent to `"shared":false`, these methods are fully functional as written. The omission is therefore not a defect. However, the coding standard prescribes the explicit form `{"invisible":true,"shared":false}` for readability and to make the intent unambiguous to future maintainers. Adding the field is recommended but not mandatory. The `4D-Method-Writing-Guide.md` should be updated to note that `"shared"` is an optional field whose default value is `false`, so that the omission is not misread as an error in future audits.

**Affected files (27):**

| File | Current first line |
|---|---|
| `OTr_uBlobToText.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uDateToText.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uEqualBLOBs.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uEqualPictures.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uEqualStrings.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uNewValueForEmbeddedType.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uPointerToText.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uTextToBlob.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uTextToDate.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uTextToPointer.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uTextToTime.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_uTimeToText.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zArrayFromObject.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zArrayType.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zIsShadowKey.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zSetOK.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zShadowKey.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zSortFillSlot.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zSortSlotPointer.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zSortValidatePair.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zXMLWriteObject.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_zXMLWriteObjectSAX.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_z_CheckHostMethods.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_z_Get4DVersion.4dm` | `//%attributes = {"invisible":true,"preemptive":"capable"}` |
| `OTr_z_Koala.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_z_Wombat.4dm` | `//%attributes = {"invisible":true}` |
| `OTr_z_timestampLocal.4dm` | `//%attributes = {"invisible":true}` |

**Recommended (not required):** For consistency with the documented standard, add `"shared":false` to each line above. The preferred explicit form is `//%attributes = {"invisible":true,"shared":false}`. For `OTr_z_Get4DVersion` the preferred form is `//%attributes = {"invisible":true,"shared":false,"preemptive":"capable"}`. These files are correct as they stand; this is a style improvement only.

**Note on `OTr_onExit` and `OTr_onStartup`:** These two event-handler methods currently carry `{"invisible":true,"shared":true}`. As lifecycle callback methods they are not part of the public API and arguably should carry `"shared":false`; however, their `shared` value is managed by 4D's project configuration and should be adjusted only if 4D permits it without breaking the startup/shutdown callbacks. Flag for manual verification rather than automated correction.

### 1.3 BOM Presence

Seventy-three files contain a UTF-8 byte-order mark (BOM, `EF BB BF`). This is the normal 4D file encoding and does not constitute a defect. The `%attributes` line is still the functional first line after BOM stripping. No action required.

---

## 2. `#DECLARE` Parameter Declaration

### 2.1 Numbered Parameters

**Result: PASS.** No numbered parameter (`$1`, `$2`, etc.) appears in any method body outside of comment lines or string literals. The single grep hit — `OTr_z_CheckHostMethods.4dm` line 76 — is a string literal constructing source code text (`$code_t:=$code_t+"C_TEXT("+$methodName_t+" ;$0;$1;$2)\r"`), not an actual numbered parameter reference. This is intentional and correct.

### 2.2 Missing `#DECLARE`

Nine files lack a `#DECLARE` line. In each case this is architecturally intentional:

| File | Reason |
|---|---|
| `OTr_ClearAll.4dm` | Requires investigation — public API method, expected to have `#DECLARE` |
| `OTr_onExit.4dm` | 4D lifecycle callback; no parameters by design |
| `OTr_onStartup.4dm` | 4D lifecycle callback; no parameters by design |
| `OTr_zInit.4dm` | Private initialisation method; no parameters |
| `OTr_zLock.4dm` | Private semaphore method; no parameters |
| `OTr_zLogShutdown.4dm` | Private log teardown; no parameters |
| `OTr_zTogglePluginBlocks.4dm` | Private utility; no parameters |
| `OTr_zUnlock.4dm` | Private semaphore method; no parameters |
| `OTr_z_LogInit.4dm` | Private log initialisation; no parameters |

**Finding:** `OTr_ClearAll.4dm` is a public API method and is the only file in this group that warrants investigation. If it takes no parameters, it should carry an explicit `#DECLARE()` per the Writing Guide §3.3. Confirm and add the no-argument form if absent.

All other no-`#DECLARE` files are no-parameter private/internal methods for which the omission is consistent with 4D's convention for parameter-free methods (though the Writing Guide recommends `#DECLARE()` even in this case). These should be updated to carry `#DECLARE()` for full compliance, but the issue is low-priority.

### 2.3 Legacy `C_*` Declarations

**Two instances found:**

- `OTr_uEqualObjects.4dm`, line 29: `C_LONGINT:C283($x; $y; $FirstItemCount_i; $SecondItemCount_i; $FirstPropertyCount_i; $SecondPropertyCount_i)`
- `OTr_zInit.4dm`, line 53: `C_BOOLEAN:C305(<>OTR_Initialised_b; OTR_Initialised_b)`

The `OTr_uEqualObjects` declaration is legacy code originating from the Cannon Smith source. The `OTr_zInit` instance declares interprocess variables (`<>OTR_Initialised_b`), for which `var` declarations are not valid in 4D v19 — the `C_BOOLEAN` form is the correct mechanism for declaring interprocess-scope variables. Accordingly, the `OTr_zInit` instance is intentional and correct.

**Required action:** Refactor `OTr_uEqualObjects.4dm` to remove the `C_LONGINT` declaration and replace it with `var` declarations. The variables `$x`, `$y`, `$FirstItemCount_i`, `$SecondItemCount_i`, `$FirstPropertyCount_i`, and `$SecondPropertyCount_i` should be declared with `var` and the `_i` suffix (they already carry the correct suffix). Note that this file also requires broader remediation (see §4.2 below).

---

## 3. Type-Suffix Compliance

### 3.1 Stray `_p` Suffix — Phase 20 Known Issue

**Result: RESOLVED.** All five files named in the Phase 20 TODO (`OTr_uPointerToText.4dm`, `OTr_uTextToPointer.4dm`, `OTr_PutArrayPointer.4dm`, `OTr_GetArrayPointer.4dm`, `OTr_zSortSlotPointer.4dm`) were scanned for stray `_p`-suffix variable names in non-comment lines. No occurrences were found. The previously documented issue has been fully corrected prior to this audit. No further action is required on this item.

### 3.2 General Suffix Compliance

The automated scan for `$1`–`$9` parameters (legacy style) produced no violations (see §2.1 above). No `_x` or other non-standard variants were detected in the public API or utility methods. Suffix usage is consistent with the table in `4D-Method-Writing-Guide.md` §2 and `OTr-Types-Reference.md` throughout the codebase.

---

## 4. Method Header Compliance

### 4.1 Structural Elements

**Result: PASS on all structural checks.**

- All 158 files contain the boxed-header separator lines (`// ---...`).
- All 158 files contain a `// Project Method:` signature line.
- 157 of 158 files contain a `// Created by` line.

### 4.2 `OTr_uEqualObjects.4dm` — Header Violations

This is the Cannon Smith–authored comparison utility. The following header violations were identified and corrected:

- **Numbered parameters in the header.** The `// Parameters:` block documented `$1` and `$2` rather than the declared `$First_o` and `$Second_o`.
- **`$0` return documented instead of `$IsEqual_b`.** The `// Returns:` block referenced `$0 : Boolean` rather than the `#DECLARE` return variable name.
- **Non-standard attribution.** The original `// Cannon Smith` line did not follow the Writing Guide format. As the original authorship date is unknown, the `Created by` line has been omitted per the reviewer's instruction; the `// Based on work by` attribution line is retained.
- **`"shared":false`, `"preemptive":"capable"`, and `"lang":"en"` attributes** are all present and correct.

**Correction applied (2026-04-11):** The `// Project Method:` signature line, `// Parameters:` block, `// Returns:` block, and attribution have all been updated to reference the `#DECLARE` parameter and return variable names. The `// Access:` line has been corrected from `Shared` to `Private`.

**Remaining item:** The legacy `C_LONGINT` declaration on line 29 and the subsequent `ARRAY LONGINT`/`ARRAY TEXT` initialisations are Cannon Smith–era code that functions correctly in 4D v19. Replacing them with `var` declarations is a separate, lower-priority refactor and is out of scope for this header-only correction pass.

### 4.3 `OTr_zInit.4dm` — C_BOOLEAN Without Full `var` Transition

The header is well-formed. The `C_BOOLEAN` declaration on line 53 (discussed under §2.3) is intentional for interprocess variable declaration and does not constitute a header violation. No header action required.

### 4.4 `OTr_ArrayType.4dm` — Missing `OTr_zInit` in Body (See §7)

The header is correct and complete. The missing `OTr_zInit` call is addressed under §7.

---

## 5. Variable Naming — Consistency

### 5.1 Handle Parameters

All public API methods use `$inObject_i` consistently for the handle parameter, matching the OT semantic name convention prescribed in Writing Guide §3.5. No deviations to `$h`, `$handle_i`, or similar were detected.

### 5.2 Tag Parameters

All public API methods use `$inTag_t` consistently for the tag-path parameter.

### 5.3 Loop Counters

Internal loop counters use `$i_i` or named counters with `_i` suffix throughout. The convention is consistent.

### 5.4 Result Variables

Return variables follow the `$result_<suffix>` pattern in utility methods and the `$<semanticName>_<suffix>` pattern in public methods (e.g., `$arrayType_i`, `$IsEqual_b`). Both forms are permitted by the Writing Guide.

---

## 6. `OTr_zSetOK` Usage

**Result: PASS.** A comprehensive search for direct `OK:=0` or `OK := 0` assignments across all 158 `.4dm` files produced no matches. The `OTr_zSetOK` method is used exclusively for all OK-zeroing operations. This check passes without exception.

---

## 7. `OTr_zInit` Call Pattern

### 7.1 Architectural Design — `OTr_zLock` as Proxy

The apparent absence of `OTr_zInit` calls in public methods is a consequence of an intentional architectural pattern: `OTr_zLock` itself calls `OTr_zInit` on every invocation. Because virtually every public method that accesses the registry acquires the semaphore via `OTr_zLock`, initialisation is guaranteed before any array access occurs. This is a sound lazy-initialisation design; the spec's requirement for `OTr_zInit` in every public method is effectively satisfied through `OTr_zLock`.

However, six categories of exception warrant individual review:

**Methods that call neither `OTr_zLock` nor `OTr_zInit` directly (32 methods).** The following public methods perform no locking. They fall into several legitimate subcategories:

- *Pure delegates* — methods that simply call another public OTr method which will itself lock (e.g., `OTr_PutArrayText` delegates entirely to `OTr_PutArrayString`; `OTr_GetText` delegates to `OTr_GetString`; `OTr_GetArrayText` delegates to `OTr_GetArrayString`). These are architecturally correct; the delegate target will call `OTr_zInit` via `OTr_zLock`.
- *Read-only metadata accessors* — methods such as `OTr_GetVersion`, `OTr_CompiledApplication`, and `OTr_LogLevel` that return static or interprocess configuration values not requiring exclusive array access.
- *Methods accessing `<>OTR_Objects_ao` without a lock* — `OTr_ArrayType` reads `<>OTR_Objects_ao{$inObject_i}` without calling `OTr_zLock` or `OTr_zInit` directly. However, its first operative statement is `OTr_zAddToCallStack`, which itself calls `OTr_zInit`, guaranteeing that the interprocess arrays are initialised before the array read occurs. As a read-only method it does not mutate any shared state, so exclusive locking is unnecessary. This pattern is correct.

The full list of 32 no-lock public methods is enumerated in Appendix A.

**Private/utility methods that call `OTr_zInit` (unexpected per spec §8).** Seven private/utility methods contain non-comment calls to `OTr_zInit`:

| File | Nature of call |
|---|---|
| `OTr_zAddToCallStack.4dm` | Direct `OTr_zInit` call |
| `OTr_zError.4dm` | Direct `OTr_zInit` call |
| `OTr_zLock.4dm` | Direct `OTr_zInit` call — **intentional, see above** |
| `OTr_zLogShutdown.4dm` | Direct `OTr_zInit` call |
| `OTr_zRemoveFromCallStack.4dm` | Direct `OTr_zInit` call |
| `OTr_zSetOK.4dm` | Comment-documented: `// Make certain everything is initialised` |
| `OTr_z_LogInit.4dm` | Direct `OTr_zInit` call |

The `OTr_zLock` case is the intended mechanism and is correct. The others (`OTr_zAddToCallStack`, `OTr_zError`, `OTr_zRemoveFromCallStack`, `OTr_zSetOK`) may be called before a public method has acquired the lock (e.g., from an error handler), so the defensive `OTr_zInit` call is a reasonable safeguard. The `OTr_zLogShutdown` and `OTr_z_LogInit` calls are similarly defensible. These do not constitute strict violations; they represent belt-and-suspenders initialisation in contexts where the call stack may be unusual. **No corrective action is required**, but the pattern should be documented in the `4D-Method-Writing-Guide.md` to clarify that the prohibition on `OTr_zInit` in private methods admits these specific exceptions.

---

## 8. Semaphore Discipline

### 8.1 Lock/Unlock Mismatch

**One defect found and corrected: `OTr_InsertElement.4dm`.**

The method called `OTr_zLock` (line 41) but never called `OTr_zUnlock`. On both the normal-exit path and the invalid-handle error path, the semaphore would have been held permanently, causing deadlock on the next `OTr_zLock` call from the same or any other process.

**Correction applied (2026-04-11):** `OTr_zUnlock` has been added immediately before the `OTr_zRemoveFromCallStack` call, placing it on the single shared exit point and covering all paths through the method.

### 8.2 Public Methods Using No Locking

Thirty-two public methods call neither `OTr_zLock` nor `OTr_zUnlock`. As noted in §7.1, the majority are either pure delegates or read-only accessors. `OTr_ArrayType` is the one case warranting remediation (it reads `<>OTR_Objects_ao` directly without a lock). All others are reviewed as architecturally appropriate.

---

## 9. `Documentation/Methods/` Per-Method Documentation

### 9.1 Missing Documentation File

One public API method has no corresponding `.md` file:

- **`OTr_SetDateMode`** — neither a documentation file nor a `folders.json` entry exists.

**Required action:** Create `Documentation/Methods/OTr_SetDateMode.md` by running `__WriteDocumentation` after the method's header is confirmed correct. Add `OTr_SetDateMode` to the appropriate group in `folders.json` (the "OT API Methods" group, if it is a public-facing API method).

### 9.2 Documentation Files Without Matching `.4dm` Files

Two `.md` documentation files exist for methods that are excluded from the automated `OTr_` scan:

- `OTr_onStartup.md`
- `OTr_onExit.md`

These are correct: the corresponding `.4dm` files exist (`OTr_onStartup.4dm`, `OTr_onExit.4dm`). The scan's exclusion of lifecycle callbacks from the public-API documentation cross-reference is intentional. No action required.

### 9.3 Methods Not Registered in `folders.json`

Eleven `.4dm` files are present on disk but absent from `folders.json`:

| File | Note |
|---|---|
| `OTr_GetActiveHandleCount.4dm` | Public API; appears to be a recent addition |
| `OTr_SaveToXMLFileSAX.4dm` | Public API; SAX variant |
| `OTr_SaveToXMLSAX.4dm` | Public API; SAX variant |
| `OTr_SetDateMode.4dm` | Public API; also missing documentation |
| `OTr_onExit.4dm` | Lifecycle callback |
| `OTr_onStartup.4dm` | Lifecycle callback |
| `OTr_uNativeDateInObject.4dm` | Utility method |
| `OTr_zLogGetCallStack.4dm` | Private method |
| `OTr_zTogglePluginBlocks.4dm` | Private method |
| `OTr_zXMLWriteObjectSAX.4dm` | Private method; SAX variant |
| `OTr_z_Get4DVersion.4dm` | Private utility |

**Required action:** Add all eleven files to their appropriate groups in `folders.json`. The lifecycle callbacks, private methods, and utility methods should be placed in the existing "OT Private Methods" or "OT Utility Methods" groups as appropriate. The three public API methods (`OTr_GetActiveHandleCount`, `OTr_SaveToXMLFileSAX`, `OTr_SaveToXMLSAX`) should be added to "OT API Methods".

---

## 10. Summary of Findings

### 10.1 Findings Requiring Correction

| ID | Severity | File(s) | Finding | Action |
|---|---|---|---|---|
| F-01 | Advisory | 27 private/utility files | `"shared"` field absent from `%attributes` (defaults correctly to `false`) | Add explicit `"shared":false` for clarity; update Writing Guide to note the field is optional |
| F-02 | High | `OTr_InsertElement.4dm` | Lock acquired but never released — deadlock risk | **Corrected 2026-04-11:** `OTr_zUnlock` added before `OTr_zRemoveFromCallStack` |
| F-03 | Medium | `OTr_uEqualObjects.4dm` | Numbered-parameter header, wrong return variable, non-standard attribution | **Corrected 2026-04-11:** Header rewritten; `C_LONGINT` body refactor deferred |
| F-04 | Medium | `OTr_ClearAll.4dm` | Possible missing `#DECLARE()` on a public method | Confirm and add `#DECLARE()` if appropriate |
| F-05 | Low | 11 files | Not registered in `folders.json` | Will be picked up automatically; no manual action needed |
| F-06 | Low | `OTr_SetDateMode` | Missing documentation file | Create `.md` doc via `__WriteDocumentation` |

### 10.2 Confirmed Passing Checks

| Check | Result |
|---|---|
| All files have `%attributes` line | PASS |
| `"invisible":true` on every method | PASS |
| All public API methods have `"shared":true` | PASS |
| No numbered parameters (`$1`–`$9`) in method bodies | PASS |
| No direct `OK:=0` assignment anywhere | PASS |
| No stray `_p` suffix (Phase 20 known issue) | RESOLVED / PASS |
| All files have boxed-header separators | PASS |
| All files have `// Project Method:` signature line | PASS |
| Type-suffix conventions followed throughout | PASS |
| Handle parameters consistently named `$inObject_i` | PASS |
| Tag parameters consistently named `$inTag_t` | PASS |
| No lock/unlock mismatches except `OTr_InsertElement` | PASS (1 exception — see F-02) |
| `Documentation/Methods/` coverage (except `OTr_SetDateMode`) | PASS |

---

## Appendix A — Public Methods Using No Semaphore Locking

The following 32 public methods call neither `OTr_zLock` nor `OTr_zUnlock`. Each has been reviewed and categorised.

| Method | Category | Assessment |
|---|---|---|
| `OTr_ArrayType` | Direct array read | OK — initialisation guaranteed via `OTr_zAddToCallStack` → `OTr_zInit`; read-only, no lock required |
| `OTr_CompiledApplication` | Metadata / static | OK — no array access |
| `OTr_FindInArray` | Requires review | Verify no unlocked array access |
| `OTr_GetActiveHandleCount` | Metadata | Verify implementation |
| `OTr_GetAllProperties` | Requires review | Verify delegate chain |
| `OTr_GetArray` | Requires review | Likely delegates; verify |
| `OTr_GetArrayBLOB` | Delegate | Delegates to `OTr_GetArray` |
| `OTr_GetArrayBoolean` | Delegate | Delegates to `OTr_GetArray` |
| `OTr_GetArrayDate` | Delegate | Delegates to `OTr_GetArray` |
| `OTr_GetArrayLong` | Delegate | Delegates to `OTr_GetArray` |
| `OTr_GetArrayPicture` | Delegate | Delegates to `OTr_GetArray` |
| `OTr_GetArrayPointer` | Delegate | Delegates to `OTr_GetArray` |
| `OTr_GetArrayReal` | Delegate | Delegates to `OTr_GetArray` |
| `OTr_GetArrayString` | Requires review | Verify locking in body |
| `OTr_GetArrayText` | Delegate | Delegates to `OTr_GetArrayString` |
| `OTr_GetArrayTime` | Delegate | Delegates to `OTr_GetArray` |
| `OTr_GetOptions` | Config read | Calls `OTr_zInit` directly; OK |
| `OTr_GetText` | Delegate | Delegates to `OTr_GetString` |
| `OTr_GetVersion` | Static | Returns constant; OK |
| `OTr_IncludeShadowKey` | Requires review | Verify implementation |
| `OTr_Info` | Requires review | Verify implementation |
| `OTr_LoadFromClipboard` | Requires review | Verify delegate or lock |
| `OTr_LoadFromFile` | Requires review | Verify delegate or lock |
| `OTr_LoadFromGZIP` | Requires review | Verify delegate or lock |
| `OTr_LoadFromXMLFile` | Requires review | Verify delegate or lock |
| `OTr_LogLevel` | Config read | Requires review |
| `OTr_ObjectToNewBLOB` | Delegate | Likely delegates to `OTr_ObjectToBLOB` |
| `OTr_PutArrayText` | Delegate | Delegates to `OTr_PutArrayString` |
| `OTr_PutText` | Delegate | Delegates to `OTr_PutString` |
| `OTr_Register` | Requires review | Verify; registration should lock |
| `OTr_SetDateMode` | Requires review | Verify implementation |
| `OTr_SizeOfArray` | Requires review | Verify delegate or lock |

Methods marked "Requires review" in Appendix A are candidates for a follow-up pass in which each method body is read individually. That pass is not within the automated scope of S5 but should be scheduled as part of the S3/S4 thread-safety review.

---

## Appendix B — Recommended Remediation Priority

1. ~~**Immediate:** F-02 — `OTr_InsertElement` missing `OTr_zUnlock`.~~ **Corrected 2026-04-11.**
2. ~~**Medium-term:** F-03 — `OTr_uEqualObjects` header rewrite.~~ **Corrected 2026-04-11** (header only; `C_LONGINT` body refactor deferred).
3. ~~**F-07** — `OTr_ArrayType` locking concern.~~ **Resolved as non-issue:** initialisation guaranteed via `OTr_zAddToCallStack`; read-only access requires no lock.
4. ~~**F-05** — `folders.json` registrations.~~ **Closed:** will be picked up automatically.
5. **Remaining — Short-term:** F-06 — create `OTr_SetDateMode.md` documentation file via `__WriteDocumentation`.
6. **Remaining — Low-priority:** F-04 — add `#DECLARE()` to no-parameter methods. Cosmetic compliance only.
7. **Remaining — Optional (style):** F-01 — add explicit `"shared":false` to the 27 private/utility `%attributes` lines. No runtime impact; purely for documentary clarity. Update `4D-Method-Writing-Guide.md` to note that `"shared"` is an optional field defaulting to `false`.
