# Review Session S2 — API Coverage Audit: Findings

**Version:** 1.0
**Date:** 2026-04-11
**Reviewer:** Claude (Cowork session)
**Status:** Complete
**Dependencies:** None

---

## Executive Summary

The S2 audit cross-referenced 107 public `OTr_` API methods against all phase specifications (Phases 1–10, 15, 20) and the `Documentation/Methods/` directory. The overall coverage picture is healthy: every public API method has a corresponding source file and a corresponding documentation file. No public API method is missing its implementation. No stale documentation files reference methods that no longer exist.

However, four substantive issues were identified:

1. **`OTr_BLOBToObject` — offset parameter resolved.** The Phase 15 spec marked the `$ioOffset_i` parameter as provisional. The implementation has now definitively dropped that parameter. The Phase 15 spec must be updated to reflect the current single-parameter signature.

2. **`OTr_zLogGetCallStack` — source file absent.** This method is referenced in `OTr_zLogWrite.4dm` and `Compiler_ObjectToolsReplacement.4dm` as a callee, but no corresponding `.4dm` file exists in `Project/Sources/Methods/`. This is a missing implementation.

3. **`OTr_zTogglePluginBlocks` — orphaned in source, absent from `folders.json`.** The file exists in `Project/Sources/Methods/` but is not registered in `folders.json` and has no callers anywhere in the codebase.

4. **Four methods absent from `folders.json` "OT Private Methods" group**: `OTr_zLogGetCallStack` (cannot be registered — file missing), `OTr_zLogFileName`, `OTr_zXMLWriteObjectSAX`, and `OTr_z_Get4DVersion` are present in source but absent from `folders.json`.

Additionally, several minor findings are noted regarding type-suffix non-conformances in utility methods and the confirmed status of all utility method callers.

---

## Step 1 — Complete Method Inventory

### 1.1 Public API methods (`OTr_` — non-z, non-u) — 107 methods

All 107 are present in `Project/Sources/Methods/`. All 107 are registered in the `folders.json` "OT API Methods" group.

| Method | In Source | In Spec | In Docs/Methods/ | folders.json |
|---|:---:|:---:|:---:|:---:|
| OTr_ArrayType | ✅ | ✅ Phase 9 | ✅ | ✅ |
| OTr_BLOBToObject | ✅ | ✅ Phase 6/15 | ✅ | ✅ |
| OTr_Clear | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_ClearAll | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_CompareItems | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_CompiledApplication | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_Copy | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_CopyItem | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_DeleteElement | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_DeleteItem | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_FindInArray | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetActiveHandleCount | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_GetAllNamedProperties | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_GetAllProperties | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_GetArray | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayBLOB | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayBoolean | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayDate | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayLong | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayPicture | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayPointer | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayReal | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayString | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayText | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetArrayTime | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_GetBLOB | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_GetBoolean | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_GetDate | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_GetHandleList | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_GetItemProperties | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_GetLong | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_GetNamedProperties | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_GetNewBLOB | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_GetObject | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_GetOptions | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_GetPicture | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_GetPointer | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_GetReal | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_GetRecord | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_GetRecordTable | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_GetString | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_GetText | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_GetTime | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_GetVariable | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_GetVersion | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_IncludeShadowKey | ✅ | ✅ Phase 9 | ✅ | ✅ |
| OTr_Info | ✅ | ✅ Phase 9 | ✅ | ✅ |
| OTr_InsertElement | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_IsEmbedded | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_IsObject | ✅ | ✅ Phase 1/3 | ✅ | ✅ |
| OTr_ItemCount | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_ItemExists | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_ItemType | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_LoadFromBlob | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_LoadFromClipboard | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_LoadFromFile | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_LoadFromGZIP | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_LoadFromText | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_LoadFromXML | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_LoadFromXMLFile | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_LogLevel | ✅ | ✅ Phase 10 | ✅ | ✅ |
| OTr_New | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_ObjectSize | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_ObjectToBLOB | ✅ | ✅ Phase 6 | ✅ | ✅ |
| OTr_ObjectToNewBLOB | ✅ | ✅ Phase 6 | ✅ | ✅ |
| OTr_PutArray | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayBLOB | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayBoolean | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayDate | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayLong | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayPicture | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayPointer | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayReal | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayString | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayText | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutArrayTime | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_PutBLOB | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_PutBoolean | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_PutDate | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_PutLong | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_PutObject | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_PutPicture | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_PutPointer | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_PutReal | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_PutRecord | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_PutString | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_PutText | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_PutTime | ✅ | ✅ Phase 2 | ✅ | ✅ |
| OTr_PutVariable | ✅ | ✅ Phase 5 | ✅ | ✅ |
| OTr_Register | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_RenameItem | ✅ | ✅ Phase 3 | ✅ | ✅ |
| OTr_ResizeArray | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_SaveToBlob | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_SaveToClipboard | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_SaveToFile | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_SaveToGZIP | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_SaveToText | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_SaveToXML | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_SaveToXMLFile | ✅ | ✅ Phase 1.5 | ✅ | ✅ |
| OTr_SaveToXMLFileSAX | ✅ | ⚠️ Phase 1.5 (SAX variant) | ✅ | ✅ |
| OTr_SaveToXMLSAX | ✅ | ⚠️ Phase 1.5 (SAX variant) | ✅ | ✅ |
| OTr_SetErrorHandler | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_SetOptions | ✅ | ✅ Phase 1 | ✅ | ✅ |
| OTr_SizeOfArray | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_SortArrays | ✅ | ✅ Phase 4 | ✅ | ✅ |
| OTr_onExit | ✅ | ✅ Phase 1 (lifecycle) | ✅ | ✅ |
| OTr_onStartup | ✅ | ✅ Phase 1 (lifecycle) | ✅ | ✅ |

