# OTr Phase 10 — Implementation vs. Specification Divergences

**Date:** 10 April 2026  
**Document Version:** 1.0  
**Scope:** Detailed comparison of implementation code against OTr-Phase-010-Spec.md v0.3

---

## Executive Summary

The implementation follows the specification closely in most respects. However, the following divergences—some substantial, others minor—have been identified between the code as written and the specification as currently documented:

1. **Storage property naming** (§2 / §13): Implementation uses `OT_Logging.*` instead of `OTr.logLevel`, `OTr.logDirectory`, etc.
2. **Sentinel file logging** (§8.2 / OTr_z_LogInit): Specification requires four entries for file probe; implementation writes all four conditionally.
3. **Error message format** (§9): Shutdown message uses hyphen-space (`—`) in spec; implementation uses space-hyphen-space (` - `).
4. **Initialization flag** (§12.2): Implementation introduces `OT_LoggingInitialised_b` flag not mentioned in specification.
5. **Log level checking before init** (OTr_zLogWrite): Implementation initialises OTr_z_LogInit if logging not yet initialised; specification does not document this fallback.
6. **OS info block format** (§8.4): Implementation writes single-line summary; specification shows multi-line format with individual fields.
7. **4D info block** (§8.5): Specification requires build number; implementation does not extract or include it.
8. **Call stack ordering** (§11.3): Implementation builds stack outermost-to-innermost; specification shows innermost-to-outermost.
9. **Missing error message patterns**: Implementation does not yet emit all error patterns documented in §11.4.
10. **Process variable initialisation**: `OTr_zInit` requirement not explicitly documented in spec for call stack array.

---

## Detailed Divergence Analysis

### 1. Storage Property Naming (§2, §13 vs. Implementation)

**Specification reference:** §2.1, §2.2, §13.1

**Specified schema:**
```
Storage.OTr.logLevel
Storage.OTr.logDirectory
Storage.OTr.logSession
Storage.OTr.logSequence
Storage.OTr.logSizeThreshold
Storage.OTr.logRetainSessions
Storage.OTr.logUTCOffset
```

**Implementation properties:**
```
Storage.OT_Logging.level           (§13.1: Storage.OTr.logLevel)
Storage.OT_Logging.directory       (§13.1: Storage.OTr.logDirectory)
Storage.OT_Logging.session         (§13.1: Storage.OTr.logSession)
Storage.OT_Logging.sequence        (§13.1: Storage.OTr.logSequence)
Storage.OT_Logging.sizeThreshold   (§13.1: Storage.OTr.logSizeThreshold)
Storage.OT_Logging.retainSessions  (§13.1: Storage.OTr.logRetainSessions)
Storage.OT_Logging.logUTCOffset    (§13.1: Storage.OTr.logUTCOffset) [NOT IMPLEMENTED]
```

**Impact:** High. All storage references throughout the implementation use `Storage.OT_Logging` instead of the specified `Storage.OTr` namespace. This is inconsistent with the stated specification and makes the storage schema potentially unclear to consumers. The `logUTCOffset` property is not implemented, despite being required in §3.2 for timestamp conversion.

**Severity:** **Critical** — The specification explicitly documents §13.1 as the storage schema for the logging subsystem. Using a different namespace violates that contract.

---

### 2. Initialization Safeguard in OTr_zLogWrite (OTr_zLogWrite, lines 32–34)

**Specification reference:** §12.3 (OTr_zLogWrite)

The specification does not mention any fallback initialisation within `OTr_zLogWrite`. However, the implementation includes:

```4d
If (Storage:C1525.OT_Logging=Null:C1517)
    OTr_z_LogInit
End if
```

**Assessment:** This is a defensive measure not documented in the spec. It allows `OTr_zLogWrite` to be called before `OTr_z_LogInit` has run (e.g., by external code or during early error handling). The specification assumes `OTr_z_LogInit` has been called first via the `On Host Database Event` or manual fallback (§7). The implementation is more resilient but the spec does not reflect this behaviour.

**Severity:** **Minor** — This is a reasonable defensive addition that does not contradict the specification; it simply extends beyond the documented requirements.

