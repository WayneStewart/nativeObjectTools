## Plan: Finish OTr Phase 10 Logging

Complete Phase 10 by fixing the core correctness gaps first (error-entry structure, call-stack reliability, lifecycle hooks, retention), then align behavior details and expand verification. This preserves current working behavior while closing spec-critical gaps that affect log integrity and production operations.

**Steps**
1. Phase A - Stabilize Core Logging Semantics
2. Fix call stack initialization in [Project/Sources/Methods/OTr_zInit.4dm](Project/Sources/Methods/OTr_zInit.4dm) so process stack setup runs in the intended first-run path and does not depend on inverted initialization logic.
3. Move error call-stack construction responsibility from [Project/Sources/Methods/OTr_zError.4dm](Project/Sources/Methods/OTr_zError.4dm) into [Project/Sources/Methods/OTr_zLogWrite.4dm](Project/Sources/Methods/OTr_zLogWrite.4dm), so errors keep C4 as pure message text and C5 as call-stack text. Keep [Project/Sources/Methods/OTr_zError.4dm](Project/Sources/Methods/OTr_zError.4dm) as the single error chokepoint.
4. Update [Project/Sources/Methods/OTr_zLogWrite.4dm](Project/Sources/Methods/OTr_zLogWrite.4dm) to always emit 5 tab-delimited columns by forwarding a fourth payload segment (empty for non-error, call stack for error) to [Project/Sources/Methods/LOG ADD ENTRY.4dm](Project/Sources/Methods/LOG ADD ENTRY.4dm). Reuse OT Right Arrow constant from [Resources/OTr.xlf](Resources/OTr.xlf) for delimiter.
5. Keep current timestamp source path through [Project/Sources/Methods/OTr_z_timestampLocal.4dm](Project/Sources/Methods/OTr_z_timestampLocal.4dm) (user direction: already in place), and keep session key format YYYY-MM-DD-HH-MM (approved).
6. Phase B - Lifecycle + Shutdown Correctness
7. Add database method [Project/Sources/Methods/On Host Database Event.4dm](Project/Sources/Methods/On Host Database Event.4dm) to handle event 1 with OTr_z_LogInit and event 3 with OTr_zLogShutdown. Ignore events 2 and 4.
8. Update [Project/Sources/Methods/OTr_onExit.4dm](Project/Sources/Methods/OTr_onExit.4dm) to call OTr_zLogShutdown instead of direct helper close so shutdown entry and writer stop are centralized.
9. Fix shutdown guard in [Project/Sources/Methods/OTr_zLogShutdown.4dm](Project/Sources/Methods/OTr_zLogShutdown.4dm) to use initialized logging object state (Storage.OT_Logging null/non-null) instead of the currently unused flag variable path.
10. Phase C - Retention + Compatibility Edges
11. Implement startup session retention in [Project/Sources/Methods/OTr_z_LogInit.4dm](Project/Sources/Methods/OTr_z_LogInit.4dm): enumerate ObjectTools session files, group by session prefix, sort, and delete sessions beyond retainSessions.
12. Confirm fallback precedence remains: log_level first, then log_debug_level, default info.
13. Verify no process/interprocess variable behavior is changed outside logging scope.
14. Phase D - Verification and Regression Safety
15. Extend existing Phase 10 test methods to validate: 5-column output, C5-only stack for errors, arrow-delimited stack order, off-level gating, shutdown entry content, and retention pruning behavior.
16. Keep plugin-optional OT comparison tests intact and add OTr-only assertions where plugin availability is not guaranteed.
17. Run targeted phase methods (10, 10a, 10b) and inspect generated files under Logs/ObjectTools for deterministic formatting and rotation/retention outcomes.

