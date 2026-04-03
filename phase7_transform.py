#!/usr/bin/env python3
"""Phase 7 OTr parameter naming alignment transformation.

Applies naming-convention changes to all public OTr_ method files:
  1. Rebuilds the Project Method: comment line to OT-style parameter names
     on a single line.
  2. Renames declared parameters in the Parameters: block and #DECLARE line
     (and throughout the method body, since 4D parameters are local vars).
  3. Updates Parameters: description text to reference OT semantic names.
  4. Adds a dated modification note above the closing dashes line.

Methods already conformant (Phase 5/6):
  OTr_PutBLOB, OTr_PutPicture, OTr_PutPointer, OTr_PutRecord,
  OTr_GetBLOB, OTr_GetNewBLOB, OTr_GetPicture, OTr_GetPointer,
  OTr_GetRecord, OTr_GetRecordTable, OTr_ObjectToNewBLOB
  → No changes needed for those.  Some partial fixes below.
"""

import re
import os
import sys

BASE = "/Users/waynestewart/4D/Projects/OT Replacement/nativeObjectTools/Project/Sources/Methods"
MOD_NOTE = "// Wayne Stewart, 2026-04-04 - Phase 7 parameter naming alignment."
CLOSING_DASHES = "// ----------------------------------------------------"


def read_file(name):
    path = os.path.join(BASE, name)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write_file(name, content):
    path = os.path.join(BASE, name)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)


def apply_renames(content, renames):
    """Apply ordered string substitutions."""
    for old, new in renames:
        content = content.replace(old, new)
    return content


def replace_project_method_line(content, new_line):
    """Replace the Project Method: comment line (possibly multi-line with backslash
    or multi-line indented continuations) with a single new_line."""
    # Match the Project Method line plus any continuation lines that start with //
    # and are indented (continuation of a multi-line signature in old format).
    # Pattern: starts at "// Project Method:" and continues through any
    # subsequent "// " lines that are part of the same comment block.
    # We identify continuations as lines immediately after that still start
    # with "// " and look like parameter / return continuations.
    #
    # Strategy: consume from "// Project Method:" to the first blank comment
    # line or a non-continuation comment line (like "// Stores..." description).
    #
    # Simpler: match "// Project Method:" line and any lines ending with \ continuation,
    # then any further "//   " lines that follow.

    # First, handle backslash-continued lines
    # Pattern: "// Project Method: ...\\\n//   ...\\\n//   ..."
    # Also handle lines that DON'T have backslash but are multi-line with "//   " indent

    pattern = re.compile(
        r'// Project Method:.*?(?=\n(?!//   )|\Z)',
        re.DOTALL
    )
    result = pattern.sub(new_line, content, count=1)
    if result == content:
        # Try a different approach: match just the first line
        lines = content.split('\n')
        new_lines = []
        i = 0
        replaced = False
        while i < len(lines):
            line = lines[i]
            if not replaced and line.startswith('// Project Method:'):
                new_lines.append(new_line)
                replaced = True
                i += 1
                # Skip any continuation lines (lines starting with "//   " that
                # are indented parameter continuations)
                while i < len(lines) and re.match(r'^//   [\$\{]', lines[i]):
                    i += 1
                # Also skip lines that are pure continuation after backslash
                # (these were already part of the Project Method line)
            else:
                new_lines.append(line)
                i += 1
        result = '\n'.join(new_lines)
    return result


def add_mod_note(content, note):
    """Add the mod note immediately before the closing dashes line."""
    # The closing dashes line is the last occurrence of CLOSING_DASHES before #DECLARE
    # Find the last CLOSING_DASHES in the header (before the method body)
    # Strategy: find the line just before the first #DECLARE or just before the body
    lines = content.split('\n')
    # Find the closing dashes line in the header
    # It's typically near the #DECLARE line
    closing_idx = -1
    for i in range(len(lines) - 1, -1, -1):
        if lines[i].strip() == CLOSING_DASHES.strip():
            closing_idx = i
            break
    if closing_idx == -1:
        return content  # Safety: no change if not found
    # Check if mod note already present (avoid duplicates)
    if note in content:
        return content
    # Insert mod note before closing dashes
    lines.insert(closing_idx, note)
    return '\n'.join(lines)


def transform_file(name, new_project_method_line, renames, new_param_descriptions=None):
    """Apply all transformations to a single file."""
    if not os.path.exists(os.path.join(BASE, name)):
        print(f"  SKIP (not found): {name}")
        return
    content = read_file(name)

    # 1. Rename parameters (handles #DECLARE, Parameters: block, and body)
    if renames:
        content = apply_renames(content, renames)

    # 2. Replace Project Method line
    if new_project_method_line:
        content = replace_project_method_line(content, new_project_method_line)

    # 3. Replace Parameters: descriptions if provided
    if new_param_descriptions:
        for old_desc, new_desc in new_param_descriptions:
            content = content.replace(old_desc, new_desc)

    # 4. Add modification note
    content = add_mod_note(content, MOD_NOTE)

    write_file(name, content)
    print(f"  OK: {name}")


# =============================================================================
# Per-file transformation definitions
# =============================================================================