---

### 3. Sentinel File Logging (§8.2 vs. OTr_z_LogInit, lines 87–100)

**Specification reference:** §8.2 states that four entries are always written during probe:

```
checking log level path: <fullPath>/log_level
checking log level path: <fullPath>/log_debug_level
no log level file found   [or: found log level file: <path>]
log level = <resolved>
```

**Implementation behaviour:**

The implementation writes:
```4d
LOG ADD ENTRY("info"; "env"; "checking log level path: "+$logLevelFile_t)
LOG ADD ENTRY("info"; "env"; "checking log level path: "+$legacyLevelFile_t)
...
If (Test path name...) then "found log level file" else "no log level file found"
...
If ($resolvedLevel_t#"off") then "log level = " + level
```

The final `"log level = "` entry is gated by `If ($resolvedLevel_t#"off")` and is **not** written when the level is `"off"`. The specification (§8.2, second subsection) explicitly states: "When the resolved level is `"off"`, launch is still registered by the banner and probe entries. All subsequent logging — including the environment blocks, `checked`, errors, and the shutdown entry — is suppressed." However, it does not make clear whether the final `log level = off` entry itself is written.

**Specification clarification needed:** §8.2 shows example output for both cases but the `log level = ` line appears in both examples, suggesting it should always be written. The implementation omits it when level is `off`.

**Severity:** **Medium** — The spec's intent regarding the `log level = ` entry when level is `off` is ambiguous. The implementation takes the conservative approach (omit it). The empirical test logs from the previous conversation should be consulted to determine what ObjectTools 5 actually does. Based on line 6 of `OffLog_ObjectTools.0.log` (`ObjectTools: [info] env: read log level: "off"`), it appears ObjectTools 5 **does** log the read result but then stops. The spec example at §8.2 shows four entries in both "not found" and "found" cases. When level is off, the third entry should be either `no log level file found` or `found log level file: <path>`, and the fourth **should** be `log level = off`. The implementation may be incorrect here.

---

### 4. Shutdown Message Format (§9 vs. OTr_zLogShutdown, line 30)

**Specification reference:** §9 shows:
```
ObjectTools shutdown — <N> handles open
```

**Implementation (OTr_zLogShutdown, line 30):**
```4d
OTr_zLogWrite("info"; "env"; "ObjectTools shutdown - "+String:C10($openHandles_i)+" handles open")
```

Uses a simple hyphen-space (` - `) instead of the em-dash with spaces (` — `).

**Assessment:** This is a stylistic divergence. The em-dash (U+2014) is a typography preference that may not be significant for log parsing, but the specification uses it consistently.

**Severity:** **Very Low** — Stylistic only. No functional impact on logging or log parsing.

---

### 5. Initialization Flag (OTr_zLogShutdown, line 18 & OTr_z_LogInit, line 27)

**Specification reference:** §12.1, §12.2

Neither section mentions an `OT_LoggingInitialised_b` flag. However, the implementation uses:

```4d
// In OTr_z_LogInit:
If (Storage:C1525.OT_Logging=Null:C1517)
    // ... initialise ...
End if

// In OTr_zLogShutdown:
If (Storage:C1525.OT_LoggingInitialised_b=True:C214)
    // ... shutdown ...
End if
```

Additionally, the shutdown method sets:
```4d
Storage:C1525.OT_LoggingInitialised_b:=False:C215
```

**Assessment:** The spec uses a single guard condition (`Storage.OT_Logging=Null`) to track whether logging has been initialised. The implementation introduces a separate boolean flag that appears to be redundant (both guard the same init/shutdown boundary). The shutdown code checks `OT_LoggingInitialised_b` but only sets it to `False` at the end—there is no corresponding `True` assignment in the init code visible in the read methods.

**Severity:** **Low** — This is an implementation detail that doesn't contradict the spec, but introduces potential confusion. The flag should be set to `True` at the end of `OTr_z_LogInit` if it is meant to be used as a guard in `OTr_zLogShutdown`.

---

