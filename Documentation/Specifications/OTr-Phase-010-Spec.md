# OTr Phase 10 — Logging Subsystem

**Version:** 0.3
**Date:** 2026-04-06
**Status:** In Progress
**Author:** Wayne Stewart / Claude / Codex
**Parent Document:** [OTr-Specification.md](OTr-Specification.md)

---

## Overview

Phase 10 introduces a structured logging subsystem to OTr. The subsystem replicates the observable behaviour of the ObjectTools 4/5 logging facility — including log file location, rotation policy, entry format, severity levels, and the run-time log level override mechanism — whilst implementing the underlying mechanics in native 4D and introducing improvements suited to OTr's architecture.

Phase 10 defines three **shared (published) methods**: `OTr_Startup`, `OTr_Shutdown`, and `OTr_LogLevel`. `OTr_Startup` and `OTr_Shutdown` allow host databases to explicitly initialise and shut down the logging subsystem when the host security setting for `On Host Database Event` execution is disabled. `OTr_LogLevel` provides a programmatic getter/setter interface to the active log level. All remaining implementation methods in this phase carry the `OTr_z` internal prefix and are `"shared":false`.

---

## 1. Scope and Goals

### 1.1 Functional Goals

The logging subsystem must satisfy the following requirements:

- Write structured, tab-delimited log entries to a set of UTF-8 plain-text files in a well-defined directory beneath the host database's Logs folder.
- Produce one log file series per application session, named with a timestamp captured at startup.
- Rotate to a new file within a session when a configurable size threshold is reached.
- Support five severity levels — `debug`, `info`, `notice`, `warn`, and `error` — matching the ObjectTools log level vocabulary exactly.
- Support a run-time log level override via a sentinel file (`log_level`) and via the public `OTr_LogLevel` API method.
- Retain the last N session log series, deleting older sessions at startup.
- Dispatch all file I/O through a dedicated worker process to serialise writes without semaphore locking.
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

The resolved directory path is cached at startup in `Storage.OTr.log.path`. Routines that need the sentinel file derive it by appending `log_level` (or `log_debug_level`) to this directory path.

### 2.2 File Naming Convention

Each application session produces its own log file series. The session timestamp is captured once at startup (during `OTr_zLogInit`) and stored in `Storage.OTr.log.session` as a text string of the form `YY-MM-DD-HH-MM`.

Log files within a session are named:

```
ObjectTools YY-MM-DD-HH-MM.NNN.txt
```

Where `NNN` is a zero-padded three-digit sequence number starting at `001`, incrementing each time the size threshold is reached within the session.

Examples:

```
ObjectTools 26-04-06-07-55.001.txt
ObjectTools 26-04-06-07-55.002.txt
```

This naming convention ensures that:

- File managers and log viewers sequence files correctly via lexicographic sort within a session.
- Sessions are immediately distinguishable by their timestamp prefix.
- The session key for grouping or archiving purposes is simply the `YY-MM-DD-HH-MM` prefix shared by all files in the series.

### 2.3 Within-Session Size Rollover

When the current log file reaches or exceeds the configured size threshold, `OTr_zLogWorker` closes the current file, increments the sequence counter stored in `Storage.OTr.log.sequence`, and opens a new file with the next sequence number. The session timestamp prefix is unchanged.

> **Workshop item:** The exact size threshold (originally 1 MB in ObjectTools 4) is subject to review. The threshold value is stored in `Storage.OTr.log.sizeThreshold` (Integer, bytes) and initialised to a default during `OTr_zLogInit`, making it straightforward to adjust without code changes.

### 2.4 Session Retention Policy

At startup, `OTr_zLogInit` enumerates all files in the log directory matching the pattern `ObjectTools *.txt`, extracts the unique `YY-MM-DD-HH-MM` session prefixes, sorts them lexicographically (which is equivalent to chronological order given the format), and deletes all files belonging to sessions beyond the most recent N, where N is stored in `Storage.OTr.log.retainSessions` (Integer, default `10`).

Deletion applies to all files in the session series (i.e., all files sharing the same timestamp prefix).

---

## 3. Log Entry Format

### 3.1 Column Structure

Each log entry occupies a single logical line with five tab-delimited columns:

| Column | Content | Example |
|---|---|---|
| C1 | Timestamp (local time, ISO-style) | `2026-04-06T07:55:02.347` |
| C2 | Application token — **TBD** (see §3.2) | `ObjectTools` |
| C3 | Severity level (plain, no brackets) | `info` |
| C4 | Message source | `env`, `plugin`, or command name e.g. `OT PutArrayReal` |
| C5 | Message text | `log level = info` |

The entry is terminated by a single LF character (`Char(10)`) on all platforms. Files are written in binary mode to prevent 4D on Windows from performing any automatic CRLF translation, ensuring the LF-only convention holds universally. Modern text editors including Notepad on Windows 10 and later handle LF-only files correctly.

Any tab characters within C5 message text must be escaped to `\t` before the entry is assembled, and any embedded LF characters escaped to `\n`, to prevent corruption of the column structure.

### 3.2 Application Token (C2) — TBD

Whether to retain the `ObjectTools` token in C2 on every line is deferred pending empirical observation of the debug-level log output (see §13). It may be determined that the token adds noise rather than value once the column structure is established, or it may prove useful for filtering in multi-component environments. The spec will be updated after the Phase 15 test run.

### 3.3 Timestamp Construction (C1)

The `Timestamp` command returns a GMT ISO 8601 string of the form `"YYYY-MM-DDTHH:MM:SS.mmmZ"`. Converting this to local time on every write via `Current date(*)` and `Current time(*)` would incur significant overhead as those calls with the `*` parameter are substantially slower than `Timestamp`. Instead, the UTC offset is computed **once at startup** and cached:

1. During `OTr_zLogInit`, call `Current date(*)` and `Current time(*)` to obtain the local wall-clock values, and parse a single `Timestamp` call to obtain the UTC values.
2. Compute the offset in seconds: `$offset_r := (local date/time as seconds) - (UTC date/time as seconds)`.
3. Store as `Storage.OTr.log.utcOffset` (Real, e.g. `36000` for UTC+10, `-12600` for UTC-3.5).

On every subsequent write, `OTr_zLogWorker` calls `Timestamp`, strips the trailing `Z`, parses the numeric components, adds `Storage.OTr.log.utcOffset` seconds, adjusts for overflow/underflow at hour and day boundaries, and formats C1 as `YYYY-MM-DDTHH:MM:SS.mmm`.

> **Known limitation:** If a daylight saving time boundary is crossed during a long-running session, the cached offset will be stale and log timestamps will diverge from wall-clock time by one hour. Refreshing the offset daily or on demand is noted as a future enhancement (see Appendix C).

### 3.4 Example Entry

```
2026-04-06T09:15:02.347	ObjectTools	info	env	log level = info
```

---

## 4. Severity Levels

Five severity levels are defined, in ascending order of urgency. The constants map to their Text token equivalents, as `Storage.OTr.log.level` stores the active level as **Text** and `Storage.OTr.log.levelPriority` stores the cached numeric threshold:

| Level token | Constant | Priority | Description |
|---|---|---|---|
| `"debug"` | `OT Log Debug` | `1` | Detailed internal diagnostic information |
| `"info"` | `OT Log Info` | `2` | General operational information |
| `"notice"` | `OT Log Notice` | `3` | Official announcements |
| `"warn"` | `OT Log Warn` | `4` | Conditions that may indicate a problem |
| `"error"` | `OT Log Error` | `5` | Internal or runtime errors requiring attention |

These constants are defined in the `OT Log Level` constant theme in the XLF resource file:

| Constant Name | Text Value |
|---|---|
| `OT Log Off` | `"off"` |
| `OT Log Debug` | `"debug"` |
| `OT Log Info` | `"info"` |
| `OT Log Notice` | `"notice"` |
| `OT Log Warn` | `"warn"` |
| `OT Log Error` | `"error"` |

For threshold comparison in `OTr_zLogWrite`, the private helper `OTr_zLogLevelConversion` normalises between the canonical Text tokens and the numeric ranks (`"off"` = `0`, `"debug"` = `1`, … `"error"` = `5`). A log entry is written if and only if its level's rank is greater than or equal to the active level stored in `Storage.OTr.log.levelPriority`, except when the active level is `"off"` (rank `0`), in which case nothing is ever written.

