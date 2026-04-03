# OTr — Phase 15: Side-by-Side Compatibility Testing

**Version:** 0.1
**Date:** 2026-04-04
**Author:** Wayne Stewart / Claude

---

## 1. Purpose

This document defines the procedure for validating OTr against the ObjectTools 5.0 plugin by running both APIs against identical test data within the same 4D session. It also catalogues all known API differences between the two implementations, which serve as the reference for determining expected test outcomes.

This testing phase is distinct from the unit tests defined in `OTr-Phase-003-Spec.md` through `OTr-Phase-006-Spec.md`. Those tests verify OTr in isolation; this phase verifies behavioural equivalence with the legacy plugin.

---

## 2. Platform Requirement

ObjectTools 5.0 is a compiled plugin that is **not compatible with macOS Tahoe (26.4) or later**. All side-by-side testing must be conducted on one of the following:

- **Windows** (any supported version)
- **macOS** running a release prior to macOS Tahoe 26.4

> This constraint must be confirmed before beginning. Attempting to load the plugin on an incompatible OS will produce a load error and prevent the test database from opening.

---

## 3. Setup

- Install the ObjectTools 5.0 plugin into the project's `PlugIns` folder and verify it loads without error (check the 4D log and confirm `OT Register` returns a non-zero handle in a quick test).
- Register the test method `____Test_OT_Compatibility` in the `Test Methods` group in `Project/Sources/folders.json`.
- Both OTr and OT must be exercised within the **same method call** so that test data is identical — do not compare across separate runs.

---

## 4. Incompatibilities with ObjectTools 5.0

This section catalogues all known API differences between OTr and ObjectTools 5.0. It is the authoritative reference for determining which test outcomes are intentional differences rather than failures.

### 4.1 Methods That Cannot Be Implemented

These methods exist in ObjectTools 5.0 but have no equivalent in OTr. The fundamental constraint is that a native 4D component method cannot write back to the caller's BLOB or Picture variable passed as an output parameter, as a plugin can.

| OT Method | OTr Equivalent | Reason |
|---|---|---|
| `OT GetBLOB(inObject; inTag; outBLOB)` | *(none)* | `outBLOB` is a BLOB output parameter; a component cannot materialise data into the caller's variable |
| `OT GetArrayBLOB(inObject; inTag; inIndex; outValue)` | *(none)* | Same BLOB output-parameter constraint |
| `OT GetArrayPicture(inObject; inTag; inIndex; outValue)` | *(none)* | Same Picture output-parameter constraint |

Recommended migration path: replace calls to these methods with `OTr_GetNewBLOB` and `OTr_GetPicture`, which return their values as function results.

### 4.2 Methods Implemented with a Changed API

These methods are implemented in OTr, but their calling signature differs from the ObjectTools 5.0 counterpart. Callers must be updated.

| OT Method | OTr Method | Change | Notes |
|---|---|---|---|
| `OT ObjectToBLOB(inObject; ioBLOB)` | `OTr_ObjectToBLOB` | `ioBLOB` cannot be an in/out BLOB parameter in a component; the OTr method uses a function result instead | See `OTr-Phase-006-Spec.md` for the revised signature |
| `OT BLOBToObject(inBLOB; ioOffset)` | `OTr_BLOBToObject` | `ioOffset` in/out semantics may require a pointer workaround; to be finalised in Phase 6 | Provisional |
| `OT GetBLOB(inObject; inTag; outBLOB)` | `OTr_GetNewBLOB(inObject; inTag)` | Returns BLOB as function result rather than writing to an output parameter | Replaces `OT GetBLOB` entirely; see §4.1 |

### 4.3 Methods Implemented with Different Behaviour

These methods share the same or similar API, but their runtime behaviour or output differs from the ObjectTools 5.0 equivalent. Callers should review each case.

