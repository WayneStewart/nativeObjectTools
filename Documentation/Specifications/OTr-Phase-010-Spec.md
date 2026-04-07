# OTr Phase 10 — Logging Subsystem

**Version:** 0.3
**Date:** 2026-04-07
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md)

---

## Overview

Phase 10 introduces a structured logging subsystem to OTr. The subsystem aims to match the observable behaviour of the ObjectTools 4/5 logging facility as closely as practical — including log file location, session-based rotation, entry format, severity reporting, and the run-time log level override mechanism — while accommodating the different architecture of the native OTr implementation.

Phase 10 introduces one new **public API method**: `OTr_LogLevel`, which provides a programmatic getter/setter interface to the active log control level. OTr owns the logging integration layer for startup, shutdown, level gating, and error/call-stack context. The installed helper logging routines own the low-level file dispatch and worker I/O.

---

## 1. Scope and Goals

### 1.1 Functional Goals

The logging subsystem must satisfy the following requirements:

- Write structured, tab-delimited log entries to a set of UTF-8 plain-text files in a well-defined directory beneath the host database's Logs folder.
- Produce one log file series per application session, named with a timestamp captured at startup.
- Rotate to a new file within a session when a configurable size threshold is reached.
- Support three log control levels — `off`, `info`, and `debug` — for startup configuration and run-time gating.
- Support a run-time log level override via a sentinel file (`log_level`) and via the public `OTr_LogLevel` API method.
- Retain the last N session log series, deleting older sessions at startup.
- Dispatch all file I/O through a dedicated worker process to serialise writes without semaphore locking.
- Maintain a per-process LIFO call stack to provide traceback context in error log entries.
- Hook into the host database lifecycle via `On Host Database Event`, with a documented fallback for hosts where the security setting is disabled.

### 1.2 Out of Scope

- No log file parsing, querying, or export facilities are required in this phase.
- Remote or structured (JSON) log output is not required.
- Integration with 4D's own diagnostic log is not required.
- Log archive (ZIP) functionality is noted as a future enhancement (see Appendix C).

---

## 2. Log File Location and Naming

### 2.1 Directory

Log files are written to:

```4d
Get 4D folder(Logs folder; *) + "ObjectTools" + Folder separator
```

The `*` parameter resolves to the **host database's** Logs folder rather than the component's own folder, ensuring OTr logs sit alongside the host's 4D application logs in a recognisable location. The `ObjectTools` subdirectory is created on first use if it does not already exist.

The resolved path is cached at startup in `Storage.OTr.logDirectory`. Routines that need the sentinel file derive it by appending `log_level` (or `log_debug_level`) to this directory path.

### 2.2 File Naming Convention

Each application session produces its own log file series. The session timestamp is captured once at startup (during `OTr_zLogInit`) and stored in `Storage.OTr.logSession` as a text string of the form `YY-MM-DD-HH-MM`.

Log files within a session are named:

```
ObjectTools YY-MM-DD-HH-MM.NNN.txt
```

Where `NNN` is a zero-padded three-digit sequence number starting at `001`, incrementing each time the size threshold is reached within the session.

Examples:

```
ObjectTools 26-04-07-16-01.001.txt
ObjectTools 26-04-07-16-01.002.txt
```

This naming convention ensures that:

- File managers and log viewers sequence files correctly via lexicographic sort within a session.
- Sessions are immediately distinguishable by their timestamp prefix.
- The session key for grouping or archiving purposes is the `YY-MM-DD-HH-MM` prefix shared by all files in the series.

### 2.3 Within-Session Size Rollover

When the current log file reaches or exceeds the configured size threshold, the OTr integration layer closes the current session log, increments the sequence counter stored in `Storage.OTr.logSequence`, and switches the helper logging routines to the next file in the session series. The session timestamp prefix is unchanged.

> **Workshop item:** The exact size threshold is subject to review. The value is stored in `Storage.OTr.logSizeThreshold` (Integer, bytes) and set to a default during `OTr_zLogInit`, making it straightforward to adjust without code changes.

### 2.4 Session Retention Policy

At startup, `OTr_zLogInit` enumerates all files in the log directory matching the pattern `ObjectTools *.txt`, extracts the unique `YY-MM-DD-HH-MM` session prefixes, sorts them lexicographically (equivalent to chronological order given the format), and deletes all files belonging to sessions beyond the most recent N, where N is stored in `Storage.OTr.logRetainSessions` (Integer, default `10`).