**Priority order for execution**
1. P0 - Fix call-stack initialization bug in [Project/Sources/Methods/OTr_zInit.4dm](Project/Sources/Methods/OTr_zInit.4dm). This is foundational for any error-stack correctness.
2. P0 - Correct error log shape: keep message in C4 and move stack to C5 in [Project/Sources/Methods/OTr_zError.4dm](Project/Sources/Methods/OTr_zError.4dm) and [Project/Sources/Methods/OTr_zLogWrite.4dm](Project/Sources/Methods/OTr_zLogWrite.4dm).
3. P0 - Enforce 5-column output for all entries in [Project/Sources/Methods/OTr_zLogWrite.4dm](Project/Sources/Methods/OTr_zLogWrite.4dm) with empty C5 for non-error and arrow-delimited C5 for error using [Resources/OTr.xlf](Resources/OTr.xlf).
4. P0 - Add lifecycle hook [Project/Sources/Methods/On Host Database Event.4dm](Project/Sources/Methods/On Host Database Event.4dm) for startup and shutdown events.
5. P1 - Centralize shutdown path: update [Project/Sources/Methods/OTr_onExit.4dm](Project/Sources/Methods/OTr_onExit.4dm) to call [Project/Sources/Methods/OTr_zLogShutdown.4dm](Project/Sources/Methods/OTr_zLogShutdown.4dm), then fix shutdown guard state logic there.
6. P1 - Implement retainSessions pruning at startup in [Project/Sources/Methods/OTr_z_LogInit.4dm](Project/Sources/Methods/OTr_z_LogInit.4dm).
7. P2 - Verify log level persistence and precedence behavior remains correct in [Project/Sources/Methods/OTr_LogLevel.4dm](Project/Sources/Methods/OTr_LogLevel.4dm) and [Project/Sources/Methods/OTr_z_LogInit.4dm](Project/Sources/Methods/OTr_z_LogInit.4dm).
8. P2 - Expand Phase 10 OTr tests in [Project/Sources/Methods/____Test_Phase_10_OTr.4dm](Project/Sources/Methods/____Test_Phase_10_OTr.4dm), [Project/Sources/Methods/____Test_Phase_10a_OTr.4dm](Project/Sources/Methods/____Test_Phase_10a_OTr.4dm), and [Project/Sources/Methods/____Test_Phase_10b_OTr.4dm](Project/Sources/Methods/____Test_Phase_10b_OTr.4dm) for format, stack, off-gating, shutdown, retention.
9. P3 - Final regression run and log-file inspection using controllers [Project/Sources/Methods/____Test_Phase_10.4dm](Project/Sources/Methods/____Test_Phase_10.4dm), [Project/Sources/Methods/____Test_Phase_10a.4dm](Project/Sources/Methods/____Test_Phase_10a.4dm), and [Project/Sources/Methods/____Test_Phase_10b.4dm](Project/Sources/Methods/____Test_Phase_10b.4dm).

**Relevant files**
- [Project/Sources/Methods/OTr_zInit.4dm](Project/Sources/Methods/OTr_zInit.4dm) - call-stack process init fix
- [Project/Sources/Methods/OTr_zError.4dm](Project/Sources/Methods/OTr_zError.4dm) - keep message-only error handoff
- [Project/Sources/Methods/OTr_zLogWrite.4dm](Project/Sources/Methods/OTr_zLogWrite.4dm) - level gating, rollover, 5-column emission, C5 stack construction
- [Project/Sources/Methods/OTr_z_LogInit.4dm](Project/Sources/Methods/OTr_z_LogInit.4dm) - startup setup, sentinel read, retention logic
- [Project/Sources/Methods/OTr_zLogShutdown.4dm](Project/Sources/Methods/OTr_zLogShutdown.4dm) - shutdown guard + final entry + writer stop
- [Project/Sources/Methods/OTr_onExit.4dm](Project/Sources/Methods/OTr_onExit.4dm) - fallback wiring to centralized shutdown
- [Project/Sources/Methods/LOG ADD ENTRY.4dm](Project/Sources/Methods/LOG ADD ENTRY.4dm) - final line assembly behavior
- [Resources/OTr.xlf](Resources/OTr.xlf) - OT Right Arrow and log level constants
- [Project/Sources/Methods/Compiler_OTr.4dm](Project/Sources/Methods/Compiler_OTr.4dm) - declarations for any new/changed method signatures
- [Project/Sources/Methods/____Test_Phase_10.4dm](Project/Sources/Methods/____Test_Phase_10.4dm) - controller harness
- [Project/Sources/Methods/____Test_Phase_10_OTr.4dm](Project/Sources/Methods/____Test_Phase_10_OTr.4dm) - OTr logging behavior checks
- [Project/Sources/Methods/____Test_Phase_10a_OTr.4dm](Project/Sources/Methods/____Test_Phase_10a_OTr.4dm) - broad OTr regression checks
- [Project/Sources/Methods/____Test_Phase_10b_OTr.4dm](Project/Sources/Methods/____Test_Phase_10b_OTr.4dm) - misuse/error-path checks

**Verification**
1. Run Phase 10 test controller methods and confirm all complete without new regressions.
2. Inspect produced log entries and verify every line has exactly 5 tab-delimited columns.
3. Trigger representative OTr errors and verify C4 contains only message text while C5 contains arrow-delimited stack.
4. Set log level to off and verify probe/banner behavior still writes while post-probe logging is suppressed.
5. Confirm shutdown emits one final info entry with handle count and cleanly stops writer.
6. Seed multiple historical session files and verify retainSessions pruning deletes only oldest sessions.

**Decisions**
- Session prefix format: keep YYYY-MM-DD-HH-MM.
- Lifecycle integration: add On Host Database Event and keep manual fallback methods.
- Timestamp handling: keep current OTr_z_timestampLocal path for now (can be revisited if strict GMT is required).
- Included scope: complete Phase 10 parity and reliability items from revised spec.
- Excluded scope: JSON/remote logging, archive ZIP, DST refresh, and new trace/full modes.

- Scratch/reference methods prefixed with _____X___ were removed from Project/Sources/Methods to keep 4D method catalog and filesystem aligned.

**Further Considerations**
1. Stack order confirmation: outermost-to-innermost should be emitted in C5; this will be locked by test assertions to prevent regressions.
2. Backward compatibility: keep accepting both log_level and log_debug_level; write only log_level for permanence.
3. If strict spec parity is later needed, a narrow follow-up can switch C1 to GMT+Z without touching retention/lifecycle work.