| OTr Method | OT Counterpart | Difference |
|---|---|---|
| `OTr_PutRecord` / `OTr_GetRecord` | `OT PutRecord` / `OT GetRecord` | OTr stores a **snapshot** of the record fields at the time `OTr_PutRecord` is called, serialised as a sub-object (`{ "__tableNum": N, "FieldName": value, ... }`). Pictures and BLOBs are stored as inline Base64 strings. `OTr_GetRecord` restores the snapshot into the current record without any database I/O; modifications to the record after `OTr_PutRecord` do not affect the stored snapshot. The legacy plugin stored a live reference to the record. |
| `OTr_ObjectToBLOB` / `OTr_ObjectToNewBLOB` / `OTr_BLOBToObject` | `OT ObjectToBLOB` / `OT ObjectToNewBLOB` / `OT BLOBToObject` | OTr uses its own binary serialisation format (`OTR1` magic bytes). Legacy OT BLOBs are **not** compatible; `OTr_BLOBToObject` will return an error and set `OK` to zero when presented with a legacy BLOB. Re-serialisation via `OTr_SaveToText` → `OTr_LoadFromText` is the recommended migration path. |
| `OTr_ObjectSize` | `OT ObjectSize` | OTr calculates size as the byte length of the JSON serialisation (`JSON Stringify`) of the object, which is an approximation. The legacy plugin reported the in-memory size of its internal structure. The two values will not match numerically. `OTr_ObjectSize` should be used for comparison and rough estimation only, not for precise memory accounting. |
| `OTr_SaveToText` / `OTr_SaveToFile` / `OTr_SaveToClipboard` | `OT SaveToText` / `OT SaveToFile` / `OT SaveToClipboard` | When the object contains BLOBs or Pictures, OTr expands `blob:N` / `pic:N` references to inline Base64 strings before serialising (`OTr_uExpandBinaries`). The resulting text representation is larger and differs structurally from the legacy format. Round-tripping within each system is safe; loading legacy OT text exports is not supported. |
| `OTr_GetBoolean` | `OT GetBoolean` | Returns an Integer (`0` or `1`) rather than a native 4D Boolean. This matches the legacy plugin's behaviour but may surprise callers expecting a Boolean expression. |
| `OTr_PutObject` / `OTr_GetObject` | `OT PutObject` / `OT GetObject` | OTr always **deep-copies** the object at storage and retrieval time. The legacy plugin used reference semantics for sub-objects in some configurations. Callers that relied on shared-reference mutation will need to use explicit `OTr_PutObject` calls to commit changes. |

---

## 5. Test Method: `____Test_OT_Compatibility`

For each category below, store the same value via OT and OTr, retrieve it via both, and assert that the OTr-retrieved value matches the OT-retrieved value. Rows marked *intentional* in the Notes column correspond to entries in §4 and should not be treated as failures.