**Notes on ⚠️ rows:**
- `OTr_SaveToXMLSAX` and `OTr_SaveToXMLFileSAX` are present in source and documentation but the Phase 1.5 spec describes the non-SAX variants only. The SAX variants appear to be additional implementations sharing the same interface contract. The spec should be updated to explicitly include them, or their relationship to the non-SAX variants should be documented.

### 1.2 Private methods (`OTr_z*`) — source inventory

| Method | In Source | folders.json Group | Notes |
|---|:---:|---|---|
| OTr_zAddToCallStack | ✅ | OT Private Methods | ✅ Registered |
| OTr_zArrayFromObject | ✅ | OT Private Methods | ✅ Registered |
| OTr_zArrayType | ✅ | OT Private Methods | ✅ Registered |
| OTr_zErrIgnore | ✅ | OT Private Methods | ✅ Registered |
| OTr_zError | ✅ | OT Private Methods | ✅ Registered |
| OTr_zInit | ✅ | OT Private Methods | ✅ Registered |
| OTr_zIsShadowKey | ✅ | OT Private Methods | ✅ Registered |
| OTr_zIsValidHandle | ✅ | OT Private Methods | ✅ Registered |
| OTr_zLock | ✅ | OT Private Methods | ✅ Registered |
| OTr_zLogFileName | ✅ | — | ❌ **NOT in folders.json** |
| OTr_zLogGetCallStack | ❌ **FILE MISSING** | — | ❌ Called but no source file |
| OTr_zLogLevelToInt | ✅ | OT Private Methods | ✅ Registered |
| OTr_zLogShutdown | ✅ | OT Private Methods | ✅ Registered |
| OTr_zLogWrite | ✅ | OT Private Methods | ✅ Registered |
| OTr_zMapType | ✅ | OT Private Methods | ✅ Registered |
| OTr_zRemoveFromCallStack | ✅ | OT Private Methods | ✅ Registered |
| OTr_zResolvePath | ✅ | OT Private Methods | ✅ Registered |
| OTr_zSetOK | ✅ | OT Private Methods | ✅ Registered |
| OTr_zShadowKey | ✅ | OT Private Methods | ✅ Registered |
| OTr_zSortFillSlot | ✅ | OT Private Methods | ✅ Registered |
| OTr_zSortSlotPointer | ✅ | OT Private Methods | ✅ Registered |
| OTr_zSortValidatePair | ✅ | OT Private Methods | ✅ Registered |
| OTr_zTogglePluginBlocks | ✅ | — | ❌ **NOT in folders.json; zero callers** |
| OTr_zUnlock | ✅ | OT Private Methods | ✅ Registered |
| OTr_zXMLReadObject | ✅ | OT Private Methods | ✅ Registered |
| OTr_zXMLWriteObject | ✅ | OT Private Methods | ✅ Registered |
| OTr_zXMLWriteObjectSAX | ✅ | — | ❌ **NOT in folders.json** |
| OTr_z_CheckHostMethods | ✅ | OT Utility Methods | ⚠️ Registered in wrong group |
| OTr_z_Get4DVersion | ✅ | — | ❌ **NOT in folders.json** |
| OTr_z_Koala | ✅ | OT Private Methods | ✅ Registered |
| OTr_z_LogDirectory | ✅ | OT Utility Methods | ⚠️ Registered in wrong group |
| OTr_z_LogInit | ✅ | OT Utility Methods | ⚠️ Registered in wrong group |
| OTr_z_timestampLocal | ✅ | OT Utility Methods | ⚠️ Registered in wrong group |
| OTr_z_Wombat | ✅ | OT Private Methods | ✅ Registered |

