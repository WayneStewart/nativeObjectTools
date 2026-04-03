# 4D Method Writing Guide

**Audience:** Claude instances (and human developers) working on this Foundation component codebase.

**Purpose:** This document prescribes how project methods must be written, with particular emphasis on header documentation. It consolidates the rules found in `CLAUDE.md`, `CODING-PREFERENCES.md`, and `Project/Sources/Methods/CLAUDE.md` into a single, authoritative reference.

---

## 1. Parameter Style

Use **named parameters only**. Every project method must declare its parameters with `#DECLARE`. Numbered parameters (`$0`, `$1`, etc.) and old-style declarations (`C_TEXT`, `C_LONGINT`, etc.) are prohibited in new or refactored code. Never mix the two styles in a single method.

```4d
// CORRECT
#DECLARE($name_t : Text; $count_i : Integer)->$result_o : Object

// WRONG — numbered parameters
C_TEXT($1)
C_OBJECT($0)
```

---

## 2. Variable Declarations and Suffixes

All local variables must be declared with `var` and must carry a type-indicator suffix. The suffix makes the type visible at every point of use, not only at the declaration.

| Suffix | Type | Example |
|--------|------|---------|
| `_t` | Text | `$name_t` |
| `_i` | Integer | `$count_i` |
| `_r` | Real | `$price_r` |
| `_b` | Boolean | `$isValid_b` |
| `_d` | Date | `$today_d` |
| `_h` | Time | `$now_h` |
| `_o` | Object | `$data_o` |
| `_c` | Collection | `$items_c` |
| `_pic` | Picture | `$myPicture_pic` |
| `_ptr` | Pointer | `$thePointer_ptr` |
| `_x` | Blob | `$myBlob_x` |
| `_e` | Entity (typed) | `$customer_e` |
| `_es` | Entity Selection | `$selection_es` |
| `_file` | 4D.File | `$config_file` |
| `_folder` | 4D.Folder | `$resources_folder` |
| `_sig` | 4D.Signal | `$done_sig` |
| `_func` | 4D.Function | `$callback_func` |
| `_v` | Variant | `$theData_v` |

When the suffix would produce a tautological name (e.g. `$pic_pic`), prefix the variable with a pronoun or article: `$myPicture_pic`, `$thePointer_ptr`.

---

## 3. Method Header — Required Format

Every project method must begin with a boxed comment header. The header is the primary documentation for the method and must be kept accurate whenever the method is changed.

### 3.1 Header Template

```4d
//%attributes = {"invisible":true,"shared":true}
  // ----------------------------------------------------
  // Project Method: ModuleName_methodName ($param1_t : Text {; $param2_i : Integer}) --> $result_t : Text

  // Brief description of what this method does. One to three sentences
  // is typical. Explain the *purpose*, not the implementation.

  // Access: Shared

  // Parameters:
  //   $param1_t  : Text    : Description of parameter
  //   $param2_i  : Integer : Description of parameter (optional)

  // Returns:
  //   $result_t : Text : Description of return value

  // Created by Author Name, YYYY-MM-DD
  // ----------------------------------------------------

#DECLARE($param1_t : Text; $param2_i : Integer)->$result_t : Text
```

### 3.2 Header Elements Explained

Each element is described below in the order it must appear.

**Attributes line** — the `//%attributes = {...}` line is managed by 4D and records method properties such as visibility and sharing. It is always the very first line. Do not alter it manually unless you understand the consequences.

**Opening separator** — a line of dashes: `// ----------------------------------------------------`. This marks the visual top of the header block.

**Method signature line** — begins with `// Project Method:` followed by the method name and a parenthesised summary of parameters and return type. Optional parameters are enclosed in curly braces. The return arrow is `-->` (not `->`, which is reserved for the `#DECLARE` line).

```
// Project Method: Fnd_Date_DateToString ($date_d : Date {; $relativeTo_d : Date {; $format_t : Text}}) --> $result_t : Text
```

**Description** — one to three comment lines explaining *what* the method does and *why* a caller would use it. Focus on behaviour, not implementation detail.

**Access line** — `// Access: Shared` (or `Private`, etc.) indicates the method's visibility. This mirrors the attributes line in a human-readable form.