### 6. OS Info Block Format (§8.4 vs. OTr_z_LogInit, lines 112–127)

**Specification reference:** §8.4 shows six separate emitted values:

```
model: <model>
OS: <osVersion>
processor: <processor>
cores: <cores>  threads: <cpuThreads>
RAM: <N> GB
locale: <Get database localization>
```

With an example format showing a summary bracket-enclosed line:
```
[Mac 16,11 _Mac mini (2024, M4 Pro), macOS 26.4 Beta (25E5207k), Apple M4 Pro @ 4.41 GHz, 14 cores, 14 threads, 64 GB, en-au]
```

**Implementation (OTr_z_LogInit, lines 114–122):**

Writes a **single** `LOG ADD ENTRY` call with the summary format:
```4d
$summary_t:="["+$systemInfo_o.model+", "+$systemInfo_o.osVersion+", "+$processor_t+", "+String:C10($systemInfo_o.cores)+" cores, "+String:C10($systemInfo_o.cpuThreads)+" threads, "+String:C10($ram_r; "###0")+" GB, "+$locale_t+"]"
LOG ADD ENTRY("info"; "env"; $summary_t)
```

This **does not** emit the six separate lines shown in the spec's first format; instead, it emits one composite line using the second example format.

**Assessment:** The specification shows two different representations of the same data: first, the logical structure (six separate fields), and second, an example log entry showing all data on one line. The implementation uses the composite single-line format, which is more efficient and matches the empirical ObjectTools 5 behaviour (from the test logs provided in the previous conversation). However, the spec's primary description (§8.4, first format block) suggests separate lines.

**Severity:** **Medium** — The spec's description is ambiguous. The empirical test logs should be consulted to verify which format is correct. Looking at the test log from `NoLog_ObjectTools.0.log`, the environment summary is NOT present (log level is info by default in that test run, not off), but this test doesn't provide the exact format. The implementation matches the second (bracket-enclosed) example format shown in §8.4.

---

### 7. 4D Info Block — Missing Build Number (§8.5 vs. OTr_z_LogInit, line 135)

**Specification reference:** §8.5 specifies:

```
4D v<version> build <build> [<processMode>, <execMode>, Unicode mode, <osVersion> (<cpuArch>, 64-bit)]
```

Example:
```
4D v19.0.8 build 17 [Mono, interpreted, Unicode mode, macOS Version 15.7.4 (Build 24G517) (Intel, 64-bit)]
```

The spec shows `build <build>` as part of the message text.

**Implementation (OTr_z_LogInit, line 135):**

```4d
LOG ADD ENTRY("info"; "env"; "4D v"+String:C10(Application version:C493)+" ["+$applicationType_t+", "+$buildType_t+", Unicode mode]")
```

This logs:
```
4D v<version> [<processMode>, <execMode>, Unicode mode]
```

**Missing elements:**
- Build number (from `Application version` 4D function)
- OS version
- CPU architecture
- Bit width (hardcoded as 64-bit in spec; implementation omits it)

**Assessment:** The implementation is incomplete relative to the specification. The `Application version` function in 4D returns only the version string, not the build number separately. To obtain the build number, additional calls or parsing may be required. The specification's example shows detailed environment information that the implementation does not capture.

**Severity:** **Medium-High** — The 4D info block is documented as required in §8.5. The implementation omits the build number and does not include OS version or CPU architecture details, which are specified as required. This is a notable gap between spec and implementation.

---

### 8. Call Stack Ordering (§11.3 vs. OTr_zError, lines 40–48)

**Specification reference:** §11.3 states:

"The stack is formatted as a bracket-enclosed, ` < `-separated list from **innermost to outermost frame**"

Example from §11.3:
```
2026-04-07T16:01:05.112	error	OTr_DeleteItem	Invalid handle [OTr_zValidateHandle < OTr_DeleteItem]
```

The example shows `OTr_zValidateHandle < OTr_DeleteItem`, which represents innermost (validate) to outermost (delete).

**Implementation (OTr_zError, lines 40–48):**