Deletion applies to all files in the session series (i.e., all files sharing the same timestamp prefix).

---

## 3. Log Entry Format

### 3.1 Column Structure

Each log entry occupies a single logical line with four tab-delimited columns:

| Column | Content | Example |
|---|---|---|
| C1 | Timestamp (local time, ISO-style) | `2026-04-07T16:01:01.347` |
| C2 | Severity level (plain, no brackets) | `info` |
| C3 | Message source | `env`, `plugin`, or OTr method name e.g. `OTr_DeleteItem` |
| C4 | Message text | `log level = info` |

The entry is terminated by a single LF character (`Char(10)`) on all platforms. Files are written in binary mode to prevent 4D on Windows from performing any automatic CRLF translation. LF-only files are handled correctly by all modern text editors including Notepad on Windows 10 and later.

Any tab characters within C4 message text must be escaped to `\t` before the entry is assembled, and any embedded LF characters escaped to `\n`, to prevent corruption of the column structure.

### 3.2 Timestamp Construction (C1)

The `Timestamp` command returns a GMT ISO 8601 string of the form `"YYYY-MM-DDTHH:MM:SS.mmmZ"`. Converting this to local time on every write via `Current date(*)` and `Current time(*)` would incur significant overhead as those calls with the `*` parameter are substantially slower than `Timestamp`. Instead, the UTC offset is computed **once at startup** and cached:

1. During `OTr_zLogInit`, call `Current date(*)` and `Current time(*)` to obtain the local wall-clock values, and parse a single `Timestamp` call to obtain the UTC values.
2. Compute the offset in seconds: `$offset_r := (local date/time as seconds) - (UTC date/time as seconds)`.
3. Store as `Storage.OTr.logUTCOffset` (Real, e.g. `36000` for UTC+10, `-12600` for UTC-3.5).

On every subsequent write, the active logging path calls `Timestamp`, strips the trailing `Z`, adds `Storage.OTr.logUTCOffset` seconds to the numeric time components, adjusts for overflow/underflow at hour and day boundaries, and formats C1 as `YYYY-MM-DDTHH:MM:SS.mmm`.

> **Known limitation:** If a daylight saving time boundary is crossed during a long-running session, the cached offset will be stale and log timestamps will diverge from wall-clock time by one hour. Refreshing the offset periodically is noted as a future enhancement (see Appendix C).

### 3.3 Example Entries

Default (`info`) level startup entry:
```
2026-04-07T16:01:01.347	info	env	log level = info
```

Error entry with call stack:
```
2026-04-07T16:01:05.112	error	OTr_DeleteItem	Invalid handle [OTr_zValidateHandle < OTr_DeleteItem]
```

---

## 4. Log Control Levels

Phase 10 uses three log control levels. `Storage.OTr.logLevel` stores the active control level as Text:

| Control token | Constant | Meaning |
|---|---|---|
| `"off"` | `OTR Log Off` | Startup probe only; suppress subsequent logging |
| `"info"` | `OTR Log Info` | Standard operational logging |
| `"debug"` | `OTR Log Debug` | Standard logging plus extra diagnostic detail |

These constants are defined in the `OTr Log Level` constant theme in the XLF resource file:

| Constant Name | Text Value |
|---|---|
| `OTR Log Off` | `"off"` |
| `OTR Log Debug` | `"debug"` |
| `OTR Log Info` | `"info"` |

For control-level comparison in `OTr_zLogWrite`, the private helper `OTr_zLogLevelToInt` maps the active level token to a numeric rank (`"off"` = `0`, `"info"` = `1`, `"debug"` = `2`).

Log entries themselves continue to carry emitted severity tokens in column C2. In the current phase, OTr writes `info` for normal operational output, `debug` for additional diagnostic output, and `error` for runtime or internal errors. `notice` and `warn` are not part of the current Phase 10 design.

**Default active level:** `"info"`.

---

## 5. Log Level Override

### 5.1 Sentinel File Mechanism

The active log level may be overridden at run time by placing a plain-text file named `log_level` in the log directory. In the current phase, the plain-text file supports the following tokens:

| File contents | Effect |
|---|---|
| `debug` | Debug logging enabled |
| `info` | Standard logging enabled |
| `off` | Logging completely suppressed |

