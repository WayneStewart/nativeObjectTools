# OTr Phase 10 — Specification Update Changelog

**Version:** 0.3 → 0.4  
**Date:** 10 April 2026  
**Purpose:** Align specification with implementation and finalise five-column log entry format

---

## Summary of Changes

The specification has been comprehensively updated to reflect the actual implementation design and introduce the five-column log entry format with separated call stack tracking. All changes have been reviewed and approved by the development team.

---

## Detailed Changes

### 1. Storage Schema Rename: `Storage.OTr` → `Storage.OT_Logging`

**Affected sections:** §2.1, §2.2, §2.3, §2.4, §4, §5.1, §8.1, §12.1, §13.1

**Change:** All references to `Storage.OTr.log*` properties updated to `Storage.OT_Logging.*`

**Rationale:** The logging system uses a separate shared object to prevent locking contention on the parent `Storage.OTr` object during frequent logging operations that may occur concurrently with other OTr subsystem access.

**Properties updated:**
- `Storage.OTr.logDirectory` → `Storage.OT_Logging.directory`
- `Storage.OTr.logSession` → `Storage.OT_Logging.session`
- `Storage.OTr.logSequence` → `Storage.OT_Logging.sequence`
- `Storage.OTr.logSizeThreshold` → `Storage.OT_Logging.sizeThreshold`
- `Storage.OTr.logRetainSessions` → `Storage.OT_Logging.retainSessions`
- `Storage.OTr.logLevel` → `Storage.OT_Logging.level`
- `Storage.OTr.logUTCOffset` → `Storage.OT_Logging.utcOffset` (marked as future)

---

### 2. Five-Column Log Entry Format

**Affected sections:** §3.1, §3.2, §3.3, §8.2, §9, §11.2, §11.3, §12.3

**Change:** Log entries now contain five tab-delimited columns instead of four.

**New structure:**
```
C1 (Timestamp) | C2 (Severity) | C3 (Source) | C4 (Message) | C5 (Call Stack)
```

**C5 (Call Stack) specification:**
- Populated only for entries with severity `error`
- Uses `OT Right Arrow` constant (`→`) as delimiter
- Reads left-to-right: outermost (oldest) caller to innermost (newest) callee
- For non-error entries, C5 is an empty string (tab present, no content)
- All entries have exactly 5 columns for spreadsheet compatibility

**Examples:**
```
Error with call stack:
2026-04-07T16:01:05.112Z	error	OTr_DeleteItem	Invalid handle	OTr_DeleteItem → OTr_zValidateHandle

Non-error (C5 empty):
2026-04-07T16:01:01.347Z	info	env	log level = info	
```

---

### 3. Timestamp Clarification

**Affected sections:** §3.2

**Change:** Current implementation uses GMT timestamps with trailing `Z`. Local-time conversion moved to future enhancements.

**Rationale:** Simplifies current implementation while documenting the planned enhancement (cached UTC offset approach remains valid but deferred).

---

### 4. OS Info Block Format Clarification

**Affected section:** §8.4

**Change:** Explicitly documented as a single log entry with composite bracket-enclosed message, not multiple separate lines.

**Format:**
```
[<model>, <osVersion>, <processor>, <cores> cores, <cpuThreads> threads, <ram> GB, <locale>]
```

---

### 5. 4D Info Block Enhancement Requirements

**Affected section:** §8.5

**Change:** Specification now requires extraction and inclusion of:
- Build number (via `OTr_z_Get4DVersion`)
- OS version (via `Get system info`)
- CPU architecture (inferred from processor and macRosetta)

**Format:**
```
4D v<version> build <build> [<processMode>, <execMode>, Unicode mode, <osVersion> (<cpuArch>)]
```

---

### 6. Sentinel File "off" Behavior Clarification

**Affected section:** §8.2

**Change:** Explicitly documented that when level is `"off"`, the final `log level = off` entry is **not** written.

**Probe sequence for `off` level:**
1. Banner (3 lines)
2. Path check lines
3. File found/not found message
4. Read result message (`read log level: "off"`)
5. **STOP — no final `log level = ` entry**

**Rationale:** Matches legacy ObjectTools 5 behaviour as verified in empirical test logs.

---