**Default active level:** `"info"` — entries at `info`, `notice`, `warn`, and `error` are written; `debug` entries are suppressed.

---

## 5. Log Level Override

### 5.1 Sentinel File Mechanism

The active log level may be overridden at run time by placing a plain-text file named `log_level` in the log directory. The file may contain any of the recognised level tokens:

| File contents | Effect |
|---|---|
| `debug` | All five severity levels are written |
| `info` | Default behaviour (same as no file) |
| `notice` | Only `notice`, `warn`, and `error` entries written |
| `warn` | Only `warn` and `error` entries written |
| `error` | Only `error` entries written |
| `off` | Logging completely suppressed |

The file is read once during `OTr_zLogInit`. The resolved level is stored in `Storage.OTr.log.level`, and the corresponding numeric threshold is stored in `Storage.OTr.log.levelPriority`. Changes made directly to the file take effect only after 4D is restarted. In-session changes are made explicitly by calling `OTr_LogLevel` (see §6).

For backward compatibility, the legacy filename `log_debug_level` is recognised with identical semantics. If both files are present, `log_level` takes precedence.

If the file exists but its contents are empty or whitespace-only, the default level (`"info"`) is used and no warning is issued. If the file contains an unrecognised token, the default level (`"info"`) is also used and no warning is issued.

### 5.2 Returning to the Default Level

The startup default is `"info"`. For file-based configuration, the effective startup level returns to this default if the `log_level` file is moved, renamed, deleted, or cleared, and 4D is restarted.

For in-session changes, `OTr_LogLevel("")` may be called to set the active level back to `"info"`. `OTr_LogLevel` does not reload the sentinel file and does not perform any automatic “restore default from disk” behaviour.

---

## 6. Public API Method: `OTr_LogLevel`

### 6.1 Purpose

`OTr_LogLevel` provides a programmatic interface to read and optionally set the active log level at run time, without requiring a restart of 4D or manual file editing. It has no direct ObjectTools 4/5 counterpart and is an OTr extension.

### 6.2 Attributes

```4d
//%attributes = {"invisible":true,"shared":true}
```

### 6.3 Signature

```4d
#DECLARE($setLogLevel_v : Variant; $permanent_b : Boolean) -> $getLogLevel_t : Text
```

### 6.4 Parameters

| Parameter | Type | Description |
|---|---|---|
| `$setLogLevel_v` | Variant | *(Optional)* New log level setting. May be either a Text token or `OT Log ...` constant value, or an Integer priority `0..5`. Empty string (`""`) is treated as `"info"`. |
| `$permanent_b` | Boolean | *(Optional)* If `True`, writes the resolved level token to the `log_level` file in the directory held in `Storage.OTr.log.path`, making it persist across restarts. Default: `False`. |
| `$getLogLevel_t` | Text | Returns the current active log level token, or `"Unrecognised"` when invalid input is supplied and no change is made. |

Optional parameters are handled via `Count parameters`. `$permanent_b` defaults to `False` when omitted.

### 6.5 Behaviour

```4d
$parametersCount_i := Count parameters

$setLogLevel_v := Choose($parametersCount_i > 0; $setLogLevel_v; Null)
$permanent_b   := Choose($parametersCount_i = 2; $permanent_b; False)

If ($parametersCount_i > 0)
    If (Type($setLogLevel_v)=Is text)
        If ($setLogLevel_v="")
            $resolvedLevel_t:="info"
            $resolvedPriority_i:=2
        Else 
            $resolvedPriority_i:=OTr_zLogLevelConversion($setLogLevel_v)
            If ($resolvedPriority_i#-1)
                $resolvedLevel_t:=OTr_zLogLevelConversion($resolvedPriority_i)
            End if 
        End if 
    Else 
        If (Type($setLogLevel_v)=Is Integer)
            $resolvedLevel_t:=OTr_zLogLevelConversion($setLogLevel_v)
            If ($resolvedLevel_t#"unrecognised token")
                $resolvedPriority_i:=$setLogLevel_v
            End if 
        End if 
    End if 
    
    If (($resolvedPriority_i#-1) & ($resolvedLevel_t#"unrecognised token"))
        Use (Storage.OTr)
            Storage.OTr.log.level:=$resolvedLevel_t
            Storage.OTr.log.levelPriority:=$resolvedPriority_i
        End use 
        
        If ($permanent_b)
            // Write $resolvedLevel_t to log_level in the directory at Storage.OTr.log.path
        End if 
    Else 
        $getLogLevel_t:="Unrecognised"
    End if 
End if

If ($getLogLevel_t#"Unrecognised")
    $getLogLevel_t:=Storage.OTr.log.level
End if
```

