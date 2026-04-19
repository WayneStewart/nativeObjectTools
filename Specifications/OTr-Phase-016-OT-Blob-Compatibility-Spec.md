# OTr Phase 16 — Legacy OT BLOB Compatibility Test Matrix

**Version:** 0.1
**Date:** 2026-04-14
**Status:** Draft
**Author:** Wayne Stewart / Codex
**Parent Document:** [OTr-Specification.md](../../OTr-Specification.md)
**Related Phase:** [OTr-Phase-015-Spec.md](OTr-Phase-015-Spec.md)

---

## 1. Purpose

Phase 16 defines the follow-up test coverage required for importing legacy ObjectTools BLOBs through `OTr_BLOBToObject`.

The immediate compatibility goal is:

1. Read an OT object BLOB.
2. Convert supported OT item payloads into the native OTr object storage shape.
3. Preserve value, type identity, array metadata, and nested structure.
4. Preserve the legacy `ioOffset` contract as far as the 4D method API permits.
5. Return a clear failure (`OK=0`, handle `0`) for unsupported OT payload markers instead of partially importing corrupt data.

This phase does not require OTr-generated BLOBs to be readable by the legacy OT plugin.

---

## 2. Current Baseline

The initial OT BLOB importer is based on the supplied sample blobs:

- `Examples/Blobs/____DummyBLOB/OT 2026-04-14T10-28-20.blob`
- `Examples/Blobs/Guy/OT BLOB.txt`

Those samples prove the following legacy payloads:

| OT payload | Example | Expected OTr storage |
|---|---|---|
| Character/Text scalar | `Name`, `customer` | Text value plus `leaf$type = OT Is Character` |
| Date scalar | `birthday` | `YYYY-MM-DD` text plus `leaf$type = Is date` |
| Character array | `Children`, `songs` | OTr array object with `arrayType`, `numElements`, `currentItem`, and element keys |

All other legacy OT payload markers must be treated as unproven until covered by tests.

---

## 3. Legacy Compatibility Contract

The legacy ObjectTools documentation defines several behaviours that Phase 16 should preserve as closely as possible.

### 3.1 Accepted Source Format

`OTr_BLOBToObject` should only import legacy object payloads written by:

- `OT ObjectToBLOB`
- `OT ObjectToNewBLOB`

It must not treat arbitrary `VARIABLE TO BLOB` payloads as legacy OT objects. Existing OTr-native BLOB import remains supported through the current compressed `VARIABLE TO BLOB` path.

### 3.2 Offset Behaviour

Legacy `OT BLOBToObject` accepts an optional `ioOffset`. If omitted, the offset defaults to zero.

Desired OTr behaviour:

- Calling `OTr_BLOBToObject($blob)` reads from byte `0`.
- If an offset-compatible OTr API is added, it must read from the supplied offset.
- On successful import, the offset-compatible API should advance the offset to the byte immediately after the imported object.
- On failure, the offset-compatible API must leave the supplied offset untouched.

4D project methods cannot exactly emulate every plugin-style in/out parameter call pattern. If exact `ioOffset` compatibility cannot be implemented through the existing public method signature, the limitation must be documented and an OTr-compatible alternative must be tested.

### 3.3 Appended Object Behaviour

The legacy `OT ObjectToBLOB` append mode can create a larger BLOB containing more than one serialized OT object, or valid serialized object bytes followed by unrelated bytes.

Therefore:

- Extra bytes after a valid object are not automatically an error.
- Sequential import from appended OT object BLOBs should be tested if offset support is implemented.
- Without offset support, OTr may reasonably import only the first object at byte `0`, but this limitation must be documented.

### 3.4 Failure Semantics

If the bytes at the read offset do not describe an OT object, or the payload type is unsupported:

- Return handle `0`.
- Set `OK=0`.
- Leave any supplied offset unchanged.
- Do not register a partial OTr handle.
- Do not mutate existing valid handles.

### 3.5 4D Version Condition

The legacy warning about BLOB and Time arrays requiring 4D v14 or later does not block this component, because OTr runs on 4D v19 or later. Phase 16 must still test BLOB and Time arrays, but the expected result is normal import support, not a version-gated error.

### 3.6 Earlier ObjectTools Versions

Legacy ObjectTools claims transparent conversion of BLOBs created with earlier ObjectTools versions. If sample BLOBs from earlier OT versions are available, Phase 16 should include them as fixture inputs. If no fixtures are available, this remains a documented coverage gap.

---

## 4. Test Strategy

Each test should generate a legacy OT object using the real ObjectTools plugin, export it with `OT ObjectToNewBLOB`, import it with `OTr_BLOBToObject`, and verify the result using the public OTr getters.

For each payload type:

- Confirm the returned handle is non-zero.
- Confirm `OK` remains successful on valid imports.
- Confirm `OTr_ItemType` returns the expected legacy-compatible type constant.
- Confirm getter output matches the original OT value.
- Confirm `OTr_ObjectToNewBLOB` can serialise the imported object as a normal OTr object.
- Confirm the reloaded OTr BLOB still returns the same values.

For unsupported payloads:

- Confirm the returned handle is `0`.
- Confirm `OK=0`.
- Confirm the offset is unchanged, where an offset-compatible API is being tested.
- Confirm no partial handle is left registered.

---

## 5. Scalar Payload Coverage

### 5.1 Character / Text

Test cases:

- Empty string.
- Short ASCII string.
- Text longer than 255 characters.
- Text containing spaces and punctuation.
- Text containing non-ASCII characters.
- Text containing line breaks.

Assertions:

- `OTr_GetText` returns the exact text.
- `OTr_GetString` returns compatible text where expected.
- `OTr_ItemType` returns `OT Is Character`.

### 5.2 Long / Integer

Test cases:

- `0`
- Positive integer.
- Negative integer.
- Large positive value.
- Large negative value.

Assertions:

- `OTr_GetLong` returns the exact value.
- `OTr_ItemType` returns `Is longint`.

### 5.3 Real

Test cases:

- `0`
- Positive decimal.
- Negative decimal.
- Integer-looking real.
- Value with several decimal places.

Assertions:

- `OTr_GetReal` returns the same numeric value within 4D real precision.
- `OTr_ItemType` returns `Is real`.

### 5.4 Boolean

Test cases:

- `True`
- `False`

Assertions:

- `OTr_GetBoolean` returns `1` for `True`.
- `OTr_GetBoolean` returns `0` for `False`.
- `OTr_ItemType` returns `Is boolean`.

### 5.5 Date

Test cases:

- Normal date.
- Old date.
- Future date.
- Null date if OT permits it.

Assertions:

- `OTr_GetDate` returns the same date.
- `OTr_ItemType` returns `Is date`.

### 5.6 Time

Test cases:

- Midnight.
- Normal time.
- Late-day time.
- Long-duration time if OT permits it.

Assertions:

- `OTr_GetTime` returns the same time.
- `OTr_ItemType` returns `Is time`.

---

## 6. Binary and Media Payload Coverage

### 6.1 BLOB

Test cases:

- Empty BLOB.
- Small text BLOB.
- Binary BLOB containing zero bytes.
- Larger BLOB.

Assertions:

- `OTr_GetNewBLOB` returns byte-identical data.
- `OTr_GetBLOB` pointer form returns byte-identical data.
- `OTr_ItemType` returns `Is BLOB`.

### 6.2 Picture

Test cases:

- PNG picture.
- JPEG picture.
- Empty/null picture if OT permits it.
- Picture with transparency if available.

Assertions:

- `OTr_GetPicture` returns an equivalent picture.
- `OTr_CompareItems` reports equivalent imported and expected picture items where practical.
- `OTr_ItemType` returns `Is picture`.

---

## 7. Pointer, Record, and Variable Payload Coverage

### 7.1 Pointer

Test cases:

- Process variable pointer.
- Interprocess variable pointer.
- Local variable pointer.

Assertions:

- Process/interprocess pointer names round-trip where OTr supports them.
- Local pointer behaviour is documented explicitly. If import cannot safely preserve it, it must fail cleanly or import as an explicitly unsupported representation.

### 7.2 Record

Test cases:

- Record with simple scalar fields.
- Record containing date/time fields.
- Record containing picture and BLOB fields.
- Record whose source record is later modified.
- Deleted or unavailable source record, if the OT blob can be generated.

Assertions:

- Imported record payload matches OTr record snapshot semantics.
- `OTr_GetRecord` restores expected field values where supported.
- `OTr_GetRecordTable` returns the expected table number/name behaviour.

### 7.3 Variable

Test cases:

- Scalar variable payloads.
- Array variable payloads.
- Unsupported variable payloads.

Assertions:

- `OTr_GetVariable` writes expected values into typed destination variables.
- Type mismatch behaviour is explicit and consistent with existing OTr rules.

---

## 8. Array Payload Coverage

For every array type, test:

- Empty array.
- One-element array.
- Multi-element array.
- Default element `{0}`.
- Current element.
- First element.
- Last element.
- Out-of-range access after import.

Array types:

| OT array payload | OTr verification |
|---|---|
| Character array | `OTr_GetArray`, `OTr_GetArrayText`, `OTr_GetArrayString` |
| Long/Integer array | `OTr_GetArray`, `OTr_GetArrayLong` |
| Real array | `OTr_GetArray`, `OTr_GetArrayReal` |
| Boolean array | `OTr_GetArray`, `OTr_GetArrayBoolean` |
| Date array | `OTr_GetArray`, `OTr_GetArrayDate` |
| Time array | `OTr_GetArray`, `OTr_GetArrayTime` |
| BLOB array | `OTr_GetArrayBLOB` |
| Picture array | `OTr_GetArrayPicture` |
| Pointer array | `OTr_GetArrayPointer` |

Assertions:

- `OTr_ArrayType` returns the expected native 4D array type constant.
- `OTr_SizeOfArray` returns the original element count.
- `OTr_GetArray` restores element count, element values, default element, and current element.
- Element getters return the same values as the restored array.

---

## 9. Embedded Object Coverage

Test cases:

