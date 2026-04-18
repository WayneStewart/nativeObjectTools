# Codex Live Testing Bridge

This project now includes a small 4D v19-compatible HTTP bridge so Codex can call whitelisted 4D methods while the project is open in 4D.

## Route

Start the 4D web server, then call:

```sh
curl --fail --silent --show-error http://127.0.0.1/codex/ping
curl --fail --silent --show-error http://127.0.0.1/codex/run/util_compileProject
curl --fail --silent --show-error --max-time 900 http://127.0.0.1/codex/run/unitTests
curl --fail --silent --show-error http://127.0.0.1/codex/run/util_restartProject
```

Use the actual web server port configured in 4D if it is not `80`.

## Security Model

The bridge intentionally does not expose arbitrary method execution.

- Requests must come from loopback: `127.0.0.1`, `::1`, or the IPv4-mapped loopback forms 4D can report.
- `Codex_Run` contains the whitelist. Add new callable test methods there explicitly.
- Responses are JSON and include only a JSON-safe summary of compiler output.

## Current Whitelist

- `ping`: confirms the web route is reachable.
- `util_compileProject`: runs `Compile project` with an empty `targets` collection, so it performs a syntax check without compiling.
- `unitTests` / `____Test_OTr_Master`: runs the master unit-test harness silently and returns pass/fail counts plus the generated Logs file path.
- `util_restartProject`: returns a JSON acknowledgement, then restarts 4D after a short delay.

## Why This Shape

This is deliberately lighter than a full MCP server in 4D. The HTTP bridge gives Codex a live test hook immediately through `curl`, while keeping the 4D surface area small and auditable. A later MCP wrapper can map MCP tool calls to these same HTTP endpoints without changing the 4D-side testing contract.