| Category | OT Command | OTr Method | Notes |
|---|---|---|---|
| Creation / destruction | `OT New` / `OT Clear` | `OTr_New` / `OTr_Clear` | Confirm handle allocation; OT and OTr handles are independent integers |
| String / Text | `OT PutString` / `OT GetString` | `OTr_PutString` / `OTr_GetString` | |
| Longint | `OT PutLong` / `OT GetLong` | `OTr_PutLong` / `OTr_GetLong` | |
| Real | `OT PutReal` / `OT GetReal` | `OTr_PutReal` / `OTr_GetReal` | |
| Boolean | `OT PutBoolean` / `OT GetBoolean` | `OTr_PutBoolean` / `OTr_GetBoolean` | OTr returns Integer (0/1); compare as Integer |
| Date | `OT PutDate` / `OT GetDate` | `OTr_PutDate` / `OTr_GetDate` | |
| Time | `OT PutTime` / `OT GetTime` | `OTr_PutTime` / `OTr_GetTime` | |
| Pointer | `OT PutPointer` / `OT GetPointer` | `OTr_PutPointer` / `OTr_GetPointer` | Dereference both and compare the pointed-to value |
| Picture | `OT PutPicture` / `OT GetPicture` | `OTr_PutPicture` / `OTr_GetPicture` | Compare byte-for-byte or via checksum |
| BLOB | `OT PutBLOB` / `OT GetNewBLOB` | `OTr_PutBLOB` / `OTr_GetNewBLOB` | |
| Variable | `OT PutVariable` / `OT GetVariable` | `OTr_PutVariable` / `OTr_GetVariable` | |
| Record | `OT PutRecord` / `OT GetRecord` | `OTr_PutRecord` / `OTr_GetRecord` | Intentional difference (§4.3) — retrieve immediately without modification; compare field values individually |
| Dot-path | `OT PutString` with dotted tag | `OTr_PutString` with dotted tag | Multi-level path; retrieve each level |
| Array Longint | `OT PutArrayLong` / `OT GetArrayLong` | `OTr_PutArrayLong` / `OTr_GetArrayLong` | Compare element-by-element; confirm 1-based index parity |
| Array Text | `OT PutArrayString` / `OT GetArrayString` | `OTr_PutArrayString` / `OTr_GetArrayString` | |
| Array Real | `OT PutArrayReal` / `OT GetArrayReal` | `OTr_PutArrayReal` / `OTr_GetArrayReal` | |
| Array Boolean | `OT PutArrayBoolean` / `OT GetArrayBoolean` | `OTr_PutArrayBoolean` / `OTr_GetArrayBoolean` | |
| Array Pointer | `OT PutArrayPointer` / `OT GetArrayPointer` | `OTr_PutArrayPointer` / `OTr_GetArrayPointer` | Dereference each element |
| Array Picture | `OT PutArrayPicture` / `OT GetArrayPicture` | `OTr_PutArrayPicture` / `OTr_GetArrayPicture` | |
| Item info | `OT ItemExists` / `OT ItemType` | `OTr_ItemExists` / `OTr_ItemType` | Confirm type constants match OT legacy values |
| Item count | `OT ItemCount` | `OTr_ItemCount` | |
| Property enumeration | `OT GetAllProperties` | `OTr_GetAllProperties` | Compare name arrays; order may differ |
| Delete / rename | `OT DeleteItem` / `OT RenameItem` | `OTr_DeleteItem` / `OTr_RenameItem` | Confirm item absent / renamed in both |
| Copy | `OT CopyItem` | `OTr_CopyItem` | Retrieve copied value from destination tag |
| Size of array | `OT SizeOfArray` | `OTr_SizeOfArray` | |
| Sort arrays | `OT SortArrays` | `OTr_SortArrays` | Compare sorted order |
| Object size | `OT ObjectSize` | `OTr_ObjectSize` | Intentional difference (§4.3) — both must be non-zero; values will not match |
| BLOB serialisation | `OT ObjectToBLOB` / `OT BLOBToObject` | `OTr_ObjectToBLOB` / `OTr_BLOBToObject` | Intentional difference (§4.3) — round-trip within each system independently; do not cross-load |
| Text export / import | `OT SaveToText` / `OT LoadFromText` | `OTr_SaveToText` / `OTr_LoadFromText` | Intentional difference (§4.3) — round-trip within each system; compare retrieved values post-load |
| Version | `OT GetVersion` | `OTr_GetVersion` | Values will differ; confirm both return non-empty, non-zero results |
| Options | `OT GetOptions` / `OT SetOptions` | `OTr_GetOptions` / `OTr_SetOptions` | Confirm `FailOnItemNotFound` and `AutoCreateObjects` behave identically |

---

## 6. Output Format and Reporting

### 6.1 Tabular Results

The test method must accumulate results into a Text array and present them as a pipe-delimited table, one row per test category, with a header row:

```
| Test Name | OT Test | OT Result | OTr Test | OTr Result |
| Creation / destruction | OT New / OT Clear | Pass | OTr_New / OTr_Clear | Pass |
| String / Text | OT PutString / OT GetString | Pass | OTr_PutString / OTr_GetString | Pass |
...
```

Each result cell must contain either `Pass` or `Fail: <brief reason>`. For rows marked as intentional differences (§4.3), the result cells should reflect the individual system's round-trip outcome, not a cross-system comparison.

A summary line must follow the table:

```
Total: 28  Pass: 27  Fail: 1
```

### 6.2 File Output

Upon completion, the method must write the full results table (header row, all data rows, and summary line) to a plain text file on the desktop. The filename must be a timestamp in the format `YYYY-MM-DD-HH-MM-SS.txt`, derived from the system time at the moment the method completes. Use `Current date` and `Current time` to construct the filename, and `Get 4D folder` with the Desktop folder constant to obtain the desktop path.

Example filename: `2026-04-04-14-32-07.txt`

### 6.3 Pass Criteria

- Every row not marked *intentional* must show `Pass` in both the OT Result and OTr Result columns.
- `OK` must equal `1` after every successful OTr call.
- No unhandled 4D errors during the test run.
- The results file must be present on the desktop on completion.