### 6.6 Usage Examples

```4d
// Query the current level
$level_t := OTr_LogLevel   // Returns e.g. "info"

// Set to debug for the current session only
OTr_LogLevel(OT Log Debug)

// Set to debug and persist across restarts
OTr_LogLevel(OT Log Debug; True)

// Restore to info and persist
OTr_LogLevel(OT Log Info; True)

// Reset the in-session level to the default
OTr_LogLevel("")
```

---

## 7. Lifecycle Integration

### 7.1 `On Host Database Event` (Preferred)

The component implements the `On Host Database Event` database method. When the host database has the security setting **"Execute 'On Host Database Event' method of the components"** enabled (Settings → Security), 4D calls this method automatically at the appropriate lifecycle points.

OTr responds to two events:

| Event constant | Value | OTr action |
|---|---|---|
| `On before host database startup` | `1` | Call `OTr_Startup` |
| `On before host database exit` | `3` | Call `OTr_Shutdown` |

Events `2` (`On after host database startup`) and `4` (`On after host database exit`) are received but require no action from the logging subsystem.

### 7.2 Manual Fallback

If the host database has the security setting disabled (the default), the host developer must call the following methods explicitly:

- `OTr_Startup` from the host's `On Startup` database method.
- `OTr_Shutdown` from the host's `On Exit` database method.

This requirement must be clearly documented in the OTr integration guide. Failure to call `OTr_Shutdown` will leave the Log Writer worker running and the log file handle open; 4D will close the file on process termination, but the shutdown log entry will be absent.


---

## 8. Startup Log Entries

`OTr_zStartup` writes the following entries at startup, based on the format observed in the ObjectTools 5 log. All entries use severity `OT Log Info` and source `env`:

```
2026-04-06T09:15:02.347	[C2]	info	env	*****************************************************************
2026-04-06T09:15:02.347	[C2]	info	env	  ObjectTools
2026-04-06T09:15:02.347	[C2]	info	env	*****************************************************************
2026-04-06T09:15:02.347	[C2]	info	env	checking log level path: <full path to log_level file>
2026-04-06T09:15:02.347	[C2]	info	env	checking log level path: <full path to log_debug_level file>
2026-04-06T09:15:02.347	[C2]	info	env	no log level file found
2026-04-06T09:15:02.347	[C2]	info	env	log level = info
2026-04-06T09:15:02.347	[C2]	info	env	OTr <version> [<platform>/<arch>, <buildType>]
2026-04-06T09:15:02.347	[C2]	info	env	4D <version> [<processMode>, <execMode>, <OSVersion>]
2026-04-06T09:15:02.347	[C2]	info	env	checked
```

> **Note:** `[C2]` is shown as a placeholder pending the decision on the application token column (§3.2).

> **Note:** ICU-related entries (`env: ICU version`, `env: ICU data directory`, `env: ICU locale`) are present in the ObjectTools 5 startup block at `info` level. Whether OTr emits equivalent entries (e.g. reporting the 4D Unicode library version or locale) is deferred pending the Phase 15 debug-level test run (§13).

The `plugin: successfully registered ObjectTools` entry observed in the legacy log is written separately when `OTr_Register` is called, not during startup. OTr emits an equivalent `info` entry with source `plugin` at that point.

---

## 9. Shutdown Log Entry

`OTr_zShutdown` writes a single entry before stopping the Log Writer worker and closing the log file:

```
2026-04-06T18:30:15.112	[C2]	info	env	ObjectTools shutdown
```

---

## 10. Internal Methods

