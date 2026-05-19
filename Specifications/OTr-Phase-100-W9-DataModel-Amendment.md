# OTr Phase 100 — W9 Data-Model Amendment

**Version:** 0.1
**Date:** 2026-05-19
**Status:** Draft for review — folds into [OTr-Phase-100-Spec.md](OTr-Phase-100-Spec.md) §2.4
**Author:** Wayne Stewart / Claude
**Compatibility target:** 4D v19 LTS, v20, v21

---

## 1. Purpose

This amendment refines the indicative sketch in §2.4 (“Storage Object
Prototype”) into a precise per-object schema for the Storage mechanism.
It resolves the seven open questions enumerated in W9 of §13. No public
API surface changes; all changes are confined to the shape of nested
shared objects rooted at `Storage.OTr_Group_N`.

The IP Arrays mechanism is unaffected. Where the two mechanisms differ
in storage shape, the wrapper described here is normalised so that the
Inner-layer comparison logic is identical (`$storedType_i = $inArrayType_i`).

---

## 2. Per-Object Schema

### 2.1 JSON form

```json
"h_11": {
  "tags": {
    "Customer Name":  { "type": 2,  "scalar": "Acme Pty Ltd" },
    "Order Numbers":  { "type": 16, "currentItem": 0, "array": [101, 102, 103] },
    "Active":         { "type": 6,  "scalar": true },
    "Photo":          { "type": 19, "currentItem": 0, "array": ["<base64>", "<base64>"] }
  }
}
```

### 2.2 Field-by-field

| Field | Type | Cardinality | Meaning |
|---|---|---|---|
| `tags` | shared Object | required, may be empty | One property per user-visible tag. |
| `tags.<tagName>` | shared Object | one per tag | The **tag wrapper**. |
| `tags.<tagName>.type` | Integer (Real on the wire) | required | 4D type constant captured at first assignment. See §3. |
| `tags.<tagName>.scalar` | any supported scalar | present iff scalar tag | The tag value. Encoded per §4 for ambiguous types. |
| `tags.<tagName>.array` | shared Collection | present iff array tag | The element collection. Encoded per §5 element-wise. |
| `tags.<tagName>.currentItem` | Integer (Real on the wire) | present iff array tag | OT-equivalent "current element" index (0-based). Defaults to 0. |

No other properties on `h_NN`. The handle is **not** denormalised into
the value (the property key already carries it). No `createdAt` field —
debugging value is low and adds write cost.

### 2.3 What is *not* in the wrapper

- **No `numElements`.** Shared collections have `.length`; storing it
  separately would invite drift.
- **No shadow keys inside `tags`** under the Storage mechanism. The
  wrapper's `type` field is the canonical record of the tag's OT type.
  See §6.
- **No per-tag locking metadata.** Locking is per-group (per
  trailing-digit), not per-tag.

---

## 3. The `type` Field

**Decision:** store the 4D type constant **as its integer value**, not as
a symbolic string.

**Rationale:**

1. The Inner-layer dispatch already receives `$inArrayType_i` as an
   Integer. Symbolic comparison would require a lookup table on every
   read.
2. The IP Arrays mechanism already stores `arrayType` as an Integer on
   the embedded array object (see `OTr_z_ArrayType.4dm`). Aligning the
   Storage mechanism keeps `OTr_z_ArrayType` mechanism-agnostic.
3. Numeric properties of a shared object are stored as Real (a
   documented 4D constraint), but the value compares equal to the
   integer constant in 4D code (e.g. `Storage.OTr_Group_1.h_11.tags["X"].type = LongInt array`).
4. The constants are defined and stable across v19–v21
   (see [OTr-Types-Reference.md](../OTr-Types-Reference.md)).

The symbolic string `"longInt array"` shown in the §2.4 sketch was
illustrative only.

---

## 4. Scalar Tags

Scalar tags use the same wrapper for shape consistency, with `scalar`
in place of `array` and no `currentItem`. The §12 deferred-decision
note about scalars not needing a three-layer split applies to the
**access path** (the Outer/Middle/Inner layers may remain unchanged
for scalars), not the **storage shape** — scalars under the Storage
mechanism still get the wrapper so that `OTr_ItemType`, the
enumerator, and the type-coherence checks all use one code path.

For scalars whose 4D representation is lossy (see §6.2), the encoded
form lives in `scalar` and the wrapper's `type` field records the
original OT type. The shadow-key convention from the IP mechanism is
not used.

---

## 5. Array Storage, Type by Type