The absence of the file, an empty file, or any unrecognised content all produce the default level, which is `"info"`. For backward compatibility with the original ObjectTools behaviour, `debug` and `off` remain the important legacy tokens. OTr also accepts explicit `info`, which is the value written by `OTr_LogLevel` when persistence is requested for the normal/default state.

To change the log level via file:

1. In a text editor, create a new plain text document.
2. Enter the text `debug`, `info`, or `off`.
3. Save the document as `log_level` in the OTr log directory.
4. Restart 4D.

The file is read once during `OTr_zLogInit`. The resolved level is stored in `Storage.OTr.logLevel`. Changes to the file take effect only after 4D is restarted.

For backward compatibility, the legacy filename `log_debug_level` is recognised with identical semantics. If both files are present, `log_level` takes precedence.

### 5.2 Restoring the Default Level

The default level is restored by any of the following, followed by a restart of 4D:

- Moving, renaming, or deleting the `log_level` file.
- Clearing the file's contents.

---

## 6. Public API Method: `OTr_LogLevel`

### 6.1 Purpose

`OTr_LogLevel` provides a programmatic interface to read and optionally set the active log control level at run time, without requiring a restart of 4D or manual file editing. It has no direct ObjectTools 4/5 counterpart and is an OTr extension.

### 6.2 Attributes

```4d
//%attributes = {"invisible":true,"shared":true}
```

### 6.3 Signature

```4d
#DECLARE($setLogLevel_t : Text; $permanent_b : Boolean) -> $getLogLevel_t : Text
```

### 6.4 Parameters

| Parameter | Type | Description |
|---|---|---|
| `$setLogLevel_t` | Text | *(Optional)* New log control token. One of `"debug"`, `"info"`, or `"off"`. Recommended: pass an `OTR Log` constant. |
| `$permanent_b` | Boolean | *(Optional)* If `True`, writes the new level to the `log_level` file beneath `Storage.OTr.logDirectory`, making it persist across restarts. Default: `False`. |
| `$getLogLevel_t` | Text | Returns the current active log level token after any set operation. |

Optional parameters are handled via `Count parameters`. `$permanent_b` defaults to `False` when omitted.

### 6.5 Behaviour

```4d
$parametersCount_i := Count parameters

$setLogLevel_t := Choose($parametersCount_i > 0; $setLogLevel_t; "")
$permanent_b   := Choose($parametersCount_i = 2; $permanent_b; False)

If (Length($setLogLevel_t) > 0)
    Use (Storage.OTr)
        Storage.OTr.logLevel := $setLogLevel_t
    End use
End if

If ($permanent_b)
    // Write $setLogLevel_t to the log_level file beneath Storage.OTr.logDirectory
End if

$getLogLevel_t := Storage.OTr.logLevel
```

### 6.6 Usage Examples

```4d
// Query the current level
$level_t := OTr_LogLevel   // Returns e.g. "info"

// Set to debug for the current session only
OTr_LogLevel(OTR Log Debug)

// Set to debug and persist across restarts
OTr_LogLevel(OTR Log Debug; True)

// Restore to info and persist
OTr_LogLevel(OTR Log Info; True)
```

---

## 7. Lifecycle Integration

### 7.1 `On Host Database Event` (Preferred)

The component implements the `On Host Database Event` database method. When the host database has the security setting **"Execute 'On Host Database Event' method of the components"** enabled (Settings → Security), 4D calls this method automatically at the appropriate lifecycle points.

OTr responds to two events:

| Event constant | Value | OTr action |
|---|---|---|
| `On before host database startup` | `1` | Call `OTr_zLogInit` |
| `On before host database exit` | `3` | Call `OTr_zLogShutdown` |

Events `2` (`On after host database startup`) and `4` (`On after host database exit`) are received but require no action from the logging subsystem.

### 7.2 Manual Fallback

If the host database has the security setting disabled (the default), the host developer must call the following methods explicitly:

- `OTr_zLogInit` from the host's `On Startup` database method.
- `OTr_zLogShutdown` from the host's `On Exit` database method.

This requirement must be clearly documented in the OTr integration guide. Failure to call `OTr_zLogShutdown` will leave the Log Writer worker running and the log file handle open; 4D will close the file on process termination, but the shutdown log entry will be absent.

---

## 8. Startup Log Entries

`OTr_zLogInit` writes the following entries at startup. These entries aim to stay close to the legacy ObjectTools startup behaviour while using the installed helper logging routines for low-level file dispatch.