### 10.1 `OTr_Startup`

**Access:** Shared (`"invisible":true`, `"shared":true`)

**Signature:** `#DECLARE`

**Implementation guidelines:** 
- The existing method `OTr_zInit` must be modified so it calls `OTr_zLogInit` after the main Storage object and core module state have been initialised.
- `OTr_Startup` is a shared wrapper intended for use by the host database when the component `On Host Database Event` mechanism is not enabled.
- `OTr_Startup` shall call `OTr_zInit` immediately after variable declarations to initialise the component.
- `OTr_Startup` shall then determine from the state of `Storage.OTr` whether startup processing has already been completed; if not, it shall call `OTr_zStartup`.
- This makes startup idempotent: automatic component startup and manual host startup can coexist safely.

**Responsibilities:**

1. `OTr_zLogInit`: Resolve and create the log directory (`Get 4D folder(Logs folder; *) + "ObjectTools" + Folder separator`). 
2. `OTr_zLogInit`: Cache the directory in `Storage.OTr.log.path`.
3. `OTr_zLogInit`: Apply session retention policy: enumerate existing session prefixes, delete files belonging to sessions beyond the most recent N (`Storage.OTr.log.retainSessions`).
4. `OTr_zLogInit`: Capture the session timestamp (`YY-MM-DD-HH-MM` from local time using a single `Current date(*)`/`Current time(*)` call). Store in `Storage.OTr.log.session`.
5. `OTr_zLogInit`: Compute and cache the UTC offset in `Storage.OTr.log.utcOffset` (see §3.3).
6. `OTr_zLogInit`: Set initial sequence counter `Storage.OTr.log.sequence` to `1`.
7. `OTr_zLogInit`: Read the `log_level` (or `log_debug_level`) file if present; resolve it via `OTr_zLogLevelConversion`; set both `Storage.OTr.log.level` and `Storage.OTr.log.levelPriority`; fall back to `"info"` / `2`.
8. `OTr_zStartup`: Write the startup log block (§8).

---

### 10.2 `OTr_Shutdown`

**Access:** Shared (`"invisible":true`, `"shared":true`)

**Signature:** `#DECLARE`

**Responsibilities:** Determine from `Storage.OTr` whether shutdown processing is required; if so, call `OTr_zShutdown`.

---

### 10.3 `OTr_zStartup`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:** `#DECLARE`

**Responsibilities:** Mark startup as completed in `Storage.OTr`; write the startup log block (§8).

---

### 10.4 `OTr_zShutdown`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:** `#DECLARE`

**Responsibilities:** Write the shutdown entry (§9); send a close-file message to the Log Writer worker; stop the worker via `CALL WORKER(Log Writer; "OTr_zLogWorkerStop")`; mark shutdown in `Storage.OTr`.

---

### 10.5 `OTr_zLogWrite`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE($inLevel_t : Text; $inSource_t : Text; $inMessage_t : Text)
```

**Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `$inLevel_t` | Text | One of the `OT Log` text constants |
| `$inSource_t` | Text | Source identifier: `"env"`, `"plugin"`, or an OT command name |
| `$inMessage_t` | Text | Message body; embedded tabs escaped to `\t`, LFs to `\n` |

**Behaviour:**

1. Read `Storage.OTr.log.levelPriority`. If `0`, return immediately.
2. Call `OTr_zLogLevelConversion` for the entry level. If the entry rank is less than `Storage.OTr.log.levelPriority`, return immediately.
3. Dispatch to the Log Writer worker: `CALL WORKER(Log Writer; "OTr_zLogWorker"; $inLevel_t; $inSource_t; $inMessage_t)`.

---

### 10.6 `OTr_zLogWorker`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE($inLevel_t : Text; $inSource_t : Text; $inMessage_t : Text)
```

This method executes in the `Log Writer` worker process. It is called exclusively via `CALL WORKER` and must never be called directly.

**Behaviour:**

1. Call `Timestamp` and apply `Storage.OTr.log.utcOffset` to produce the local-time C1 string.
2. Assemble the tab-delimited entry string (C1 through C5, terminated by `Char(10)`).
3. Check whether the current log file size has reached `Storage.OTr.log.sizeThreshold`. If so: close the current document, increment `Storage.OTr.log.sequence`, open a new file.
4. If no file is currently open: open (or create) `ObjectTools <session>.<NNN>.txt` via `Append document` / `Create document`.
5. Write the entry via `SEND PACKET`.