def run_all():

    print("Phase 7 OTr parameter naming alignment")
    print("=" * 50)

    # -------------------------------------------------------------------------
    # Group 1: Creation / Destruction
    # -------------------------------------------------------------------------
    print("\n--- Group 1: Creation/Destruction ---")

    # OTr_New: fix Project Method line (remove declared-var format from return)
    transform_file(
        "OTr_New.4dm",
        "// Project Method: OTr_New () --> Longint",
        renames=[],  # $handle_i is the RETURN, keep it (meaningful name)
        new_param_descriptions=[
            ("$handle_i : Integer : Allocated handle",
             "$handle_i : Integer : New OTr object handle"),
        ]
    )

    # OTr_Clear: ioObject per OT spec
    transform_file(
        "OTr_Clear.4dm",
        "// Project Method: OTr_Clear (ioObject)",
        renames=[
            ("$handle_i", "$ioObject_i"),
        ],
        new_param_descriptions=[
            ("$ioObject_i : Integer : Handle to release",
             "$ioObject_i : Integer : OTr handle to clear (ioObject)"),
        ]
    )

    # OTr_ClearAll: already correct, just add mod note
    transform_file(
        "OTr_ClearAll.4dm",
        None,  # Project Method line is fine
        renames=[],
    )

    # OTr_Copy: inObject for the input param, return $copyHandle_i stays
    transform_file(
        "OTr_Copy.4dm",
        "// Project Method: OTr_Copy (inObject) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : Source object handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$copyHandle_i : Integer : New handle with copied object, or 0 on failure",
             "$copyHandle_i : Integer : New handle containing copied object, or 0 on failure"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 2: Scalar Put (excluding already-conformant PutBLOB/PutPicture/PutPointer/PutRecord/PutVariable)
    # -------------------------------------------------------------------------
    print("\n--- Group 2: Scalar Put ---")

    transform_file(
        "OTr_PutLong.4dm",
        "// Project Method: OTr_PutLong (inObject; inTag; inValue)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_i", "$inValue_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$inValue_i  : Integer : Value to store",
             "$inValue_i  : Integer : Value to store (inValue)"),
        ]
    )

    transform_file(
        "OTr_PutReal.4dm",
        "// Project Method: OTr_PutReal (inObject; inTag; inValue)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_r", "$inValue_r"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$inValue_r  : Real    : Value to store",
             "$inValue_r  : Real    : Value to store (inValue)"),
        ]
    )

    # OTr_PutString is the REFERENCE — no changes needed, but add mod note
    # Actually, as the reference it should already be perfect. Skip it.

    transform_file(
        "OTr_PutText.4dm",
        "// Project Method: OTr_PutText (inObject; inTag; inValue)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_t", "$inValue_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$inValue_t  : Text    : Value to store",
             "$inValue_t  : Text    : Value to store (inValue)"),
        ]
    )

    transform_file(
        "OTr_PutDate.4dm",
        "// Project Method: OTr_PutDate (inObject; inTag; inValue)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_d", "$inValue_d"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$inValue_d  : Date    : Value to store",
             "$inValue_d  : Date    : Value to store (inValue)"),
        ]
    )

    transform_file(
        "OTr_PutTime.4dm",
        "// Project Method: OTr_PutTime (inObject; inTag; inValue)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_h", "$inValue_h"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$inValue_h  : Time    : Value to store",
             "$inValue_h  : Time    : Value to store (inValue)"),
        ]
    )

    transform_file(
        "OTr_PutBoolean.4dm",
        "// Project Method: OTr_PutBoolean (inObject; inTag; inValue)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_b", "$inValue_b"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$inValue_b  : Boolean : Value to store",
             "$inValue_b  : Boolean : Value to store (inValue)"),
        ]
    )

    # OTr_PutBLOB — already conformant; just add mod note
    transform_file(
        "OTr_PutBLOB.4dm",
        None,
        renames=[],
    )

    # OTr_PutPicture — already conformant; just add mod note
    transform_file(
        "OTr_PutPicture.4dm",
        None,
        renames=[],
    )

    # OTr_PutPointer — already conformant; just add mod note
    transform_file(
        "OTr_PutPointer.4dm",
        None,
        renames=[],
    )

    # OTr_PutObject: two handles — dest=$inObject_i, source=$inSourceObject_i
    transform_file(
        "OTr_PutObject.4dm",
        "// Project Method: OTr_PutObject (inObject; inTag; inObject)",
        renames=[
            # Order matters: rename sourceHandle first to avoid collision
            ("$sourceHandle_i", "$inSourceObject_i"),
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i       : Integer : Destination OTr handle",
             "$inObject_i       : Integer : OTr inObject (destination)"),
            ("$inTag_t          : Text    : Destination tag path",
             "$inTag_t          : Text    : Tag path (inTag)"),
            ("$inSourceObject_i : Integer : Source OTr handle",
             "$inSourceObject_i : Integer : OTr inObject (source to embed — inObject)"),
        ]
    )

    # OTr_PutRecord — already conformant; just add mod note
    transform_file(
        "OTr_PutRecord.4dm",
        None,
        renames=[],
    )

    # OTr_PutVariable — $inObject_i and $inTag_t already correct; fix $varPtr
    transform_file(
        "OTr_PutVariable.4dm",
        "// Project Method: OTr_PutVariable (inObject; inTag; inVarPointer)",
        renames=[
            ("$varPtr", "$inVarPointer_ptr"),
        ],
        new_param_descriptions=[
            ("$inVarPointer_ptr : Pointer : Pointer to variable to store",
             "$inVarPointer_ptr : Pointer : Pointer to variable to store (inVarPointer)"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 3: Scalar Get
    # -------------------------------------------------------------------------
    print("\n--- Group 3: Scalar Get ---")

    transform_file(
        "OTr_GetLong.4dm",
        "// Project Method: OTr_GetLong (inObject; inTag) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_i", "$result_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$result_i : Integer : Stored value, or 0 when missing/invalid",
             "$result_i : Integer : Stored value, or 0 on missing/invalid"),
        ]
    )

    transform_file(
        "OTr_GetReal.4dm",
        "// Project Method: OTr_GetReal (inObject; inTag) --> Real",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_r", "$result_r"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$result_r : Real : Stored value, or 0 on missing/invalid",
             "$result_r : Real : Stored value, or 0 on missing/invalid"),
        ]
    )

    transform_file(
        "OTr_GetString.4dm",
        "// Project Method: OTr_GetString (inObject; inTag) --> Text",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_t", "$result_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$result_t : Text : Stored value, or empty text when missing/invalid",
             "$result_t : Text : Stored value, or empty text on missing/invalid"),
        ]
    )

    transform_file(
        "OTr_GetText.4dm",
        "// Project Method: OTr_GetText (inObject; inTag) --> Text",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_t", "$result_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$result_t : Text : Stored value, or empty text when missing/invalid",
             "$result_t : Text : Stored value, or empty text on missing/invalid"),
        ]
    )

    transform_file(
        "OTr_GetDate.4dm",
        "// Project Method: OTr_GetDate (inObject; inTag) --> Date",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_d", "$result_d"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$result_d : Date : Stored value, or empty date when missing/invalid",
             "$result_d : Date : Stored value, or empty date on missing/invalid"),
        ]
    )

    transform_file(
        "OTr_GetTime.4dm",
        "// Project Method: OTr_GetTime (inObject; inTag) --> Time",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_h", "$result_h"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$result_h : Time : Stored value, or 00:00:00 when missing/invalid",
             "$result_h : Time : Stored value, or 00:00:00 on missing/invalid"),
        ]
    )

    # OTr_GetBoolean: return is $value_i (Integer 1/0); body also has $value_b (local Boolean)
    # Only rename $value_i → $result_i; leave $value_b alone
    transform_file(
        "OTr_GetBoolean.4dm",
        "// Project Method: OTr_GetBoolean (inObject; inTag) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_i", "$result_i"),
            # NOTE: $value_b is a local Boolean var in the body — NOT renamed
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path",
             "$inTag_t    : Text    : Tag path (inTag)"),
            ("$result_i : Integer : 1 when True, otherwise 0",
             "$result_i : Integer : 1 when True, otherwise 0"),
        ]
    )

    # OTr_GetBLOB — already conformant
    transform_file("OTr_GetBLOB.4dm", None, renames=[])

    # OTr_GetNewBLOB — already conformant
    transform_file("OTr_GetNewBLOB.4dm", None, renames=[])

    # OTr_GetPicture — already conformant
    transform_file("OTr_GetPicture.4dm", None, renames=[])

    # OTr_GetPointer — already conformant
    transform_file("OTr_GetPointer.4dm", None, renames=[])

    # OTr_GetObject: $handle_i (input) → $inObject_i; $newHandle_i (return) kept
    transform_file(
        "OTr_GetObject.4dm",
        "// Project Method: OTr_GetObject (inObject; inTag) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            # $newHandle_i kept — meaningful name for the return
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : Source OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path to embedded object",
             "$inTag_t    : Text    : Tag path to embedded object (inTag)"),
            ("$newHandle_i : Integer : New handle containing copied object, or 0",
             "$newHandle_i : Integer : New handle containing a copy of the embedded object, or 0"),
        ]
    )

    # OTr_GetRecord — already conformant
    transform_file("OTr_GetRecord.4dm", None, renames=[])

    # OTr_GetRecordTable — already conformant
    transform_file("OTr_GetRecordTable.4dm", None, renames=[])

    # OTr_GetVariable — $inObject_i and $inTag_t already correct; fix $varPtr
    transform_file(
        "OTr_GetVariable.4dm",
        "// Project Method: OTr_GetVariable (inObject; inTag; outVarPointer)",
        renames=[
            ("$varPtr", "$outVarPointer_ptr"),
        ],
        new_param_descriptions=[
            ("$outVarPointer_ptr : Pointer : Pointer to variable to receive the value",
             "$outVarPointer_ptr : Pointer : Pointer to variable to receive the value (outVarPointer)"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 4: Array Put
    # -------------------------------------------------------------------------
    print("\n--- Group 4: Array Put ---")

    # OTr_PutArray
    transform_file(
        "OTr_PutArray.4dm",
        "// Project Method: OTr_PutArray (inObject; inTag; inArray)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$array_ptr", "$inArray_ptr"),
        ],
        new_param_descriptions=[
            ("$inObject_i  : Integer : OTr handle",
             "$inObject_i  : Integer : OTr inObject"),
            ("$inTag_t     : Text    : Tag path for the array",
             "$inTag_t     : Text    : Tag path for the array (inTag)"),
            ("$inArray_ptr : Pointer : Pointer to a 4D array",
             "$inArray_ptr : Pointer : Pointer to the source 4D array (inArray)"),
        ]
    )

    def put_array_element(filename, ot_name, value_param, value_type, value_desc):
        """Helper for PutArrayXxx methods."""
        transform_file(
            filename,
            f"// Project Method: {ot_name} (inObject; inTag; inIndex; inValue)",
            renames=[
                ("$handle_i", "$inObject_i"),
                ("$tag_t", "$inTag_t"),
                ("$index_i", "$inIndex_i"),
                (value_param, "$inValue" + value_param[len("$value"):]),
            ],
            new_param_descriptions=[
                ("$inObject_i : Integer : OTr handle",
                 "$inObject_i : Integer : OTr inObject"),
                ("$inTag_t    : Text    : Tag path to the array item",
                 "$inTag_t    : Text    : Tag path to the array item (inTag)"),
                ("$inIndex_i  : Integer : Element index (0 = default element)",
                 "$inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)"),
                (f"$inValue{value_param[len('$value'):]}  : {value_type} : Value to store",
                 f"$inValue{value_param[len('$value'):]}  : {value_type} : Value to store (inValue)"),
                # Handle alignment variations
                (f"$inValue{value_param[len('$value'):]} : {value_type} : Value to store",
                 f"$inValue{value_param[len('$value'):]} : {value_type} : Value to store (inValue)"),
            ]
        )

    put_array_element("OTr_PutArrayLong.4dm",    "OTr_PutArrayLong",    "$value_i",    "Integer", "inValue_i")
    put_array_element("OTr_PutArrayReal.4dm",    "OTr_PutArrayReal",    "$value_r",    "Real",    "inValue_r")
    put_array_element("OTr_PutArrayString.4dm",  "OTr_PutArrayString",  "$value_t",    "Text",    "inValue_t")
    put_array_element("OTr_PutArrayText.4dm",    "OTr_PutArrayText",    "$value_t",    "Text",    "inValue_t")
    put_array_element("OTr_PutArrayDate.4dm",    "OTr_PutArrayDate",    "$value_d",    "Date",    "inValue_d")
    put_array_element("OTr_PutArrayTime.4dm",    "OTr_PutArrayTime",    "$value_h",    "Time",    "inValue_h")
    put_array_element("OTr_PutArrayBoolean.4dm", "OTr_PutArrayBoolean", "$value_b",    "Boolean", "inValue_b")
    put_array_element("OTr_PutArrayBLOB.4dm",    "OTr_PutArrayBLOB",    "$value_blob", "Blob",    "inValue_blob")
    put_array_element("OTr_PutArrayPicture.4dm", "OTr_PutArrayPicture", "$value_pic",  "Picture", "inValue_pic")
    put_array_element("OTr_PutArrayPointer.4dm", "OTr_PutArrayPointer", "$value_ptr",  "Pointer", "inValue_ptr")

    # -------------------------------------------------------------------------
    # Group 5: Array Get
    # -------------------------------------------------------------------------
    print("\n--- Group 5: Array Get ---")

    # OTr_GetArray: $arrayPtr → $outArray_ptr
    transform_file(
        "OTr_GetArray.4dm",
        "// Project Method: OTr_GetArray (inObject; inTag; outArray)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$arrayPtr", "$outArray_ptr"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path to the array item",
             "$inTag_t    : Text    : Tag path to the array item (inTag)"),
            ("$outArray_ptr : Pointer : Pointer to target 4D array",
             "$outArray_ptr : Pointer : Pointer to the destination 4D array (outArray)"),
        ]
    )

    def get_array_element(filename, ot_name, return_param, return_type, return_desc):
        """Helper for GetArrayXxx methods."""
        new_return = "$result" + return_param[len("$value"):]
        transform_file(
            filename,
            f"// Project Method: {ot_name} (inObject; inTag; inIndex) --> {return_type}",
            renames=[
                ("$handle_i", "$inObject_i"),
                ("$tag_t", "$inTag_t"),
                ("$index_i", "$inIndex_i"),
                (return_param, new_return),
            ],
            new_param_descriptions=[
                ("$inObject_i : Integer : OTr handle",
                 "$inObject_i : Integer : OTr inObject"),
                ("$inTag_t    : Text    : Tag path to the array item",
                 "$inTag_t    : Text    : Tag path to the array item (inTag)"),
                ("$inIndex_i  : Integer : Element index (0 = default element)",
                 "$inIndex_i  : Integer : Element index, 1-based; 0 = default element (inIndex)"),
            ]
        )

    get_array_element("OTr_GetArrayLong.4dm",    "OTr_GetArrayLong",    "$value_i",    "Longint", "int")
    get_array_element("OTr_GetArrayReal.4dm",    "OTr_GetArrayReal",    "$value_r",    "Real",    "real")
    get_array_element("OTr_GetArrayString.4dm",  "OTr_GetArrayString",  "$value_t",    "Text",    "text")
    get_array_element("OTr_GetArrayText.4dm",    "OTr_GetArrayText",    "$value_t",    "Text",    "text")
    get_array_element("OTr_GetArrayDate.4dm",    "OTr_GetArrayDate",    "$value_d",    "Date",    "date")
    get_array_element("OTr_GetArrayTime.4dm",    "OTr_GetArrayTime",    "$value_h",    "Time",    "time")
    get_array_element("OTr_GetArrayBoolean.4dm", "OTr_GetArrayBoolean", "$value_i",    "Longint", "int")
    get_array_element("OTr_GetArrayBLOB.4dm",    "OTr_GetArrayBLOB",    "$value_blob", "Blob",    "blob")
    get_array_element("OTr_GetArrayPicture.4dm", "OTr_GetArrayPicture", "$value_pic",  "Picture", "pic")
    get_array_element("OTr_GetArrayPointer.4dm", "OTr_GetArrayPointer", "$value_ptr",  "Pointer", "ptr")

    # -------------------------------------------------------------------------
    # Group 6: Array Utilities
    # -------------------------------------------------------------------------
    print("\n--- Group 6: Array Utilities ---")

    # OTr_SizeOfArray: return $size_i kept (meaningful)
    transform_file(
        "OTr_SizeOfArray.4dm",
        "// Project Method: OTr_SizeOfArray (inObject; inTag) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path to the array item",
             "$inTag_t    : Text    : Tag path to the array item (inTag)"),
            ("$size_i : Integer : Number of elements, or 0",
             "$size_i : Integer : Number of elements (not counting element 0), or 0"),
        ]
    )

    # OTr_ResizeArray: $size_i → $inSize_i (input param)
    transform_file(
        "OTr_ResizeArray.4dm",
        "// Project Method: OTr_ResizeArray (inObject; inTag; inSize)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$size_i", "$inSize_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path to the array item",
             "$inTag_t    : Text    : Tag path to the array item (inTag)"),
            ("$inSize_i   : Integer : New number of elements",
             "$inSize_i   : Integer : New number of elements (inSize)"),
        ]
    )

    # OTr_InsertElement
    transform_file(
        "OTr_InsertElement.4dm",
        "// Project Method: OTr_InsertElement (inObject; inTag; inWhere {; inHowMany})",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$where_i", "$inWhere_i"),
            ("$howMany_i", "$inHowMany_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i  : Integer : OTr handle",
             "$inObject_i  : Integer : OTr inObject"),
            ("$inTag_t     : Text    : Tag path to the array item",
             "$inTag_t     : Text    : Tag path to the array item (inTag)"),
            ("$inWhere_i   : Integer : 1-based insert position",
             "$inWhere_i   : Integer : 1-based insert position (inWhere)"),
            ("$inHowMany_i : Integer : Number of elements to insert (default 1)",
             "$inHowMany_i : Integer : Number of elements to insert; default 1 (inHowMany)"),
        ]
    )

    # OTr_DeleteElement
    transform_file(
        "OTr_DeleteElement.4dm",
        "// Project Method: OTr_DeleteElement (inObject; inTag; inWhere {; inHowMany})",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$where_i", "$inWhere_i"),
            ("$howMany_i", "$inHowMany_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i  : Integer : OTr handle",
             "$inObject_i  : Integer : OTr inObject"),
            ("$inTag_t     : Text    : Tag path to the array item",
             "$inTag_t     : Text    : Tag path to the array item (inTag)"),
            ("$inWhere_i   : Integer : 1-based position of first element to delete",
             "$inWhere_i   : Integer : 1-based position of first element to delete (inWhere)"),
            ("$inHowMany_i : Integer : Number of elements to delete (default 1)",
             "$inHowMany_i : Integer : Number of elements to delete; default 1 (inHowMany)"),
        ]
    )

    # OTr_FindInArray
    transform_file(
        "OTr_FindInArray.4dm",
        "// Project Method: OTr_FindInArray (inObject; inTag; inValue {; inStart}) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$value_t", "$inValue_t"),
            ("$startFrom_i", "$inStart_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i  : Integer : OTr handle",
             "$inObject_i     : Integer : OTr inObject"),
            ("$inTag_t     : Text    : Tag path to the array item",
             "$inTag_t        : Text    : Tag path to the array item (inTag)"),
            ("$inValue_t   : Text    : Value to search for (as text)",
             "$inValue_t      : Text    : Value to search for as text (inValue)"),
            ("$inStart_i : Integer : Where to start from, optional defaults to 1",
             "$inStart_i      : Integer : Starting index, 1-based; default 1 (inStart)"),
        ]
    )

    # OTr_SortArrays — complex multi-param rename
    transform_file(
        "OTr_SortArrays.4dm",
        "// Project Method: OTr_SortArrays (inObject; inTag1; inDirection1 {; inTag2; inDirection2 {; inTag3; inDirection3 {; inTag4; inDirection4 {; inTag5; inDirection5 {; inTag6; inDirection6 {; inTag7; inDirection7}}}}}})",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag1_t",   "$inTag1_t"),
            ("$tag2_t",   "$inTag2_t"),
            ("$tag3_t",   "$inTag3_t"),
            ("$tag4_t",   "$inTag4_t"),
            ("$tag5_t",   "$inTag5_t"),
            ("$tag6_t",   "$inTag6_t"),
            ("$tag7_t",   "$inTag7_t"),
            ("$dir1_t",   "$inDirection1_t"),
            ("$dir2_t",   "$inDirection2_t"),
            ("$dir3_t",   "$inDirection3_t"),
            ("$dir4_t",   "$inDirection4_t"),
            ("$dir5_t",   "$inDirection5_t"),
            ("$dir6_t",   "$inDirection6_t"),
            ("$dir7_t",   "$inDirection7_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i          : Integer : Object handle",
             "$inObject_i               : Integer : OTr inObject"),
            ("$inTag1_t .. $inTag7_t : Text    : Array tag name",
             "$inTag1_t .. $inTag7_t    : Text    : Array tag name (inTag1..inTag7)"),
            ("$inDirection1_t .. $inDirection7_t : Text    : Direction code",
             "$inDirection1_t .. $inDirection7_t : Text    : Sort direction (inDirection1..inDirection7)"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 7: Object Info
    # -------------------------------------------------------------------------
    print("\n--- Group 7: Object Info ---")

    # OTr_IsObject: return $isObject_i kept (meaningful)
    transform_file(
        "OTr_IsObject.4dm",
        "// Project Method: OTr_IsObject (inObject) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : Handle to validate",
             "$inObject_i : Integer : OTr inObject"),
            ("$isObject_i : Integer : 1 when handle is valid, otherwise 0",
             "$isObject_i : Integer : 1 when handle is valid, otherwise 0"),
        ]
    )

    # OTr_ItemCount: return $count_i kept (meaningful)
    transform_file(
        "OTr_ItemCount.4dm",
        "// Project Method: OTr_ItemCount (inObject {; inTag}) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : A handle to an object",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag of an embedded object (optional)",
             "$inTag_t    : Text    : Tag of an embedded object (optional) (inTag)"),
            ("$count_i : Integer : Item count, or 0 on error",
             "$count_i : Integer : Item count (excluding internal __otr_ properties), or 0"),
        ]
    )

    # OTr_ObjectSize: return $size_i kept
    transform_file(
        "OTr_ObjectSize.4dm",
        "// Project Method: OTr_ObjectSize (inObject) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : A handle to an object",
             "$inObject_i : Integer : OTr inObject"),
            ("$size_i : Integer : Approximate size in bytes, or 0 on error",
             "$size_i : Integer : Approximate size in bytes, or 0 on error"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 8: Item Info
    # -------------------------------------------------------------------------
    print("\n--- Group 8: Item Info ---")

    # OTr_ItemExists: return $exists_i kept
    transform_file(
        "OTr_ItemExists.4dm",
        "// Project Method: OTr_ItemExists (inObject; inTag) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : A handle to an object",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag of the item to query",
             "$inTag_t    : Text    : Tag of the item to query (inTag)"),
            ("$exists_i : Integer : 1 if item exists, 0 if not",
             "$exists_i : Integer : 1 if item exists, 0 if not"),
        ]
    )

    # OTr_ItemType: return $otType_i kept
    transform_file(
        "OTr_ItemType.4dm",
        "// Project Method: OTr_ItemType (inObject; inTag) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : A handle to an object",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag of the item to query",
             "$inTag_t    : Text    : Tag of the item to query (inTag)"),
            ("$otType_i : Integer : OT type constant, or 0 on error",
             "$otType_i : Integer : OT type constant, or 0 on error"),
        ]
    )

    # OTr_IsEmbedded: return $isEmbedded_i kept
    transform_file(
        "OTr_IsEmbedded.4dm",
        "// Project Method: OTr_IsEmbedded (inObject; inTag) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i    : Integer : A handle to an object",
             "$inObject_i    : Integer : OTr inObject"),
            ("$inTag_t       : Text    : Tag of the item to query",
             "$inTag_t       : Text    : Tag of the item to query (inTag)"),
            ("$isEmbedded_i : Integer : 1 if item is an embedded object, 0 if not",
             "$isEmbedded_i : Integer : 1 if item is an embedded object, 0 if not"),
        ]
    )

    # OTr_GetItemProperties: $handle_i → $inObject_i, $index_i → $inIndex_i
    transform_file(
        "OTr_GetItemProperties.4dm",
        "// Project Method: OTr_GetItemProperties (inObject; inIndex; outName {; outType {; outItemSize {; outDataSize}}})",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$index_i", "$inIndex_i"),
            # $outName_ptr, $outType_ptr, $outItemSize_ptr, $outDataSize_ptr already correct
        ],
        new_param_descriptions=[
            ("$inObject_i      : Integer : A handle to an object",
             "$inObject_i      : Integer : OTr inObject"),
            ("$inIndex_i       : Integer : 1-based index of the item",
             "$inIndex_i       : Integer : 1-based index of the item (inIndex)"),
        ]
    )

    # OTr_GetNamedProperties: $handle_i → $inObject_i, $tag_t → $inTag_t
    transform_file(
        "OTr_GetNamedProperties.4dm",
        "// Project Method: OTr_GetNamedProperties (inObject; inTag; outType {; outItemSize {; outDataSize {; outIndex}}})",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i        : Integer : A handle to an object",
             "$inObject_i        : Integer : OTr inObject"),
            ("$inTag_t           : Text    : An item tag",
             "$inTag_t           : Text    : Tag of the item to query (inTag)"),
        ]
    )

    # OTr_GetAllProperties: $handle_i → $inObject_i
    transform_file(
        "OTr_GetAllProperties.4dm",
        "// Project Method: OTr_GetAllProperties (inObject; outNames {; outTypes {; outItemSizes {; outDataSizes}}})",
        renames=[
            ("$handle_i", "$inObject_i"),
        ],
        new_param_descriptions=[
            ("$inObject_i         : Integer : A handle to an object",
             "$inObject_i         : Integer : OTr inObject"),
        ]
    )

    # OTr_GetAllNamedProperties: $handle_i → $inObject_i, $tag_t → $inTag_t
    transform_file(
        "OTr_GetAllNamedProperties.4dm",
        "// Project Method: OTr_GetAllNamedProperties (inObject; inTag; outNames {; outTypes {; outItemSizes {; outDataSizes}}})",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i       : Integer : A handle to an object",
             "$inObject_i       : Integer : OTr inObject"),
            ("$inTag_t          : Text    : Tag of an embedded object (empty for root)",
             "$inTag_t          : Text    : Tag of an embedded object; empty for root (inTag)"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 9: Item Utilities
    # -------------------------------------------------------------------------
    print("\n--- Group 9: Item Utilities ---")

    # OTr_CopyItem
    transform_file(
        "OTr_CopyItem.4dm",
        "// Project Method: OTr_CopyItem (inSourceObject; inSourceTag; inDestObject; inDestTag)",
        renames=[
            ("$srcHandle_i",  "$inSourceObject_i"),
            ("$srcTag_t",     "$inSourceTag_t"),
            ("$destHandle_i", "$inDestObject_i"),
            ("$destTag_t",    "$inDestTag_t"),
        ],
        new_param_descriptions=[
            ("$inSourceObject_i  : Integer : A handle to the source object",
             "$inSourceObject_i  : Integer : OTr inSourceObject"),
            ("$inSourceTag_t     : Text    : Source item tag",
             "$inSourceTag_t     : Text    : Source item tag (inSourceTag)"),
            ("$inDestObject_i : Integer : A handle to the destination object",
             "$inDestObject_i    : Integer : OTr inDestObject"),
            ("$inDestTag_t    : Text    : Destination item tag",
             "$inDestTag_t       : Text    : Destination item tag (inDestTag)"),
        ]
    )

    # OTr_CompareItems: return $result_i already correct
    transform_file(
        "OTr_CompareItems.4dm",
        "// Project Method: OTr_CompareItems (inSourceObject; inSourceTag; inCompareObject; inCompareTag) --> Longint",
        renames=[
            ("$srcHandle_i", "$inSourceObject_i"),
            ("$srcTag_t",    "$inSourceTag_t"),
            ("$cmpHandle_i", "$inCompareObject_i"),
            ("$cmpTag_t",    "$inCompareTag_t"),
        ],
        new_param_descriptions=[
            ("$inSourceObject_i : Integer : A handle to the source object",
             "$inSourceObject_i  : Integer : OTr inSourceObject"),
            ("$inSourceTag_t    : Text    : Source item tag",
             "$inSourceTag_t     : Text    : Source item tag (inSourceTag)"),
            ("$inCompareObject_i : Integer : A handle to the comparison object",
             "$inCompareObject_i : Integer : OTr inCompareObject"),
            ("$inCompareTag_t    : Text    : Comparison item tag",
             "$inCompareTag_t    : Text    : Comparison item tag (inCompareTag)"),
        ]
    )

    # OTr_RenameItem: $newTag_t → $inNewTag_t
    transform_file(
        "OTr_RenameItem.4dm",
        "// Project Method: OTr_RenameItem (inObject; inTag; inNewTag)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
            ("$newTag_t", "$inNewTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : A handle to an object",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Full tag of the item to rename",
             "$inTag_t    : Text    : Full tag path of the item to rename (inTag)"),
            ("$inNewTag_t : Text    : New leaf name for the item",
             "$inNewTag_t : Text    : New leaf name (inNewTag)"),
        ]
    )

    # OTr_DeleteItem
    transform_file(
        "OTr_DeleteItem.4dm",
        "// Project Method: OTr_DeleteItem (inObject; inTag)",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : A handle to an object",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag of the item to delete",
             "$inTag_t    : Text    : Tag of the item to delete (inTag)"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 10: Import / Export
    # -------------------------------------------------------------------------
    print("\n--- Group 10: Import/Export ---")

    # OTr_ObjectToBLOB: $inObject_i and $ioBLOB_ptr already correct; fix $append_i
    transform_file(
        "OTr_ObjectToBLOB.4dm",
        "// Project Method: OTr_ObjectToBLOB (inObject; ioBLOB {; inAppend})",
        renames=[
            ("$append_i", "$inAppend_i"),
        ],
        new_param_descriptions=[
            ("$inAppend_i   : Integer : 0 = replace (default), non-zero = append\n"
             "  //                           (optional)",
             "$inAppend_i   : Integer : 0 = replace (default), non-zero = append (inAppend) (optional)"),
            # Also handle the inline format
            ("$inAppend_i   : Integer : 0 = replace (default), non-zero = append",
             "$inAppend_i   : Integer : 0 = replace (default), non-zero = append (inAppend)"),
        ]
    )

    # OTr_ObjectToNewBLOB — already conformant
    transform_file("OTr_ObjectToNewBLOB.4dm", None, renames=[])

    # OTr_BLOBToObject: $handle_i (return) kept as meaningful name; $inBLOB_blob correct
    transform_file(
        "OTr_BLOBToObject.4dm",
        "// Project Method: OTr_BLOBToObject (inBLOB) --> Longint",
        renames=[],  # $inBLOB_blob correct; $handle_i is the return — keep
        new_param_descriptions=[
            ("$handle_i : Integer : New handle, or 0 on error",
             "$handle_i : Integer : New OTr handle, or 0 on error"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 11: Object Utilities
    # -------------------------------------------------------------------------
    print("\n--- Group 11: Object Utilities ---")

    # OTr_GetVersion: return $version_t kept
    transform_file(
        "OTr_GetVersion.4dm",
        "// Project Method: OTr_GetVersion () --> Text",
        renames=[],
        new_param_descriptions=[
            ("$version_t : Text : OTr version text",
             "$version_t : Text : OTr version string"),
        ]
    )

    # OTr_Register: $serial_t → $inSerialNum_t
    transform_file(
        "OTr_Register.4dm",
        "// Project Method: OTr_Register (inSerialNum) --> Longint",
        renames=[
            ("$serial_t", "$inSerialNum_t"),
        ],
        new_param_descriptions=[
            ("$inSerialNum_t : Text : Legacy registration string (ignored)",
             "$inSerialNum_t : Text : Registration serial number string (inSerialNum)"),
        ]
    )

    # OTr_SetErrorHandler: $handler_t → $inNewHandler_t; return kept as $previousHandler_t
    transform_file(
        "OTr_SetErrorHandler.4dm",
        "// Project Method: OTr_SetErrorHandler (inNewHandler) --> Text",
        renames=[
            ("$handler_t", "$inNewHandler_t"),
        ],
        new_param_descriptions=[
            ("$inNewHandler_t : Text : Method name to execute for OTr errors",
             "$inNewHandler_t : Text : Method name to use as error handler (inNewHandler)"),
            ("$previousHandler_t : Text : Previously configured handler method name",
             "$previousHandler_t : Text : Previously registered handler method name"),
        ]
    )

    # OTr_GetOptions: return $options_i kept (meaningful)
    transform_file(
        "OTr_GetOptions.4dm",
        "// Project Method: OTr_GetOptions () --> Longint",
        renames=[],
        new_param_descriptions=[
            ("$options_i : Integer : Current options bit field",
             "$options_i : Integer : Current OTr options bit field"),
        ]
    )

    # OTr_SetOptions: $options_i → $inOptions_i
    transform_file(
        "OTr_SetOptions.4dm",
        "// Project Method: OTr_SetOptions (inOptions)",
        renames=[
            ("$options_i", "$inOptions_i"),
        ],
        new_param_descriptions=[
            ("$inOptions_i : Integer : New options bit field",
             "$inOptions_i : Integer : New OTr options bit field (inOptions)"),
        ]
    )

    # OTr_CompiledApplication: return $isCompiled_i kept
    transform_file(
        "OTr_CompiledApplication.4dm",
        "// Project Method: OTr_CompiledApplication () --> Longint",
        renames=[],
    )

    # OTr_GetHandleList: $handles_ptr → $outHandles_ptr
    transform_file(
        "OTr_GetHandleList.4dm",
        "// Project Method: OTr_GetHandleList (outHandles)",
        renames=[
            ("$handles_ptr", "$outHandles_ptr"),
        ],
        new_param_descriptions=[
            ("$outHandles_ptr : Pointer : Pointer to Longint array destination",
             "$outHandles_ptr : Pointer : Pointer to Longint array to receive active handles (outHandles)"),
        ]
    )

    # -------------------------------------------------------------------------
    # Group 12: OTr-Specific (no OT counterpart — no ORIGINAL DOCUMENTATION)
    # -------------------------------------------------------------------------
    print("\n--- Group 12: OTr-Specific ---")

    # OTr_SaveToText
    transform_file(
        "OTr_SaveToText.4dm",
        "// Project Method: OTr_SaveToText (inObject {; inPrettyPrint}) --> Text",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$prettyPrint_b", "$inPrettyPrint_b"),
        ],
        new_param_descriptions=[
            ("$inObject_i      : Integer : OTr handle",
             "$inObject_i      : Integer : OTr inObject"),
            ("$inPrettyPrint_b : Boolean : True for indented output; \\\n//                              default False (optional)",
             "$inPrettyPrint_b : Boolean : True for indented output; default False (optional)"),
            # Alternative format (no backslash)
            ("$inPrettyPrint_b : Boolean : True for indented output; default False (optional)",
             "$inPrettyPrint_b : Boolean : True for indented output; default False (optional)"),
        ]
    )

    # OTr_SaveToFile
    transform_file(
        "OTr_SaveToFile.4dm",
        "// Project Method: OTr_SaveToFile (inObject; inFilePath {; inPrettyPrint})",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$filePath_t", "$inFilePath_t"),
            ("$prettyPrint_b", "$inPrettyPrint_b"),
        ],
        new_param_descriptions=[
            ("$inObject_i      : Integer : OTr handle",
             "$inObject_i      : Integer : OTr inObject"),
            ("$inFilePath_t    : Text    : Full path of the target file",
             "$inFilePath_t    : Text    : Full path of the target file (inFilePath)"),
            ("$inPrettyPrint_b : Boolean : True for indented output; \\\n//                              default True (optional)",
             "$inPrettyPrint_b : Boolean : True for indented output; default True (optional)"),
            ("$inPrettyPrint_b : Boolean : True for indented output; default True (optional)",
             "$inPrettyPrint_b : Boolean : True for indented output; default True (optional)"),
        ]
    )

    # OTr_SaveToClipboard
    transform_file(
        "OTr_SaveToClipboard.4dm",
        "// Project Method: OTr_SaveToClipboard (inObject {; inPrettyPrint})",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$prettyPrint_b", "$inPrettyPrint_b"),
        ],
        new_param_descriptions=[
            ("$inObject_i      : Integer : OTr handle",
             "$inObject_i      : Integer : OTr inObject"),
            ("$inPrettyPrint_b : Boolean : True for indented output; \\\n//                              default True (optional)",
             "$inPrettyPrint_b : Boolean : True for indented output; default True (optional)"),
            ("$inPrettyPrint_b : Boolean : True for indented output; default True (optional)",
             "$inPrettyPrint_b : Boolean : True for indented output; default True (optional)"),
        ]
    )

    # OTr_ArrayType: return $arrayType_i kept (meaningful)
    transform_file(
        "OTr_ArrayType.4dm",
        "// Project Method: OTr_ArrayType (inObject; inTag) --> Longint",
        renames=[
            ("$handle_i", "$inObject_i"),
            ("$tag_t", "$inTag_t"),
        ],
        new_param_descriptions=[
            ("$inObject_i : Integer : OTr handle",
             "$inObject_i : Integer : OTr inObject"),
            ("$inTag_t    : Text    : Tag path to the array item",
             "$inTag_t    : Text    : Tag path to the array item (inTag)"),
            ("$arrayType_i : Integer : Stored arrayType, or -1",
             "$arrayType_i : Integer : Stored array type constant, or -1"),
        ]
    )

    print("\n" + "=" * 50)
    print("Done.")


if __name__ == "__main__":
    run_all()
