//%attributes = {"invisible":true}
// ----------------------------------------------------
// Project Method: OTr_z_CreateConstants ()

// Generates the OTr.xlf constants file in Resources.
// Run manually whenever constants need to be updated,
// then restart the database.

// Created by Wayne Stewart, 2026-03-31
// Wayne Stewart, 2026-05-19 - Restored from git history; renamed from _DEL_OTr_CreateConstants.
// Wayne Stewart, 2026-05-19 - Renamed to OTr_z_ prefix (internal utilities).
// ----------------------------------------------------


Constants_NewFile("OTr.xlf")

Constants_NewGroup("OTr Storage Mechanism")
Constants_AddLong("OTR IP Arrays"; 1)
Constants_AddLong("OTR Storage"; 2)

Constants_NewGroup("OTr Array Access Mode")
Constants_AddLong("OTR Get Element"; 1)
Constants_AddLong("OTR Put Element"; 2)

Constants_NewGroup("OT Logging Mode")
Constants_AddString("OT Log Off"; "off")
Constants_AddString("OT Log Debug"; "debug")
Constants_AddString("OT Log Info"; "info")
Constants_AddString("OT Log Notice"; "notice")
Constants_AddString("OT Log Warn"; "warn")
Constants_AddString("OT Log Error"; "error")

Constants_NewGroup("OT Miscellaneous")
Constants_AddString("Log Writer"; "$Log Writer")
Constants_AddString("OT Right Arrow"; "→")

Constants_NewGroup("OT Type Constants")
Constants_AddLong("OT Is Character"; 112)
Constants_AddLong("OT Character array"; 113)
Constants_AddLong("OT Is Object"; 114)
Constants_AddLong("OT Is Record"; 115)

Constants_SaveFile
