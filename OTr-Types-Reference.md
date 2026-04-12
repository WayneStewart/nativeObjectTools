# OTr — Type Constants Reference

**Version:** 0.1
**Date:** 2026-04-01
**Author:** Wayne Stewart / Claude
**Parent Document:** [OTr-Specification.md](OTr-Specification.md) (§7)

---

## Overview

This document is the authoritative reference for 4D type constants as used throughout the OTr method suite. All OTr methods that inspect, store, or return type information use the native 4D constants listed here — not the legacy ObjectTools type constants.

The **Suffix** column gives the variable name suffix convention used in OTr method source code (as per the 4D Method Writing Guide). Entries marked `<do not use>` indicate types that are obsolete, unsupported, or not applicable in OTr's target environment (4D v19 LTS and later).

---

## 4D Type Constants

| Constant | Value | Suffix | Notes |
|---|---|---|---|
| `Is alpha field` | 0 | `_t` | Map to text |
| `Is real` | 1 | `_r` | |
| `Is text` | 2 | `_t` | |
| `Is picture` | 3 | `_pic` | Stored natively as an Object property in OTr (4D v16R4+) |
| `Is date` | 4 | `_d` | Stored as `YYYY-MM-DD` text in OTr |
| `Is undefined` | 5 | | |
| `Is Boolean` | 6 | `_b` | |
| `Is subtable` | 7 | | `<do not use>` |
| `Is integer` | 8 | `_i` | Map to longint |
| `Is longint` | 9 | `_i` | Primary integer type |
| `Is time` | 11 | `_h` | Stored as `HH:MM:SS` text in OTr |
| `Is variant` | 12 | `_v` | |
| `Array 2D` | 13 | | `<as per underlying type>` |
| `Real array` | 14 | `_ar` | |
| `Integer array` | 15 | `_ai` | |
| `LongInt array` | 16 | `_ai` | |
| `Date array` | 17 | `_ad` | |
| `Text array` | 18 | `_at` | |
| `Picture array` | 19 | `_apic` | |
| `Pointer array` | 20 | `_aptr` | |
| `String array` | 21 | `_at` | Map to array text |
| `Boolean array` | 22 | `_ab` | |
| `Is pointer` | 23 | `_ptr` | Stored via `ptr:` serialisation in OTr |
| `Is string var` | 24 | `_t` | Map to text |
| `Is integer 64 bits` | 25 | | `<do not use>` |
| `Is BLOB` | 30 | `_blob` | Stored natively on v19R2+; base64 Text via `OTr_uBlobToText` on v19/v19R1 |
| `Blob array` | 31 | `_ablob` | |
| `Time array` | 32 | `_ah` | |
| `_o_Is float` | 35 | | `<do not use>` |
| `Is object` | 38 | `_o` | Native 4D Object |
| `Object array` | 39 | `_ao` | |
| `Is collection` | 42 | `_c` | Used for array storage in OTr |
| `Is null` | 255 | | |

---

## Legacy OT Type Constants

The legacy ObjectTools plugin defined its own type constants. The table below maps each OT constant to its native 4D equivalent, for reference when migrating existing code or implementing `OTr_uMapType`.

See §7 of the parent specification for the full bidirectional mapping table.

| OT Constant | OT Value | Maps To (4D) | OTr Storage Convention |
|---|---|---|---|
| `OT Character` | 112 | `Is text, Is string var, or Is alpha field` | Direct |
| `OT Array Character` | 113 | `Text array or String array` | Either type but Array text is most common |
| `OT Object` | 114 | `Is object` | Embedded 4D Object |
| `OT Record` | 115 | *(none)* | `rec:tableNum;recordNum` text |