### 1.3 Utility methods (`OTr_u*`) — source inventory

| Method | In Source | folders.json Group | Notes |
|---|:---:|---|---|
| OTr_u_AccessArrayElement | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uBlobToText | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uDateToText | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uEqualBLOBs | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uEqualObjects | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uEqualPictures | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uEqualStrings | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uMapType | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uNewValueForEmbeddedType | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uPointerToText | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uTextToBlob | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uTextToDate | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uTextToPointer | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uTextToTime | ✅ | OT Utility Methods | ✅ Registered |
| OTr_uTimeToText | ✅ | OT Utility Methods | ✅ Registered |

---

## Step 2 — Cross-Reference Summary

### 2.1 Methods in source, not in any spec

The following methods exist in source but are not explicitly named in a phase specification's method-signature table. Each was introduced during development and documented in Phase 9 (audit/corrections) rather than in a dedicated phase spec:

- `OTr_ArrayType` — documented in Phase 9; returns the stored array-type constant for a named array property
- `OTr_GetActiveHandleCount` — diagnostic helper; useful for leak detection
- `OTr_IncludeShadowKey` — controls whether shadow keys are included in output; Phase 9
- `OTr_Info` — general-purpose diagnostic enquiry method; Phase 9
- `OTr_onExit` — lifecycle callback registered with 4D's `ON EXIT DATABASE`; Phase 1
- `OTr_onStartup` — lifecycle callback registered with 4D's `On Startup`; Phase 1
- `OTr_SaveToXMLSAX` — SAX-based XML serialisation variant; not separately specified
- `OTr_SaveToXMLFileSAX` — SAX-based XML file serialisation variant; not separately specified

**Recommended disposition:** All eight methods have documentation files in `Documentation/Methods/` and are registered in `folders.json`. No action required for the methods themselves. The SAX variants should be acknowledged in the Phase 1.5 spec (or a brief addendum) to close the gap formally.

### 2.2 Methods in spec, not in source

**None.** Every method named in a specification's signature table has a corresponding `.4dm` file in `Project/Sources/Methods/`.

> **Note on Phase 20 TODO (Load methods):** `OTr_LoadFromText`, `OTr_LoadFromFile`, and `OTr_LoadFromClipboard` were flagged in the Phase 20 TODO as potentially unimplemented. All three are confirmed as **implemented**. Their `.4dm` files exist, their `#DECLARE` signatures are correct, and they are registered in `folders.json`. The Phase 20 TODO item can be closed.

### 2.3 Methods in `Documentation/Methods/` but not in source

**None.** Every `.md` file in `Documentation/Methods/` corresponds to an existing `.4dm` source file. There are no stale documentation files.

### 2.4 Methods in source but not in `Documentation/Methods/`

**None.** Every public `OTr_` API method has a corresponding documentation file.