All arrays under the Storage mechanism are **shared collections** held
in the wrapper's `array` field. The element encoding compensates for
the constraints documented in
*[Shared objects and shared collections](https://developer.4d.com/docs/Concepts/shared/)*
and *[New shared object](https://developer.4d.com/docs/commands-legacy/new-shared-object/)*:
shared containers support only number-as-Real, text, boolean, date,
time-as-milliseconds-Real, null, shared object, and shared collection.
Picture and pointer are explicitly excluded.

| OTr type | Constant | Element encoding under Storage | Round-trip fidelity vs IP Arrays |
|---|---|---|---|
| Real array | 14 | Real | identical |
| Integer array | 15 | Real (collapsed) | precision preserved; type recovered from `type` field |
| LongInt array | 16 | Real (collapsed) | precision preserved up to 2⁵³; type recovered from `type` field |
| Date array | 17 | Text `YYYY-MM-DD` | identical to IP — same `OTr_u_DateToText` helper |
| Text array | 18 | Text | identical |
| Picture array | 19 | shared Object `{ codec, data }`; `data` is `PICTURE TO BLOB` → `OTr_u_BlobToText` base64 | round-trip preserved; see §5.2 below |
| Pointer array | 20 | Text (`ptr:` serialisation) | identical to IP — same `OTr_u_PointerToText` helper, with the documented cross-process caveat |
| String array | 21 | Text | identical |
| Boolean array | 22 | Boolean | identical |
| BLOB array | 31 | Text (`OTr_u_BlobToText` base64) | identical to the IP base64 fallback; see §5.1 below |
| Time array | 32 | Text `HH:MM:SS` | identical to IP — same `OTr_u_TimeToText` helper |
| Object array | 39 | shared Object | embedded objects must themselves be shared (a 4D-level constraint) |

### 5.1 BLOB arrays

Neither BLOBs nor Pictures are supported as element types of shared
objects or shared collections on v19, v20, or v21. Under the Storage
mechanism, BLOB array elements are **base64-encoded Text
unconditionally**, using the existing `OTr_u_BlobToText` /
`OTr_u_TextToBlob` helpers. The wrapper's `type` field carries
`Blob array (31)` so that the encoding is invisible to the Inner
layer and to `OTr_ItemType`.

The `Storage.OTr.nativeBlobInObject` flag is therefore inert under
the Storage mechanism for the v19–v21 compatibility window: it has
no `True` branch to take. The flag is retained on the config object
as a forward-compatibility hook and is read by the Outer-layer
BLOB/Picture methods only, never by the Inner layer.

The §10A table should be updated accordingly: the "Storage mechanism,
`nativeBlobInObject = True`" column for BLOB and Picture rows is not
reachable under v19–v21 and can either be marked "reserved" or
removed.

### 5.2 Picture arrays

Pictures are not storable in shared objects on v19–v21, so each
element is encoded to a small shared sub-object that carries both the
codec and the base64 payload:

```json
"Photos": {
  "type": 19,
  "currentItem": 0,
  "array": [
    { "codec": ".png",  "data": "<base64>" },
    { "codec": ".jpg",  "data": "<base64>" }
  ]
}
```

The encode/decode pattern follows the OBJ_Module precedent
(`OBJ_Set_Picture.4dm`, `OBJ_Get_Picture.4dm`): `PICTURE TO BLOB` →
`BASE64 ENCODE` → `Convert to text` on Put; the reverse on Get. The
codec field must be one of the values returned by `GET PICTURE
FORMATS` on the running machine; the public OTr Picture-array API
does not currently take a codec argument and so the Outer layer is
responsible for selecting one.

**Codec selection at Put.** Read the inbound picture's native codec
list using the standard 4D picture-properties facility and pick the
first entry; this preserves the source format whenever the picture
originated from a file or database read. If the list is empty (e.g.
a freshly drawn vector), fall back to `".png"`. The chosen codec is
recorded in the element wrapper alongside the base64 payload.

**Codec selection at Get.** Read the codec field from the element
wrapper and pass it to `BLOB TO PICTURE`. Round-trip fidelity is
preserved across the IP Arrays mechanism and the Storage mechanism
for any picture whose source codec is recognised by the running 4D
instance.

References: [Pictures (4D v19)](https://doc.4d.com/4Dv19/4D/19.8/Pictures.300-7112129.en.html),
[GET PICTURE FORMATS (4D v19)](https://doc.4d.com/4Dv19/4D/19.8/GET-PICTURE-FORMATS.301-7112107.en.html).

This raises a minor schema question — array elements under the
Storage mechanism are no longer uniformly scalar; for Picture arrays
they are shared sub-objects. This does not affect the wrapper's
`type` field (still `Picture array (19)`) and does not require the
Inner layer to distinguish: the Inner layer reads and writes whatever
element shape the Outer layer hands it. See
[open question OQ-3a](#83-oq-3-object-array-elements) for a related
point about Object array elements that must also be shared.

### 5.3 Pointer arrays

The cross-process semantics of pointers are already broken under the
IP Arrays mechanism (see `OTr_PutArrayPointer.4dm` warning). The
Storage mechanism does not make this worse: pointers are serialised
to Text via `OTr_u_PointerToText` and stored as Text elements. The
caller-visible warning in the Outer layer remains accurate.

### 5.4 Numeric type collapse

Integer and LongInt elements survive as Real with identical numeric
value within the safe-integer range (±2⁵³ for LongInt; trivially for
Integer). The Inner layer must not compare the **runtime value type**
of a fetched element against `$inArrayType_i`; it must compare against
the wrapper's stored `type` field. The Phase 8 dispatcher already
performs the equivalent comparison via `OTr_z_ArrayType` — the same
helper, redirected at the wrapper, suffices.

---

## 6. Shadow-Key Handling

### 6.1 Decision

Shadow keys (`<leafKey>$type`) **are not stored** inside
`Storage.OTr_Group_N.h_NN.tags` under the Storage mechanism. The
wrapper's `type` field replaces them.

### 6.2 Why shadow keys exist in IP

Under the IP Arrays mechanism the per-object tree is a `Storage`-free
nested-object structure where `OB Get type` returns a 4D-native type
that is ambiguous for two cases: a Pointer serialised as Text (looks
like Text on read-back) and, on v19/v19R1, a BLOB serialised as
base64 Text (also looks like Text). The shadow key carries the
**OT** type constant so that `OTr_ItemType` can return the original
type rather than the on-disk type.

### 6.3 Why they are unnecessary under Storage

Every tag is wrapped, and the wrapper carries the original type for
both scalars and arrays. Reading `tags["X"].type` is a single
property access with no `Use…End use` (reads of shared-object
properties are unguarded). There is no ambiguity to resolve.

### 6.4 Effect on `OTr_GetAllNamedProperties`

The enumerator must continue to honour `Storage.OTr.includeShadowKeys`.
Under the Storage mechanism, when the flag is `True` the enumerator
**synthesises** a `<leafKey>$type` entry per real tag at iteration
time, value = `tags[<leafKey>].type`. This preserves the public
contract of the enumerator with zero on-disk duplication and no risk
of shadow/wrapper drift. The synthesis happens in
`OTr_GetAllNamedProperties` (or its Storage-side Inner equivalent) and
never touches the stored tree.

See [open question OQ-2](#71-open-questions) for the alternative
(store explicit shadow entries for byte-for-byte parity).

---

## 7. Object Lifecycle

### 7.1 Empty object after `OTr_New`

```json
"h_47": { "tags": {} }
```

`OTr_New` creates the per-handle object with a non-null, empty `tags`
property. The alternative (absent until first Put) would force every
Inner-layer read to distinguish "object never written" from "object
never created" — a distinction the controller registry
(`Storage.OTrController.inUse`) already makes unambiguously.

### 7.2 Controller registry

The `Storage.OTrController.inUse[<h_NN>]` Boolean is the source of
truth for handle validity. The Inner layer must consult it (under the
controller semaphore) before assuming `Storage.OTr_Group_N.h_NN`
exists; the converse is not safe, because a stale `h_NN` could exist
mid-`OTr_Clear` if the registry has been cleared first.

`OTr_Clear` removes both entries atomically under the controller
semaphore.

---

## 8. Open Questions

The following items could not be fully resolved against v19–v21
documentation; the spec author is asked to adjudicate.

### 8.1 OQ-1 — Synthesised vs stored shadow keys

§6 proposes synthesising shadow entries on enumeration rather than
storing them. The alternative — store
`tags["X$type"] = { "type": ..., "scalar": <ot-type-constant> }` — is
heavier on the wire but preserves bit-for-bit parity with the IP
Arrays mechanism's enumerator output and removes any synthesis logic
from the Get path. Recommendation stands at synthesis; flagging for
review.

### 8.2 OQ-2 — Time arrays: native Time element vs Text

Shared containers accept `Time` natively but coerce it to "number of
milliseconds (Real)". The IP Arrays mechanism stores Time array
elements as `HH:MM:SS` Text. §5 above keeps the Text encoding for
parity. The alternative (store as Real-ms and convert on Get) would
save a few bytes per element and avoid two helper calls per access.
Recommendation stands at Text for parity; flagging for review.

### 8.3 OQ-3 — Object array elements

Object array elements under the Storage mechanism must themselves be
shared objects (a 4D constraint). The IP Arrays mechanism has no such
requirement. If a caller hands `OTr_PutArrayObject` a standard
(non-shared) Object, the Outer layer must either (a) deep-copy it
into a shared Object before storage, or (b) reject it. The IP-side
behaviour is (a) implicitly (assignment into a nested object is
always a value copy under IP). Confirm (a) is desired under Storage
and that `OTr_PutArrayObject` is responsible for the conversion.

---

## 9. Summary of Decisions

| # | Question | Decision |
|---|---|---|
| 1 | Tag wrapper shape | `{ type, scalar }` for scalars; `{ type, currentItem, array }` for arrays |
| 2 | `type` encoding | 4D Integer constant (stored as Real per shared-object rules) |
| 3 | Array container | shared Collection; `numElements` omitted (use `.length`) |
| 4 | Scalar tag shape | same wrapper as arrays, with `scalar` in place of `array` |
| 5 | Per-object extras | none beyond `tags` |
| 6 | Empty object | `{ "tags": {} }` on `OTr_New` |
| 7 | Shadow keys | not stored; synthesised by enumerator when `includeShadowKeys = True` |

End of amendment.
