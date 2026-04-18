# Codex Live Testing Process Specification

## Purpose

This specification defines the local testing bridge that lets Codex participate as a live test partner while the 4D project is open.

The bridge is intentionally small and 4D v19-compatible. It uses the existing 4D web server and a whitelisted dispatcher rather than exposing arbitrary project method execution or implementing a full MCP server inside 4D.

## Scope

The process covers:

- HTTP access from Codex to the local 4D web server.
- Syntax checks through `util_compileProject`.
- Automated unit-test execution through the master test harness.
- Controlled 4D restart through `util_restartProject`.
- Permission rules for restart operations.

The process does not cover:

- Remote access from another machine.
- Arbitrary project method execution.
- A general-purpose 4D MCP server.
- Production deployment of the bridge.

## Environment

- Target 4D version: 4D v19.
- Web server port: `80` unless changed in 4D settings.
- Expected caller: Codex running on the same machine as 4D.
- Expected URL base: `http://127.0.0.1`.

## Bridge Entry Points

The 4D web server routes Codex calls through `onWebConnection`.

Supported routes:

```sh
curl --fail --silent --show-error http://127.0.0.1/codex/ping
curl --fail --silent --show-error http://127.0.0.1/codex/run/util_compileProject
curl --fail --silent --show-error --max-time 900 http://127.0.0.1/codex/run/unitTests
curl --fail --silent --show-error http://127.0.0.1/codex/run/util_restartProject
```

## Dispatcher Contract

`Codex_Run(methodName; clientIP)` is the dispatcher.

It must:

- Reject non-loopback callers.
- Keep a fixed whitelist of callable methods.
- Return JSON-safe objects.
- Avoid exposing arbitrary method execution.
- Run non-thread-safe or long-running operations through workers where required.

Current whitelist:

| Method | Purpose | Expected Result |
| --- | --- | --- |
| `ping` | Connectivity check. | `ok:true`, `message:"pong"` |
| `util_compileProject` | Run 4D syntax check. | Compile summary with `success`, `errorCount`, `warningCount`, and messages. |
| `unitTests` | Alias for `____Test_OTr_Master`. | Unit-test summary with pass/fail counts and log path. |
| `____Test_OTr_Master` | Direct name for master unit-test runner. | Same as `unitTests`. |
| `util_restartProject` | Restart 4D after acknowledgement. | `ok:true`, then delayed restart. |

## Syntax Check Process

Codex calls:

```sh
curl --fail --silent --show-error --max-time 180 http://127.0.0.1/codex/run/util_compileProject
```

Expected pass condition:

- `result.success = true`
- `result.errorCount = 0`

Warnings are non-blocking for this project unless Wayne explicitly says otherwise. The project currently has known compiler warnings, so Codex should report them only when useful and should not treat them as a failed check.

## Unit-Test Process

Codex calls:

```sh
curl --fail --silent --show-error --max-time 900 http://127.0.0.1/codex/run/unitTests
```

The endpoint runs `____Test_OTr_Master(True)` through `Codex_z_RunUnitTestWorker`.

The worker is named `____Test_OTr_Master` so that the existing process-name guard in the master test harness runs the test body inline rather than spawning an interactive UI process.

Expected response shape:

```json
{
  "ok": false,
  "method": "unitTests",
  "result": {
    "ok": false,
    "method": "____Test_OTr_Master",
    "totalTests": 131,
    "passCount": 129,
    "failCount": 2,
    "summary": "Unit test total: 131  Pass: 129  Fail: 2",
    "logFile": "____Test_OTr_Master-YYYY-MM-DD-HH-MM-SS.txt",
    "logPath": "Macintosh HD:..."
  }
}
```

`ok` is false when any unit test fails. This is a valid bridge response and means the test suite ran successfully but found failing tests.

Codex should read the generated log file when tests fail and report the failing rows, not just the summary counts.

## Restart Process

Codex may call:

```sh
curl --fail --silent --show-error http://127.0.0.1/codex/run/util_restartProject
```

The dispatcher returns a JSON acknowledgement first, then calls `Codex_z_RestartProjectWorker`.

`Codex_z_RestartProjectWorker` waits briefly, then calls `util_restartProject` on the main process. This avoids cutting off the HTTP response before 4D restarts.

## Restart Permission Rule

Restarting 4D is disruptive and must be treated differently from syntax checks and unit tests.

Default rule:

- Codex must ask Wayne for permission before calling `/codex/run/util_restartProject`.

Allowed exception:

- Wayne may grant session-scoped permission, for example: "you can restart 4D without asking for this session".
- Session-scoped permission applies only to the current Codex session.
- Codex must not carry restart permission into future sessions unless Wayne explicitly grants a persistent rule.

Codex may still edit restart-related bridge code, compile-check it, and document it without asking for restart permission. The permission rule applies to actually triggering a restart.

## Recommended Codex Workflow

1. Make the requested code change.
2. Run the compile endpoint.
3. Treat `errorCount = 0` as a syntax pass, ignoring known warnings.
4. Run the unit-test endpoint when relevant.
5. If tests fail, read the generated log and report failing rows.
6. Ask permission before restarting 4D unless session-scoped permission has already been granted.
7. After a restart, confirm the bridge is reachable with `/codex/ping`.
8. Re-run compile and tests if the restart was needed to load code changes.

## Security Notes

- The bridge must remain loopback-only.
- The whitelist must stay explicit.
- Do not add a generic "run any method" endpoint.
- Do not expose this bridge through a public network interface.
- If a future MCP server is added, it should call the same whitelisted HTTP endpoints rather than bypassing this contract.

## Current Known Test State

At the time this process was documented, the live unit-test endpoint ran successfully and reported:

```text
totalTests: 131
passCount: 129
failCount: 2
```

The failing rows were Phase 16 legacy OT BLOB compatibility checks:

```text
110 Phase 16 Legacy OT BLOB import preserves nested values and DOCX BLOB
111 Phase 16 Imported legacy OT object round-trips as native OTr BLOB
```

These failures are test/product behavior results, not bridge failures.