---

## Step 3 — Signature Audit

### 3.1 `OTr_GetBoolean` — return type

**Spec says:** Returns Integer (0 or 1); explicitly not Boolean.

**Source `#DECLARE`:**
```
#DECLARE($inObject_i : Integer; $inTag_t : Text)->$result_i : Integer
```

**Verdict:** ✅ Correct. The source returns Integer, matching the spec.

---

### 3.2 `OTr_GetBLOB` — deprecated with output-parameter pattern

**Spec says:** Deprecated; uses output-parameter pattern (Pointer) rather than function result; delegates to `OTr_GetNewBLOB`.

**Source `#DECLARE`:**
```
#DECLARE($inObject_i : Integer; $inTag_t : Text; $outBLOB_ptr : Pointer)
```

**Verdict:** ✅ Correct. The output-parameter pattern is implemented and the suffix `_ptr` is correct for a Pointer type. The deprecation status should be visible in the method's header comment and in the documentation file.

---

### 3.3 `OTr_BLOBToObject` — offset parameter status

**Phase 15 spec (provisional note):** The `$ioOffset_i` parameter was marked as provisional, with a note that it might be removed.

**Source `#DECLARE`:**
```
#DECLARE($inBLOB_blob : Blob)->$handle_i : Integer
```

**Source change log (lines 30–31 of source):** "Simplified: dropped ioOffset parameter and OTR1 envelope."

**Verdict:** ⚠️ **Spec update required.** The implementation has definitively resolved the provisional status by removing the offset parameter. The Phase 15 spec must be updated to remove the provisional note and to reflect the current single-parameter signature. This resolves Cross-Cutting Issue #5 from the Review Index.

---

### 3.4 `OTr_GetArrayPointer` — function result vs output parameter

**Spec says:** Changed signature — now returns Pointer as a function result rather than via an output parameter.

**Source `#DECLARE`:**
```
#DECLARE($inObject_i : Integer; $inTag_t : Text; $inIndex_i : Integer)->$result_ptr : Pointer
```

**Verdict:** ✅ Correct. The function-result pattern is implemented and the suffix `_ptr` is correct.

---

### 3.5 `OTr_LoadFromText`, `OTr_LoadFromFile`, `OTr_LoadFromClipboard`

**Phase 20 TODO:** Flagged as potentially unimplemented.

**Source `#DECLARE` statements:**
```
OTr_LoadFromText:      #DECLARE($inJSON_t : Text)->$handle_i : Integer
OTr_LoadFromFile:      #DECLARE($inFilePath_t : Text)->$handle_i : Integer
OTr_LoadFromClipboard: #DECLARE()->$handle_i : Integer
```

**Verdict:** ✅ All three are implemented. Phase 20 TODO item can be closed.

---

### 3.6 `OTr_uTextToTime` — minor suffix non-conformance

**Source `#DECLARE`:**
```
#DECLARE($dateAsText_t : Text)->$thetime_h : Time
```

**Issue:** The return variable is `$thetime_h` (lowercase 't' in 'time'). The naming convention requires capitalisation of the semantic component: `$theTime_h`. This is a cosmetic issue with no functional impact.

**Verdict:** ⚠️ Minor. Correction recommended for consistency. Also note the parameter name `$dateAsText_t` in `OTr_uTextToTime` — this appears to be a copy-paste artefact from `OTr_uTextToDate`; it should be `$timeAsText_t`.

---

### 3.7 `OTr_uBlobToText` — suffix non-conformance

**Source `#DECLARE`:**
```
#DECLARE($theBlob_x : Blob)->$blobRef_t : Text
```

**Issue:** The suffix `_x` for a BLOB parameter is non-standard. Per `OTr-Types-Reference.md`, BLOB variables should use the suffix `_blob`. The correct signature should be `$theBlob_blob`.

**Verdict:** ⚠️ **Non-conformance.** This is flagged in the S1 and S5 review sessions as the stray `_x` suffix issue. Correction required.

---

## Step 4 — `folders.json` Registration Audit

### 4.1 Confirmed correct registrations