### 7. Initialization Guard Clarification

**Affected section:** §12.2

**Change:** Added implementation note clarifying that `Storage.OT_Logging=Null` check serves as guard against multiple shutdown calls. Separate initialization flag (`OT_LoggingInitialised_b`) has been removed from code (not documented as feature).

---

### 8. Defensive Initialization in OTr_zLogWrite

**Affected section:** §12.3

**Change:** Added documentation of the defensive initialization safeguard that automatically calls `OTr_z_LogInit` if logging has not yet been initialized.

**Rationale:** Ensures logging is available even if integration is incomplete, though developers should follow the documented lifecycle (§7) for optimal performance.

---

### 9. Call Stack Ordering Clarification

**Affected section:** §11.2, §11.3

**Change:** Clarified that call stack is constructed left-to-right from outermost (oldest) to innermost (newest) callee, matching implementation and ObjectTools convention.

**Example:**
```
OTr_PutArrayLong → OTr_u_AccessArrayElement → OTr_ValidateArrayTarget
                 (oldest call)            (middle)            (newest/deepest)
```

---

### 10. Future Enhancement: Full Mode Logging

**Affected section:** §C (new subsection)

**Change:** Added comprehensive "Full Mode Logging" enhancement proposal.

**Scope:** Comprehensive method-level tracing with entry/exit logging, parameter recording, execution timing, and full call stack on every entry (not just errors).

**Activation options:** New log level constant, separate sentinel file, or API parameter.

**Performance:** Significant overhead; diagnostic-use only (not production steady state).

---

### 11. Method Name Consistency

**Affected:** Throughout (§2.2, §5.1, §7.1, §8.1, §12.1–12.8)

**Change:** Method names consistently use camelCase with underscore prefix for private methods:
- `OTr_zLogInit` → `OTr_z_LogInit`
- `OTr_zLogShutdown` → `OTr_zLogShutdown` (unchanged)
- `OTr_zLogWrite` → `OTr_zLogWrite` (unchanged)
- Similar for call stack and other helper methods

---

### 12. Timestamp Property Correction

**Affected section:** §3.2, §13.1

**Change:** Added note that `Storage.OT_Logging.utcOffset` is marked as future implementation (not currently used).

---

## Testing Impact

The following test cases require validation against the updated specification:

| Test Case | Purpose | Status |
|-----------|---------|--------|
| Five-column format validation | Verify all entries have exactly 5 tab-delimited columns | TBD |
| C5 empty cells on non-errors | Confirm tab character present with no content for non-error entries | TBD |
| Call stack delimiter | Verify `→` (OT Right Arrow) used as delimiter, not `<` | TBD |
| Call stack ordering | Confirm outermost-to-innermost ordering from left to right | TBD |
| Sentinel file `off` behavior | Verify final `log level = off` entry is omitted | TBD |
| OS info block single-line | Confirm composite bracket format on single entry | TBD |
| 4D info block completeness | Verify build number, OS version, CPU architecture included | TBD |
| Spreadsheet compatibility | Import logs into Excel/Sheets; verify 5-column structure | TBD |

---

## Implementation Tasks

The following implementation tasks are derived from this specification update:

1. **Enhance 4D info block** — Extract build number, OS version, CPU architecture for §8.5
2. **Remove initialization flag** — Remove `OT_LoggingInitialised_b` from `OTr_zLogShutdown`
3. **Implement C5 call stack** — Construct stack in C5 for error entries using `OT Right Arrow` delimiter
4. **Timestamp handling** — Verify GMT timestamp format with `Z` suffix is correct
5. **Future: Local-time conversion** — Implement cached UTC offset mechanism when prioritized

---

## Backward Compatibility

- **Log format change:** Five-column format is a breaking change from previous internal testing. Log file format is **not backward compatible** with any prior test logs.
- **API compatibility:** Public API (`OTr_LogLevel`, `OTr_Register`, etc.) remains unchanged.
- **Storage schema:** Internal change only; no impact to public interfaces.

---

## Version History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 0.3 | 2026-04-07 | Wayne Stewart / Claude | Initial specification |
| 0.4 | 2026-04-10 | Wayne Stewart / Claude | Implementation alignment, five-column format |

