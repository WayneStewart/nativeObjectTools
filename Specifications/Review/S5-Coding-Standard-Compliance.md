# Review Session S5 — Coding Standard and `%attributes` Compliance

**Version:** 1.0
**Date:** 2026-04-11
**Author:** Wayne Stewart / Claude
**Dependencies:** None — may be commenced immediately
**Parallel with:** S1, S2, S4 (fully independent)

---

## Purpose

Verify that all `OTr_` method source files comply with the `4D-Method-Writing-Guide.md` coding standard, that every method's `%attributes` line is correct (`"invisible":true`, correct `"shared"` value), and that method headers, parameter declarations, and variable naming conventions are consistently applied across the entire codebase. Also audit the `Documentation/Methods/` per-method documentation files for completeness and accuracy.

This is a systematic, file-by-file audit. It is well suited to automation (scripted grep/awk over `.4dm` files) and can be partially parallelised with S2.

---

## Scope

### Files to examine

- All `.4dm` files in `Project/Sources/Methods/` with the `OTr_` prefix (public API, `OTr_z*`, `OTr_u*`)
- `4D-Method-Writing-Guide.md` — the authoritative coding standard
- `OTr-Types-Reference.md` — the authoritative type suffix table
- `Documentation/Methods/` — per-method documentation files
- `Project/Sources/folders.json` — method group registration

---

## Review Checklist

### 1. `%attributes` line

Every `.4dm` file must begin with a `%attributes` line. For **public API methods**:

```
// %attributes = {"invisible":true,"shared":true}
```

For **private infrastructure (`OTr_z*`) and utility (`OTr_u*`) methods**:

```
// %attributes = {"invisible":true,"shared":false}
```

For **test methods (`____Test_Phase_*`)**:

```
// %attributes = {"invisible":true,"shared":false}
```

Checks:
- [ ] Every `.4dm` file has a `%attributes` line as the first line
- [ ] `"invisible":true` is present on every method
- [ ] `"shared":true` on all public API methods; `"shared":false` on all `OTr_z*`, `OTr_u*`, and test methods
- [ ] No other attributes are present that contradict the above

**Known issue from Phase 20 TODO:** Confirm all methods are registered correctly and that `%attributes` is consistent. Treat this audit as the definitive check.

### 2. `#DECLARE` parameter declaration

Every method that accepts parameters or returns a function result must use `#DECLARE`. No numbered parameters (`$1`, `$2`, etc.) or legacy `C_*` / `ARRAY *` declarations are permitted.

- [ ] Every method with parameters has a `#DECLARE` line
- [ ] No numbered parameters (`$1`, `$2`, etc.) appear in any method body
- [ ] No `C_LONGINT`, `C_TEXT`, `C_BOOLEAN`, etc. declarations appear (legacy syntax)
- [ ] Function results use the `-> $result` or `-> $result_<suffix>` syntax

### 3. Parameter naming — type suffixes

Per `OTr-Types-Reference.md` and `4D-Method-Writing-Guide.md`, every parameter and local variable name must carry the appropriate type suffix.

**Common suffixes:**

| Type | Suffix | Example |
|---|---|---|
| Integer / Longint | `_i` | `$handle_i` |
| Real | `_r` | `$value_r` |
| Text | `_t` | `$tag_t` |
| Boolean | `_b` | `$found_b` |
| Object | `_o` | `$obj_o` |
| Collection | `_c` | `$list_c` |
| BLOB | `_blob` | `$data_blob` |
| Picture | `_pic` | `$image_pic` |
| Pointer | `_ptr` | `$thePointer_ptr` |
| Date | `_d` | `$date_d` |
| Time | `_h` | `$time_h` |
| Variant | `_x` or `_v` | (check guide) |

Checks:
- [ ] All `#DECLARE` parameters carry the correct suffix
- [ ] All local variables (`$var`) carry the correct suffix
- [ ] **Known issue:** Stray `_p` suffix in `OTr_uPointerToText.4dm`, `OTr_uTextToPointer.4dm`, `OTr_PutArrayPointer.4dm`, `OTr_GetArrayPointer.4dm`, `OTr_zSortSlotPointer.4dm` — confirm and correct per Phase 20 TODO
- [ ] **Known issue:** Stray `_p` / `_x` suffixes in `OTr-Phase-004-Spec.md` — note for S1 resolution

### 4. Method header (boxed comment block)

Every method must have a boxed header comment block following the `%attributes` line and `#DECLARE`. The standard format (per `4D-Method-Writing-Guide.md`) includes at minimum:

- Method name
- Purpose / description
- Parameters (name, type, direction, description)
- Return value (if function)
- Errors / `OK` behaviour

Checks:
- [ ] Every method has a boxed header block
- [ ] The header accurately describes the method's current behaviour (not a stale copy from an earlier version)
- [ ] The `OK` variable behaviour is documented in the header (e.g., "Sets OK to 0 if handle is invalid")
- [ ] Parameter descriptions match the `#DECLARE` parameter names and types

### 5. Variable naming — consistency

Beyond type suffixes, check for consistent naming patterns:

- [ ] Handle parameters consistently named `$handle_i` (not `$h`, `$hObject`, `$theHandle`, etc.)
- [ ] Tag parameters consistently named `$tag_t` (not `$key`, `$name`, `$theTag`, etc.)
- [ ] Internal loop counters named consistently (e.g., `$i_i` or `$idx_i`)
- [ ] Result/return variable named consistently (e.g., `$result_*`)

### 6. `OTr_zSetOK` usage

The method `OTr_zSetOK` (or equivalent) is the prescribed mechanism for setting `OK` to 0 on error. Direct assignment `OK:=0` should not appear in public or utility methods.

- [ ] Search all `.4dm` files for direct `OK:=0` or `OK := 0` assignments
- [ ] Any such instances should be replaced with `OTr_zSetOK` calls (or documented as intentional)

### 7. Semaphore discipline

Every public method that accesses interprocess arrays must acquire and release the semaphore. This overlaps with S3 §8 (thread safety), but here the check is structural rather than semantic.

- [ ] All public methods call `OTr_zLock` (or equivalent) before array access
- [ ] All public methods call `OTr_zUnlock` (or equivalent) after array access
- [ ] `OTr_zUnlock` is called on **every** exit path, including early returns and error paths (a missing unlock causes permanent deadlock)

### 8. `OTr_zInit` call

Every public method must call `OTr_zInit` (lazy initialisation) before any other operation.

- [ ] Every public API method includes an `OTr_zInit` call as its first operative statement
- [ ] `OTr_zInit` is not called from private (`OTr_z*`) or utility (`OTr_u*`) methods (they are internal and rely on the public caller to have initialised)

### 9. `Documentation/Methods/` per-method docs

Each public API method should have a corresponding `.md` file in `Documentation/Methods/`.

- [ ] Cross-reference `Documentation/Methods/` against the list of public API methods (from S2)
- [ ] For each existing documentation file, confirm:
  - Method name in the file matches the `.4dm` filename
  - Parameter descriptions match the current `#DECLARE` signature
  - Return value description is accurate
  - `OK` behaviour description is accurate
  - Examples (if present) are syntactically valid 4D code

---

## Automation Suggestions

The following checks are well suited to scripted grep over the `.4dm` files and should be automated where possible:

| Check | Grep pattern |
|---|---|
| Missing `%attributes` line | Files not starting with `// %attributes` |
| `"invisible":false` | `"invisible":false` |
| Numbered parameters | `\$[1-9][^_]` |
| Legacy C_* declarations | `^C_` |
| Direct `OK:=0` assignment | `OK\s*:=\s*0` |
| Stray `_p` suffix | `\$\w+_p[^a-z]` |
| Missing `#DECLARE` | Files with parameters but no `#DECLARE` line |

---

## Expected Outputs

1. A list of `%attributes` violations by file
2. A list of `#DECLARE` / numbered-parameter violations by file
3. A list of type-suffix violations by file, with corrections noted
4. A list of methods missing boxed headers or with stale/inaccurate headers
5. Confirmation that `OTr_zSetOK` is used consistently
6. Confirmation (or list of violations) of semaphore discipline
7. Confirmation that `OTr_zInit` is called correctly in all public methods
8. A list of `Documentation/Methods/` files that are missing or inaccurate

---

## Notes for the Reviewer

The `4D-Method-Writing-Guide.md` is the final authority on all coding standard questions. When in doubt, it takes precedence over any individual method's existing style.

The stray `_p` suffix issue is well-documented in the Phase 20 TODO. Treat this as a known finding and verify that all five named files (`OTr_uPointerToText.4dm`, `OTr_uTextToPointer.4dm`, `OTr_PutArrayPointer.4dm`, `OTr_GetArrayPointer.4dm`, `OTr_zSortSlotPointer.4dm`) still contain the issue, then produce corrected versions.

This session is largely mechanical and is a strong candidate for automation assistance. Consider asking Claude to generate a compliance report by scanning the `.4dm` files programmatically before beginning the manual review.