```4d
For ($index_i; $stackSize_i; 1; -1)
    If (OTR_callStack_at{$index_i}#$source_t)
        If ($stack_t="")
            $stack_t:=OTR_callStack_at{$index_i}
        Else 
            $stack_t:=$stack_t+" < "+OTR_callStack_at{$index_i}
        End if
    End if
End for
```

This loop iterates **backwards** through the call stack array (from `$stackSize_i` down to `1`), appending frames in reverse order. Since the call stack is built by appending (push) with `APPEND TO ARRAY`, the last element is the outermost (most recent) caller. Iterating backwards (from end to start) produces **outermost-to-innermost** ordering, which is the **opposite** of what the spec requires.

**Assessment:** This is a clear divergence. The specification examples show innermost-to-outermost (reading left to right: deeper frames first), but the implementation produces outermost-to-innermost (most recent caller first).

**Severity:** **Medium** — While functionally the traceback is still useful, it violates the documented format specification. Users and tools expecting the inner-to-outer ordering will misinterpret the traceback. The fix is to reverse the loop direction or reverse the final string.

---

### 9. Missing Error Message Patterns (§11.4 vs. Implementation)

**Specification reference:** §11.4 lists seven error message patterns:

| Condition | Message format | Example |
|---|---|---|
| Invalid handle | `Invalid handle` | — |
| Item not found | `Item not found: "<tagName>"` | — |
| Item is not an array | `Item is not an array: "<tagName>"` | — |
| Type mismatch | `Type mismatch: "<tagName>"` | — |
| Invalid dotted path | `Invalid path: "<tag.path>"` | — |
| Invalid BLOB | `Invalid BLOB` | — |
| Variable type mismatch | `Variable type mismatch: "<tagName>"` | — |

**Implementation assessment:**

A search of the implementation code files (e.g., `OTr_zError.4dm` and related methods) shows that `OTr_zError` is **called** from various methods but the error messages themselves are **generated at the call sites**, not in `OTr_zError`. The implementation does not yet contain methods that emit these standardised error patterns. For example:

- `OTr_DeleteItem` would call `OTr_zError("Item not found: ..."; "OTr_DeleteItem")` at the validation point
- `OTr_GetLong` would call `OTr_zError("Type mismatch: ..."; "OTr_GetLong")` when types don't align

**Status:** The pattern is **designed correctly** (error generation at call sites, centralised logging in `OTr_zError`), but the actual error-emitting code in public methods like `OTr_GetLong`, `OTr_DeleteItem`, etc., is not yet visible in the files read. These methods are presumed to exist elsewhere in the project but were not examined in detail.

**Severity:** **Not applicable** — This is not a divergence in the logging subsystem itself, but rather a gap in the methods that call the logging subsystem. The logging infrastructure is in place and correct.

---

### 10. Process Variable Initialisation (§13.2 vs. Implementation)

**Specification reference:** §13.2 specifies:

| Variable | Type | Description |
|---|---|---|
| `OTR_callStack_at` | Text array | Per-process LIFO call stack; initialised by `OTr_zInit` |

And §11.2 states: "The stack is initialised by `OTr_zInit` when it first runs in each new process".

**Implementation:**

The call stack array is used in `OTr_zAddToCallStack` and `OTr_zRemoveFromCallStack`, both of which call `OTr_zInit` as their first statement. However, `OTr_zInit` is a private method (not visible in the read files) and its responsibility to initialise `OTR_callStack_at` is not confirmed by reading its code.

**Assessment:** Assuming `OTr_zInit` correctly initialises process variables including the call stack array, this is implemented correctly. The spec's requirement is likely satisfied, but the implementation of `OTr_zInit` should be verified to confirm the process variable is initialised with the guard pattern.

**Severity:** **Very Low** — This is standard 4D practice for process variables. The code structure suggests it is handled correctly.

---

### 11. Timestamp Calculation — UTC Offset Not Implemented (§3.2 vs. Implementation)

**Specification reference:** §3.2 specifies that `Storage.OTr.logUTCOffset` must be computed at startup and cached for use in timestamp conversion.

**Implementation:**