**Parameters block** — a `// Parameters:` heading followed by one indented comment line per parameter. Each line contains the parameter name, its type, and a prose description. Mark optional parameters with `(optional)`.

```
  // Parameters:
  //   $date_d       : Date : The date to convert to a string
  //   $relativeTo_d : Date : The relative date (optional)
  //   $format_t     : Text : The date format, e.g. "M/D/Y" (optional)
```

**Returns block** — a `// Returns:` heading with the return variable, type, and description. If the method returns nothing, write `// Returns: Nothing`.

**Created-by line** — For methods in this project use the following two-line form:

```
// Created by Wayne Stewart, YYYY-MM-DD
// Based on work by himself, Rob Laveaux, and Cannon Smith.
```

The second line acknowledges the three contributors whose prior work (Fnd_Dict, OBJ_Module, and the Constants/FCS utilities) informs this codebase. Include it on every new OTr method. If the original author was someone else, use their name on the first line and adjust the second line accordingly.

**Modification notes** — placed between the Created-by line and the closing separator. Each note follows the format `// <Name>, YYYY-MM-DD - <short description>`. Long descriptions may be wrapped and indented. See Section 5 for full rules.

**Closing separator** — a matching line of dashes, identical to the opening separator.

### 3.3 Methods with No Parameters

For methods that take no parameters, the signature line uses empty parentheses and the Parameters block is omitted:

```4d
  // ----------------------------------------------------
  // Project Method: Fnd_Date_Init ()

  // Initialises the date module's interprocess variables.

  // Access: Shared

  // Returns: Nothing

  // Created by Dave Batton, 2004-04-28
  // ----------------------------------------------------

#DECLARE()
```

### 3.4 Methods with No Return Value

Omit the `-->` from the signature line and write `// Returns: Nothing`:

```4d
  // Project Method: Fnd_Log_Enable ($enable_b : Boolean)
  ...
  // Returns: Nothing
```

---

## 4. Code Layout After the Header

Immediately after the closing separator, write the `#DECLARE` line. Then declare local variables, followed by the method body. Separate logical sections with `//MARK:` comments.

```4d
  // ----------------------------------------------------
  // ... header ...
  // ----------------------------------------------------

#DECLARE($input_t : Text; $silent_b : Boolean)->$result_o : Object

var $temp_t : Text
var $count_i : Integer

//MARK:- initialisation
If (Count parameters < 2)
    $silent_b := False

End if

//MARK:- processing
// ... method body ...
```

### 4.1 Style Rules Within the Body

These rules apply to all code after the header:

- Keep lines at or below 80 characters when practical; prefer wrapping near 60 characters using `\` for continuation.
- Do not split logical pairs (e.g. a parameter name and its value) across continuation lines.
- Use generous whitespace: blank lines within and between control-structure blocks.
- In `If`/`Else` blocks, put the shortest block first for readability.
- Prefer ORDA over classic commands for all data access.
- Prefer collection methods (`.map()`, `.filter()`, `.query()`, `.orderBy()`) over manual loops.

---

## 5. Modification Notes

Document meaningful changes in the header at least once per day or once per feature. The note goes between the Created-by line and the closing separator.

### Format

```
// <Developer Name>, YYYY-MM-DD - <short description>
```

### Rules

- The date should reflect when the bulk of the work occurred (it may be a prior day).
- Use concise, descriptive language. State *what* changed, not *how*.
- When a description wraps, indent the continuation slightly (assume a fixed-width font).
- Do not rewrite the entire header during a refactor; preserve existing notes.

### Example

```4d
  // Created by Dave Batton, 2004-05-12
  // Gary Boudreaux, 2008-12-21 - Removed extraneous return parameter description
  //       in header. Corrected method name in first line of header.
  // Wayne Stewart, 2026-03-29 - Swapped method to #DECLARE and added optional
  //       silent flag.
  // Wayne Stewart, 2026-03-30 - Improved markdown output formatting
  //       (paragraph spacing, parameter/return tables, and no-parameter display).
  // ----------------------------------------------------
