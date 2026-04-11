//%attributes = {"invisible":true,"shared":false}
// ----------------------------------------------------
// Project Method: OTr_uNativeDateInObject --> Boolean

// Probes whether the current process stores Date values natively
// in 4D Objects (True) or as ISO-formatted text strings (False).

// Access: Private

// Returns:
//   $result_b : Boolean : True  = current process stores Date natively
//                                 (SET DATABASE PARAMETER default, or
//                                  Date type constant explicitly set)
//                         False = current process stores Date as ISO text
//                                 (String type without time zone, or
//                                  String type with time zone)

// Background:
//   Since 4D v17, native Date storage in Objects is the default. However,
//   the "Dates inside objects" setting (SET DATABASE PARAMETER) is
//   per-process scope. Any process may override the default at runtime,
//   independently of any other process and independently of the project-level
//   compatibility setting (Structure Settings > Compatibility > Database >
//   "Use date type instead of ISO date format in objects").
//
//   Because the current setting cannot be read back via GET DATABASE PARAMETER
//   and the compatibility setting cannot be read programmatically at all, the
//   only reliable approach is to probe it directly: write Current date to a
//   temporary object and check the resulting property type via OB Get type.
//
//   This probe is intentionally per-call rather than cached. The cost is
//   negligible (one New object + one OB Get type), and caching in a process
//   variable or in Storage would produce incorrect results for any process
//   that changes its setting after OTr_zInit has run.
//
//   Reference: 4D KB 78256 — "Tech Tip: Store Date as ISO format String in Object"
//              https://kb.4d.com/assetid=78256

// Created by Wayne Stewart, 2026-04-11
// Based on work by himself, Rob Laveaux, and Cannon Smith.
// ----------------------------------------------------

#DECLARE->$result_b : Boolean

var $probe_o : Object
var $today_d : Date

$today_d:=Current date
$probe_o:=New object("d"; $today_d)
$result_b:=(OB Get type($probe_o; "d")=Is date)