The worker keeps the document handle open between calls, as per the pattern established in the `LOG THIS` helper (see Appendix B). The handle is closed only by `OTr_zLogWorkerStop`.

---

### 10.7 `OTr_zLogWorkerStop`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:** `#DECLARE`

Called by `OTr_Shutdown` via `CALL WORKER` to close the open document handle and terminate the worker process cleanly.

---

### 10.8 `OTr_zLogLevelConversion`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE($inLevel_v : Variant) -> $outLevel_v : Variant
```

Maps between a level token and its numeric rank for threshold comparison and normalisation:

| Token | Rank |
|---|---|
| `"off"` | `0` |
| `"debug"` | `1` |
| `"info"` | `2` |
| `"notice"` | `3` |
| `"warn"` | `4` |
| `"error"` | `5` |

Behaviour:

- If `$inLevel_v` is Text, return the Integer rank.
- If `$inLevel_v` is Integer, return the canonical Text token.
- Unrecognised Text returns `-1`.
- Unrecognised Integer returns `"unrecognised token"`.

---

### 10.9 `OTr_zLogDirectory`

**Access:** Private (`"invisible":true`, `"shared":false`)

**Signature:**

```4d
#DECLARE -> $outPath_t : Text
```

Returns the absolute path to the `ObjectTools` log subdirectory with trailing separator, creating the directory if absent. Used during `OTr_zLogInit` and by `OTr_LogLevel` when writing the `log_level` file.

---

## 11. Storage Schema

The logging subsystem uses a subobject `Storage.OTr.log` to store the following properties on the shared `Storage.OTr` object:

| Property | Type | Description |
|---|---|---|
| `Storage.OTr.log.level` | Text | Active minimum severity token (`"info"`, `"debug"`, etc.) |
| `Storage.OTr.log.levelPriority` | Integer | Cached numeric threshold for the active level (`0..5`) |
| `Storage.OTr.log.path` | Text | Resolved absolute path to the log directory |
| `Storage.OTr.log.session` | Text | Session timestamp prefix `YY-MM-DD-HH-MM` |
| `Storage.OTr.log.sequence` | Integer | Current within-session file sequence number |
| `Storage.OTr.log.sizeThreshold` | Integer | File size rollover threshold in bytes (default TBD — workshop item) |
| `Storage.OTr.log.retainSessions` | Integer | Number of sessions to retain (default `10`) |
| `Storage.OTr.log.utcOffset` | Real | UTC offset in seconds, computed once at startup |

---

## 12. Constants

The `OT Log Level` constant theme in the XLF resource file:

| Constant Name | Text Value |
|---|---|
| `OT Log Off` | `"off"` |
| `OT Log Debug` | `"debug"` |
| `OT Log Info` | `"info"` |
| `OT Log Notice` | `"notice"` |
| `OT Log Warn` | `"warn"` |
| `OT Log Error` | `"error"` |

---

## 13. Testing

### 13.1 Status

The test matrix for this phase is **pending empirical observation**. Before finalising tests, the Phase 15 side-by-side compatibility test (see [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md)) must be run with ObjectTools 5 at each log level (`info`, `debug`, and `off`) to determine:

- The exact set of entries produced at each level.
- Whether additional `debug`-level entries (e.g. ICU data, internal state) need to be replicated in OTr.
- Whether the `ObjectTools` application token in C2 adds meaningful value (§3.2 TBD).

The Phase 15 test may subsume the Phase 10 unit tests entirely, or a separate `Test_OTr_Phase010` method may be warranted. This will be determined after the empirical run.

### 13.2 Provisional Test Areas

Regardless of the above, the following areas must be covered by whatever test method is adopted:

| Test Area | Notes |
|---|---|
| Startup block entries written correctly at `info` level | Verify all lines in §8 are present |
| `debug` entries suppressed under default level | None should appear in the file |
| `debug` entries present when level is `"debug"` | All five levels visible |
| `OTr_LogLevel` getter returns current level | No argument form |
| `OTr_LogLevel` setter updates `Storage.OTr.log.level` and `Storage.OTr.log.levelPriority` immediately | In-session change |
| `OTr_LogLevel` with `$permanent_b = True` writes the `log_level` file | File present and readable after call |
| `OTr_LogLevel("")` resets the in-session level to `"info"` | No restart required |
| `OTr_LogLevel` accepts Integer input `0..5` | Canonical token and priority updated correctly |
| Invalid `OTr_LogLevel` input returns `"Unrecognised"` and leaves state unchanged | No side effects |
| Session file naming is correct | `YY-MM-DD-HH-MM.001.txt` |
| Within-session rollover produces `.002.txt` at threshold | File present with correct name |
| Session retention deletes old sessions beyond N at startup | Files from oldest session absent |
| Shutdown entry written and worker stops cleanly | Entry present; no orphaned worker |
| `log_debug_level` accepted as backward-compatible synonym | Debug level activated |
| Unrecognised `log_level` file content defaults to `"info"` | No error raised |
| Embedded tab in message text is escaped to `\t` | Column structure intact |

Tests must not leave residual `log_level` or `log_debug_level` files in the log directory. Clean-up must occur explicitly at the end of the test method.

---

## Appendix A — ObjectTools 4/5 Logging Documentation (Source Reference)

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

## Appendix B — Reference Implementation: Logging Helper Component

The `Helpers or Examples/Logging` project provides a proven native 4D logging implementation that informs the OTr logging architecture. Key patterns adopted from this reference:

**Worker-based I/O.** All file writes are dispatched via `CALL WORKER` to a dedicated `Log Writer` worker process (`LOG THIS`). This serialises writes naturally without semaphore locking — the worker's single-threaded execution model guarantees that entries are never interleaved.

**Document handle kept open.** The worker maintains an open document handle between calls (using `SEND PACKET` rather than `APPEND DOCUMENT`), avoiding repeated open/close overhead on every entry. Handles are tracked in process arrays (`Log_Paths_at` / `Log_DocRefs_ah`) local to the worker.

**`Timestamp` for C1.** `LOG ADD ENTRY` uses `Timestamp` directly as the timestamp source, confirming the approach adopted in §3.3. OTr extends this by applying the cached UTC offset to convert GMT to local time.

**Tab-delimited columns with escape.** The helper uses `Storage.k.tab` as the column delimiter and escapes embedded tabs and line feeds within message text to `\t` and `\r` respectively, protecting column integrity. OTr adopts the same escaping convention (using `\n` for line feeds to align with standard notation).

**`Get 4D folder(Logs folder; *)` for location.** `Log_Init` uses this exact call for the default log location, confirming the approach in §2.1.

**`Count parameters` for optional parameters.** `LOG ENABLE` and other methods use `Count parameters` to distinguish optional from omitted arguments, confirming the pattern used in `OTr_LogLevel` (§6).

---

## Appendix C — Future Enhancements

The following items are out of scope for Phase 10 but are recorded here for future consideration:

**Log archiving.** When a session is to be purged by the retention policy, rather than deleting the files, all `.txt` files in the session series could be combined into a single ZIP archive (`ObjectTools YY-MM-DD-HH-MM.zip`) using `ZIP Create archive` with the `files` collection syntax, and the source `.txt` files deleted upon successful archive creation. Archived sessions would not count against the `logRetainSessions` limit, or a separate `logRetainArchives` count could be introduced. Reference: `ZIP Create archive` (4D v19 documentation).

**DST offset refresh.** The cached `Storage.OTr.log.utcOffset` could be refreshed at a daily boundary to handle daylight saving time transitions in long-running servers.

**Configurable thresholds.** The `logRetainSessions` and `logSizeThreshold` values could be exposed via an extended API or a separate `OTr_LogConfig` method.

**Developer-authored log entries.** A future extension could allow host developers to insert their own messages into the OTr log stream. The source token would be `developer`, and developer-authored entry priorities could be represented as `10 + baseLevel`, allowing the system to recover the underlying severity by subtracting `10`. This remains provisional and would require refactoring of the current logging path before adoption.