- **"OT API Methods"**: All 107 public API methods correctly registered.
- **"OT Private Methods"**: 29 of 34 `OTr_z*` methods correctly registered.
- **"OT Utility Methods"**: All 15 `OTr_u*` methods correctly registered.
- **"OT Testing"**: All 23 test and utility methods correctly registered.

### 4.2 Missing registrations — private methods

The following `OTr_z*` source files exist but are absent from `folders.json`:

| Method | Issue |
|---|---|
| `OTr_zLogGetCallStack` | **Source file does not exist** — cannot be registered. This is the more serious underlying problem. |
| `OTr_zLogFileName` | Source file exists; not registered in any group. |
| `OTr_zXMLWriteObjectSAX` | Source file exists; not registered in any group. |
| `OTr_z_Get4DVersion` | Source file exists; not registered in any group. |

### 4.3 Wrong-group registrations — `OTr_z*` methods in "OT Utility Methods"

Four methods with the `OTr_z_` prefix (double underscore convention for "internal private") are registered in "OT Utility Methods" rather than "OT Private Methods":

| Method | Current Group | Correct Group |
|---|---|---|
| `OTr_z_CheckHostMethods` | OT Utility Methods | OT Private Methods |
| `OTr_z_LogDirectory` | OT Utility Methods | OT Private Methods |
| `OTr_z_LogInit` | OT Utility Methods | OT Private Methods |
| `OTr_z_timestampLocal` | OT Utility Methods | OT Private Methods |

**Recommended action:** Move these four entries from "OT Utility Methods" to "OT Private Methods" in `folders.json`.

### 4.4 `OTr_zTogglePluginBlocks` — orphaned source file

`OTr_zTogglePluginBlocks.4dm` exists in `Project/Sources/Methods/` but:
- Is not registered in `folders.json`
- Has **zero callers** anywhere in the codebase

**Recommended action:** Determine whether this method is still required (e.g., used only at development time, invoked manually). If not, delete the source file. If it is a developer tool, register it under "OT Private Methods" and add a comment to the header clarifying its purpose.

---

## Step 5 — Critical Finding: `OTr_zLogGetCallStack` Missing Source File

`OTr_zLogGetCallStack` is called from:
- `OTr_zLogWrite.4dm`
- `Compiler_ObjectToolsReplacement.4dm`

However, **no source file `OTr_zLogGetCallStack.4dm` exists** in `Project/Sources/Methods/`.

This is a **compilation error risk** in interpreted mode and a **definite compilation failure** in compiled mode. It must be resolved before release.

**Possible explanations:**
1. The method was renamed (perhaps merged into `OTr_zAddToCallStack` or `OTr_zRemoveFromCallStack`) and the call sites were not updated.
2. The method was deleted and the call sites were overlooked.
3. The source file exists under a different name or in a different location.

**Required action:** Investigate call sites in `OTr_zLogWrite.4dm` and `Compiler_ObjectToolsReplacement.4dm` to determine what `OTr_zLogGetCallStack` is expected to return, then either implement it or update the call sites to use the correct existing method.

---

## Step 6 — Utility Method Retirement Assessment

### 6.1 Date/Time conversion utilities

| Method | Active Callers | Verdict |
|---|---|---|
| `OTr_uDateToText` | 6 (PutArray, PutArrayDate, PutRecord, PutVariable, Compiler_OTR, DemoForAi) | ✅ **Retain** |
| `OTr_uTextToDate` | 7 (FindInArray, GetArrayDate, GetRecord, GetVariable, zArrayFromObject, Compiler_OTR, DemoForAi) | ✅ **Retain** |
| `OTr_uTimeToText` | 6 (PutArray, PutArrayTime, PutRecord, PutVariable, Compiler_OTR, DemoForAi) | ✅ **Retain** |
| `OTr_uTextToTime` | 7 (FindInArray, GetArrayTime, GetRecord, GetVariable, zArrayFromObject, Compiler_OTR, DemoForAi) | ✅ **Retain** |

**Assessment:** All four Date/Time conversion utilities are actively called by multiple production methods. The Phase 20 TODO question ("determine whether these are still called or can be retired") is now resolved: **they are essential and must be retained.**