### 8.1 Banner (written on launch, including `off`)

```
*****************************************************************
  ObjectTools
*****************************************************************
```

### 8.2 Log Level Probe (always written on launch)

**When no file is found:**
```
checking log level path: <fullPath>/log_level
checking log level path: <fullPath>/log_debug_level
no log level file found
log level = info
```

**When the file is found:**
```
checking log level path: <fullPath>/log_level
found log level file: <fullPath>/log_level
read log level: "debug"
log level = debug
```

> **`off` behaviour:** When the resolved level is `"off"`, launch is still registered by the banner and probe entries. All subsequent logging — including the environment blocks, `checked`, errors, and the shutdown entry — is suppressed.

### 8.3 OTr Info Block (all levels except `off`)

Emitted message text:

```
OTr <version> [<buildType>, 64-bit]
```

Example:
```
OTr 0.5.0 [release, 64-bit]
```

- `buildType`: `"release"` if `Is compiled`, otherwise `"interpreted"`.
- Bit width is `"64-bit"` unconditionally on 4D v19+.

### 8.4 OS Info Block (all levels except `off`)

The following values are gathered from `Get system info` and `Get database localization` and then emitted as a single `info` / `env` summary line.

```
model: <model>
OS: <osVersion>
processor: <processor>
cores: <cores>  threads: <cpuThreads>
RAM: <N> GB
locale: <Get database localization>
```

Examples:
```
model: iMac12,2
OS: macOS Version 15.7.4 (Build 24G517)
processor: Intel(R) Core(TM) i7-2600 CPU @ 3.40GHz
cores: 4  threads: 8
RAM: 16 GB
locale: en-au
```

- RAM is converted from kilobytes to GB, rounded to the nearest whole number: `$physicalMemory / 1048576`.
- `(Rosetta)` is appended to the processor line if `macRosetta = True`.

Emitted message text example:

```
[Mac 16,11 _Mac mini (2024, M4 Pro), macOS 26.4 Beta (25E5207k), Apple M4 Pro @ 4.41 GHz, 14 cores, 14 threads, 64 GB, en-au]
```

### 8.5 4D Info Block (all levels except `off`)

Emitted message text:

```
4D v<version> build <build> [<processMode>, <execMode>, Unicode mode, <osVersion> (<cpuArch>, 64-bit)]
```

Example:
```
4D v19.0.8 build 17 [Mono, interpreted, Unicode mode, macOS Version 15.7.4 (Build 24G517) (Intel, 64-bit)]
```

- Version and build number from `Application version`.
- Process mode from `Application type` → `"Mono"`, `"Server"`, or `"Remote"`.
- Execution mode: `Is compiled` → `"release"` / `"interpreted"`.
- Unicode mode: constant `"Unicode mode"` on v19+.
- CPU architecture inferred from `Get system info.processor` and `macRosetta`.

### 8.6 `debug`-Only Additions

When the active level is `"debug"`, two additional entries are interleaved within the OS Info block. These are functionally analogous to the ObjectTools 5 ICU debug entries but use 4D-accessible data since the ICU internals are not available to native code:

Message text:

```
looking for locale data
```
Written between the `OS:` line and the `processor:` line.

Message text:

```
raw system locale: <Get system info.osLanguage>
```
Written between the `locale:` line and `checked`.

### 8.7 Closing Entry (all levels except `off`)

Message text:

```
checked
```

---

## 9. Shutdown Log Entry

`OTr_zLogShutdown` writes a single entry before shutting down logging. As an OTr enhancement beyond the legacy behaviour, the count of currently open handles is appended to assist memory leak detection:

Message text:

```
ObjectTools shutdown — <N> handles open
```

Examples:
```
ObjectTools shutdown — 0 handles open
ObjectTools shutdown — 3 handles open
```

A non-zero count indicates that `OTr_Clear` was not called for all allocated handles before exit. This entry is not written when the level is `"off"`.

---

## 10. Registration Entry

Written when `OTr_Register` is called, source `plugin`:

Message text:

```
successfully registered ObjectTools
```

---

## 11. Error Logging

### 11.1 Integration Point: `OTr_zError`

All OTr error reporting passes through the single method `OTr_zError`, which is called throughout the codebase as:

```4d
OTr_zError("Invalid handle"; Current method name)
OTr_zError("Item not found: " + $inTag_t; Current method name)
OTr_zError("Invalid path: " + $inTag_t; Current method name)
```

