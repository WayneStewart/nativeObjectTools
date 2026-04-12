//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_u_NativeDateInObject --> Boolean

// Probes whether the current process stores Date values natively in 4D
// Objects (True) or as ISO-formatted text strings (False).

// Since 4D v17, native Date storage in Objects is the default. However,
// the "Dates inside objects" setting (SET DATABASE PARAMETER) is per-process
// scope — any process may override it at runtime. Because the current setting
// cannot be read back via GET DATABASE PARAMETER, the only reliable approach
// is to probe directly: write Current date to a temporary object and inspect
// the property type via OB Get type.

// This probe is intentionally per-call rather than cached. Caching in a
// process variable or Storage would produce incorrect results for any process
// that changes its setting after OTr_z_Init has run.

// Reference: 4D KB 78256 — "Tech Tip: Store Date as ISO format String in Object"

// Access: Private

// Returns:
//   $result_b : Boolean : True if the current process stores Date natively;
//                         False if Date is stored as ISO text

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE->$result_b : Boolean

var $probe_o : Object
var $today_d : Date

$today_d:=Current date:C33
$probe_o:=New object:C1471("d"; $today_d)
$result_b:=(OB Get type:C1230($probe_o; "d")=Is date:K8:7)