```

---

## 6. Naming Conventions

### Module Pattern (Foundation methods)

```
Fnd_[Module]_[verbOrSubject]
```

Examples: `Fnd_Date_DateToString`, `Fnd_Data_ParseName`, `Fnd_Log_Enable`.

### General Pattern

```
[PascalCaseSubject]_[action]
```

Examples: `Customer_save`, `InventoryExceptions_report`.

### Test Methods

```
Test_[ClassNameOrSubject]
```

Examples: `Test_Coords`, `Test_FormBuilder`.

---

## 7. Optional Parameters

In the header signature, wrap optional parameters in curly braces. In the `#DECLARE`, list all parameters (4D does not use curly braces in `#DECLARE`). Handle optionality via `Count parameters`:

```4d
  // Project Method: Fnd_Example ($name_t : Text {; $options_o : Object}) --> $result_o : Object

#DECLARE($name_t : Text; $options_o : Object)->$result_o : Object

If (Count parameters < 2) | ($options_o = Null)
    $options_o := {}

End if
```

---

## 8. OTr Project Conventions

### 8.1 Semaphore Pattern

The registry lock uses a **process-local semaphore** (name prefixed with `$`) so it does not block unrelated processes. The semaphore name is stored in the interprocess variable `<>OTR_Semaphore_t`, which is initialised in `OTr_zInit` to `"$OTr_Registry"`.

```4d
// Lock — OTr_zLock
While (Semaphore(<>OTR_Semaphore_t; 10))
    IDLE
End while

// Unlock — OTr_zUnlock
CLEAR SEMAPHORE(<>OTR_Semaphore_t)
```

Do **not** use a plain local variable (`$semaphore_t`) for the semaphore name; always read it from `<>OTR_Semaphore_t` so the value is consistent across all methods. See https://doc.4d.com/4Dv19/4D/19.8/Semaphore.301-7112726.en.html for the `$`-prefix local semaphore convention.

### 8.2 Constants Utility Methods

A set of helper methods (`Constants_NewFile`, `Constants_NewGroup`, `Constants_AddLong`, `Constants_AddReal`, `Constants_AddString`, `Constants_SaveFile`) is available to generate 4D `.xlf` constant files from code. These were written by Cannon Smith (Synergy Farm Solutions). If a module needs named constants, create a `<Module>_Constants` caller method and drive it through those helpers. See `Constants__Readme.4dm` for usage examples.

### 8.3 Documentation Utility Methods

Two routines generate markdown documentation from method headers:
- `Fnd_FCS_WriteDocumentation` — parses Foundation-style headers and writes `.md` files to the `Documentation/Methods/` folder.
- `Fnd_FCS_ParseParameterLine` — helper used by the above.

Run `__WriteDocumentation` to regenerate docs for all OTr methods after adding or changing headers. The output folder `Documentation/Methods/` is tracked in Git.

---

## 9. Compatibility Note (4D v20 LTS)

For 4D 20 LTS compatibility, keep `Compiler_xxx` method declarations for `#DECLARE` methods; do not remove or comment out those entries, even when modernising.

For 4D v19 compatibility in shared project methods:

- Do not use typed array local declarations such as `var $items_ai : Array Integer`.
- Use classic array initialisation commands instead (for example: `ARRAY LONGINT($items_ai; 0)`).
- Do not use `return` statements in project methods; structure control flow with `If`, `Case of`, and final result assignment.

---

## 10. Quick Checklist

Before committing a new or refactored method, verify:

- [ ] Header present with opening and closing `// ----` separators
- [ ] Signature line matches actual `#DECLARE` parameters and return type
- [ ] All parameters documented in the Parameters block
- [ ] Return value documented (or `Returns: Nothing`)
- [ ] Created-by line present with date in YYYY-MM-DD format
- [ ] Modification note added if this is a change to an existing method
- [ ] All local variables declared with `var` and type suffixes
- [ ] Array locals use classic `ARRAY ...` initialisation (no `var ... : Array ...`)
- [ ] No `return` statements used in project methods (4D v19-safe flow)
- [ ] Semaphore name read from `<>OTR_Semaphore_t`, not a local variable
- [ ] Created-by block uses two-line format with contributor acknowledgement
- [ ] `#DECLARE` used (no numbered parameters)
- [ ] Lines kept within 80 characters where practical