The underlying rationale is that 4D's native `OB SET` with Date and Time types stores them in ISO 8601 format internally, but OTr stores them as formatted text strings (`YYYY-MM-DD`, `HH:MM:SS`) as specified in §3.6 of the master spec. These conversion utilities are the canonical implementation of that storage strategy. They should not be retired unless the Date/Time storage strategy is changed (see Cross-Cutting Issue #1 in the Review Index).

### 6.2 BLOB conversion utility

| Method | Active Callers | Verdict |
|---|---|---|
| `OTr_uBlobToText` | 5 (PutArray, PutArrayBLOB, PutBLOB, PutVariable, Compiler_OTR) | ✅ **Retain — with caveat** |
| `OTr_uTextToBlob` | 5 (GetArrayBLOB, GetBLOB, GetNewBLOB, GetVariable, Compiler_OTR) | ✅ **Retain — with caveat** |

**Assessment:** Both BLOB conversion utilities are actively called. Per Phase 4 spec, BLOB storage on pre-v19R2 databases uses base64 encoding (via these utilities), while v19R2 and later uses native BLOB storage. The utilities remain necessary for compatibility with databases on older 4D versions.

The suffix non-conformance (`$theBlob_x` instead of `$theBlob_blob`) should be corrected as a separate mechanical fix (S5 scope).

---

## Findings Summary

### Blockers

| ID | Finding | Severity | Action Required |
|---|---|---|---|
| S2-B1 | `OTr_zLogGetCallStack` source file missing; method is called in production code | **Blocker** | Implement method or fix call sites |

### Required corrections

| ID | Finding | Severity | Action Required |
|---|---|---|---|
| S2-R1 | Phase 15 spec still shows `OTr_BLOBToObject` with provisional `$ioOffset_i` parameter | High | Update Phase 15 spec to reflect current single-parameter signature |
| S2-R2 | `OTr_zLogFileName`, `OTr_zXMLWriteObjectSAX`, `OTr_z_Get4DVersion` not registered in `folders.json` | Medium | Add to "OT Private Methods" group in `folders.json` |
| S2-R3 | `OTr_z_CheckHostMethods`, `OTr_z_LogDirectory`, `OTr_z_LogInit`, `OTr_z_timestampLocal` registered in wrong `folders.json` group | Low | Move from "OT Utility Methods" to "OT Private Methods" |
| S2-R4 | `OTr_uTextToTime`: return variable named `$thetime_h` (lowercase); parameter named `$dateAsText_t` (wrong semantic name) | Low | Rename to `$theTime_h` and `$timeAsText_t` respectively |
| S2-R5 | `OTr_uBlobToText`: `$theBlob_x` suffix non-conformant; should be `$theBlob_blob` | Low | Rename parameter (also tracked in S5) |

### Recommended actions (non-blocking)

| ID | Finding | Recommendation |
|---|---|---|
| S2-A1 | `OTr_SaveToXMLSAX` and `OTr_SaveToXMLFileSAX` not explicitly named in Phase 1.5 spec | Add brief note to Phase 1.5 spec acknowledging SAX variants |
| S2-A2 | `OTr_zTogglePluginBlocks` — source exists, no callers, not in `folders.json` | Determine if still needed; delete or document and register |
| S2-A3 | Phase 20 TODO item re Load methods (LoadFromText, LoadFromFile, LoadFromClipboard) | Close as resolved — all three are implemented |
| S2-A4 | Utility Date/Time method retirement question (Phase 20 TODO) | Close as resolved — all four are actively called and must be retained |

---

## Relationship to Cross-Cutting Issues

| Index Issue | S2 Status |
|---|---|
| #1 Date/Time storage strategy discrepancy | Partially addressed: utility methods confirmed active; underlying strategy question remains open for S1/S3 |
| #3 Phase 1.5 Load methods potentially unimplemented | **Resolved:** all three confirmed implemented |
| #5 `OTr_BLOBToObject` offset parameter provisional | **Resolved:** offset parameter dropped; spec update required (S2-R1) |