`OTr_zLogWrite` is called from within `OTr_zError`, making it the universal OTr logging chokepoint. No individual method requires any direct helper logging calls beyond that shared path.

### 11.2 Call Stack

To provide traceback context in error entries, OTr maintains a per-process LIFO call stack as a process variable Text array (`OTR_callStack_at`).

Every OTr public method calls `OTr_zAddToCallStack(Current method name)` as its first statement, (immediately below the #DECLARE line if one is present) and `OTr_zRemoveFromCallStack(Current method name)` as its last statement. Since 4D v19 LTS does not support early returns, every method runs to completion — there is no risk of an unmatched push/pop.

The stack is initialised by `OTr_zInit` when it first runs in each new process, consistent with the existing guard pattern for process variables.

**Performance gate:** `OTr_zAddToCallStack` and `OTr_zRemoveFromCallStack` return immediately without touching the array if `Storage.OTr.logLevel` is `"off"`, eliminating all stack maintenance overhead when logging is disabled.

### 11.3 Error Entry Format

Error entries use the four-column structure with the call stack appended to C4:

```
<C1>	error	<callingMethodName>	<errorMessage> [<stack>]
```

The stack is formatted as a bracket-enclosed, ` < `-separated list from innermost to outermost frame:

```
2026-04-07T16:01:05.112	error	OTr_DeleteItem	Invalid handle [OTr_zValidateHandle < OTr_DeleteItem]
```

### 11.4 Error Message Patterns

The following message patterns are used by `OTr_zError`, derived from the legacy ObjectTools error vocabulary:

| Condition | Message format | Example |
|---|---|---|
| Invalid handle | `Invalid handle` | `Invalid handle` |
| Item not found | `Item not found: "<tagName>"` | `Item not found: "missingDelete"` |
| Item is not an array | `Item is not an array: "<tagName>"` | `Item is not an array: "scalar"` |
| Type mismatch | `Type mismatch: "<tagName>"` | `Type mismatch: "scalar"` |
| Invalid dotted path | `Invalid path: "<tag.path>"` | `Invalid path: "scalar.child"` |
| Invalid BLOB | `Invalid BLOB` | `Invalid BLOB` |
| Variable type mismatch | `Variable type mismatch: "<tagName>"` | `Variable type mismatch: "varMixed"` |

---

## 12. Internal Methods

### 12.1 `OTr_zLogInit`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:** `#DECLARE`

**Responsibilities:**

1. Resolve and create the log directory. Cache in `Storage.OTr.logDirectory`.
2. Configure the installed helper logging routines to use the OTr log folder and current session log file.
3. Apply any agreed session retention and session-file naming policy.
4. Compute and cache UTC offset in `Storage.OTr.logUTCOffset` if required by the chosen timestamp format (§3.2).
5. Read `log_level` or `log_debug_level` file; set `Storage.OTr.logLevel`; fall back to `"info"`.
6. Write the startup log block (§8).

---

### 12.2 `OTr_zLogShutdown`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:** `#DECLARE`

**Responsibilities:** Write the shutdown entry including open handle count (§9); then use the installed helper shutdown routines to close log files and stop the helper log writer cleanly.

---

### 12.3 `OTr_zLogWrite`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE($inLevel_t : Text; $inSource_t : Text; $inMessage_t : Text)
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `$inLevel_t` | Text | One of the `OTR Log` text constants |
| `$inSource_t` | Text | `"env"`, `"plugin"`, or an OTr method name |
| `$inMessage_t` | Text | Message body; embedded tabs escaped to `\t`, LFs to `\n` |

**Behaviour:**

1. Read `Storage.OTr.logLevel`.
2. Apply the current control-level rules: `off` suppresses all non-launch output; `info` writes normal and error output; `debug` also writes extra diagnostic output.
3. Dispatch qualifying entries through the installed helper logging routines rather than implementing direct worker/file I/O in OTr.

---

### 12.4 `OTr_zLogLevelToInt`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE($inLevel_t : Text) -> $outRank_i : Integer
```

Maps a control-level token to its numeric rank:

| Token | Rank |
|---|---|
| `"off"` | `0` |
| `"info"` | `1` |
| `"debug"` | `2` |

Unrecognised tokens return `1` (the `"info"` rank) as a safe default.

---

### 12.5 `OTr_zLogDirectory`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE -> $outPath_t : Text
```

Returns the absolute path to the `ObjectTools` log subdirectory with trailing separator, creating the directory if absent.

---

### 12.6 `OTr_zAddToCallStack`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE($inMethodName_t : Text)
```

Called as the **first statement** of every OTr public method. Returns immediately if `Storage.OTr.logLevel` is `"off"`. Otherwise appends `$inMethodName_t` to the process variable array `OTR_callStack_at`.

---

### 12.7 `OTr_zRemoveFromCallStack`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE($inMethodName_t : Text)
```

Called as the **last statement** of every OTr public method. Returns immediately if `Storage.OTr.logLevel` is `"off"`. Otherwise removes the last element from `OTR_callStack_at`.

---

### 12.8 Installed Helper Logging Routines

The following installed helper routines are used unchanged as the low-level logging infrastructure for Phase 10:

- `Log_Init`
- `LOG ADD ENTRY`
- `LOG THIS`
- `LOG CLOSE LOG`
- `LOG STOP LOG WRITER`
- `Log Folder Path`
- `Log File Name`
- `LOG USE LOG`

These methods are dependency methods, not OTr-prefixed Phase 10 design targets. OTr integrates with them rather than re-implementing their worker/file-writing behaviour.

---

## 13. Storage Schema

### 13.1 Interprocess (`Storage.OTr`)

| Property | Type | Description |
|---|---|---|
| `Storage.OTr.logLevel` | Text | Active minimum severity token (`"info"`, `"debug"`, etc.) |
| `Storage.OTr.logDirectory` | Text | Resolved absolute path to the log directory |
| `Storage.OTr.logSession` | Text | Session timestamp prefix `YY-MM-DD-HH-MM` |
| `Storage.OTr.logSequence` | Integer | Current within-session file sequence number |
| `Storage.OTr.logSizeThreshold` | Integer | File size rollover threshold in bytes (default TBD — workshop item) |
| `Storage.OTr.logRetainSessions` | Integer | Number of sessions to retain (default `10`) |
| `Storage.OTr.logUTCOffset` | Real | UTC offset in seconds, computed once at startup |

### 13.2 Process Variables

| Variable | Type | Description |
|---|---|---|
| `OTR_callStack_at` | Text array | Per-process LIFO call stack; initialised by `OTr_zInit` |

---

## 14. Constants

The current Phase 10 implementation uses the following `OTr Log Level` constants:

| Constant Name | Text Value |
|---|---|
| `OTR Log Off` | `"off"` |
| `OTR Log Debug` | `"debug"` |
| `OTR Log Info` | `"info"` |

---

## 15. Testing

### 15.1 Status

The existing Phase 10 plugin-comparison methods are retained as reference data sources. They are not, by themselves, a full subsystem verification harness for the helper-backed OTr logging implementation.

### 15.2 Test Matrix

| Test Case | Expected Outcome |
|---|---|
| Startup at default level — all §8 entries present | Banner, no-file probe, OTr info, OS info, 4D info, `checked` |
| Startup at `debug` level — additional entries present | Two `debug` entries interleaved per §8.6 |
| Startup at `off` level — logging stops after probe | Last entry is `read log level: "off"`; no env block written |
| `OTr_LogLevel` getter — returns current level | Correct token returned with no argument |
| `OTr_LogLevel` setter — updates `Storage.OTr.logLevel` | Immediate in-session effect confirmed |
| `OTr_LogLevel` with `$permanent_b = True` — writes file | `log_level` file present and readable after call |
| `log_debug_level` accepted as backward-compatible synonym | Debug level activated |
| Explicit `info` token in `log_level` — standard logging active | No error raised; `info` level active |
| Unrecognised `log_level` file content — defaults to `"info"` | No error raised; `info` level active |
| Error entry — call stack present in C4 | Stack formatted as `[inner < outer]` |
| Call stack gate at `off` level | `OTr_zAddToCallStack` returns immediately; no array mutation |
| Shutdown entry — zero handle count after clean session | `ObjectTools shutdown — 0 handles open` |
| Shutdown entry — non-zero handle count when handles leaked | Correct non-zero count reported |
| Embedded tab in message text escaped to `\t` | Column structure intact in file |
| Helper writer stop — clean exit | No orphaned worker process after shutdown |

Tests must not leave residual `log_level` or `log_debug_level` files in the log directory. Clean-up must occur explicitly at the end of the test method.

---

## Appendix A — ObjectTools 4 Logging Documentation (Source Reference)

The following is a verbatim transcription of the ObjectTools 4 logging documentation, as extracted from the product documentation and used as the primary reference for this specification. It is preserved here to provide an unambiguous record of the original behaviour that Phase 10 is designed to emulate.

---

### Logging

#### The ObjectTools Log

ObjectTools 4 logs its internal operations to help you debug problems that are difficult to trace otherwise.

Logs are kept in `<database structure directory>/Logs/ObjectTools`, where the "Logs" directory is what would be returned by `Get 4D folder(Logs Folder)`. Log files are rotated automatically when they reach 1 MB in size. A total of seven log files are kept, with `ObjectTools.0.log` being the current log file, `ObjectTools.1.log` being the previous log file, and so on up to `ObjectTools.6.log`.

ObjectTools logs the following types of information in the log file:

- Information about the host environment
- Internal and runtime errors

Each log entry occupies one logical line and looks something like this:

```
Nov 20 17:08:34 ObjectTools: [notice] env: ObjectTools 4.0
[Macintosh/Intel, release]
```

Log entries contain the date and time of the entry, followed by `"ObjectTools:"`, followed by the entry type, followed by the message.

The log entry types are:

- **info**: General information about ObjectTools operations or environment
- **notice**: "Official" announcements
- **warn**: Conditions that may cause problems or errors and should be looked into
- **error**: Internal or runtime errors that should be attended to
- **debug**: Detailed information about ObjectTools's internal operations

#### Changing the Log Level

If the normal logging does not provide enough information to debug a problem, or if you would like to disable logging altogether, you can change the log level.

To change the log level, follow these steps:

1. In a text editor, create a new plain text document.
2. In the document, enter the text `"debug"` or `"off"`.
3. Save the document as `"log_level"` in the ObjectTools log directory.
4. Restart 4D.

If ObjectTools finds `"log_level"` (or for backward compatibility, `"log_debug_level"`) in the log directory and it contains `"debug"` or `"off"`, the log level is set accordingly.

- When the log level is `"debug"`, you will see many extra log entries of type `"debug"`. This level gives you detailed information about the inner workings of ObjectTools.
- When the log level is `"off"`, logging is completely turned off.

The default log level can be restored either by moving, renaming, or deleting the `"log_level"` file, or by deleting the text within the file, then restarting 4D.

---

## Appendix B — Installed Helper Logging Component

The helper logging routines are now installed in the project and used as the low-level logging infrastructure for Phase 10. Key patterns retained from that helper implementation:

**Worker-based I/O.** All file writes are dispatched via `CALL WORKER` to a dedicated `Log Writer` worker process (`LOG THIS`). This serialises writes naturally without semaphore locking — the worker's single-threaded execution model guarantees that entries are never interleaved.

**Document handle kept open.** The worker maintains an open document handle between calls (using `SEND PACKET` rather than `APPEND DOCUMENT`), avoiding repeated open/close overhead on every entry. Handles are tracked in process arrays (`Log_Paths_at` / `Log_DocRefs_ah`) local to the worker.

**`Timestamp` for C1.** `LOG ADD ENTRY` uses `Timestamp` directly as the timestamp source. OTr layers any additional timestamp policy on top of this helper behaviour.

**Tab-delimited columns with escape.** The helper uses `Storage.k.tab` as the column delimiter and escapes embedded tabs and line feeds within message text, protecting column integrity. OTr adopts the same convention.

**`Get 4D folder(Logs folder; *)` for location.** `Log_Init` uses this exact call for the default log location, confirming the approach in §2.1.

**`Count parameters` for optional parameters.** `LOG ENABLE` and other methods use `Count parameters` to distinguish optional from omitted arguments, confirming the pattern used in `OTr_LogLevel` (§6).

---

## Appendix C — Future Enhancements

**Log archiving.** When a session is purged by the retention policy, all `.txt` files in the session series could be combined into a single ZIP archive (`ObjectTools YY-MM-DD-HH-MM.zip`) using `ZIP Create archive` with the `files` collection syntax, with source files deleted on success. Reference: `ZIP Create archive` (4D v19 documentation).

**DST offset refresh.** The cached `Storage.OTr.logUTCOffset` could be refreshed at a daily boundary to handle daylight saving time transitions in long-running servers.

**Configurable thresholds.** The `logRetainSessions` and `logSizeThreshold` values could be exposed via a separate `OTr_LogConfig` method.