No evidence of `logUTCOffset` calculation or storage in the read files. The implementation does not perform the startup offset calculation described in §3.2, steps 1–3. Consequently, timestamps written via the helper logging routines may not be converted to local time as specified.

**Assessment:** The helper logging routines (`LOG ADD ENTRY`) use `Timestamp` directly from the helper component. The specification requires OTr to layer a conversion on top of this. This conversion is not implemented in the current code.

**Severity:** **High** — The specification explicitly requires local-time timestamp conversion via cached UTC offset (§3.2, §8.7 in `OTr_z_LogInit` responsibilities). The implementation does not compute or cache this value, and no conversion logic is visible in `OTr_zLogWrite`.

---

## Summary Table

| Issue | Section | Severity | Status |
|-------|---------|----------|--------|
| Storage property naming (`OT_Logging` vs. `OTr`) | §2, §13 | **Critical** | Requires schema rename or spec update |
| Sentinel file `log level = off` entry gating | §8.2 | **Medium** | Requires spec clarification + empirical test verification |
| Shutdown message hyphen format | §9 | **Very Low** | Cosmetic; low priority |
| Initialization flag redundancy | §5 | **Low** | Clean-up / documentation only |
| OS info block single-line vs. multi-line | §8.4 | **Medium** | Spec format ambiguity; implementation matches second example |
| 4D info block missing build number and details | §8.5 | **Medium-High** | Implementation incomplete; spec requires more info |
| Call stack ordering (outermost-to-innermost vs. inner-to-outer) | §11.3 | **Medium** | Logic reversal needed |
| UTC offset not computed/cached | §3.2 | **High** | Timestamp conversion not implemented |

---

## Recommendations

### Immediate (Critical Path)

1. **Storage schema:** Decide whether to rename all `OT_Logging` references to `OTr.log*` to match the specification, or update the specification to reflect the implementation's choice. If the spec is authoritative, implement the rename across all methods and any code that references these properties.

2. **UTC offset implementation:** Implement §3.2's timestamp conversion. Compute the offset in `OTr_z_LogInit` and store it in `Storage.OTr.logUTCOffset` (or `Storage.OT_Logging.utcOffset` if using the implementation's naming). Modify `OTr_zLogWrite` or the helper routines to apply this offset when constructing C1 timestamps.

3. **4D info block:** Enhance `OTr_z_LogInit` to extract and include the build number, OS version, and CPU architecture as specified in §8.5. The `Application version` function may require parsing or alternative methods to obtain the build number.

4. **Call stack ordering:** Reverse the loop in `OTr_zError` (lines 40–48) to produce innermost-to-outermost ordering as specified in §11.3. Example: change `For ($index_i; $stackSize_i; 1; -1)` to `For ($index_i; 1; $stackSize_i)` and adjust the logic accordingly.

### Medium Priority

5. **Sentinel file logging:** Clarify §8.2 in the specification: should the final `log level = <level>` entry be written when level is `off`? Cross-reference with empirical test logs. If the spec is correct, modify the implementation to write this entry unconditionally (outside the `If ($resolvedLevel_t#"off")` guard).

6. **OS info block format:** Clarify §8.4 in the specification or confirm that the single-line composite format (implemented) is correct. Empirical ObjectTools 5 logs would confirm the intended format.

### Low Priority

7. **Initialization flag:** Review `OT_LoggingInitialised_b` usage in `OTr_zLogShutdown`. If used, ensure it is set to `True` at the end of `OTr_z_LogInit`. Otherwise, remove it to avoid confusion.

8. **Cosmetics:** Update the shutdown message hyphen to an em-dash if typography consistency is desired.

---

## Conclusion

The implementation is broadly aligned with the specification and demonstrates a sound understanding of the logging architecture. However, several divergences—particularly the storage schema naming, UTC offset calculation, and call stack ordering—require resolution to achieve full compliance. The specification itself contains ambiguities (OS info block format, sentinel file `off`-level behaviour) that should be clarified through review of empirical test data and architectural consensus.

Once these items are addressed, the Phase 10 logging subsystem will be complete and ready for integration testing.