- Object containing only scalars.
- Object containing arrays.
- Object containing another embedded object.
- Nested dotted paths such as `parent.child.grandchild.value`.
- Mixed sibling items before and after embedded objects.

Assertions:

- `OTr_IsEmbedded` reports embedded objects correctly.
- `OTr_GetObject` returns a valid OTr handle.
- Nested getters return the same values.
- Item counts and named property lists match expected content, excluding shadow keys unless explicitly requested.

---

## 10. Tag Name Coverage

Test cases:

- Short tag names.
- Long tag names.
- Mixed-case names.
- Names containing spaces.
- Names containing punctuation.
- Names containing non-ASCII characters.
- Dotted paths.
- Names ending in `$type`.

Assertions:

- Imported keys are not truncated.
- Case is preserved.
- Shadow-key collisions are prevented or fail cleanly.
- Dotted paths produce the same accessible structure as equivalent OTr-created objects.

---

## 11. Ordering and Offset Coverage

The OT binary format is offset-sensitive. Tests must include item ordering variants:

- One-item object.
- Many-item object.
- Text before array.
- Array before text.
- Date before array.
- Array before date.
- Multiple arrays in a row.
- Mixed scalar, binary, array, and embedded object payloads.
- Valid OT object at offset `0` followed by trailing bytes.
- Valid OT object at a non-zero offset.
- Multiple valid OT objects appended into one BLOB.

Assertions:

- Every item after an array remains readable.
- Every item after text/date/binary payloads remains readable.
- No parser branch consumes bytes belonging to the next item.
- Import from offset `0` works when no offset is supplied.
- Import from non-zero offset works if an offset-compatible API is implemented.
- Successful offset-based import advances the offset to the next unread byte.

---

## 12. Failure Coverage

Test cases:

- Empty BLOB.
- Random non-OT BLOB.
- Truncated OT header.
- Truncated key name.
- Truncated scalar payload.
- Truncated array descriptor.
- Truncated array element payload.
- Valid OT header with unsupported item marker.
- Invalid bytes at offset `0`.
- Invalid bytes at a non-zero offset, if an offset-compatible API is implemented.
- Valid first object followed by corrupt trailing bytes.

Assertions:

- Invalid input returns handle `0`.
- `OK=0` is set.
- Any supplied offset is left untouched on failure.
- Error text identifies unsupported or invalid legacy OT data.
- No partial handle is registered.
- Existing valid handles remain unaffected.
- A valid first object followed by corrupt trailing bytes imports successfully when reading only the first object.

---

## 13. Minimum Next Test Method

Create a focused generator/import test, for example `____Test_Phase_16_OTBlob`, that builds one OT object containing:

- `text`
- `long`
- `real`
- `boolean`
- `date`
- `time`
- `blob`
- `picture`
- `textArray`
- `longArray`
- `realArray`
- `booleanArray`
- `dateArray`
- `timeArray`
- `embeddedObject.text`
- `embeddedObject.textArray`

Recommended flow:

```4d
$otHandle_i:=OT New
// Populate all payloads using OT Put... methods.
$legacyBlob_blob:=OT ObjectToNewBLOB($otHandle_i)
OT Clear($otHandle_i)

$otrHandle_i:=OTr_BLOBToObject($legacyBlob_blob)
// Assert handle, OK, item types, getters, arrays, and nested values.

$otrBlob_blob:=OTr_ObjectToNewBLOB($otrHandle_i)
$roundTripHandle_i:=OTr_BLOBToObject($otrBlob_blob)
// Assert the imported object is now a normal OTr object.
```

This single method should expose the next set of unsupported OT markers and payload layouts to implement.

Create a second focused method for the legacy offset contract, for example `____Test_Phase_16_OTBlobOffset`, once an offset-compatible API exists.

Recommended offset cases:

```4d
// Default offset behaviour
$h1_i:=OTr_BLOBToObject($legacyBlob_blob)

// Desired offset-compatible behaviour, exact API TBD
$offset_i:=0
$h2_i:=OTr_BLOBToObject($appendedBlob_blob; ->$offset_i)
// Assert $offset_i advanced after success.

$badOffset_i:=$offset_i
$hBad_i:=OTr_BLOBToObject($appendedBlob_blob; ->$badOffset_i)
// Assert failure leaves $badOffset_i unchanged.
```

---

## 14. Acceptance Criteria

Phase 16 is complete when:

- All supported OT scalar payloads import correctly.
- All supported OT array payloads import correctly, including metadata.
- Embedded objects import correctly.
- Binary/media payloads either import byte-equivalently or fail cleanly with documented limitations.
- Pointer, record, and variable payloads have explicit tested behaviour.
- Unsupported payload markers fail cleanly.
- Offset compatibility is implemented or explicitly documented as a deliberate OTr API difference.
- Failure leaves the caller-visible offset unchanged where offset compatibility is implemented.
- Appended-object BLOB behaviour is tested.
- Earlier ObjectTools-version BLOB fixtures are tested, or their absence is documented as a coverage gap.
- At least two real-world OT BLOB samples import without using the legacy plugin at read time.
- Imported OT BLOBs can be re-serialised with `OTr_ObjectToNewBLOB` and read back as normal OTr BLOBs.
